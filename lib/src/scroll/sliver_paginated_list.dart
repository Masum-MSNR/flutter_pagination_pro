/// SliverPaginatedList - A paginated SliverList for use in CustomScrollView
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

/// A paginated [SliverList] for use inside a [CustomScrollView].
///
/// Drop-in replacement for `SliverList` that adds automatic pagination.
/// Requires an external [PaginationController] since the parent
/// [CustomScrollView] owns the scroll controller.
///
/// ## Usage
///
/// ```dart
/// final controller = PaginationController<User>(
///   fetchPage: (page) => api.getUsers(page: page),
/// );
///
/// CustomScrollView(
///   controller: scrollController,
///   slivers: [
///     SliverAppBar(title: Text('Users')),
///     SliverPaginatedList<User>(
///       controller: controller,
///       scrollController: scrollController,
///       itemBuilder: (context, user, index) => ListTile(
///         title: Text(user.name),
///       ),
///     ),
///   ],
/// )
/// ```
///
/// ## With Separators
///
/// ```dart
/// SliverPaginatedList<User>(
///   controller: controller,
///   scrollController: scrollController,
///   itemBuilder: (context, user, index) => UserTile(user),
///   separatorBuilder: (context, index) => Divider(),
/// )
/// ```
class SliverPaginatedList<T> extends StatefulWidget {
  /// Creates a [SliverPaginatedList].
  ///
  /// Requires an external [controller] and the parent [scrollController]
  /// from the enclosing [CustomScrollView] for scroll-based loading.
  const SliverPaginatedList({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.scrollController,
    this.paginationType = PaginationType.infiniteScroll,
    this.separatorBuilder,
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

  /// Builder for each item in the list.
  final ItemBuilder<T> itemBuilder;

  /// The scroll controller from the parent [CustomScrollView].
  ///
  /// Required for infinite scroll mode to detect when the user scrolls
  /// near the bottom. Can be omitted if only using [PaginationType.loadMore].
  final ScrollController? scrollController;

  /// The type of pagination (infiniteScroll or loadMore).
  final PaginationType paginationType;

  /// Optional builder for separators between items.
  final SeparatorBuilder? separatorBuilder;

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
  /// Improves performance when items are inserted, removed, or reordered.
  /// When [separatorBuilder] is used, your callback should return the **item**
  /// index (0, 1, 2…) — the package automatically maps to delegate indices.
  final ChildIndexGetter? findChildIndexCallback;

  @override
  State<SliverPaginatedList<T>> createState() =>
      _SliverPaginatedListState<T>();
}

class _SliverPaginatedListState<T> extends State<SliverPaginatedList<T>>
    with PaginationStateMixin<T, SliverPaginatedList<T>> {
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
  void didUpdateWidget(covariant SliverPaginatedList<T> oldWidget) {
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

    // Items + optional footer
    return _buildSliverList(state);
  }

  Widget _buildSliverList(PaginationState<T> state) {
    final hasSeparator = widget.separatorBuilder != null;
    final hasFooter = shouldShowFooter(state);

    final int itemSlotCount;
    if (hasSeparator) {
      // items at even indices, separators at odd: count = items*2-1
      itemSlotCount =
          state.items.isEmpty ? 0 : state.items.length * 2 - 1;
    } else {
      itemSlotCount = state.items.length;
    }

    final totalCount = itemSlotCount + (hasFooter ? 1 : 0);

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Footer
          if (index >= itemSlotCount) {
            return buildFooter(state);
          }

          if (hasSeparator) {
            if (index.isOdd) {
              return widget.separatorBuilder!(context, index ~/ 2);
            }
            final itemIndex = index ~/ 2;
            return widget.itemBuilder(
                context, state.items[itemIndex], itemIndex);
          }

          return widget.itemBuilder(context, state.items[index], index);
        },
        childCount: totalCount,
        findChildIndexCallback:
            widget.findChildIndexCallback != null && hasSeparator
                ? (Key key) {
                    final itemIndex = widget.findChildIndexCallback!(key);
                    return itemIndex != null ? itemIndex * 2 : null;
                  }
                : widget.findChildIndexCallback,
      ),
    );
  }
}
