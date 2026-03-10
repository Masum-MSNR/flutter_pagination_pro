/// Testing utilities for `flutter_pagination_pro`.
///
/// Import this file in your test files (not in production code) to get
/// access to test helpers and custom matchers.
///
/// ```dart
/// import 'package:flutter_pagination_pro/testing.dart';
///
/// void main() {
///   test('controller starts loaded', () {
///     final controller = testPaginationController<int, String>(
///       items: ['a', 'b', 'c'],
///       status: PaginationStatus.loaded,
///       currentPageKey: 1,
///     );
///
///     expect(controller, hasItemCount(3));
///     expect(controller, isOnPage(1));
///     expect(controller, hasStatus(PaginationStatus.loaded));
///   });
/// }
/// ```
library;

export 'src/testing/test_pagination_controller.dart';
export 'src/testing/pagination_matchers.dart';
// Re-export core types users will need with matchers
export 'src/core/pagination_status.dart';
export 'src/core/pagination_controller.dart';
export 'src/core/pagination_state.dart';
