/// PaginationGridView - A GridView with built-in pagination support
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
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
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
    this.mainAxisSpacing = 0.0,
    this.crossAxisSpacing = 0.0,
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
  final OnPageLoaded<T>? onPageLoaded;
  final OnError? onError;

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
  final double mainAxisSpacing;
  final double crossAxisSpacing;

  @override
  State<PaginationGridView<T>> createState() => _PaginationGridViewState<T>();
}

class _PaginationGridViewState<T> extends State<PaginationGridView<T>> {
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

    if (widget.config.autoLoadFirstPage &&
        _controller.status == PaginationStatus.initial) {
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

    if (state.status == PaginationStatus.loaded ||
        state.status == PaginationStatus.completed) {
      widget.onPageLoaded?.call(state.currentPage, state.items);
    }

    if (state.error != null && state.status.isError) {
      widget.onError?.call(state.error!);
    }

    if (mounted) setState(() {});
  }

  void _onScroll() {
    if (!_controller.status.canLoadMore || !_controller.hasMorePages) return;

    final position = _scrollController.position;
    final maxScroll = position.maxScrollExtent;
    final currentScroll = position.pixels;
    final threshold = widget.config.invisibleItemsThreshold * 150.0;

    if (currentScroll >= maxScroll - threshold) {
      _controller.loadNextPage();
    }
  }

  @override
  void didUpdateWidget(covariant PaginationGridView<T> oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget._externalController && widget._controller != oldWidget._controller) {
      oldWidget._controller?.removeListener(_onStateChanged);
      _controller = widget._controller!;
      _controller.addListener(_onStateChanged);
    }

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

    if (state.status.isInitialLoading) {
      return widget.firstPageLoadingBuilder?.call(context) ??
          const DefaultFirstPageLoading();
    }

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

    if (state.status.isEmpty) {
      return widget.emptyBuilder?.call(context) ?? const DefaultEmpty();
    }

    return _buildGrid(state);
  }

  Widget _buildGrid(PaginationState<T> state) {
    final hasFooter = _shouldShowFooter(state);

    // Use CustomScrollView with slivers for better footer handling
    return CustomScrollView(
      controller: _scrollController,
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
            ),
          ),
        ),
        if (hasFooter)
          SliverToBoxAdapter(
            child: Padding(
              padding: widget.padding ?? EdgeInsets.zero,
              child: _buildFooter(state),
            ),
          ),
      ],
    );
  }

  bool _shouldShowFooter(PaginationState<T> state) {
    return state.status == PaginationStatus.loadingMore ||
        state.status == PaginationStatus.loadMoreError ||
        state.status == PaginationStatus.completed ||
        (widget.paginationType == PaginationType.loadMore &&
            state.status == PaginationStatus.loaded &&
            state.hasMorePages);
  }

  Widget _buildFooter(PaginationState<T> state) {
    if (state.status == PaginationStatus.loadingMore) {
      if (widget.paginationType == PaginationType.loadMore) {
        return widget.loadMoreButtonBuilder?.call(context, () {}, true) ??
            const DefaultLoadMoreButton(onPressed: _doNothing, isLoading: true);
      }
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
      return widget.endOfListBuilder?.call(context) ?? const DefaultEndOfList();
    }

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
