/// PaginationListView - A ListView with built-in pagination support
library;

import 'package:flutter/gestures.dart';
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
  /// Called when a page is successfully loaded.
  final OnPageLoaded<T>? onPageLoaded;

  /// Called when an error occurs.
  final OnError? onError;

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

  @override
  State<PaginationListView<T>> createState() => _PaginationListViewState<T>();
}

class _PaginationListViewState<T> extends State<PaginationListView<T>> {
  late PaginationController<T> _controller;
  late ScrollController _scrollController;
  bool _ownsScrollController = false;

  @override
  void initState() {
    super.initState();
    _initController();
    _initScrollController();
  }

  void _initController() {
    if (widget._externalController) {
      _controller = widget._controller!;
    } else {
      _controller = PaginationController<T>(
        fetchPage: widget.fetchPage!,
        config: widget.config,
      );
    }

    _controller.addListener(_onStateChanged);

    // Auto load first page
    if (widget.config.autoLoadFirstPage &&
        _controller.status == PaginationStatus.initial) {
      // Use post-frame callback to avoid calling during build
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _controller.loadFirstPage();
      });
    }
  }

  void _initScrollController() {
    if (widget.scrollController != null) {
      _scrollController = widget.scrollController!;
    } else {
      _scrollController = ScrollController();
      _ownsScrollController = true;
    }

    if (widget.paginationType == PaginationType.infiniteScroll) {
      _scrollController.addListener(_onScroll);
    }
  }

  void _onStateChanged() {
    final state = _controller.state;

    // Notify callbacks
    if (state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.completed) {
      widget.onPageLoaded?.call(state.currentPage, state.items);
    }

    if (state.error != null && state.status.isError) {
      widget.onError?.call(state.error!);
    }

    // Trigger rebuild
    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_controller.status.canLoadMore || !_controller.hasMorePages) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = widget.config.invisibleItemsThreshold * 56.0; // Approximate item height

    if (currentScroll >= maxScroll - threshold) {
      _controller.loadNextPage();
    }
  }

  @override
  void didUpdateWidget(covariant PaginationListView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Handle controller changes
    if (widget._externalController && widget._controller != oldWidget._controller) {
      oldWidget._controller?.removeListener(_onStateChanged);
      _controller = widget._controller!;
      _controller.addListener(_onStateChanged);
    }

    // Handle scroll controller changes
    if (widget.scrollController != oldWidget.scrollController) {
      if (_ownsScrollController) {
        _scrollController.removeListener(_onScroll);
        _scrollController.dispose();
        _ownsScrollController = false;
      } else {
        _scrollController.removeListener(_onScroll);
      }
      _initScrollController();
    }

    // Handle pagination type changes
    if (widget.paginationType != oldWidget.paginationType) {
      if (oldWidget.paginationType == PaginationType.infiniteScroll) {
        _scrollController.removeListener(_onScroll);
      }
      if (widget.paginationType == PaginationType.infiniteScroll) {
        _scrollController.addListener(_onScroll);
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onStateChanged);
    if (!widget._externalController) {
      _controller.dispose();
    }

    _scrollController.removeListener(_onScroll);
    if (_ownsScrollController) {
      _scrollController.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _controller.state;

    // Handle first page loading
    if (state.status.isInitialLoading) {
      return widget.firstPageLoadingBuilder?.call(context) ??
          const DefaultFirstPageLoading();
    }

    // Handle first page error
    if (state.status.isFirstPageError) {
      return widget.firstPageErrorBuilder?.call(
            context,
            state.error!,
            _controller.retry,
          ) ??
          DefaultFirstPageError(
            error: state.error!,
            onRetry: _controller.retry,
          );
    }

    // Handle empty state
    if (state.status.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? const DefaultEmpty();
    }

    // Build the list
    return _buildList(state);
  }

  Widget _buildList(PaginationState<T> state) {
    final itemCount = _calculateItemCount(state);
    final hasSeparator = widget.separatorBuilder != null;

    // Calculate total count for separated list
    // items * 2 - 1 (for separators between items) but only if there are items
    // then add 1 for footer if needed
    int totalCount;
    if (hasSeparator) {
      final itemsWithSeparators = state.items.isEmpty ? 0 : state.items.length * 2 - 1;
      final footerCount = _shouldShowFooter(state) ? 1 : 0;
      totalCount = itemsWithSeparators + footerCount;
    } else {
      totalCount = itemCount;
    }

    return ListView.builder(
      controller: _scrollController,
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

    // Add 1 for footer (loading, error, end of list, or load more button)
    if (_shouldShowFooter(state)) {
      count += 1;
    }

    return count;
  }

  bool _shouldShowFooter(PaginationState<T> state) {
    return state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.loadMoreError ||
        state.status == PaginationStatus.completed ||
        (widget.paginationType == PaginationType.loadMore &&
            state.status == PaginationStatus.loaded &&
            state.hasMorePages);
  }

  Widget _buildItem(BuildContext context, int index, PaginationState<T> state) {
    // Footer item
    if (index >= state.items.length) {
      return _buildFooter(state);
    }

    // Regular item
    return widget.itemBuilder(context, state.items[index], index);
  }

  Widget _buildSeparatedItem(BuildContext context, int index, PaginationState<T> state) {
    final itemCount = state.items.length;
    
    // With separators: items at even indices (0, 2, 4, ...), separators at odd indices (1, 3, 5, ...)
    // Total items + separators = itemCount * 2 - 1 (e.g., 15 items = 29 positions: 0-28)
    // Footer comes at index itemCount * 2 - 1 if there are items, else at 0
    final footerIndex = itemCount == 0 ? 0 : itemCount * 2 - 1;

    // Footer item - comes after all items and separators
    if (_shouldShowFooter(state) && index >= footerIndex) {
      return _buildFooter(state);
    }

    // Check if it's a separator (odd indices are separators)
    if (index.isOdd) {
      final separatorIndex = index ~/ 2;
      return widget.separatorBuilder!(context, separatorIndex);
    }

    // Regular item (even indices)
    final itemIndex = index ~/ 2;
    return widget.itemBuilder(context, state.items[itemIndex], itemIndex);
  }

  Widget _buildFooter(PaginationState<T> state) {
    // Loading more
    if (state.status == PaginationStatus.loadingMore) {
      if (widget.paginationType == PaginationType.loadMore) {
        return widget.loadMoreButtonBuilder?.call(context, () {}, true) ??
            const DefaultLoadMoreButton(onPressed: _doNothing, isLoading: true);
      }
      return widget.loadMoreLoadingBuilder?.call(context) ??
          const DefaultLoadMoreLoading();
    }

    // Load more error
    if (state.status == PaginationStatus.loadMoreError) {
      return widget.loadMoreErrorBuilder?.call(
            context,
            state.error!,
            _controller.retry,
          ) ??
          DefaultLoadMoreError(
            error: state.error!,
            onRetry: _controller.retry,
          );
    }

    // Completed (no more items)
    if (state.status == PaginationStatus.completed) {
      return widget.endOfListBuilder?.call(context) ?? const DefaultEndOfList();
    }

    // Load more button (only in loadMore mode)
    if (widget.paginationType == PaginationType.loadMore &&
        state.status == PaginationStatus.loaded &&
        state.hasMorePages) {
      return widget.loadMoreButtonBuilder?.call(
            context,
            _controller.loadNextPage,
            false,
          ) ??
          DefaultLoadMoreButton(
            onPressed: _controller.loadNextPage,
            isLoading: false,
          );
    }

    return const SizedBox.shrink();
  }

  static void _doNothing() {}
}
