/// PaginationGridView - A GridView with built-in pagination support
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/pagination_status.dart';
import '../core/typedefs.dart';
import 'pagination_state_mixin.dart';

/// A [GridView] with built-in pagination support.
///
/// `K` is the page key type. `T` is the item type.
///
/// ## Simple Usage
///
/// ```dart
/// PaginationGridView<int, Product>(
///   fetchPage: (page) => api.getProducts(page: page),
///   initialPageKey: 1,
///   itemBuilder: (context, product, index) => ProductCard(product: product),
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2,
///   ),
/// )
/// ```
class PaginationGridView<K, T> extends StatefulWidget {
  /// Creates a [PaginationGridView] with automatic controller management.
  const PaginationGridView({
    super.key,
    required this.fetchPage,
    K? initialPageKey,
    required this.itemBuilder,
    required this.gridDelegate,
    this.nextPageKeyBuilder,
    this.paginationType = PaginationType.infiniteScroll,
    this.config = PaginationConfig.defaults,
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
    this.loadMoreButtonBuilder,
    this.onPageLoaded,
    this.onError,
    this.enablePullToRefresh = false,
    this.header,
    this.footer,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.findChildIndexCallback,
  })  : _controller = null,
        _externalController = false,
        _isControlled = false,
        _initialPageKey = initialPageKey,
        _controlledItems = null,
        _controlledStatus = null,
        _controlledHasMorePages = true,
        _controlledError = null,
        _controlledOnLoadMore = null,
        _controlledOnRefresh = null,
        _controlledOnRetry = null;

  /// Creates a [PaginationGridView] with an external controller.
  const PaginationGridView.withController({
    super.key,
    required PaginationController<K, T> controller,
    required this.itemBuilder,
    required this.gridDelegate,
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
    this.enablePullToRefresh = false,
    this.header,
    this.footer,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.findChildIndexCallback,
  })  : _controller = controller,
        _externalController = true,
        _isControlled = false,
        _initialPageKey = null,
        fetchPage = null,
        nextPageKeyBuilder = null,
        config = PaginationConfig.defaults,
        _controlledItems = null,
        _controlledStatus = null,
        _controlledHasMorePages = true,
        _controlledError = null,
        _controlledOnLoadMore = null,
        _controlledOnRefresh = null,
        _controlledOnRetry = null;

  /// Creates a [PaginationGridView] in controlled mode.
  ///
  /// You provide items and status directly — no [PaginationController] is used.
  const PaginationGridView.controlled({
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
    this.paginationType = PaginationType.infiniteScroll,
    this.config = PaginationConfig.defaults,
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
    this.loadMoreButtonBuilder,
    this.enablePullToRefresh = false,
    this.header,
    this.footer,
    this.scrollController,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.primary,
    this.physics,
    this.shrinkWrap = false,
    this.padding,
    this.cacheExtent,
    this.dragStartBehavior = DragStartBehavior.start,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.restorationId,
    this.clipBehavior = Clip.hardEdge,
    this.findChildIndexCallback,
  })  : _controller = null,
        _externalController = false,
        _isControlled = true,
        _initialPageKey = null,
        fetchPage = null,
        nextPageKeyBuilder = null,
        onPageLoaded = null,
        onError = null,
        _controlledItems = items,
        _controlledStatus = status,
        _controlledHasMorePages = hasMorePages,
        _controlledError = error,
        _controlledOnLoadMore = onLoadMore,
        _controlledOnRefresh = onRefresh,
        _controlledOnRetry = onRetry;

  // Controller
  final PaginationController<K, T>? _controller;
  final bool _externalController;
  final bool _isControlled;
  final K? _initialPageKey;

  // Controlled mode fields
  final List<T>? _controlledItems;
  final PaginationStatus? _controlledStatus;
  final bool _controlledHasMorePages;
  final Object? _controlledError;
  final VoidCallback? _controlledOnLoadMore;
  final Future<void> Function()? _controlledOnRefresh;
  final VoidCallback? _controlledOnRetry;

  /// Function to fetch a page of items.
  final FetchPage<K, T>? fetchPage;

