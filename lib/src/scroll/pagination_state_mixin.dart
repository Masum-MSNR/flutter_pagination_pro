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
/// Concrete [State] classes must implement the abstract getters to bridge
/// between their specific widget properties and the mixin's shared logic.
mixin PaginationStateMixin<T, W extends StatefulWidget> on State<W> {
  // ── Abstract getters for widget properties ──────────────────────────────

  /// The external controller provided via `.withController()`, if any.
  PaginationController<T>? get widgetExternalController;

  /// Whether an external controller is being used.
  bool get isExternalController;

  /// The fetch function when using an internally managed controller.
  FetchPage<T>? get widgetFetchPage;

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
  OnPageLoaded<T>? get widgetOnPageLoaded;
  OnError? get widgetOnError;

  // ── Internal state ──────────────────────────────────────────────────────

  late PaginationController<T> _paginationController;
  late ScrollController _internalScrollController;
  bool _ownsScrollController = false;
  int _previousItemCount = 0;

  /// The active pagination controller.
  PaginationController<T> get paginationController => _paginationController;

  /// The active scroll controller.
  ScrollController get activeScrollController => _internalScrollController;

  /// Whether this State owns (and should dispose) the scroll controller.
  bool get ownsScrollController => _ownsScrollController;

  /// The effective config — from the controller when external, from widget otherwise.
  PaginationConfig get _effectiveConfig =>
      isExternalController ? _paginationController.config : widgetConfig;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  /// Initializes the pagination controller and scroll controller.
  ///
  /// Call from [State.initState].
  void initPagination() {
    _initController();
    _initScrollController();
  }

  /// Handles widget updates that affect pagination.
  ///
  /// Call from [State.didUpdateWidget].
  void didUpdatePagination({
    required PaginationController<T>? oldExternalController,
    required ScrollController? oldScrollController,
    required PaginationType oldPaginationType,
  }) {
    // Handle controller changes
    if (isExternalController &&
        widgetExternalController != oldExternalController) {
      oldExternalController?.removeListener(_onStateChanged);
      _paginationController = widgetExternalController!;
      _paginationController.addListener(_onStateChanged);
      _previousItemCount = _paginationController.items.length;
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
    _paginationController.removeListener(_onStateChanged);
    if (!isExternalController) {
      _paginationController.dispose();
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
      _paginationController = PaginationController<T>(
        fetchPage: widgetFetchPage!,
        config: widgetConfig,
      );
    }

    _paginationController.addListener(_onStateChanged);

    if (_effectiveConfig.autoLoadFirstPage &&
        _paginationController.status == PaginationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _paginationController.loadFirstPage();
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
    final state = _paginationController.state;

    // Fire onPageLoaded with only the NEW items from the latest page
    if (state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.completed) {
      final newItems = state.items.length > _previousItemCount
          ? state.items.sublist(_previousItemCount)
          : <T>[];
      widgetOnPageLoaded?.call(state.currentPage, newItems);
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
    if (!_paginationController.status.canLoadMore ||
        !_paginationController.hasMorePages) {
      return;
    }

    final position = _internalScrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = _effectiveConfig.scrollThreshold;

    if (currentScroll >= maxScroll - threshold) {
      _paginationController.loadNextPage();
    }
  }

  // ── Shared build helpers ────────────────────────────────────────────────

  /// Builds the appropriate widget for the current pagination state.
  ///
  /// Shows loading, error, or empty widgets for non-content states.
  /// When items are available, calls [contentBuilder] and optionally
  /// wraps the result in a [RefreshIndicator].
  Widget buildPaginationState({
    required Widget Function(PaginationState<T> state) contentBuilder,
  }) {
    final state = _paginationController.state;

    if (state.status.isInitialLoading) {
      return widgetFirstPageLoadingBuilder?.call(context) ??
          const DefaultFirstPageLoading();
    }

    if (state.status.isFirstPageError) {
      return widgetFirstPageErrorBuilder?.call(
            context,
            state.error!,
            _paginationController.retry,
          ) ??
          DefaultFirstPageError(
            error: state.error!,
            onRetry: _paginationController.retry,
          );
    }

    if (state.status.isEmpty) {
      return widgetEmptyBuilder?.call(context) ?? const DefaultEmpty();
    }

    final content = contentBuilder(state);

    if (widgetEnablePullToRefresh) {
      return RefreshIndicator(
        onRefresh: _paginationController.refresh,
        child: content,
      );
    }

    return content;
  }

  /// Whether a footer widget should be displayed below items.
  bool shouldShowFooter(PaginationState<T> state) {
    return state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.loadMoreError ||
        state.status == PaginationStatus.completed ||
        (widgetPaginationType == PaginationType.loadMore &&
            state.status == PaginationStatus.loaded &&
            state.hasMorePages);
  }

  /// Builds the footer widget (loading indicator, error, end-of-list, or
  /// load-more button) based on the current [state].
  Widget buildFooter(PaginationState<T> state) {
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
            _paginationController.retry,
          ) ??
          DefaultLoadMoreError(
            error: state.error!,
            onRetry: _paginationController.retry,
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
            _paginationController.loadNextPage,
            false,
          ) ??
          DefaultLoadMoreButton(
            onPressed: _paginationController.loadNextPage,
            isLoading: false,
          );
    }

    return const SizedBox.shrink();
  }
}
