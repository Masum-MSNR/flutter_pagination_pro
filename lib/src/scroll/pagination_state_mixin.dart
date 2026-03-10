/// Shared pagination state management mixin
library;

import 'package:flutter/material.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/pagination_status.dart';
import '../core/typedefs.dart';
import '../widgets/default_loading.dart';
import '../widgets/default_error.dart';
import '../widgets/default_empty.dart';
import '../widgets/default_end_of_list.dart';
import '../widgets/default_load_more.dart';

/// A no-op callback used as a placeholder when loading state prevents interaction.
void _doNothing() {}

/// Mixin providing shared pagination state management for scroll-based
/// pagination widgets.
///
/// Handles controller lifecycle, scroll detection, state change callbacks,
/// and builds shared UI states (loading, error, empty, footer).
///
/// Supports three modes:
/// - **Internal controller**: Widget creates and manages a controller
/// - **External controller**: User provides a controller via `.withController()`
/// - **Controlled mode**: User provides items + status directly via `.controlled()`
///
/// Concrete [State] classes must implement the abstract getters to bridge
/// between their specific widget properties and the mixin's shared logic.
mixin PaginationStateMixin<K, T, W extends StatefulWidget> on State<W> {
  // ── Abstract getters for widget properties ──────────────────────────────

  /// Whether this widget is in controlled mode (no internal controller).
  bool get isControlledMode;

  /// The external controller provided via `.withController()`, if any.
  PaginationController<K, T>? get widgetExternalController;

  /// Whether an external controller is being used.
  bool get isExternalController;

  /// The fetch function when using an internally managed controller.
  FetchPage<K, T>? get widgetFetchPage;

  /// The initial page key when using an internally managed controller.
  K? get widgetInitialPageKey;

  /// The next page key builder when using an internally managed controller.
  NextPageKeyBuilder<K, T>? get widgetNextPageKeyBuilder;

  /// The pagination config from the widget.
  PaginationConfig get widgetConfig;

  /// The pagination type (infinite scroll or load more).
  PaginationType get widgetPaginationType;

  /// The external scroll controller, if any.
  ScrollController? get widgetScrollController;

  /// Whether pull-to-refresh is enabled.
  bool get widgetEnablePullToRefresh;

  // Builder getters
  LoadingBuilder? get widgetFirstPageLoadingBuilder;
  LoadingBuilder? get widgetLoadMoreLoadingBuilder;
  ErrorBuilder? get widgetFirstPageErrorBuilder;
  ErrorBuilder? get widgetLoadMoreErrorBuilder;
  EmptyBuilder? get widgetEmptyBuilder;
  EndOfListBuilder? get widgetEndOfListBuilder;
  LoadMoreBuilder? get widgetLoadMoreButtonBuilder;

  // Callback getters
  OnPageLoaded<K, T>? get widgetOnPageLoaded;
  OnError? get widgetOnError;

  // ── Controlled mode getters ─────────────────────────────────────────────

  /// Items provided in controlled mode.
  List<T> get controlledItems => const [];

  /// Status in controlled mode.
  PaginationStatus get controlledStatus => PaginationStatus.initial;

  /// Whether there are more pages in controlled mode.
  bool get controlledHasMorePages => true;

  /// Error object in controlled mode.
  Object? get controlledError;

  /// Callback when more items should be loaded (controlled mode).
  VoidCallback? get controlledOnLoadMore;

  /// Callback when the list should be refreshed (controlled mode).
  Future<void> Function()? get controlledOnRefresh;

  /// Callback when a failed operation should be retried (controlled mode).
  VoidCallback? get controlledOnRetry;

  // ── Internal state ──────────────────────────────────────────────────────

  PaginationController<K, T>? _paginationController;
  late ScrollController _internalScrollController;
  bool _ownsScrollController = false;
  int _previousItemCount = 0;

  /// The active pagination controller (null in controlled mode).
  PaginationController<K, T>? get paginationController => _paginationController;

  /// The active scroll controller.
  ScrollController get activeScrollController => _internalScrollController;

  /// Whether this State owns (and should dispose) the scroll controller.
  bool get ownsScrollController => _ownsScrollController;

  /// The effective config — from the controller when external, from widget otherwise.
  PaginationConfig get _effectiveConfig {
    if (isControlledMode) return widgetConfig;
    return isExternalController ? _paginationController!.config : widgetConfig;
  }

  // ── State accessors (work in both controller and controlled modes) ──────

  /// The current pagination state, from controller or controlled props.
  PaginationState<K, T> get _currentState {
    if (isControlledMode) {
      return PaginationState<K, T>(
        items: controlledItems,
        status: controlledStatus,
        hasMorePages: controlledHasMorePages,
        error: controlledError,
      );
    }
    return _paginationController!.state;
  }

  /// Retry action for the current mode.
  VoidCallback get _retryAction {
    if (isControlledMode) return controlledOnRetry ?? _doNothing;
    return _paginationController!.retry;
  }

  /// Load-more action for the current mode.
  VoidCallback get _loadMoreAction {
    if (isControlledMode) return controlledOnLoadMore ?? _doNothing;
    return _paginationController!.loadNextPage;
  }

  /// Refresh action for the current mode.
  Future<void> Function() get _refreshAction {
    if (isControlledMode) return controlledOnRefresh ?? () async {};
    return _paginationController!.refresh;
  }

  // ── Lifecycle ───────────────────────────────────────────────────────────

  /// Initializes the pagination controller and scroll controller.
  ///
  /// Call from [State.initState].
  void initPagination() {
    if (!isControlledMode) {
      _initController();
    }
    _initScrollController();
  }

  /// Handles widget updates that affect pagination.
  ///
  /// Call from [State.didUpdateWidget].
  void didUpdatePagination({
    required PaginationController<K, T>? oldExternalController,
    required ScrollController? oldScrollController,
    required PaginationType oldPaginationType,
  }) {
    if (!isControlledMode) {
      // Handle controller changes
      if (isExternalController &&
          widgetExternalController != oldExternalController) {
        oldExternalController?.removeListener(_onStateChanged);
        _paginationController = widgetExternalController!;
        _paginationController!.addListener(_onStateChanged);
        _previousItemCount = _paginationController!.items.length;
      }
    }

    // Handle scroll controller changes
    if (widgetScrollController != oldScrollController) {
      if (_ownsScrollController) {
        _internalScrollController.removeListener(_onScroll);
        _internalScrollController.dispose();
        _ownsScrollController = false;
      } else {
        _internalScrollController.removeListener(_onScroll);
      }
      _initScrollController();
    }

    // Handle pagination type changes
    if (widgetPaginationType != oldPaginationType) {
      if (oldPaginationType == PaginationType.infiniteScroll) {
        _internalScrollController.removeListener(_onScroll);
      }
      if (widgetPaginationType == PaginationType.infiniteScroll) {
        _internalScrollController.addListener(_onScroll);
      }
    }
  }

  /// Cleans up controllers and listeners.
  ///
  /// Call from [State.dispose] **before** `super.dispose()`.
  void disposePagination() {
    if (!isControlledMode && _paginationController != null) {
      _paginationController!.removeListener(_onStateChanged);
      if (!isExternalController) {
        _paginationController!.dispose();
      }
    }

    _internalScrollController.removeListener(_onScroll);
    if (_ownsScrollController) {
      _internalScrollController.dispose();
    }
  }

  // ── Private helpers ─────────────────────────────────────────────────────

  void _initController() {
    if (isExternalController) {
      _paginationController = widgetExternalController!;
    } else {
      _paginationController = PaginationController<K, T>(
        fetchPage: widgetFetchPage!,
        initialPageKey: widgetInitialPageKey,
        nextPageKeyBuilder: widgetNextPageKeyBuilder,
        config: widgetConfig,
      );
    }

    _paginationController!.addListener(_onStateChanged);

    if (_effectiveConfig.autoLoadFirstPage &&
        _paginationController!.status == PaginationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _paginationController!.loadFirstPage();
      });
    }
  }

  void _initScrollController() {
    if (widgetScrollController != null) {
      _internalScrollController = widgetScrollController!;
    } else {
      _internalScrollController = ScrollController();
      _ownsScrollController = true;
    }

    if (widgetPaginationType == PaginationType.infiniteScroll) {
      _internalScrollController.addListener(_onScroll);
    }
  }

  void _onStateChanged() {
    final state = _paginationController!.state;

    // Fire onPageLoaded with only the NEW items from the latest page
    if (state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.completed) {
      final newItems = state.items.length > _previousItemCount
          ? state.items.sublist(_previousItemCount)
          : <T>[];
      if (state.pageKey != null) {
        widgetOnPageLoaded?.call(state.pageKey as K, newItems);
      }
    }

    // Reset tracking when starting fresh fetches
    if (state.status == PaginationStatus.refreshing ||
        state.status == PaginationStatus.loadingFirstPage) {
      _previousItemCount = 0;
    } else {
      _previousItemCount = state.items.length;
    }

    if (state.error != null && state.status.isError) {
      widgetOnError?.call(state.error!);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void _onScroll() {
    final bool canLoad;
    final bool hasMore;

    if (isControlledMode) {
      canLoad = controlledStatus.canLoadMore;
      hasMore = controlledHasMorePages;
    } else {
      canLoad = _paginationController!.status.canLoadMore;
      hasMore = _paginationController!.hasMorePages;
    }

    if (!canLoad || !hasMore) return;

    final position = _internalScrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = _effectiveConfig.scrollThreshold;

    if (currentScroll >= maxScroll - threshold) {
      _loadMoreAction();
    }
  }

  // ── Shared build helpers ────────────────────────────────────────────────

  /// Builds the appropriate widget for the current pagination state.
  ///
  /// Shows loading, error, or empty widgets for non-content states.
  /// When items are available, calls [contentBuilder] and optionally
  /// wraps the result in a [RefreshIndicator].
  Widget buildPaginationState({
    required Widget Function(PaginationState<K, T> state) contentBuilder,
  }) {
    final state = _currentState;

    if (state.status.isInitialLoading) {
      return widgetFirstPageLoadingBuilder?.call(context) ??
          const DefaultFirstPageLoading();
    }

    if (state.status.isFirstPageError) {
      return widgetFirstPageErrorBuilder?.call(
            context,
            state.error!,
            _retryAction,
          ) ??
          DefaultFirstPageError(
            error: state.error!,
            onRetry: _retryAction,
          );
    }

    if (state.status.isEmpty) {
      return widgetEmptyBuilder?.call(context) ?? const DefaultEmpty();
    }

    final content = contentBuilder(state);

    if (widgetEnablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _refreshAction,
        child: content,
      );
    }

    return content;
  }

  /// Whether a footer widget should be displayed below items.
  bool shouldShowFooter(PaginationState<K, T> state) {
    return state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.loadMoreError ||
        state.status == PaginationStatus.completed ||
        (widgetPaginationType == PaginationType.loadMore &&
            state.status == PaginationStatus.loaded &&
            state.hasMorePages);
  }

  /// Builds the footer widget (loading indicator, error, end-of-list, or
  /// load-more button) based on the current [state].
  Widget buildFooter(PaginationState<K, T> state) {
    if (state.status == PaginationStatus.loadingMore) {
      if (widgetPaginationType == PaginationType.loadMore) {
        return widgetLoadMoreButtonBuilder?.call(context, _doNothing, true) ??
            const DefaultLoadMoreButton(onPressed: _doNothing, isLoading: true);
      }
      return widgetLoadMoreLoadingBuilder?.call(context) ??
          const DefaultLoadMoreLoading();
    }

    if (state.status == PaginationStatus.loadMoreError) {
      return widgetLoadMoreErrorBuilder?.call(
            context,
            state.error!,
            _retryAction,
          ) ??
          DefaultLoadMoreError(
            error: state.error!,
            onRetry: _retryAction,
          );
    }

    if (state.status == PaginationStatus.completed) {
      return widgetEndOfListBuilder?.call(context) ?? const DefaultEndOfList();
    }

    if (widgetPaginationType == PaginationType.loadMore &&
        state.status == PaginationStatus.loaded &&
        state.hasMorePages) {
      return widgetLoadMoreButtonBuilder?.call(
            context,
            _loadMoreAction,
            false,
          ) ??
          DefaultLoadMoreButton(
            onPressed: _loadMoreAction,
            isLoading: false,
          );
    }

    return const SizedBox.shrink();
  }
}
