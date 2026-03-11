/// Custom matchers for [PaginationController] assertions in tests.
///
/// ```dart
/// import 'package:flutter_pagination_pro/testing.dart';
///
/// expect(controller, hasItemCount(3));
/// expect(controller, isOnPage(2));
/// expect(controller, hasStatus(PaginationStatus.loaded));
/// expect(controller, isPaginationCompleted);
/// ```
library;

import 'package:matcher/matcher.dart';
import '../core/pagination_controller.dart';
import '../core/pagination_status.dart';

/// Matches a [PaginationController] whose item list has exactly [count] items.
///
/// ```dart
/// expect(controller, hasItemCount(5));
/// ```
Matcher hasItemCount(int count) => _HasItemCount(count);

/// Matches a [PaginationController] whose [currentPageKey] equals [pageKey].
///
/// ```dart
/// expect(controller, isOnPage(2));
/// ```
Matcher isOnPage(Object? pageKey) => _IsOnPage(pageKey);

/// Matches a [PaginationController] whose status equals the given [status].
///
/// ```dart
/// expect(controller, hasStatus(PaginationStatus.loaded));
/// ```
Matcher hasStatus(PaginationStatus status) => _HasStatus(status);

/// Matches a [PaginationController] that has reached the end of pagination
/// (status is [PaginationStatus.completed] with no more pages).
///
/// ```dart
/// expect(controller, isPaginationCompleted);
/// ```
const Matcher isPaginationCompleted = _IsPaginationCompleted();

/// Matches a [PaginationController] that currently has an error.
///
/// When [error] is provided, also checks that the error matches.
///
/// ```dart
/// expect(controller, hasPaginationError());
/// expect(controller, hasPaginationError('Network error'));
/// ```
Matcher hasPaginationError([Object? error]) => _HasPaginationError(error);

/// Matches a [PaginationController] whose items list is empty.
///
/// ```dart
/// expect(controller, isPaginationEmpty);
/// ```
const Matcher isPaginationEmpty = _IsPaginationEmpty();

// ── Private matcher implementations ─────────────────────────────────────

class _HasItemCount extends Matcher {
  const _HasItemCount(this._expected);

  final int _expected;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      return item.items.length == _expected;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('PaginationController with $_expected items');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add('has ${item.items.length} items');
    }
    return mismatch.add('is not a PaginationController');
  }
}

class _IsOnPage extends Matcher {
  const _IsOnPage(this._expected);

  final Object? _expected;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      return item.currentPageKey == _expected;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('PaginationController on page $_expected');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add('is on page ${item.currentPageKey}');
    }
    return mismatch.add('is not a PaginationController');
  }
}

class _HasStatus extends Matcher {
  const _HasStatus(this._expected);

  final PaginationStatus _expected;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      return item.status == _expected;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('PaginationController with status $_expected');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add('has status ${item.status}');
    }
    return mismatch.add('is not a PaginationController');
  }
}

class _IsPaginationCompleted extends Matcher {
  const _IsPaginationCompleted();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      return item.status == PaginationStatus.completed && !item.hasMorePages;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('PaginationController that has completed pagination');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add(
        'has status ${item.status} '
        '(hasMorePages: ${item.hasMorePages})',
      );
    }
    return mismatch.add('is not a PaginationController');
  }
}

class _HasPaginationError extends Matcher {
  const _HasPaginationError(this._expectedError);

  final Object? _expectedError;

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      final hasError = item.status == PaginationStatus.firstPageError ||
          item.status == PaginationStatus.loadMoreError;
      if (!hasError) return false;
      if (_expectedError != null) {
        return item.state.error == _expectedError;
      }
      return true;
    }
    return false;
  }

  @override
  Description describe(Description description) {
    if (_expectedError != null) {
      return description.add(
        'PaginationController with error $_expectedError',
      );
    }
    return description.add('PaginationController with an error');
  }

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add(
        'has status ${item.status} '
        '(error: ${item.state.error})',
      );
    }
    return mismatch.add('is not a PaginationController');
  }
}

class _IsPaginationEmpty extends Matcher {
  const _IsPaginationEmpty();

  @override
  bool matches(Object? item, Map<dynamic, dynamic> matchState) {
    if (item is PaginationController) {
      return item.items.isEmpty && item.status == PaginationStatus.empty;
    }
    return false;
  }

  @override
  Description describe(Description description) =>
      description.add('PaginationController that is empty');

  @override
  Description describeMismatch(
    Object? item,
    Description mismatch,
    Map<dynamic, dynamic> matchState,
    bool verbose,
  ) {
    if (item is PaginationController) {
      return mismatch.add(
        'has ${item.items.length} items with status ${item.status}',
      );
    }
    return mismatch.add('is not a PaginationController');
  }
}
