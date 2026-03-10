/// Pagination controller
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'pagination_state.dart';
import 'pagination_status.dart';
import 'pagination_config.dart';
import 'typedefs.dart';

/// Controller for managing pagination state with generic page keys.
///
/// `K` is the page key type (int, String, cursor, offset, etc.).
/// `T` is the item type.
///
/// This controller handles:
/// - Fetching pages using any key type
/// - Managing state transitions
/// - Error handling
/// - Refresh, reset, and search/filter operations
///
/// ## Integer Pages (most common — just provide fetchPage!)
///
/// ```dart
/// final controller = PaginationController<int, User>(
///   fetchPage: (page) => api.getUsers(page: page),
/// );
/// ```
///
/// ## Cursor-Based Pagination
///
/// ```dart
/// final controller = PaginationController<String, User>(
///   fetchPage: (cursor) => api.getUsers(cursor: cursor),
///   initialPageKey: '',
///   nextPageKeyBuilder: (_, items) => items.last.cursor,
/// );
/// ```
///
/// ## Offset-Based Pagination
///
/// ```dart
/// final controller = PaginationController<int, Product>(
///   fetchPage: (offset) => api.getProducts(offset: offset, limit: 20),
///   initialPageKey: 0,
///   nextPageKeyBuilder: (offset, items) => offset + items.length,
/// );
/// ```
class PaginationController<K, T> extends ValueNotifier<PaginationState<K, T>> {
  /// Creates a pagination controller.
  ///
  /// [fetchPage] is required and will be called to fetch each page.
  /// [initialPageKey] is the key for the first page. **Defaults to `1` for
  /// `int` keys**, so you can omit it for simple page-number pagination.
  /// Required for non-int keys (cursors, offsets, etc.).
  /// [nextPageKeyBuilder] computes the next page key from the current key
  /// and loaded items. Defaults to `(key, _) => key + 1` for `int` keys.
  /// [config] provides pagination behavior settings.
  /// [initialItems] optionally prepopulates the list with cached data,
  /// skipping the initial load. The controller starts in
  /// [PaginationStatus.loaded] state.
  PaginationController({
    required FetchPage<K, T> fetchPage,
    K? initialPageKey,
    NextPageKeyBuilder<K, T>? nextPageKeyBuilder,
    PaginationConfig config = PaginationConfig.defaults,
    List<T>? initialItems,
  })  : _fetchPage = fetchPage,
        _initialPageKey = _resolveInitialPageKey<K>(initialPageKey),
        _config = config,
        _nextPageKey = _resolveInitialPageKey<K>(initialPageKey),
        _nextPageKeyBuilder = nextPageKeyBuilder ?? _intDefaultOrThrow<K, T>(),
        super(
          initialItems != null && initialItems.isNotEmpty
              ? PaginationState<K, T>(
                  items: List<T>.of(initialItems),
                  pageKey: _resolveInitialPageKey<K>(initialPageKey),
                  status: PaginationStatus.loaded,
                  hasMorePages: true,
                )
              : PaginationState<K, T>(),
        ) {
    assert(
      nextPageKeyBuilder != null || _initialPageKey is int,
      'nextPageKeyBuilder is required when the page key type is not int. '
      'Provide a function that computes the next page key from the current '
      'key and the loaded items.',
    );

    // When initialItems are provided, advance _nextPageKey past the first page
    // so that loadNextPage fetches page 2 (not page 1 again).
    if (initialItems != null && initialItems.isNotEmpty) {
      _nextPageKey = _nextPageKeyBuilder(_initialPageKey, initialItems);
    }
  }

  /// Resolves the initial page key, defaulting to `1` for int keys.
  ///
  /// Throws [ArgumentError] if `K` is not `int` and no key is provided.
  static K _resolveInitialPageKey<K>(K? key) {
    if (key != null) return key;
    if (K == int) return 1 as K;
    throw ArgumentError(
      'initialPageKey is required when the page key type is not int. '
      'For int keys, it defaults to 1.',
    );
  }

