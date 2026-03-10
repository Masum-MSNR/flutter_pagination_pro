/// Pagination state management
library;

import 'package:flutter/foundation.dart';
import 'pagination_status.dart';

/// Immutable state object for pagination.
///
/// Contains all the state needed to render a paginated list:
/// - [items]: The list of loaded items
/// - [pageKey]: The key of the last loaded page
/// - [status]: The current pagination status
/// - [error]: The last error that occurred (if any)
@immutable
class PaginationState<K, T> {
  /// Creates a new pagination state.
  const PaginationState({
    List<T>? items,
    this.pageKey,
    this.status = PaginationStatus.initial,
    this.error,
    this.hasMorePages = true,
    this.totalItems,
  }) : items = items ?? const [];

  /// The list of loaded items.
  final List<T> items;

  /// The key of the last loaded page, or null if no page has been loaded.
  ///
  /// For integer-based pagination, this is the page number (e.g. 1, 2, 3).
  /// For cursor-based APIs, this might be a cursor string or document snapshot.
  final K? pageKey;

  /// The current pagination status.
  final PaginationStatus status;

  /// The last error that occurred, or null if no error.
  final Object? error;

  /// Whether there are more pages to load.
  final bool hasMorePages;

  /// The total number of items available (from API metadata).
  ///
  /// This is `null` when the total is unknown. Set via
  /// [PaginationController.setTotalItems] when your API provides
  /// a total count in the response.
  final int? totalItems;

  /// Creates a copy of this state with the given fields replaced.
  PaginationState<K, T> copyWith({
    List<T>? items,
    K? pageKey,
    PaginationStatus? status,
    Object? error,
    bool? hasMorePages,
    bool clearError = false,
    int? totalItems,
  }) {
    return PaginationState<K, T>(
      items: items ?? this.items,
      pageKey: pageKey ?? this.pageKey,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      hasMorePages: hasMorePages ?? this.hasMorePages,
      totalItems: totalItems ?? this.totalItems,
    );
  }

  /// Resets the state to initial values.
  PaginationState<K, T> reset() => PaginationState<K, T>();

  /// The total number of items loaded.
  int get itemCount => items.length;

  /// Whether the list is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the list has items.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationState<K, T> &&
        listEquals(other.items, items) &&
        other.pageKey == pageKey &&
        other.status == status &&
        other.error == error &&
        other.hasMorePages == hasMorePages &&
        other.totalItems == totalItems;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        pageKey,
        status,
        error,
        hasMorePages,
        totalItems,
      );

  @override
  String toString() {
    return 'PaginationState('
        'itemCount: ${items.length}, '
        'pageKey: $pageKey, '
        'status: $status, '
        'hasMorePages: $hasMorePages, '
        'totalItems: $totalItems, '
        'error: $error)';
  }
}
