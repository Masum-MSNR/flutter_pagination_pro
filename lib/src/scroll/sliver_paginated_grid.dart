/// SliverPaginatedGrid - A paginated SliverGrid for use in CustomScrollView
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

import 'pagination_state_mixin.dart';

/// A paginated [SliverGrid] for use inside a [CustomScrollView].
///
/// Drop-in replacement for `SliverGrid` that adds automatic pagination.
/// Requires an external [PaginationController] since the parent
/// [CustomScrollView] owns the scroll controller.
///
/// ## Usage
///
/// ```dart
/// final controller = PaginationController<Photo>(
///   fetchPage: (page) => api.getPhotos(page: page),
/// );
///
/// CustomScrollView(
///   controller: scrollController,
///   slivers: [
///     SliverAppBar(title: Text('Gallery')),
///     SliverPaginatedGrid<Photo>(
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
class SliverPaginatedGrid<T> extends StatefulWidget {
  /// Creates a [SliverPaginatedGrid].
  ///
  /// Requires an external [controller], the parent [scrollController],
  /// and a [gridDelegate] that controls the grid layout.
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
  }) : assert(
         paginationType != PaginationType.infiniteScroll ||
             scrollController != null,
         'scrollController is required for infiniteScroll mode in slivers. '
         'Pass the parent CustomScrollView\'s ScrollController.',
       );

  /// The pagination controller. You are responsible for creating and disposing it.
  final PaginationController<T> controller;

  /// Builder for each item in the grid.
  final ItemBuilder<T> itemBuilder;

  /// Controls the layout of tiles in the grid.
  final SliverGridDelegate gridDelegate;

  /// The scroll controller from the parent [CustomScrollView].
  ///
  /// Required for infinite scroll mode to detect when the user scrolls
  /// near the bottom. Can be omitted if only using [PaginationType.loadMore].
  final ScrollController? scrollController;

  /// The type of pagination (infiniteScroll or loadMore).
  final PaginationType paginationType;

  // Custom builders for different states
  /// Builder for the first page loading indicator.
  final LoadingBuilder? firstPageLoadingBuilder;

  /// Builder for the load more loading indicator.
  final LoadingBuilder? loadMoreLoadingBuilder;

  /// Builder for first page errors.
  final ErrorBuilder? firstPageErrorBuilder;

  /// Builder for load more errors.
  final ErrorBuilder? loadMoreErrorBuilder;

  /// Builder for empty state.
  final EmptyBuilder? emptyBuilder;

  /// Builder for end of list indicator.
  final EndOfListBuilder? endOfListBuilder;

  /// Builder for the load more button (when using loadMore mode).
  final LoadMoreBuilder? loadMoreButtonBuilder;

  // Callbacks
  /// Called when a page is successfully loaded with only the new items.
  final OnPageLoaded<T>? onPageLoaded;

  /// Called when an error occurs.
  final OnError? onError;

  /// Optional callback to find a child's index by its key.
  ///
  /// Improves performance when items are inserted, removed, or reordered
  /// by helping Flutter reuse existing widgets.
  final ChildIndexGetter? findChildIndexCallback;

  @override
  State<SliverPaginatedGrid<T>> createState() =>
      _SliverPaginatedGridState<T>();
}

class _SliverPaginatedGridState<T> extends State<SliverPaginatedGrid<T>>
    with PaginationStateMixin<T, SliverPaginatedGrid<T>> {
  // ── Mixin bridge ────────────────────────────────────────────────────────

  @override
  PaginationController<T>? get widgetExternalController => widget.controller;
  @override
  bool get isExternalController => true;
  @override
  FetchPage<T>? get widgetFetchPage => null;
  @override
  PaginationConfig get widgetConfig => widget.controller.config;
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
  void didUpdateWidget(covariant SliverPaginatedGrid<T> oldWidget) {
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
    final state = paginationController.state;

    // Full-area states returned as SliverFillRemaining
    if (state.status.isInitialLoading) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widgetFirstPageLoadingBuilder?.call(context) ??
            const DefaultFirstPageLoading(),
      );
    }

    if (state.status.isFirstPageError) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widgetFirstPageErrorBuilder?.call(
              context,
              state.error!,
              paginationController.retry,
            ) ??
            DefaultFirstPageError(
              error: state.error!,
              onRetry: paginationController.retry,
            ),
      );
    }

    if (state.status.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: widgetEmptyBuilder?.call(context) ?? const DefaultEmpty(),
      );
    }

    // Grid items + optional footer as separate sliver
    return _buildSliverContent(state);
  }

  Widget _buildSliverContent(PaginationState<T> state) {
    final hasFooter = shouldShowFooter(state);

    final sliverGrid = SliverGrid(
      gridDelegate: widget.gridDelegate,
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            widget.itemBuilder(context, state.items[index], index),
        childCount: state.items.length,
        findChildIndexCallback: widget.findChildIndexCallback,
      ),
    );

    if (!hasFooter) {
      return sliverGrid;
    }

    // Use a MultiSliver-like approach: wrap grid + footer in a SliverMainAxisGroup
    // SliverMainAxisGroup is available from Flutter 3.13+
    // For broader compatibility, we return a MultiSliver wrapper.
    return SliverMainAxisGroup(
      slivers: [
        sliverGrid,
        SliverToBoxAdapter(child: buildFooter(state)),
      ],
    );
  }
}
