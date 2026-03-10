/// Bidirectional pagination state
library;

import 'package:flutter/foundation.dart';
import 'pagination_status.dart';

/// Immutable state for bidirectional (two-way) pagination.
///
/// Tracks items and loading state for both **forward** (append/newer)
/// and **backward** (prepend/older) directions independently.
///
/// Items are split into two lists:
/// - [backwardItems]: Items loaded going backward (oldest → most recent)
/// - [forwardItems]: Items from the initial page onward (oldest → newest)
///
/// Use [items] to get the complete list in display order
/// (backward oldest → forward newest).
///
/// ```dart
/// // Display order (top to bottom):
/// //   backwardItems[0]     ← oldest loaded item
/// //   backwardItems[1]
/// //   ...
/// //   backwardItems[last]  ← most recent backward item
/// //   forwardItems[0]      ← initial page start
/// //   ...
/// //   forwardItems[last]   ← newest loaded item
/// ```
@immutable
class BidirectionalPaginationState<K, T> {
  /// Creates a new bidirectional pagination state.
  const BidirectionalPaginationState({
    List<T>? forwardItems,
    List<T>? backwardItems,
    this.status = PaginationStatus.initial,
    this.error,
    this.isLoadingForward = false,
    this.isLoadingBackward = false,
    this.hasMoreForward = true,
    this.hasMoreBackward = true,
    this.forwardError,
    this.backwardError,
  })  : forwardItems = forwardItems ?? const [],
        backwardItems = backwardItems ?? const [];

  /// Items from the initial page onward (forward/append direction).
  final List<T> forwardItems;

  /// Items loaded going backward (prepend direction), in display order.
  ///
  /// `backwardItems[0]` is the oldest, `backwardItems.last` is closest
  /// to the initial page.
  final List<T> backwardItems;

  /// Overall lifecycle status.
  ///
  /// Tracks the initial load phase:
  /// - [PaginationStatus.initial]: not yet loaded
  /// - [PaginationStatus.loadingFirstPage]: loading anchor page
  /// - [PaginationStatus.loaded]: at least one page loaded
  /// - [PaginationStatus.empty]: anchor page returned no items
  /// - [PaginationStatus.firstPageError]: anchor page failed
  /// - [PaginationStatus.refreshing]: reloading from anchor
  final PaginationStatus status;

  /// Error from the initial page load, or null.
  final Object? error;

  /// Whether the forward (append) direction is currently loading.
  final bool isLoadingForward;

  /// Whether more pages are available in the forward direction.
  final bool hasMoreForward;

  /// Error from the last forward load attempt, or null.
  final Object? forwardError;

  /// Whether the backward (prepend) direction is currently loading.
  final bool isLoadingBackward;

  /// Whether more pages are available in the backward direction.
  final bool hasMoreBackward;

  /// Error from the last backward load attempt, or null.
  final Object? backwardError;

  /// All items in display order (backward oldest → forward newest).
  List<T> get items => [...backwardItems, ...forwardItems];

  /// Total item count across both directions.
  int get itemCount => backwardItems.length + forwardItems.length;

  /// Whether any items have been loaded.
  bool get isEmpty => itemCount == 0;

  /// Whether items exist.
  bool get isNotEmpty => itemCount > 0;

  /// Whether either direction is currently loading.
  bool get isLoading =>
      status.isLoading || isLoadingForward || isLoadingBackward;

  /// Whether the initial page has been loaded successfully.
  bool get isInitialized => status == PaginationStatus.loaded ||
      status == PaginationStatus.completed ||
      status == PaginationStatus.refreshing;

  /// Creates a copy with the given fields replaced.
  BidirectionalPaginationState<K, T> copyWith({
    List<T>? forwardItems,
    List<T>? backwardItems,
    PaginationStatus? status,
    Object? error,
    bool clearError = false,
    bool? isLoadingForward,
    bool? hasMoreForward,
    Object? forwardError,
    bool clearForwardError = false,
    bool? isLoadingBackward,
    bool? hasMoreBackward,
    Object? backwardError,
    bool clearBackwardError = false,
  }) {
    return BidirectionalPaginationState<K, T>(
      forwardItems: forwardItems ?? this.forwardItems,
      backwardItems: backwardItems ?? this.backwardItems,
      status: status ?? this.status,
      error: clearError ? null : (error ?? this.error),
      isLoadingForward: isLoadingForward ?? this.isLoadingForward,
      hasMoreForward: hasMoreForward ?? this.hasMoreForward,
      forwardError:
          clearForwardError ? null : (forwardError ?? this.forwardError),
      isLoadingBackward: isLoadingBackward ?? this.isLoadingBackward,
      hasMoreBackward: hasMoreBackward ?? this.hasMoreBackward,
      backwardError:
          clearBackwardError ? null : (backwardError ?? this.backwardError),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BidirectionalPaginationState<K, T> &&
        listEquals(other.forwardItems, forwardItems) &&
        listEquals(other.backwardItems, backwardItems) &&
        other.status == status &&
        other.error == error &&
        other.isLoadingForward == isLoadingForward &&
        other.hasMoreForward == hasMoreForward &&
        other.forwardError == forwardError &&
        other.isLoadingBackward == isLoadingBackward &&
        other.hasMoreBackward == hasMoreBackward &&
        other.backwardError == backwardError;
  }

  @override
  int get hashCode => Object.hash(
        Object.hashAll(forwardItems),
        Object.hashAll(backwardItems),
        status,
        error,
        isLoadingForward,
        hasMoreForward,
        forwardError,
        isLoadingBackward,
        hasMoreBackward,
        backwardError,
      );

  @override
  String toString() =>
      'BidirectionalPaginationState(forward: ${forwardItems.length}, '
      'backward: ${backwardItems.length}, status: $status, '
      'loadingFwd: $isLoadingForward, loadingBwd: $isLoadingBackward, '
      'moreFwd: $hasMoreForward, moreBwd: $hasMoreBackward)';
}