  FetchPage<K, T> _fetchPage;
  final K _initialPageKey;
  final PaginationConfig _config;
  final NextPageKeyBuilder<K, T> _nextPageKeyBuilder;

  /// The key for the next page to be fetched.
  K _nextPageKey;

  /// Tracks the current async operation to handle cancellation.
  Object? _currentOperation;

  /// Timer used for retry delays; cancelled on refresh/reset/dispose.
  Timer? _retryTimer;

  /// Returns a default [NextPageKeyBuilder] that increments int keys by 1.
  ///
  /// Throws a [StateError] at call-time if K is not int.
  static NextPageKeyBuilder<K, T> _intDefaultOrThrow<K, T>() {
    return (K key, List<T> _) {
      if (key is int) return (key + 1) as K;
      // Should not reach here due to constructor assert
      throw StateError(
        'nextPageKeyBuilder is required for non-int page keys.',
      );
    };
  }

  /// The current state.
  PaginationState<K, T> get state => value;

  /// The list of loaded items.
  List<T> get items => value.items;

  /// The key of the last loaded page, or null if no page has been loaded.
  K? get currentPageKey => value.pageKey;

  /// The current status.
  PaginationStatus get status => value.status;

  /// Whether there are more pages to load.
  bool get hasMorePages => value.hasMorePages;

  /// Whether currently loading.
  bool get isLoading => value.status.isLoading;

  /// The configuration.
  PaginationConfig get config => _config;

  /// The initial page key.
  K get initialPageKey => _initialPageKey;

  /// Cancels any pending retry timer.
  void _cancelRetryTimer() {
    _retryTimer?.cancel();
    _retryTimer = null;
  }

  /// Waits for [duration] using a cancellable timer.
  ///
  /// Returns `false` if the timer was cancelled (operation changed).
  Future<bool> _waitForRetry(Duration duration, Object operation) {
    final completer = Completer<bool>();
    _retryTimer = Timer(duration, () {
      if (operation == _currentOperation) {
        completer.complete(true);
      } else {
        completer.complete(false);
      }
    });
    return completer.future;
  }

  /// Loads the first page.
  ///
  /// This is typically called automatically when the widget is first built
  /// if [PaginationConfig.autoLoadFirstPage] is true.
  ///
  /// If a [RetryPolicy] is configured with [RetryPolicy.retryFirstPage]
  /// set to `true`, failed first-page loads will be retried automatically
  /// with exponential backoff.
  Future<void> loadFirstPage() async {
    if (value.status == PaginationStatus.loadingFirstPage) return;

    _cancelRetryTimer();
    final operation = _currentOperation = Object();

    value = value.copyWith(
      status: PaginationStatus.loadingFirstPage,
      clearError: true,
      retryCount: 0,
    );

    final retryPolicy = _config.retryPolicy;
    var attempt = 0;

    while (true) {
      try {
        final items = await _fetchPage(_initialPageKey);

        if (operation != _currentOperation) return; // Cancelled

        if (items.isEmpty) {
          value = PaginationState<K, T>(
            items: [],
            pageKey: _initialPageKey,
            status: PaginationStatus.empty,
            hasMorePages: false,
          );
        } else {
          final isLastPage =
              _config.pageSize != null && items.length < _config.pageSize!;
          if (!isLastPage) {
            _nextPageKey = _nextPageKeyBuilder(_initialPageKey, items);
          }
          value = PaginationState<K, T>(
            items: items,
            pageKey: _initialPageKey,
            status: isLastPage
                ? PaginationStatus.completed
                : PaginationStatus.loaded,
            hasMorePages: !isLastPage,
          );
        }
        return; // Success – exit loop
      } catch (error) {
        if (operation != _currentOperation) return; // Cancelled

        // Check if we should retry
        if (retryPolicy != null &&
            retryPolicy.retryFirstPage &&
            attempt < retryPolicy.maxRetries &&
            retryPolicy.shouldRetry(error)) {
          attempt++;
          value = value.copyWith(retryCount: attempt);

          final delay = retryPolicy.delayForAttempt(attempt - 1);
          final shouldContinue = await _waitForRetry(delay, operation);
          if (!shouldContinue) return; // Cancelled during wait
          continue; // Retry
        }

        value = value.copyWith(
          status: PaginationStatus.firstPageError,
          error: error,
        );

        // Rethrow non-Exception errors (programming errors)
        if (error is! Exception) rethrow;
        return;
      }
    }
  }

