/// Bidirectional pagination controller
library;

import 'dart:async';

import 'package:flutter/foundation.dart';

import 'bidirectional_state.dart';
import 'pagination_config.dart';
import 'pagination_status.dart';
import 'typedefs.dart';

/// Controller for bidirectional (two-way) pagination.
///
/// Manages fetching pages in both **forward** (append/newer) and
/// **backward** (prepend/older) directions. Ideal for chat apps,
/// timelines, and log viewers.
///
/// `K` is the page key type, `T` is the item type.
///
/// ```dart
/// final controller = BidirectionalPaginationController<int, Message>(
///   fetchPage: (page) => api.getMessages(page: page),
///   fetchPreviousPage: (page) => api.getOlderMessages(before: page),
///   initialPageKey: 10,
///   previousPageKeyBuilder: (key, _) => key - 1,
/// );
/// ```
class BidirectionalPaginationController<K, T>
    extends ValueNotifier<BidirectionalPaginationState<K, T>> {
  /// Creates a bidirectional pagination controller.
  ///
  /// [fetchPage] loads pages in the forward direction.
  /// [fetchPreviousPage] loads pages in the backward direction (optional).
  /// [initialPageKey] is the anchor page to load first.
  /// [nextPageKeyBuilder] computes the next forward key.
  /// [previousPageKeyBuilder] computes the next backward key.
  /// [config] provides pagination settings (pageSize, retryPolicy, etc.).
  BidirectionalPaginationController({
    required FetchPage<K, T> fetchPage,
    FetchPage<K, T>? fetchPreviousPage,
    required K initialPageKey,
    NextPageKeyBuilder<K, T>? nextPageKeyBuilder,
    NextPageKeyBuilder<K, T>? previousPageKeyBuilder,
    PaginationConfig config = PaginationConfig.defaults,
  })  : assert(
          nextPageKeyBuilder != null || initialPageKey is int,
          'nextPageKeyBuilder is required when the page key type is not int. '
          'Provide a function that computes the next page key from the current '
          'key and the loaded items.',
        ),
        assert(
          previousPageKeyBuilder != null || initialPageKey is int,
          'previousPageKeyBuilder is required when the page key type is not int. '
          'Provide a function that computes the previous page key from the '
          'current key and the loaded items.',
        ),
        _fetchForward = fetchPage,
        _fetchBackward = fetchPreviousPage,
        _initialPageKey = initialPageKey,
        _forwardKeyBuilder = nextPageKeyBuilder ?? _intDefaultOrThrow<K, T>(),
        _backwardKeyBuilder =
            previousPageKeyBuilder ?? _intDefaultDecrementOrThrow<K, T>(),
        _config = config,
        _forwardPageKey = initialPageKey,
        _backwardPageKey = initialPageKey,
        super(const BidirectionalPaginationState());

  final FetchPage<K, T> _fetchForward;
  final FetchPage<K, T>? _fetchBackward;
  final K _initialPageKey;
  final NextPageKeyBuilder<K, T> _forwardKeyBuilder;
  final NextPageKeyBuilder<K, T> _backwardKeyBuilder;
  final PaginationConfig _config;

  K _forwardPageKey;
  K _backwardPageKey;

  Object? _forwardOperation;
  Object? _backwardOperation;
  Object? _initialOperation;

  /// Default forward key builder for int keys: `key + 1`.
  static NextPageKeyBuilder<K, T> _intDefaultOrThrow<K, T>() {
    return (K key, List<T> _) {
      if (key is int) return (key + 1) as K;
      throw StateError(
        'nextPageKeyBuilder is required for non-int page keys.',
      );
    };
  }

  /// Default backward key builder for int keys: `key - 1`.
  static NextPageKeyBuilder<K, T> _intDefaultDecrementOrThrow<K, T>() {
    return (K key, List<T> _) {
      if (key is int) return (key - 1) as K;
      throw StateError(
        'previousPageKeyBuilder is required for non-int page keys.',
      );
    };
  }

  /// The current state.
  BidirectionalPaginationState<K, T> get state => value;

  /// All items in display order.
  List<T> get items => value.items;

  /// The configuration.
  PaginationConfig get config => _config;

  /// Loads the initial (anchor) page.
  ///
  /// After this succeeds, [loadNextPage] and [loadPreviousPage] become
  /// available.
  Future<void> loadInitialPage() async {
    if (value.status == PaginationStatus.loadingFirstPage) return;

    _cancelAll();
    final operation = _initialOperation = Object();

    value = value.copyWith(
      status: PaginationStatus.loadingFirstPage,
      clearError: true,
    );

    try {
      final items = await _fetchForward(_initialPageKey);

      if (operation != _initialOperation) return;

      if (items.isEmpty) {
        value = BidirectionalPaginationState<K, T>(
          status: PaginationStatus.empty,
          hasMoreForward: false,
          hasMoreBackward: _fetchBackward != null,
        );
      } else {
        final isLastPage =
            _config.pageSize != null && items.length < _config.pageSize!;
        if (!isLastPage) {
          _forwardPageKey = _forwardKeyBuilder(_initialPageKey, items);
        }

        // Compute backward start key from initial page
        _backwardPageKey = _backwardKeyBuilder(_initialPageKey, items);

        // Determine if backward is possible
        final canGoBackward = _fetchBackward != null;
        final backwardKeyInvalid =
            _backwardPageKey is int && (_backwardPageKey as int) < 1;

        value = BidirectionalPaginationState<K, T>(
          forwardItems: items,
          status: PaginationStatus.loaded,
          hasMoreForward: !isLastPage,
          hasMoreBackward: canGoBackward && !backwardKeyInvalid,
        );
      }
    } catch (error) {
      if (operation != _initialOperation) return;

      value = value.copyWith(
        status: PaginationStatus.firstPageError,
        error: error,
      );

      if (error is! Exception) rethrow;
    }
  }

  /// Loads the next page in the forward (append) direction.
  ///
  /// Does nothing if already loading forward, or no more forward pages.
  Future<void> loadNextPage() async {
    if (value.isLoadingForward ||
        !value.hasMoreForward ||
        !value.isInitialized) {
      return;
    }

    final operation = _forwardOperation = Object();
    final pageKey = _forwardPageKey;

    value = value.copyWith(
      isLoadingForward: true,
      clearForwardError: true,
    );

    try {
      final newItems = await _fetchForward(pageKey);

      if (operation != _forwardOperation) return;

      if (newItems.isEmpty) {
        value = value.copyWith(
          isLoadingForward: false,
          hasMoreForward: false,
        );
      } else {
        final isLastPage =
            _config.pageSize != null && newItems.length < _config.pageSize!;
        if (!isLastPage) {
          _forwardPageKey = _forwardKeyBuilder(pageKey, newItems);
        }
        value = value.copyWith(
          forwardItems: [...value.forwardItems, ...newItems],
          isLoadingForward: false,
          hasMoreForward: !isLastPage,
        );
      }
    } catch (error) {
      if (operation != _forwardOperation) return;

      value = value.copyWith(
        isLoadingForward: false,
        forwardError: error,
      );

      if (error is! Exception) rethrow;
    }
  }

  /// Loads the next page in the backward (prepend) direction.
  ///
  /// Does nothing if:
  /// - Already loading backward
  /// - No more backward pages
  /// - No [fetchPreviousPage] was provided
  /// - Initial page hasn't loaded yet
  Future<void> loadPreviousPage() async {
    if (_fetchBackward == null ||
        value.isLoadingBackward ||
        !value.hasMoreBackward ||
        !value.isInitialized) {
      return;
    }

    final operation = _backwardOperation = Object();
    final pageKey = _backwardPageKey;

    value = value.copyWith(
      isLoadingBackward: true,
      clearBackwardError: true,
    );

    try {
      final newItems = await _fetchBackward!(pageKey);

      if (operation != _backwardOperation) return;

      if (newItems.isEmpty) {
        value = value.copyWith(
          isLoadingBackward: false,
          hasMoreBackward: false,
        );
      } else {
        final isLastPage =
            _config.pageSize != null && newItems.length < _config.pageSize!;
        final newBackwardKey = _backwardKeyBuilder(pageKey, newItems);

        // For int keys, auto-detect exhaustion
        final keyExhausted =
            newBackwardKey is int && newBackwardKey < 1;

        if (!isLastPage && !keyExhausted) {
          _backwardPageKey = newBackwardKey;
        }

        value = value.copyWith(
          // Prepend: new items go before existing backward items
          backwardItems: [...newItems, ...value.backwardItems],
          isLoadingBackward: false,
          hasMoreBackward: !isLastPage && !keyExhausted,
        );
      }
    } catch (error) {
      if (operation != _backwardOperation) return;

      value = value.copyWith(
        isLoadingBackward: false,
        backwardError: error,
      );

      if (error is! Exception) rethrow;
    }
  }

  /// Refreshes by reloading from the initial page.
  ///
  /// Clears all items and resets both forward/backward state.
  Future<void> refresh() async {
    _cancelAll();
    _forwardPageKey = _initialPageKey;
    _backwardPageKey = _initialPageKey;

    value = value.copyWith(
      status: PaginationStatus.refreshing,
      clearError: true,
      clearForwardError: true,
      clearBackwardError: true,
      isLoadingForward: false,
      isLoadingBackward: false,
    );

    final operation = _initialOperation = Object();

    try {
      final items = await _fetchForward(_initialPageKey);

      if (operation != _initialOperation) return;

      if (items.isEmpty) {
        value = BidirectionalPaginationState<K, T>(
          status: PaginationStatus.empty,
          hasMoreForward: false,
          hasMoreBackward: _fetchBackward != null,
        );
      } else {
        final isLastPage =
            _config.pageSize != null && items.length < _config.pageSize!;
        if (!isLastPage) {
          _forwardPageKey = _forwardKeyBuilder(_initialPageKey, items);
        }

        _backwardPageKey = _backwardKeyBuilder(_initialPageKey, items);
        final canGoBackward = _fetchBackward != null;
        final backwardKeyInvalid =
            _backwardPageKey is int && (_backwardPageKey as int) < 1;

        value = BidirectionalPaginationState<K, T>(
          forwardItems: items,
          status: PaginationStatus.loaded,
          hasMoreForward: !isLastPage,
          hasMoreBackward: canGoBackward && !backwardKeyInvalid,
        );
      }
    } catch (error) {
      if (operation != _initialOperation) return;

      value = value.copyWith(
        status: PaginationStatus.firstPageError,
        error: error,
      );

      if (error is! Exception) rethrow;
    }
  }

  /// Retries the last failed operation.
  Future<void> retry() async {
    if (value.status == PaginationStatus.firstPageError) {
      return loadInitialPage();
    }
    // Retry direction-specific errors
    if (value.forwardError != null) {
      return loadNextPage();
    }
    if (value.backwardError != null) {
      return loadPreviousPage();
    }
  }

  /// Resets to initial state.
  void reset() {
    _cancelAll();
    _forwardPageKey = _initialPageKey;
    _backwardPageKey = _initialPageKey;
    value = const BidirectionalPaginationState();
  }

  void _cancelAll() {
    _initialOperation = null;
    _forwardOperation = null;
    _backwardOperation = null;
  }

  @override
  void dispose() {
    _cancelAll();
    super.dispose();
  }

  @override
  String toString() =>
      'BidirectionalPaginationController<$K, $T>('
      'status: ${value.status}, '
      'forward: ${value.forwardItems.length}, '
      'backward: ${value.backwardItems.length}, '
      'moreFwd: ${value.hasMoreForward}, '
      'moreBwd: ${value.hasMoreBackward})';
}
