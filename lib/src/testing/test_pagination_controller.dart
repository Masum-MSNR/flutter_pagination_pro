/// Test factory extension for PaginationController.
library;

import '../core/pagination_controller.dart';
import '../core/pagination_state.dart';
import '../core/pagination_status.dart';

/// Extends [PaginationController] with a test-only factory.
///
/// This creates a pre-seeded controller that skips async fetching,
/// making widget tests fast and deterministic.
///
/// ```dart
/// import 'package:flutter_pagination_pro/testing.dart';
///
/// final controller = PaginationController<int, User>.test(
///   items: [User('Alice'), User('Bob')],
///   status: PaginationStatus.loaded,
///   currentPageKey: 1,
/// );
/// ```
extension TestPaginationControllerExtension<K, T>
    on PaginationController<K, T> {
  // Extension cannot add factories, so we expose a static helper.
}

/// Creates a [PaginationController] pre-populated with a known state,
/// ideal for widget tests.
///
/// No network calls are made — the controller starts with the given
/// [items], [status], and [currentPageKey].
///
/// ```dart
/// final controller = testPaginationController<int, String>(
///   items: ['a', 'b', 'c'],
///   status: PaginationStatus.loaded,
///   currentPageKey: 1,
/// );
/// ```
PaginationController<K, T> testPaginationController<K, T>({
  List<T> items = const [],
  PaginationStatus status = PaginationStatus.loaded,
  K? currentPageKey,
  bool hasMorePages = true,
  Object? error,
  int? totalItems,
}) {
  final controller = PaginationController<K, T>(
    fetchPage: (_) async => <T>[],
    initialPageKey: currentPageKey,
    // Provide a no-op nextPageKeyBuilder for non-int key types
    nextPageKeyBuilder: K == int ? null : (key, _) => key,
  );

  controller.value = PaginationState<K, T>(
    items: items,
    pageKey: currentPageKey,
    status: status,
    hasMorePages: hasMorePages,
    error: error,
    totalItems: totalItems,
  );

  return controller;
}
