/// AnimatedPaginationListView — a paginated list with animated item changes
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/pagination_controller.dart';
import '../core/pagination_config.dart';
import '../core/pagination_state.dart';
import '../core/pagination_status.dart';
import '../core/typedefs.dart';
import '../widgets/default_empty.dart';
import '../widgets/default_error.dart';
import '../widgets/default_loading.dart';
import '../widgets/default_end_of_list.dart';

/// Signature for building an animated item widget.
///
/// [animation] drives the entry/exit transition.
///
/// Named `PaginatedAnimatedItemBuilder` to avoid conflict with Flutter's
/// built-in `AnimatedItemBuilder` from `animated_scroll_view.dart`.
typedef PaginatedAnimatedItemBuilder<T> = Widget Function(
  BuildContext context,
  T item,
  int index,
  Animation<double> animation,
);

/// A paginated [AnimatedList] that animates item insertions and removals.
///
/// Provides smooth slide+fade animations when new pages load (staggered)
/// and when individual items are inserted or removed via the controller.
///
/// `K` is the page key type, `T` is the item type.
///
/// ## Simple Usage
///
/// ```dart
/// AnimatedPaginationListView<int, User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index, animation) => SizeTransition(
///     sizeFactor: animation,
///     child: UserTile(user: user),
///   ),
/// )
/// ```
///
/// ## With Default Animations
///
/// If you prefer the built-in slide+fade animation, use [plainItemBuilder]
/// which wraps your non-animated builder:
///
/// ```dart
/// AnimatedPaginationListView<int, User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   plainItemBuilder: (context, user, index) => UserTile(user: user),
/// )
/// ```
class AnimatedPaginationListView<K, T> extends StatefulWidget {
  /// Creates an animated paginated list with automatic controller management.
  AnimatedPaginationListView({
    super.key,
    required this.fetchPage,
    K? initialPageKey,
    this.itemBuilder,
    this.plainItemBuilder,
    this.nextPageKeyBuilder,
    this.config = PaginationConfig.defaults,
    this.removeItemBuilder,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
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
    this.clipBehavior = Clip.hardEdge,
  })  : controller = null,
        _initialPageKey = initialPageKey ?? (1 as K),
        _isControlled = false,
        assert(
          itemBuilder != null || plainItemBuilder != null,
          'Either itemBuilder or plainItemBuilder must be provided.',
        );

  /// Creates an animated paginated list with a user-provided controller.
  AnimatedPaginationListView.withController({
    super.key,
    required this.controller,
    this.itemBuilder,
    this.plainItemBuilder,
    this.removeItemBuilder,
    this.insertDuration = const Duration(milliseconds: 300),
    this.removeDuration = const Duration(milliseconds: 300),
    this.staggerDelay = const Duration(milliseconds: 50),
    this.firstPageLoadingBuilder,
    this.loadMoreLoadingBuilder,
    this.firstPageErrorBuilder,
    this.loadMoreErrorBuilder,
    this.emptyBuilder,
    this.endOfListBuilder,
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
    this.clipBehavior = Clip.hardEdge,
  })  : fetchPage = null,
        nextPageKeyBuilder = null,
        config = PaginationConfig.defaults,
        _initialPageKey = null,
        _isControlled = true,
        assert(
          itemBuilder != null || plainItemBuilder != null,
          'Either itemBuilder or plainItemBuilder must be provided.',
        );

  // --- Fetch params (only for default constructor) ---

  /// Fetches pages in the forward direction.
  final FetchPage<K, T>? fetchPage;

  /// Computes the next page key.
  final NextPageKeyBuilder<K, T>? nextPageKeyBuilder;

  /// Pagination configuration.
  final PaginationConfig config;

  final K? _initialPageKey;
  final bool _isControlled;

  // --- Controller (only for .withController) ---

  /// External controller. Null when using the default constructor.
  final PaginationController<K, T>? controller;

  // --- Animation params ---

