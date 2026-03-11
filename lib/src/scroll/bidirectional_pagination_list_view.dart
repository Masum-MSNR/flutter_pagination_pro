/// BidirectionalPaginationListView — a ListView that loads in both directions
library;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../core/bidirectional_controller.dart';
import '../core/bidirectional_state.dart';
import '../core/pagination_config.dart';
import '../core/pagination_status.dart';
import '../core/typedefs.dart';
import '../widgets/default_empty.dart';
import '../widgets/default_error.dart';
import '../widgets/default_loading.dart';

/// A [ListView] that supports loading items in both directions.
///
/// Uses Flutter's [CustomScrollView] with a `center` key so that
/// backward (prepend) items grow upward without disturbing the
/// scroll position — ideal for chat apps, timelines, and log viewers.
///
/// `K` is the page key type, `T` is the item type.
///
/// ## Simple Usage
///
/// ```dart
/// BidirectionalPaginationListView<int, Message>(
///   fetchPage: (page) => api.getMessages(page: page),
///   fetchPreviousPage: (page) => api.getOlderMessages(before: page),
///   initialPageKey: latestPage,
///   itemBuilder: (context, msg, index) => MessageBubble(msg),
///   reverse: true, // newest at bottom (chat-style)
/// )
/// ```
///
/// ## With Controller
///
/// ```dart
/// BidirectionalPaginationListView<int, Message>.withController(
///   controller: myController,
///   itemBuilder: (context, msg, index) => MessageBubble(msg),
/// )
/// ```
class BidirectionalPaginationListView<K, T> extends StatefulWidget {
  /// Creates a bidirectional list with automatic controller management.
  const BidirectionalPaginationListView({
    super.key,
    required this.fetchPage,
    this.fetchPreviousPage,
    K? initialPageKey,
    required this.itemBuilder,
    this.nextPageKeyBuilder,
    this.previousPageKeyBuilder,
    this.config = PaginationConfig.defaults,
    this.separatorBuilder,
    this.firstPageLoadingBuilder,
    this.forwardLoadingBuilder,
    this.backwardLoadingBuilder,
    this.firstPageErrorBuilder,
    this.forwardErrorBuilder,
    this.backwardErrorBuilder,
    this.emptyBuilder,
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
  })  : controller = null,
        _initialPageKey = initialPageKey ?? (1 as K),
        _isControlled = false;

  /// Creates a bidirectional list with a user-provided controller.
  const BidirectionalPaginationListView.withController({
    super.key,
    required this.controller,
    required this.itemBuilder,
    this.separatorBuilder,
    this.firstPageLoadingBuilder,
    this.forwardLoadingBuilder,
    this.backwardLoadingBuilder,
    this.firstPageErrorBuilder,
    this.forwardErrorBuilder,
    this.backwardErrorBuilder,
    this.emptyBuilder,
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
  })  : fetchPage = null,
        fetchPreviousPage = null,
        nextPageKeyBuilder = null,
        previousPageKeyBuilder = null,
        config = PaginationConfig.defaults,
        _initialPageKey = null,
        _isControlled = true;

  // --- Fetch params (only for default constructor) ---

  /// Fetches pages in the forward (append) direction.
  final FetchPage<K, T>? fetchPage;

  /// Fetches pages in the backward (prepend) direction.
  final FetchPage<K, T>? fetchPreviousPage;

  /// Computes the next forward page key.
  final NextPageKeyBuilder<K, T>? nextPageKeyBuilder;

  /// Computes the next backward page key.
  final NextPageKeyBuilder<K, T>? previousPageKeyBuilder;

  /// Pagination configuration.
  final PaginationConfig config;

  final K? _initialPageKey;
  final bool _isControlled;

  // --- Controller (only for .withController) ---

  /// External controller. Null when using the default constructor.
  final BidirectionalPaginationController<K, T>? controller;

  // --- UI builders ---

  /// Builds each item widget.
  final ItemBuilder<T> itemBuilder;

  /// Optional separator between items.
  final IndexedWidgetBuilder? separatorBuilder;

  /// Widget shown while the initial page is loading.
  final WidgetBuilder? firstPageLoadingBuilder;

