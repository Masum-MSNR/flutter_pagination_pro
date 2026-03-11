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
/// `K` is the page key type. `T` is the item type.
///
/// Requires an external [PaginationController] (or controlled mode) since
/// the parent [CustomScrollView] owns the scroll controller.
///
/// ## With Controller
///
/// ```dart
/// final controller = PaginationController<int, User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   initialPageKey: 1,
/// );
///
/// CustomScrollView(
///   controller: scrollController,
///   slivers: [
///     SliverAppBar(title: Text('Users')),
///     SliverPaginatedList<int, User>(
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
/// ## Controlled Mode
///
/// ```dart
/// SliverPaginatedList<int, User>.controlled(
///   items: users,
///   status: myStatus,
///   scrollController: scrollController,
///   itemBuilder: (context, user, index) => UserTile(user),
///   onLoadMore: () => loadMore(),
/// )
/// ```
class SliverPaginatedList<K, T> extends StatefulWidget {
  /// Creates a [SliverPaginatedList] with an external controller.
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
    this.placeholderItem,
    this.placeholderCount = 6,
    this.skeletonOverlayColor,
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

  /// Creates a [SliverPaginatedList] in controlled mode.
  ///
  /// You provide items and status directly — no controller is used.
  const SliverPaginatedList.controlled({
    super.key,
    required List<T> items,
    required PaginationStatus status,
    required this.itemBuilder,
    bool hasMorePages = true,
    Object? error,
    VoidCallback? onLoadMore,
    Future<void> Function()? onRefresh,
    VoidCallback? onRetry,
    this.scrollController,
    this.paginationType = PaginationType.infiniteScroll,
    this.config = PaginationConfig.defaults,
    this.separatorBuilder,
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
    this.skeletonOverlayColor,
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

  /// Builder for each item in the list.
  final ItemBuilder<T> itemBuilder;

  /// The scroll controller from the parent [CustomScrollView].
  final ScrollController? scrollController;

  /// The type of pagination (infiniteScroll or loadMore).
  final PaginationType paginationType;

  /// Configuration for pagination behavior (used for scrollThreshold).
  final PaginationConfig config;

  /// Optional builder for separators between items.
  final SeparatorBuilder? separatorBuilder;

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

  /// Overlay color for skeleton items (defaults to `Colors.grey.shade300`).
  ///
  /// Only used when [placeholderItem] is provided.
  final Color? skeletonOverlayColor;

  @override
  State<SliverPaginatedList<K, T>> createState() =>
      _SliverPaginatedListState<K, T>();
}

class _SliverPaginatedListState<K, T> extends State<SliverPaginatedList<K, T>>
    with PaginationStateMixin<K, T, SliverPaginatedList<K, T>> {
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
  SeparatorBuilder? get widgetSeparatorBuilder => widget.separatorBuilder;
  @override
  T? get widgetPlaceholderItem => widget.placeholderItem;
  @override
  int get widgetPlaceholderCount => widget.placeholderCount;
  @override
  Color? get widgetSkeletonOverlayColor => widget.skeletonOverlayColor;

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
  void didUpdateWidget(covariant SliverPaginatedList<K, T> oldWidget) {
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

    // Items + optional footer
    return _buildSliverList(state);
  }

  Widget _buildSliverList(PaginationState<K, T> state) {
    final hasSeparator = widget.separatorBuilder != null;
    final hasFooter = shouldShowFooter(state);
    final skeletonCount = skeletonLoadMoreCount(state);
    final effectiveItemCount = state.items.length + skeletonCount;

    final int itemSlotCount;
    if (hasSeparator) {
      itemSlotCount =
          effectiveItemCount == 0 ? 0 : effectiveItemCount * 2 - 1;
    } else {
      itemSlotCount = effectiveItemCount;
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
            if (itemIndex >= state.items.length) {
              return buildSkeletonItem(context, itemIndex);
            }
            return widget.itemBuilder(
                context, state.items[itemIndex], itemIndex);
          }

          if (index >= state.items.length) {
            return buildSkeletonItem(context, index);
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

  Widget _buildSkeletonSliver() {
    final placeholder = widgetPlaceholderItem as T;
    final hasSeparator = widgetSeparatorBuilder != null;
    final count = widgetPlaceholderCount;

    final int totalSlots = hasSeparator && count > 0 ? count * 2 - 1 : count;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (hasSeparator && index.isOdd) {
            return widgetSeparatorBuilder!(context, index ~/ 2);
          }
          final itemIndex = hasSeparator ? index ~/ 2 : index;
          return DefaultFirstPageLoading.skeletonize(
            context,
            widgetItemBuilder(context, placeholder, itemIndex),
            overlayColor: widgetSkeletonOverlayColor,
          );
        },
        childCount: totalSlots,
      ),
    );
  }
}
