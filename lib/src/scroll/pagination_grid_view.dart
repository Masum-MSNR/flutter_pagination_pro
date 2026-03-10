/// PaginationGridView - A GridView with built-in pagination support
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/typedefs.dart';
import 'pagination_state_mixin.dart';

/// A [GridView] with built-in pagination support.
///
/// Supports two pagination modes:
/// - [PaginationType.infiniteScroll]: Automatically loads more when scrolling near the end
/// - [PaginationType.loadMore]: Shows a button to load more items
///
/// ## Simple Usage
///
/// ```dart
/// PaginationGridView<Product>(
///   fetchPage: (page) => api.getProducts(page: page),
///   itemBuilder: (context, product, index) => ProductCard(product: product),
///   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
///     crossAxisCount: 2,
///   ),
/// )
/// ```
class PaginationGridView<T> extends StatefulWidget {
  /// Creates a [PaginationGridView] with automatic controller management.
  const PaginationGridView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
    required this.gridDelegate,
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
        _externalController = false;

  /// Creates a [PaginationGridView] with an external controller.
  const PaginationGridView.withController({
    super.key,
    required PaginationController<T> controller,
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
        fetchPage = null,
        config = PaginationConfig.defaults;

  // Controller
  final PaginationController<T>? _controller;
  final bool _externalController;

  /// Function to fetch a page of items.
  final FetchPage<T>? fetchPage;

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
  final OnPageLoaded<T>? onPageLoaded;

  /// Called when an error occurs.
  final OnError? onError;

  /// Whether pull-to-refresh is enabled.
  ///
  /// When true, wraps the grid in a [RefreshIndicator] that triggers
  /// [PaginationController.refresh] on pull.
  final bool enablePullToRefresh;

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
  ///
  /// Improves performance when items are inserted, removed, or reordered
  /// by helping Flutter reuse existing widgets.
  final ChildIndexGetter? findChildIndexCallback;

  @override
  State<PaginationGridView<T>> createState() => _PaginationGridViewState<T>();
}

class _PaginationGridViewState<T> extends State<PaginationGridView<T>>
    with PaginationStateMixin<T, PaginationGridView<T>> {
  // ── Mixin bridge ────────────────────────────────────────────────────────

  @override
  PaginationController<T>? get widgetExternalController => widget._controller;
  @override
  bool get isExternalController => widget._externalController;
  @override
  FetchPage<T>? get widgetFetchPage => widget.fetchPage;
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
  OnPageLoaded<T>? get widgetOnPageLoaded => widget.onPageLoaded;
  @override
  OnError? get widgetOnError => widget.onError;

  // ── Lifecycle ───────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    initPagination();
  }

  @override
  void didUpdateWidget(covariant PaginationGridView<T> oldWidget) {
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

  Widget _buildGrid(PaginationState<T> state) {
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
      ],
    );
  }
}