  /// Widget shown at the bottom while loading more forward items.
  final WidgetBuilder? forwardLoadingBuilder;

  /// Widget shown at the top while loading more backward items.
  final WidgetBuilder? backwardLoadingBuilder;

  /// Widget shown when the initial page fails.
  final Widget Function(BuildContext, Object, VoidCallback)?
      firstPageErrorBuilder;

  /// Widget shown when a forward load fails.
  final Widget Function(BuildContext, Object, VoidCallback)?
      forwardErrorBuilder;

  /// Widget shown when a backward load fails.
  final Widget Function(BuildContext, Object, VoidCallback)?
      backwardErrorBuilder;

  /// Widget shown when the list is empty.
  final WidgetBuilder? emptyBuilder;

  /// Called when a page loads successfully.
  final void Function(K pageKey, List<T> items)? onPageLoaded;

  /// Called when an error occurs.
  final void Function(Object error)? onError;

  // --- Scroll params ---

  /// Scroll controller.
  final ScrollController? scrollController;

  /// Scroll direction.
  final Axis scrollDirection;

  /// Whether to reverse the scroll direction (newest at bottom).
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

  /// Keyboard dismiss behavior.
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;

  /// Restoration ID.
  final String? restorationId;

  /// Clip behavior.
  final Clip clipBehavior;

  @override
  State<BidirectionalPaginationListView<K, T>> createState() =>
      _BidirectionalPaginationListViewState<K, T>();
}