  /// Loads the next page.
  ///
  /// Does nothing if:
  /// - Already loading
  /// - No more pages available
  /// - In an error or empty state that can't load more
  ///
  /// If a [RetryPolicy] is configured, failed load-more operations will be
  /// retried automatically with exponential backoff.
  Future<void> loadNextPage() async {
    if (!value.status.canLoadMore || !value.hasMorePages) return;

    _cancelRetryTimer();
    final operation = _currentOperation = Object();
    final pageKey = _nextPageKey;

    value = value.copyWith(
      status: PaginationStatus.loadingMore,
      clearError: true,
      retryCount: 0,
    );

    final retryPolicy = _config.retryPolicy;
    var attempt = 0;

    while (true) {
      try {
        final newItems = await _fetchPage(pageKey);

        if (operation != _currentOperation) return; // Cancelled

        if (newItems.isEmpty) {
          value = value.copyWith(
            pageKey: pageKey,
            status: PaginationStatus.completed,
            hasMorePages: false,
          );
        } else {
          final isLastPage =
              _config.pageSize != null && newItems.length < _config.pageSize!;
          if (!isLastPage) {
            _nextPageKey = _nextPageKeyBuilder(pageKey, newItems);
          }
          value = value.copyWith(
            items: [...value.items, ...newItems],
            pageKey: pageKey,
            status: isLastPage
                ? PaginationStatus.completed
                : PaginationStatus.loaded,
            hasMorePages: !isLastPage,
          );
        }
        return; // Success – exit loop
      } catch (error) {
        if (operation != _currentOperation) return; // Cancelled

        // Check if we should retry
        if (retryPolicy != null &&
            attempt < retryPolicy.maxRetries &&
            retryPolicy.shouldRetry(error)) {
          attempt++;
          value = value.copyWith(retryCount: attempt);

          final delay = retryPolicy.delayForAttempt(attempt - 1);
          final shouldContinue = await _waitForRetry(delay, operation);
          if (!shouldContinue) return; // Cancelled during wait
          continue; // Retry
        }

        value = value.copyWith(
          status: PaginationStatus.loadMoreError,
          error: error,
        );

        // Rethrow non-Exception errors (programming errors)
        if (error is! Exception) rethrow;
        return;
      }
    }
  }

  /// Refreshes the list by reloading from the first page.
  ///
  /// This clears all existing items and starts fresh.
  Future<void> refresh() async {
    _cancelRetryTimer();
    _currentOperation = null; // Cancel any ongoing operation
    _nextPageKey = _initialPageKey;

    value = value.copyWith(
      status: PaginationStatus.refreshing,
      clearError: true,
    );

    final operation = _currentOperation = Object();

    try {
      final items = await _fetchPage(_initialPageKey);

      if (operation != _currentOperation) return; // Cancelled

      if (items.isEmpty) {
        value = PaginationState<K, T>(
          items: [],
          pageKey: _initialPageKey,
          status: PaginationStatus.empty,
          hasMorePages: false,
        );
      } else {
        final isLastPage =
            _config.pageSize != null && items.length < _config.pageSize!;
        if (!isLastPage) {
          _nextPageKey = _nextPageKeyBuilder(_initialPageKey, items);
        }
        value = PaginationState<K, T>(
          items: items,
          pageKey: _initialPageKey,
          status: isLastPage
              ? PaginationStatus.completed
              : PaginationStatus.loaded,
          hasMorePages: !isLastPage,
        );
      }
    } catch (error) {
      if (operation != _currentOperation) return; // Cancelled

      value = value.copyWith(
        status: PaginationStatus.firstPageError,
        error: error,
      );

      // Rethrow non-Exception errors (programming errors)
      if (error is! Exception) rethrow;
    }
  }