  /// Builds each item with an animation. Use this to create custom
  /// insert transitions (e.g. `SizeTransition`, `SlideTransition`).
  ///
  /// Either this or [plainItemBuilder] must be provided.
  final PaginatedAnimatedItemBuilder<T>? itemBuilder;

  /// Simplified item builder that doesn't handle animation directly.
  /// The widget wraps it with a default slide+fade animation.
  ///
  /// Either this or [itemBuilder] must be provided.
  final ItemBuilder<T>? plainItemBuilder;

  /// Builds the widget shown during item removal animation.
  /// If null, a default fade+shrink animation is used.
  final PaginatedAnimatedItemBuilder<T>? removeItemBuilder;

  /// Duration for insert animations.
  final Duration insertDuration;

  /// Duration for remove animations.
  final Duration removeDuration;

  /// Delay between each item's insert animation during bulk page loads.
  final Duration staggerDelay;

  // --- UI builders ---

  /// Widget shown while the initial page is loading.
  final WidgetBuilder? firstPageLoadingBuilder;

  /// Widget shown at the bottom while loading more.
  final WidgetBuilder? loadMoreLoadingBuilder;

  /// Widget shown when the initial page fails.
  final Widget Function(BuildContext, Object, VoidCallback)?
      firstPageErrorBuilder;

  /// Widget shown when a load-more fails.
  final Widget Function(BuildContext, Object, VoidCallback)?
      loadMoreErrorBuilder;

  /// Widget shown when the list is empty.
  final WidgetBuilder? emptyBuilder;

  /// Widget shown when all items are loaded.
  final WidgetBuilder? endOfListBuilder;

  /// Called when a page loads successfully.
  final void Function(K pageKey, List<T> items)? onPageLoaded;

  /// Called when an error occurs.
  final void Function(Object error)? onError;

  // --- Scroll params ---

  /// Scroll controller.
  final ScrollController? scrollController;

  /// Scroll direction.
  final Axis scrollDirection;

  /// Whether to reverse the scroll direction.
  final bool reverse;

  /// Whether this is the primary scroll view.
  final bool? primary;

  /// Scroll physics.
  final ScrollPhysics? physics;

  /// Whether to shrink-wrap.
  final bool shrinkWrap;

  /// Padding around the list.
  final EdgeInsetsGeometry? padding;

  /// Cache extent.
  final double? cacheExtent;

  /// Drag start behavior.
  final DragStartBehavior dragStartBehavior;

  /// Clip behavior.
  final Clip clipBehavior;

  @override
  State<AnimatedPaginationListView<K, T>> createState() =>
      _AnimatedPaginationListViewState<K, T>();
}

