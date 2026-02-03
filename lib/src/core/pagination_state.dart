/// Pagination state management
library;

import 'package:flutter/foundation.dart';
import 'pagination_status.dart';

/// Immutable state object for pagination.
///
/// Contains all the state needed to render a paginated list:
/// - [items]: The list of loaded items
/// - [currentPage]: The current page number (1-indexed)
/// - [status]: The current pagination status
/// - [error]: The last error that occurred (if any)
@immutable
class PaginationState<T> {
  /// Creates a new pagination state.
  const PaginationState({
    List<T>? items,
    this.currentPage = 0,
    this.status = PaginationStatus.initial,
    this.error,
    this.hasMorePages = true,
  }) : items = items ?? const [];

  /// The list of loaded items.
  final List<T> items;

  /// The current page number (1-indexed, 0 means no page loaded yet).
  final int currentPage;

  /// The current pagination status.
  final PaginationStatus status;

  /// The last error that occurred, or null if no error.
  final Object? error;

  /// Whether there are more pages to load.
  final bool hasMorePages;

  /// Creates a copy of this state with the given fields replaced.
  PaginationState<T> copyWith({
    List<T>? items,
    int? currentPage,
    PaginationStatus? status,
    Object? error,
    bool? hasMorePages,
    bool clearError = false,
  }) {
    return PaginationState<T>(
      items: items ?? this.items,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      hasMorePages: hasMorePages ?? this.hasMorePages,
    );
  }

  /// Resets the state to initial values.
  PaginationState<T> reset() => PaginationState<T>();

  /// The total number of items loaded.
  int get itemCount => items.length;

  /// Whether the list is empty.
  bool get isEmpty => items.isEmpty;

  /// Whether the list has items.
  bool get isNotEmpty => items.isNotEmpty;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationState<T> &&
        listEquals(other.items, items) &&
        other.currentPage == currentPage &&
        other.status == status &&
        other.error == error &&
        other.hasMorePages == hasMorePages;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(items),
        currentPage,
        status,
        error,
        hasMorePages,
      );

  @override
  String toString() {
    return 'PaginationState('
        'itemCount: ${items.length}, '
        'currentPage: $currentPage, '
        'status: $status, '
        'hasMorePages: $hasMorePages, '
        'error: $error)';
  }
}