  /// Retries the last failed operation.
  Future<void> retry() async {
    if (value.status == PaginationStatus.firstPageError) {
      return loadFirstPage();
    } else if (value.status == PaginationStatus.loadMoreError) {
      return loadNextPage();
    }
  }

  /// Replaces the fetch function and automatically resets + reloads.
  ///
  /// Use this for search/filter scenarios where the data source changes.
  /// The controller cancels any ongoing operation, resets state, and
  /// loads the first page with the new fetch function.
  ///
  /// ```dart
  /// // Update search query
  /// controller.updateFetchPage(
  ///   (page) => api.searchUsers(page: page, query: 'john'),
  /// );
  /// ```
  Future<void> updateFetchPage(FetchPage<K, T> newFetchPage) async {
    _fetchPage = newFetchPage;
    _currentOperation = null; // Cancel ongoing
    _nextPageKey = _initialPageKey;
    value = PaginationState<K, T>();
    return loadFirstPage();
  }

  /// Sets the total number of items available.
  ///
  /// Call this when your API provides a total count in the response.
  /// Automatically adjusts [hasMorePages] and transitions to
  /// [PaginationStatus.completed] when all items have been loaded.
  ///
  /// ```dart
  /// PaginationListView<int, User>.withController(
  ///   controller: controller,
  ///   onPageLoaded: (page, items) {
  ///     controller.setTotalItems(apiTotalFromResponse);
  ///   },
  ///   itemBuilder: (context, user, index) => UserTile(user: user),
  /// )
  /// ```
  void setTotalItems(int total) {
    final allLoaded = value.items.length >= total;
    value = value.copyWith(
      totalItems: total,
      hasMorePages: !allLoaded,
      status: allLoaded && value.status == PaginationStatus.loaded
          ? PaginationStatus.completed
          : null,
    );
  }

  /// Resets the controller to initial state.
  void reset() {
    _cancelRetryTimer();
    _currentOperation = null;
    _nextPageKey = _initialPageKey;
    value = PaginationState<K, T>();
  }

  /// Updates items using a mapper function.
  ///
  /// Useful for updating specific items without refetching.
  void updateItems(T Function(T item) mapper) {
    value = value.copyWith(
      items: value.items.map(mapper).toList(),
    );
  }

  /// Removes items matching a predicate.
  void removeWhere(bool Function(T item) predicate) {
    final newItems = value.items.where((item) => !predicate(item)).toList();
    value = value.copyWith(
      items: newItems,
      status: newItems.isEmpty ? PaginationStatus.empty : value.status,
    );
  }

  /// Inserts an item at the specified index.
  void insertItem(int index, T item) {
    final newItems = List<T>.from(value.items);
    newItems.insert(index.clamp(0, newItems.length), item);
    value = value.copyWith(items: newItems);
  }

  /// Removes an item at the specified index.
  void removeItemAt(int index) {
    if (index < 0 || index >= value.items.length) return;
    final newItems = List<T>.from(value.items)..removeAt(index);
    value = value.copyWith(
      items: newItems,
      status: newItems.isEmpty ? PaginationStatus.empty : value.status,
    );
  }

  /// Updates a single item at the specified index.
  void updateItemAt(int index, T item) {
    if (index < 0 || index >= value.items.length) return;
    final newItems = List<T>.from(value.items);
    newItems[index] = item;
    value = value.copyWith(items: newItems);
  }

  @override
  void dispose() {
    _cancelRetryTimer();
    _currentOperation = null;
    super.dispose();
  }
}