class _AnimatedPaginationListViewState<K, T>
    extends State<AnimatedPaginationListView<K, T>> {
  PaginationController<K, T>? _internalController;
  final _listKey = GlobalKey<AnimatedListState>();
  int _previousItemCount = 0;
  List<T> _previousItems = [];
  bool _isAnimating = false;

  PaginationController<K, T> get _controller =>
      widget.controller ?? _internalController!;

  AnimatedListState? get _animatedListState => _listKey.currentState;

  @override
  void initState() {
    super.initState();
    if (!widget._isControlled) {
      _internalController = PaginationController<K, T>(
        fetchPage: widget.fetchPage!,
        initialPageKey: widget._initialPageKey as K,
        nextPageKeyBuilder: widget.nextPageKeyBuilder,
        config: widget.config,
      );
      _internalController!.addListener(_onStateChanged);
      if (widget.config.autoLoadFirstPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _internalController!.loadFirstPage();
        });
      }
    } else {
      widget.controller!.addListener(_onStateChanged);
      _previousItemCount = widget.controller!.items.length;
      _previousItems = List<T>.from(widget.controller!.items);
      if (widget.controller!.state.status == PaginationStatus.initial &&
          widget.config.autoLoadFirstPage) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.controller!.loadFirstPage();
        });
      }
    }
  }

  @override
  void dispose() {
    if (!widget._isControlled) {
      _internalController?.removeListener(_onStateChanged);
      _internalController?.dispose();
    } else {
      widget.controller?.removeListener(_onStateChanged);
    }
    super.dispose();
  }

  void _onStateChanged() {
    if (!mounted) return;

    final state = _controller.state;
    final newItems = state.items;
    final oldItems = _previousItems;

    // Fire callbacks
    if (state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.completed) {
      if (newItems.length > _previousItemCount) {
        final pageItems = newItems.sublist(_previousItemCount);
        if (state.pageKey != null) {
          widget.onPageLoaded?.call(state.pageKey as K, pageItems);
        }
      }
    }

    if (state.error != null && state.status.isError) {
      widget.onError?.call(state.error!);
    }

    // Reset tracking on fresh fetches
    if (state.status == PaginationStatus.refreshing ||
        state.status == PaginationStatus.loadingFirstPage) {
      _previousItemCount = 0;
      _previousItems = [];
      // For refresh, we need to remove all items from the animated list
      _clearAnimatedList();
      setState(() {});
      return;
    }

    // Diff and animate
    if (_animatedListState != null) {
      _diffAndAnimate(oldItems, newItems);
    }

    _previousItemCount = newItems.length;
    _previousItems = List<T>.from(newItems);
    setState(() {});
  }

  /// Clears all items from the AnimatedList with removal animations.
  void _clearAnimatedList() {
    final listState = _animatedListState;
    if (listState == null) return;

    for (var i = _previousItems.length - 1; i >= 0; i--) {
      final item = _previousItems[i];
      listState.removeItem(
        i,
        (context, animation) => _buildRemovedItem(item, i, animation),
        duration: const Duration(milliseconds: 100),
      );
    }
  }

  /// Diffs old and new item lists, then animates insertions and removals.
  void _diffAndAnimate(List<T> oldItems, List<T> newItems) {
    final listState = _animatedListState;
    if (listState == null) return;

    if (_isAnimating) return;

    // Case 1: Items were appended (page load)
    if (newItems.length > oldItems.length &&
        _listsMatchPrefix(oldItems, newItems)) {
      _animateBulkInsert(oldItems.length, newItems.length);
      return;
    }

    // Case 2: Items were removed (removeItemAt / removeWhere)
    if (newItems.length < oldItems.length) {
      _animateRemovals(oldItems, newItems);
      return;
    }

    // Case 3: Single insert
    if (newItems.length == oldItems.length + 1) {
      // Find the insertion point
      for (var i = 0; i < newItems.length; i++) {
        if (i >= oldItems.length || !identical(oldItems[i], newItems[i])) {
          listState.insertItem(i, duration: widget.insertDuration);
          return;
        }
      }
    }

    // Case 4: Complete replacement (refresh result, updateItems, etc.)
    // No animation for full replacement — just rebuild
  }

  /// Checks if [shorter] is a prefix of [longer] using identity comparison.
  bool _listsMatchPrefix(List<T> shorter, List<T> longer) {
    for (var i = 0; i < shorter.length; i++) {
      if (!identical(shorter[i], longer[i])) return false;
    }
    return true;
  }

  /// Animates bulk insert with stagger for page loads.
  Future<void> _animateBulkInsert(int startIndex, int endIndex) async {
    _isAnimating = true;
    final listState = _animatedListState;
    if (listState == null) {
      _isAnimating = false;
      return;
    }

    for (var i = startIndex; i < endIndex; i++) {
      if (!mounted) break;
      listState.insertItem(i, duration: widget.insertDuration);
      if (widget.staggerDelay > Duration.zero && i < endIndex - 1) {
        await Future.delayed(widget.staggerDelay);
      }
    }
    _isAnimating = false;
  }

  /// Animates removals by finding which items were removed.
  void _animateRemovals(List<T> oldItems, List<T> newItems) {
    final listState = _animatedListState;
    if (listState == null) return;

    // Build a set of new items for identity comparison
    final newSet = Set<T>.identity()..addAll(newItems);

    // Find removed items (go reverse to maintain indices)
    var removedCount = 0;
    for (var i = oldItems.length - 1; i >= 0; i--) {
      if (!newSet.contains(oldItems[i])) {
        final item = oldItems[i];
        listState.removeItem(
          i,
          (context, animation) => _buildRemovedItem(item, i, animation),
          duration: widget.removeDuration,
        );
        removedCount++;
      }
    }

    // If we didn't find specific removals but count differs,
    // it's a bulk operation — remove from end
    if (removedCount == 0) {
      for (var i = oldItems.length - 1; i >= newItems.length; i--) {
        final item = oldItems[i];
        listState.removeItem(
          i,
          (context, animation) => _buildRemovedItem(item, i, animation),
          duration: widget.removeDuration,
        );
      }
    }
  }

  Widget _buildItem(T item, int index, Animation<double> animation) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, item, index, animation);
    }

    // Default slide + fade animation for plainItemBuilder
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: widget.plainItemBuilder!(context, item, index),
      ),
    );
  }

  Widget _buildRemovedItem(T item, int index, Animation<double> animation) {
    if (widget.removeItemBuilder != null) {
      return widget.removeItemBuilder!(context, item, index, animation);
    }

    // Default fade + shrink animation
    return SizeTransition(
      sizeFactor: animation,
      child: FadeTransition(
        opacity: animation,
        child: widget.plainItemBuilder != null
            ? widget.plainItemBuilder!(context, item, index)
            : widget.itemBuilder!(context, item, index, animation),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<PaginationState<K, T>>(
      valueListenable: _controller,
      builder: (context, state, _) {
        // Initial loading
        if (state.status == PaginationStatus.loadingFirstPage ||
            state.status == PaginationStatus.initial) {
          return widget.firstPageLoadingBuilder?.call(context) ??
              const DefaultFirstPageLoading();
        }

        // Initial error
        if (state.status == PaginationStatus.firstPageError) {
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

        // Empty
        if (state.status == PaginationStatus.empty) {
          return widget.emptyBuilder?.call(context) ??
              DefaultEmpty(onRefresh: _controller.refresh);
        }

        // Loaded — build animated list
        return _buildAnimatedList(state);
      },
    );
  }

  Widget _buildAnimatedList(PaginationState<K, T> state) {
    final hasFooter = state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.loadMoreError ||
        state.status == PaginationStatus.completed;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          final controllerState = _controller.state;
          final threshold = _controller.config.scrollThreshold;

          if (metrics.maxScrollExtent > 0 &&
              metrics.maxScrollExtent - metrics.pixels <= threshold &&
              controllerState.status.canLoadMore &&
              controllerState.hasMorePages) {
            _controller.loadNextPage();
          }
        }
        return false;
      },
      child: CustomScrollView(
        controller: widget.scrollController,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        primary: widget.primary,
        physics: widget.physics,
        shrinkWrap: widget.shrinkWrap,
        cacheExtent: widget.cacheExtent,
        dragStartBehavior: widget.dragStartBehavior,
        clipBehavior: widget.clipBehavior,
        slivers: [
          SliverPadding(
            padding: widget.padding ?? EdgeInsets.zero,
            sliver: SliverAnimatedList(
              key: _listKey,
              initialItemCount: state.items.length,
              itemBuilder: (context, index, animation) {
                if (index >= state.items.length) {
                  return const SizedBox.shrink();
                }
                return _buildItem(state.items[index], index, animation);
              },
            ),
          ),
          if (hasFooter)
            SliverToBoxAdapter(
              child: _buildFooter(state),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(PaginationState<K, T> state) {
    if (state.status == PaginationStatus.loadingMore) {
      return widget.loadMoreLoadingBuilder?.call(context) ??
          const DefaultLoadMoreLoading();
    }

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

    if (state.status == PaginationStatus.completed) {
      return widget.endOfListBuilder?.call(context) ??
          const DefaultEndOfList();
    }

    return const SizedBox.shrink();
  }
}
