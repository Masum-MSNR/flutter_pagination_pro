/// PaginationListView - A ListView with built-in pagination support
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/typedefs.dart';
import 'pagination_state_mixin.dart';

/// A [ListView] with built-in pagination support.
///
/// Supports two pagination modes:
/// - [PaginationType.infiniteScroll]: Automatically loads more when scrolling near the end
/// - [PaginationType.loadMore]: Shows a button to load more items
///
/// ## Simple Usage
///
/// ```dart
/// PaginationListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => ListTile(
///     title: Text(user.name),
///   ),
/// )
/// ```
///
/// ## With Load More Button
///
/// ```dart
/// PaginationListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => UserTile(user: user),
///   paginationType: PaginationType.loadMore,
/// )
/// ```
///
/// ## With Controller (for programmatic control)
///
/// ```dart
/// final controller = PaginationController<User>(
///   fetchPage: (page) => api.getUsers(page: page),
/// );
///
/// PaginationListView<User>.withController(
///   controller: controller,
///   itemBuilder: (context, user, index) => UserTile(user: user),
/// )
///
/// // Later: controller.refresh(), controller.retry(), etc.
/// ```
class PaginationListView<T> extends StatefulWidget {
  /// Creates a [PaginationListView] with automatic controller management.
  ///
  /// The controller is created and disposed automatically.
  const PaginationListView({
    super.key,
    required this.fetchPage,
    required this.itemBuilder,
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

  /// Creates a [PaginationListView] with an external controller.
  ///
  /// You are responsible for disposing the controller.
  const PaginationListView.withController({
    super.key,
    required PaginationController<T> controller,
    required this.itemBuilder,
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

  /// Function to fetch a page of items. Required when not using withController.
  final FetchPage<T>? fetchPage;

  /// Configuration for pagination behavior.
  final PaginationConfig config;

  /// Builder for each item in the list.
  final ItemBuilder<T> itemBuilder;

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

  /// Whether pull-to-refresh is enabled.
  ///
  /// When true, wraps the list in a [RefreshIndicator] that triggers
  /// [PaginationController.refresh] on pull.
  final bool enablePullToRefresh;

  // ListView properties
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
  /// by helping Flutter reuse existing widgets. When [separatorBuilder] is
  /// used, your callback should return the **item** index (0, 1, 2…) —
  /// the package automatically maps to delegate indices.
  final ChildIndexGetter? findChildIndexCallback;

  @override
  State<PaginationListView<T>> createState() => _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends State<PaginationListView<T>>
    with PaginationStateMixin<T, PaginationListView<T>> {
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
  void didUpdateWidget(covariant PaginationListView<T> oldWidget) {
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
    return buildPaginationState(contentBuilder: _buildList);
  }

  Widget _buildList(PaginationState<T> state) {
    final itemCount = _calculateItemCount(state);
    final hasSeparator = widget.separatorBuilder != null;

    int totalCount;
    if (hasSeparator) {
      final itemsWithSeparators =
          state.items.isEmpty ? 0 : state.items.length * 2 - 1;
      final footerCount = shouldShowFooter(state) ? 1 : 0;
      totalCount = itemsWithSeparators + footerCount;
    } else {
      totalCount = itemCount;
    }

    return ListView.builder(
      controller: activeScrollController,
      scrollDirection: widget.scrollDirection,
      reverse: widget.reverse,
      primary: widget.primary,
      physics: widget.physics,
      shrinkWrap: widget.shrinkWrap,
      padding: widget.padding,
      cacheExtent: widget.cacheExtent,
      dragStartBehavior: widget.dragStartBehavior,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      restorationId: widget.restorationId,
      clipBehavior: widget.clipBehavior,
      findChildIndexCallback:
          widget.findChildIndexCallback != null && hasSeparator
              ? (Key key) {
                  final itemIndex = widget.findChildIndexCallback!(key);
                  return itemIndex != null ? itemIndex * 2 : null;
                }
              : widget.findChildIndexCallback,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (hasSeparator) {
          return _buildSeparatedItem(context, index, state);
        }
        return _buildItem(context, index, state);
      },
    );
  }

  int _calculateItemCount(PaginationState<T> state) {
    int count = state.items.length;
    if (shouldShowFooter(state)) {
      count += 1;
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index, PaginationState<T> state) {
    if (index >= state.items.length) {
      return buildFooter(state);
    }
    return widget.itemBuilder(context, state.items[index], index);
  }

  Widget _buildSeparatedItem(
    BuildContext context,
    int index,
    PaginationState<T> state,
  ) {
    final itemCount = state.items.length;
    final footerIndex = itemCount == 0 ? 0 : itemCount * 2 - 1;

    if (shouldShowFooter(state) && index >= footerIndex) {
      return buildFooter(state);
    }

    if (index.isOdd) {
      final separatorIndex = index ~/ 2;
      return widget.separatorBuilder!(context, separatorIndex);
    }

    final itemIndex = index ~/ 2;
    return widget.itemBuilder(context, state.items[itemIndex], itemIndex);
  }
}
