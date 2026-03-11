/// SliverPaginatedGrid - A paginated SliverGrid for use in CustomScrollView
library;

import 'package:flutter/material.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/pagination_status.dart';
import '../core/skeleton_config.dart';
import '../core/typedefs.dart';
import '../widgets/default_loading.dart';
import '../widgets/default_error.dart';
import '../widgets/default_empty.dart';

import 'pagination_state_mixin.dart';

/// A paginated [SliverGrid] for use inside a [CustomScrollView].
///
/// `K` is the page key type. `T` is the item type.
///
/// Requires an external [PaginationController] (or controlled mode) since
/// the parent [CustomScrollView] owns the scroll controller.
///
/// ## With Controller
///
/// ```dart
/// final controller = PaginationController<int, Photo>(
///   fetchPage: (page) => api.getPhotos(page: page),
///   initialPageKey: 1,
/// );
///
/// CustomScrollView(
///   controller: scrollController,
///   slivers: [
///     SliverAppBar(title: Text('Gallery')),
///     SliverPaginatedGrid<int, Photo>(
///       controller: controller,
///       scrollController: scrollController,
///       gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
///         crossAxisCount: 3,
///       ),
///       itemBuilder: (context, photo, index) => Image.network(photo.url),
///     ),
///   ],
/// )
/// ```
class SliverPaginatedGrid<K, T> extends StatefulWidget {
  /// Creates a [SliverPaginatedGrid] with an external controller.
  const SliverPaginatedGrid({
    super.key,
    required this.controller,
    required this.itemBuilder,
    required this.gridDelegate,
    this.scrollController,
    this.paginationType = PaginationType.infiniteScroll,
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
    this.loadMoreButtonBuilder,
    this.onPageLoaded,
    this.onError,
    this.findChildIndexCallback,
    this.placeholderItem,
    this.placeholderCount = 6,
    this.skeletonConfig,
  })  : assert(
          paginationType != PaginationType.infiniteScroll ||
              scrollController != null,
          'scrollController is required for infiniteScroll mode in slivers. '
          'Pass the parent CustomScrollView\'s ScrollController.',
        ),
        _isControlled = false,
        _controlledItems = null,
        _controlledStatus = null,
        _controlledHasMorePages = true,
        _controlledError = null,
        _controlledOnLoadMore = null,
        _controlledOnRefresh = null,
        _controlledOnRetry = null,
        config = PaginationConfig.defaults;

  /// Creates a [SliverPaginatedGrid] in controlled mode.
  ///
  /// You provide items and status directly — no controller is used.
  const SliverPaginatedGrid.controlled({
    super.key,
    required List<T> items,
    required PaginationStatus status,
    required this.itemBuilder,
    required this.gridDelegate,
    bool hasMorePages = true,
    Object? error,
    VoidCallback? onLoadMore,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
    this.scrollController,
    this.paginationType = PaginationType.infiniteScroll,
    this.config = PaginationConfig.defaults,
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
    this.loadMoreButtonBuilder,
    this.findChildIndexCallback,
    this.placeholderItem,
    this.placeholderCount = 6,
    this.skeletonConfig,
  })  : assert(
          paginationType != PaginationType.infiniteScroll ||
              scrollController != null,
          'scrollController is required for infiniteScroll mode in slivers. '
          'Pass the parent CustomScrollView\'s ScrollController.',
        ),
        controller = null,
        _isControlled = true,
        onPageLoaded = null,
        onError = null,
        _controlledItems = items,
        _controlledStatus = status,
        _controlledHasMorePages = hasMorePages,
        _controlledError = error,
        _controlledOnLoadMore = onLoadMore,
        _controlledOnRefresh = onRefresh,
        _controlledOnRetry = onRetry;

  /// The pagination controller. You are responsible for creating and disposing it.
  final PaginationController<K, T>? controller;

  final bool _isControlled;

  // Controlled mode fields
  final List<T>? _controlledItems;
  final PaginationStatus? _controlledStatus;
  final bool _controlledHasMorePages;
  final Object? _controlledError;
  final VoidCallback? _controlledOnLoadMore;
  final Future<void> Function()? _controlledOnRefresh;
  final VoidCallback? _controlledOnRetry;