class _BidirectionalPaginationListViewState<K, T>
    extends State<BidirectionalPaginationListView<K, T>> {
  BidirectionalPaginationController<K, T>? _internalController;
  final _centerKey = UniqueKey();

  BidirectionalPaginationController<K, T> get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (!widget._isControlled) {
      _internalController = BidirectionalPaginationController<K, T>(
        fetchPage: widget.fetchPage!,
        fetchPreviousPage: widget.fetchPreviousPage,
        initialPageKey: widget._initialPageKey as K,
        nextPageKeyBuilder: widget.nextPageKeyBuilder,
        previousPageKeyBuilder: widget.previousPageKeyBuilder,
        config: widget.config,
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _internalController!.loadInitialPage();
      });
    } else if (widget.controller!.state.status == PaginationStatus.initial) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.controller!.loadInitialPage();
      });
    }
  }

  @override
  void dispose() {
    _internalController?.dispose();
    super.dispose();
  }

  void _onForwardScroll() {
    final controller = _controller;
    final state = controller.state;
    if (!state.isLoadingForward &&
        state.hasMoreForward &&
        state.isInitialized) {
      controller.loadNextPage();
    }
  }

  void _onBackwardScroll() {
    final controller = _controller;
    final state = controller.state;
    if (!state.isLoadingBackward &&
        state.hasMoreBackward &&
        state.isInitialized) {
      controller.loadPreviousPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<BidirectionalPaginationState<K, T>>(
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

        // Loaded — build the bidirectional list
        return _buildBidirectionalList(state);
      },
    );
  }

  Widget _buildBidirectionalList(
      BidirectionalPaginationState<K, T> state) {
    final threshold = _controller.config.scrollThreshold;

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollUpdateNotification) {
          final metrics = notification.metrics;
          final currentState = _controller.state;

          // Forward (down/end) — trigger when near bottom
          // Skip if all content fits on screen (maxScrollExtent == 0)
          // to avoid infinite trigger loop.
          if (metrics.maxScrollExtent > 0 &&
              metrics.maxScrollExtent - metrics.pixels <= threshold &&
              !currentState.isLoadingForward &&
              currentState.hasMoreForward) {
            _onForwardScroll();
          }

          // Backward (up/start) — trigger when user scrolls near top
          // For center-based CustomScrollView, minScrollExtent is negative.
          if (metrics.minScrollExtent < 0 &&
              metrics.pixels - metrics.minScrollExtent <= threshold &&
              !currentState.isLoadingBackward &&
              currentState.hasMoreBackward) {
            _onBackwardScroll();
          }
        }
        return false;
      },
      child: CustomScrollView(
        center: _centerKey,
        controller: widget.scrollController,
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
          // --- Backward loading indicator (above center) ---
          if (state.isLoadingBackward)
            SliverToBoxAdapter(
              child: widget.backwardLoadingBuilder?.call(context) ??
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
            ),

          // --- Backward error ---
          if (state.backwardError != null && !state.isLoadingBackward)
            SliverToBoxAdapter(
              child: widget.backwardErrorBuilder?.call(
                    context,
                    state.backwardError!,
                    _controller.loadPreviousPage,
                  ) ??
                  _buildDirectionError(
                    state.backwardError!,
                    _controller.loadPreviousPage,
                  ),
            ),

          // --- Backward items ---
          _buildBackwardSliver(state),

          // --- Forward items (center key) ---
          _buildForwardSliver(state),

          // --- Forward error ---
          if (state.forwardError != null && !state.isLoadingForward)
            SliverToBoxAdapter(
              child: widget.forwardErrorBuilder?.call(
                    context,
                    state.forwardError!,
                    _controller.loadNextPage,
                  ) ??
                  _buildDirectionError(
                    state.forwardError!,
                    _controller.loadNextPage,
                  ),
            ),

          // --- Forward loading indicator (below center) ---
          if (state.isLoadingForward)
            SliverToBoxAdapter(
              child: widget.forwardLoadingBuilder?.call(context) ??
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
            ),
        ],
      ),
    );
  }

  /// Builds the backward sliver (items grow upward from center).
  ///
  /// In a `CustomScrollView(center:)`, slivers before the center key
  /// render in reverse (index 0 is closest to center, highest index
  /// is at the top).
  Widget _buildBackwardSliver(BidirectionalPaginationState<K, T> state) {
    final backwardItems = state.backwardItems;
    if (backwardItems.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    if (widget.separatorBuilder != null) {
      final totalCount =
          backwardItems.length + (backwardItems.length - 1).clamp(0, 999999);

      return SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            // Reverse: index 0 = closest to center = backwardItems.last
            final reversedIndex = totalCount - 1 - index;
            if (reversedIndex.isEven) {
              final itemIndex = reversedIndex ~/ 2;
              return widget.itemBuilder(
                  context, backwardItems[itemIndex], itemIndex);
            } else {
              return widget.separatorBuilder!(
                  context, reversedIndex ~/ 2);
            }
          },
          childCount: totalCount,
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          // Reverse: index 0 = closest to center
          final reversedIndex = backwardItems.length - 1 - index;
          return widget.itemBuilder(
              context, backwardItems[reversedIndex], reversedIndex);
        },
        childCount: backwardItems.length,
      ),
    );
  }

  /// Builds the forward sliver (center key, items grow downward).
  Widget _buildForwardSliver(BidirectionalPaginationState<K, T> state) {
    final forwardItems = state.forwardItems;

    if (widget.separatorBuilder != null && forwardItems.length > 1) {
      // If there are backward items, add a separator between backward and forward
      final hasBackward = state.backwardItems.isNotEmpty;
      final separatorOffset = hasBackward ? 1 : 0;
      final totalCount =
          forwardItems.length + (forwardItems.length - 1) + separatorOffset;

      return SliverList(
        key: _centerKey,
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (hasBackward && index == 0) {
              // Separator between backward and forward
              return widget.separatorBuilder!(context, -1);
            }
            final adjustedIndex = index - separatorOffset;
            if (adjustedIndex.isEven) {
              final itemIndex = adjustedIndex ~/ 2;
              return widget.itemBuilder(
                  context, forwardItems[itemIndex], itemIndex);
            } else {
              return widget.separatorBuilder!(
                  context, adjustedIndex ~/ 2);
            }
          },
          childCount: totalCount,
        ),
      );
    }

    return SliverList(
      key: _centerKey,
      delegate: SliverChildBuilderDelegate(
        (context, index) =>
            widget.itemBuilder(context, forwardItems[index], index),
        childCount: forwardItems.length,
      ),
    );
  }

  Widget _buildDirectionError(Object error, VoidCallback onRetry) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 16, color: Colors.red),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              error.toString(),
              style: const TextStyle(fontSize: 13, color: Colors.red),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
