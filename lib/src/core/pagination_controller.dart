/// Pagination controller
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'pagination_state.dart';
import 'pagination_status.dart';
import 'pagination_config.dart';
import 'typedefs.dart';

/// Controller for managing pagination state.
///
/// This controller handles:
/// - Fetching pages
/// - Managing state transitions
/// - Error handling
/// - Refresh and reset operations
///
/// Example:
/// ```dart
/// final controller = PaginationController<User>(
///   fetchPage: (page) => api.getUsers(page: page),
/// );
///
/// // Use in widget
/// PaginationListView<User>.withController(
///   controller: controller,
///   itemBuilder: (context, user, index) => UserTile(user: user),
/// )
///
/// // Programmatic control
/// controller.refresh();
/// controller.loadNextPage();
/// ```
class PaginationController<T> extends ValueNotifier<PaginationState<T>> {
  /// Creates a pagination controller.
  ///
  /// [fetchPage] is required and will be called to fetch each page.
  /// [config] provides pagination behavior settings.
  PaginationController({
    required FetchPage<T> fetchPage,
    PaginationConfig config = PaginationConfig.defaults,
  })  : _fetchPage = fetchPage,
        _config = config,
        super(PaginationState<T>());

  final FetchPage<T> _fetchPage;
  final PaginationConfig _config;

  /// Tracks the current async operation to handle cancellation.
  Object? _currentOperation;

  /// The current state.
  PaginationState<T> get state => value;

  /// The list of loaded items.
  List<T> get items => value.items;

  /// The current page number.
  int get currentPage => value.currentPage;

  /// The current status.
  PaginationStatus get status => value.status;

  /// Whether there are more pages to load.
  bool get hasMorePages => value.hasMorePages;

  /// Whether currently loading.
  bool get isLoading => value.status.isLoading;

  /// The configuration.
  PaginationConfig get config => _config;

  /// Loads the first page.
  ///
  /// This is typically called automatically when the widget is first built
  /// if [PaginationConfig.autoLoadFirstPage] is true.
  Future<void> loadFirstPage() async {
    if (value.status == PaginationStatus.loadingFirstPage) return;

    final operation = _currentOperation = Object();

    value = value.copyWith(
      status: PaginationStatus.loadingFirstPage,
      clearError: true,
    );

    try {
      final items = await _fetchPage(_config.initialPage);

      if (operation != _currentOperation) return; // Cancelled

      if (items.isEmpty) {
        value = PaginationState<T>(
          items: [],
          currentPage: _config.initialPage,
          status: PaginationStatus.empty,
          hasMorePages: false,
        );
      } else {
        value = PaginationState<T>(
          items: items,
          currentPage: _config.initialPage,
          status: PaginationStatus.loaded,
          hasMorePages: true,
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

  /// Loads the next page.
  ///
  /// Does nothing if:
  /// - Already loading
  /// - No more pages available
  /// - In an error or empty state that can't load more
  Future<void> loadNextPage() async {
    if (!value.status.canLoadMore || !value.hasMorePages) return;

    final operation = _currentOperation = Object();
    final nextPage = value.currentPage + 1;

    value = value.copyWith(
      status: PaginationStatus.loadingMore,
      clearError: true,
    );

    try {
      final newItems = await _fetchPage(nextPage);

      if (operation != _currentOperation) return; // Cancelled

      if (newItems.isEmpty) {
        value = value.copyWith(
          currentPage: nextPage,
          status: PaginationStatus.completed,
          hasMorePages: false,
        );
      } else {
        value = value.copyWith(
          items: [...value.items, ...newItems],
          currentPage: nextPage,
          status: PaginationStatus.loaded,
        );
      }
    } catch (error) {
      if (operation != _currentOperation) return; // Cancelled

      value = value.copyWith(
        status: PaginationStatus.loadMoreError,
        error: error,
      );

      // Rethrow non-Exception errors (programming errors)
      if (error is! Exception) rethrow;
    }
  }

  /// Refreshes the list by reloading from the first page.
  ///
  /// This clears all existing items and starts fresh.
  Future<void> refresh() async {
    _currentOperation = null; // Cancel any ongoing operation

    value = value.copyWith(
      status: PaginationStatus.refreshing,
      clearError: true,
    );

    final operation = _currentOperation = Object();

    try {
      final items = await _fetchPage(_config.initialPage);

      if (operation != _currentOperation) return; // Cancelled

      if (items.isEmpty) {
        value = PaginationState<T>(
          items: [],
          currentPage: _config.initialPage,
          status: PaginationStatus.empty,
          hasMorePages: false,
        );
      } else {
        value = PaginationState<T>(
          items: items,
          currentPage: _config.initialPage,
          status: PaginationStatus.loaded,
          hasMorePages: true,
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

  /// Resets the controller to initial state.
  void reset() {
    _currentOperation = null;
    value = PaginationState<T>();
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
    _currentOperation = null;
    super.dispose();
  }
}