  /// Builder for each item in the grid.
  final ItemBuilder<T> itemBuilder;

  /// Controls the layout of tiles in the grid.
  final SliverGridDelegate gridDelegate;

  /// The scroll controller from the parent [CustomScrollView].
  final ScrollController? scrollController;

  /// The type of pagination (infiniteScroll or loadMore).
  final PaginationType paginationType;

  /// Configuration for pagination behavior (used for scrollThreshold).
  final PaginationConfig config;

  // Custom builders for different states

  /// Widget shown while the first page is loading.
  final LoadingBuilder? firstPageLoadingBuilder;

  /// Widget shown at the bottom while loading subsequent pages.
  final LoadingBuilder? loadMoreLoadingBuilder;

  /// Widget shown when the first page load fails.
  final ErrorBuilder? firstPageErrorBuilder;

  /// Widget shown when a load-more request fails.
  final ErrorBuilder? loadMoreErrorBuilder;

  /// Widget shown when the list is empty (no items).
  final EmptyBuilder? emptyBuilder;

  /// Widget shown at the bottom when all pages have been loaded.
  final EndOfListBuilder? endOfListBuilder;

  /// Widget shown as the "Load More" button in [PaginationType.loadMore] mode.
  final LoadMoreBuilder? loadMoreButtonBuilder;

  // Callbacks

  /// Called when a page is successfully loaded with only the new items.
  final OnPageLoaded<K, T>? onPageLoaded;

  /// Called when an error occurs.
  final OnError? onError;

  /// Optional callback to find a child's index by its key.
  final ChildIndexGetter? findChildIndexCallback;

  /// A placeholder instance of `T` used to auto-generate skeleton loading.
  ///
  /// When provided (and [firstPageLoadingBuilder] is not set), the widget
  /// automatically renders your [itemBuilder] with this placeholder item,
  /// applying a grey [ColorFiltered] overlay to produce a skeleton effect.
  final T? placeholderItem;

  /// Number of skeleton placeholder items to display (default 6).
  ///
  /// Only used when [placeholderItem] is provided.
  final int placeholderCount;

  /// Skeleton configuration for automatic skeleton loading.
  ///
  /// Controls overlay colour, border radius, shimmer speed, etc.
  /// Only used when [placeholderItem] is provided.
  final SkeletonConfig? skeletonConfig;

  @override
  State<SliverPaginatedGrid<K, T>> createState() =>
      _SliverPaginatedGridState<K, T>();
}