  /// Computes the next page key. Defaults to `(k, _) => k + 1` for int keys.
  final NextPageKeyBuilder<K, T>? nextPageKeyBuilder;

  /// Configuration for pagination behavior.
  final PaginationConfig config;

  /// Builder for each item in the grid.
  final ItemBuilder<T> itemBuilder;

  /// Delegate that controls the layout of the children within the GridView.
  final SliverGridDelegate gridDelegate;

  /// The type of pagination (infiniteScroll or loadMore).
  final PaginationType paginationType;

  // Custom builders for different states
  final LoadingBuilder? firstPageLoadingBuilder;
  final LoadingBuilder? loadMoreLoadingBuilder;
  final ErrorBuilder? firstPageErrorBuilder;
  final ErrorBuilder? loadMoreErrorBuilder;
  final EmptyBuilder? emptyBuilder;
  final EndOfListBuilder? endOfListBuilder;
  final LoadMoreBuilder? loadMoreButtonBuilder;

  // Callbacks
  /// Called when a page is successfully loaded with only the new items.
  final OnPageLoaded<K, T>? onPageLoaded;

  /// Called when an error occurs.
  final OnError? onError;

  /// Whether pull-to-refresh is enabled.
  final bool enablePullToRefresh;

  /// Optional widget displayed above the paginated grid items.
  ///
  /// Scrolls together with the grid. Useful for titles, filters, or banners.
  final Widget? header;

  /// Optional widget displayed below all paginated items and the footer.
  ///
  /// Scrolls together with the items.
  final Widget? footer;

  // GridView properties
  final ScrollController? scrollController;
  final Axis scrollDirection;
  final bool reverse;
  final bool? primary;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final DragStartBehavior dragStartBehavior;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final String? restorationId;
  final Clip clipBehavior;

  /// Optional callback to find a child's index by its key.
  final ChildIndexGetter? findChildIndexCallback;

  @override
  State<PaginationGridView<K, T>> createState() =>
      _PaginationGridViewState<K, T>();
}

class _PaginationGridViewState<K, T> extends State<PaginationGridView<K, T>>
    with PaginationStateMixin<K, T, PaginationGridView<K, T>> {
  // ── Mixin bridge ────────────────────────────────────────────────────────

  @override
  bool get isControlledMode => widget._isControlled;
  @override
  PaginationController<K, T>? get widgetExternalController => widget._controller;
  @override
  bool get isExternalController => widget._externalController;
  @override
  FetchPage<K, T>? get widgetFetchPage => widget.fetchPage;
  @override
  K? get widgetInitialPageKey => widget._initialPageKey;
  @override
  NextPageKeyBuilder<K, T>? get widgetNextPageKeyBuilder =>
      widget.nextPageKeyBuilder;
  @override
  PaginationConfig get widgetConfig => widget.config;
  @override
  PaginationType get widgetPaginationType => widget.paginationType;
  @override
  ScrollController? get widgetScrollController => widget.scrollController;
  @override
  bool get widgetEnablePullToRefresh => widget.enablePullToRefresh;
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
  void didUpdateWidget(covariant PaginationGridView<K, T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    didUpdatePagination(
      oldExternalController: oldWidget._controller,
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
    return buildPaginationState(contentBuilder: _buildGrid);
  }

  Widget _buildGrid(PaginationState<K, T> state) {
    final hasFooter = shouldShowFooter(state);

    return CustomScrollView(
      controller: activeScrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      slivers: [
        if (widget.header != null)
          SliverToBoxAdapter(child: widget.header),
        SliverPadding(
          padding: widget.padding ?? EdgeInsets.zero,
          sliver: SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) => widget.itemBuilder(
                context,
                state.items[index],
                index,
              ),
              childCount: state.items.length,
              findChildIndexCallback: widget.findChildIndexCallback,
            ),
          ),
        ),
        if (hasFooter)
          SliverToBoxAdapter(
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: buildFooter(state),
            ),
          ),
        if (widget.footer != null)
          SliverToBoxAdapter(child: widget.footer),
      ],
    );
  }
}