class _SliverPaginatedGridState<K, T> extends State<SliverPaginatedGrid<K, T>>
    with PaginationStateMixin<K, T, SliverPaginatedGrid<K, T>> {
  // ── Mixin bridge ────────────────────────────────────────────────────────

  @override
  bool get isControlledMode => widget._isControlled;
  @override
  PaginationController<K, T>? get widgetExternalController => widget.controller;
  @override
  bool get isExternalController => !widget._isControlled;
  @override
  FetchPage<K, T>? get widgetFetchPage => null;
  @override
  K? get widgetInitialPageKey => null;
  @override
  NextPageKeyBuilder<K, T>? get widgetNextPageKeyBuilder => null;
  @override
  PaginationConfig get widgetConfig =>
      isControlledMode ? widget.config : (widget.controller?.config ?? widget.config);
  @override
  PaginationType get widgetPaginationType => widget.paginationType;
  @override
  ScrollController? get widgetScrollController => widget.scrollController;
  @override
  bool get widgetEnablePullToRefresh => false;
  @override
  LoadingBuilder? get widgetFirstPageLoadingBuilder =>
      widget.firstPageLoadingBuilder;
  @override
  LoadingBuilder? get widgetLoadMoreLoadingBuilder =>
      widget.loadMoreLoadingBuilder;
  @override
  ErrorBuilder? get widgetFirstPageErrorBuilder =>
      widget.firstPageErrorBuilder;
  @override
  ErrorBuilder? get widgetLoadMoreErrorBuilder => widget.loadMoreErrorBuilder;
  @override
  EmptyBuilder? get widgetEmptyBuilder => widget.emptyBuilder;
  @override
  EndOfListBuilder? get widgetEndOfListBuilder => widget.endOfListBuilder;
  @override
  LoadMoreBuilder? get widgetLoadMoreButtonBuilder =>
      widget.loadMoreButtonBuilder;
  @override
  OnPageLoaded<K, T>? get widgetOnPageLoaded => widget.onPageLoaded;
  @override
  OnError? get widgetOnError => widget.onError;
  @override
  ItemBuilder<T> get widgetItemBuilder => widget.itemBuilder;
  @override
  SeparatorBuilder? get widgetSeparatorBuilder => null;
  @override
  T? get widgetPlaceholderItem => widget.placeholderItem;
  @override
  int get widgetPlaceholderCount => widget.placeholderCount;
  @override
  SkeletonConfig? get widgetSkeletonConfig => widget.skeletonConfig;

  // Controlled mode bridge
  @override
  List<T> get controlledItems => widget._controlledItems ?? const [];
  @override
  PaginationStatus get controlledStatus =>
      widget._controlledStatus ?? PaginationStatus.initial;
  @override
  bool get controlledHasMorePages => widget._controlledHasMorePages;
  @override
  Object? get controlledError => widget._controlledError;
  @override
  VoidCallback? get controlledOnLoadMore => widget._controlledOnLoadMore;
  @override
  Future<void> Function()? get controlledOnRefresh =>
      widget._controlledOnRefresh;
  @override
  VoidCallback? get controlledOnRetry => widget._controlledOnRetry;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initPagination();
  }

  @override
  void didUpdateWidget(covariant SliverPaginatedGrid<K, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    didUpdatePagination(
      oldExternalController: oldWidget.controller,
      oldScrollController: oldWidget.scrollController,
      oldPaginationType: oldWidget.paginationType,
    );
  }

  @override
  void dispose() {
    disposePagination();
    super.dispose();
  }

  // ── Build ───────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = isControlledMode
        ? PaginationState<K, T>(
            items: controlledItems,
            status: controlledStatus,
            hasMorePages: controlledHasMorePages,
            error: controlledError,
          )
        : paginationController!.state;

    // Full-area states returned as SliverFillRemaining
    if (state.status.isInitialLoading) {
      if (widgetFirstPageLoadingBuilder != null) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: widgetFirstPageLoadingBuilder!.call(context),
        );
      }
      if (widgetPlaceholderItem != null) {
        return _buildSkeletonSliver();
      }
      return SliverFillRemaining(
        hasScrollBody: false,
        child: const DefaultFirstPageLoading(),
      );
    }

    if (state.status.isFirstPageError) {
      final retryAction = isControlledMode
          ? (controlledOnRetry ?? () {})
          : paginationController!.retry;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widgetFirstPageErrorBuilder?.call(
              context,
              state.error!,
              retryAction,
            ) ??
            DefaultFirstPageError(
              error: state.error!,
              onRetry: retryAction,
            ),
      );
    }

    if (state.status.isEmpty) {
      final retryAction = isControlledMode
          ? (controlledOnRetry ?? () {})
          : paginationController!.retry;
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widgetEmptyBuilder?.call(context) ??
            DefaultEmpty(onRefresh: retryAction),
      );
    }

    // Grid items + optional footer as separate sliver
    return _buildSliverContent(state);
  }

  Widget _buildSliverContent(PaginationState<K, T> state) {
    final hasFooter = shouldShowFooter(state);
    final skeletonCount = skeletonLoadMoreCount(state);
    final effectiveCount = state.items.length + skeletonCount;

    final sliverGrid = SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index >= state.items.length) {
            return buildSkeletonItem(context, index);
          }
          return widget.itemBuilder(context, state.items[index], index);
        },
        childCount: effectiveCount,
        findChildIndexCallback: widget.findChildIndexCallback,
      ),
    );

    if (!hasFooter) {
      return sliverGrid;
    }

    return SliverMainAxisGroup(
      slivers: [
        sliverGrid,
        SliverToBoxAdapter(child: buildFooter(state)),
      ],
    );
  }

  Widget _buildSkeletonSliver() {
    final placeholder = widgetPlaceholderItem as T;

    return SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) => DefaultFirstPageLoading.skeletonize(
          context,
          widgetItemBuilder(context, placeholder, index),
          config: widgetSkeletonConfig,
        ),
        childCount: widgetPlaceholderCount,
      ),
    );
  }
}
