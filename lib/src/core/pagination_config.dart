/// Pagination configuration
library;

import 'dart:math' show pow;

import 'package:flutter/foundation.dart' show immutable;

/// The type of pagination behavior.
enum PaginationType {
  /// Infinite scroll - automatically loads more when reaching the bottom.
  infiniteScroll,

  /// Load more button - requires user to tap a button to load more.
  loadMore,
}

/// Configuration for automatic retry behavior with exponential backoff.
///
/// When attached to a [PaginationConfig], the controller will automatically
/// retry failed fetches before settling into an error state.
///
/// ```dart
/// PaginationController<int, User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   config: PaginationConfig(
///     retryPolicy: RetryPolicy(
///       maxRetries: 3,
///       initialDelay: Duration(seconds: 1),
///       backoffMultiplier: 2.0, // 1s → 2s → 4s
///     ),
///   ),
/// );
/// ```
@immutable
class RetryPolicy {
  /// Creates a retry policy.
  ///
  /// [maxRetries] must be > 0 (default 3).
  /// [backoffMultiplier] must be >= 1.0 (default 2.0).
  /// [initialDelay] must be non-negative (default 1 second).
  const RetryPolicy({
    this.maxRetries = 3,
    this.initialDelay = const Duration(seconds: 1),
    this.backoffMultiplier = 2.0,
    this.retryOn,
    this.retryFirstPage = false,
  }) : assert(maxRetries > 0, 'maxRetries must be > 0'),
       assert(backoffMultiplier >= 1.0, 'backoffMultiplier must be >= 1.0');

  /// Maximum number of retry attempts before giving up.
  final int maxRetries;

  /// Delay before the first retry.
  final Duration initialDelay;

  /// Each subsequent retry delay is multiplied by this factor.
  ///
  /// For example, with [initialDelay] of 1s and [backoffMultiplier] of 2.0:
  /// retry 1 → 1s, retry 2 → 2s, retry 3 → 4s.
  final double backoffMultiplier;

  /// Optional predicate to filter which errors should be retried.
  ///
  /// If null, all errors are retried. If provided, only errors where
  /// `retryOn(error)` returns `true` will trigger a retry.
  final bool Function(Object error)? retryOn;

  /// Whether to also retry first-page errors.
  ///
  /// By default, only load-more errors are retried. Set to `true` to
  /// also auto-retry when the first page fails.
  final bool retryFirstPage;

  /// Calculates the delay for a given retry attempt (0-based).
  ///
  /// Uses true exponential backoff: `initialDelay * backoffMultiplier^attempt`.
  /// For example, with initialDelay=1s and backoffMultiplier=2.0:
  /// attempt 0 → 1s, attempt 1 → 2s, attempt 2 → 4s, attempt 3 → 8s.
  Duration delayForAttempt(int attempt) {
    final multiplier = pow(backoffMultiplier, attempt).toDouble();
    return Duration(
      milliseconds: (initialDelay.inMilliseconds * multiplier).round(),
    );
  }

  /// Whether the given error should be retried.
  bool shouldRetry(Object error) => retryOn?.call(error) ?? true;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RetryPolicy &&
        other.maxRetries == maxRetries &&
        other.initialDelay == initialDelay &&
        other.backoffMultiplier == backoffMultiplier &&
        other.retryFirstPage == retryFirstPage;
  }

  @override
  int get hashCode => Object.hash(
        maxRetries,
        initialDelay,
        backoffMultiplier,
        retryFirstPage,
      );

  @override
  String toString() =>
      'RetryPolicy(maxRetries: $maxRetries, initialDelay: $initialDelay, '
      'backoffMultiplier: $backoffMultiplier, retryFirstPage: $retryFirstPage)';
}

/// Configuration options for pagination behavior.
@immutable
class PaginationConfig {
  /// Creates a pagination configuration.
  ///
  /// [scrollThreshold] must be > 0 (default 200.0 pixels).
  /// [pageSize], when set, must be > 0.
  const PaginationConfig({
    this.scrollThreshold = 200.0,
    this.autoLoadFirstPage = true,
    this.pageSize,
    this.retryPolicy,
  })  : assert(scrollThreshold > 0, 'scrollThreshold must be > 0'),
        assert(
          pageSize == null || pageSize > 0,
          'pageSize must be > 0 when specified',
        );

  /// Distance in pixels from the bottom of the scrollable area that triggers
  /// loading the next page in infinite scroll mode.
  ///
  /// When the user scrolls to within this many pixels of the end,
  /// the next page will be automatically fetched.
  ///
  /// Default is 200.0 pixels.
  final double scrollThreshold;

  /// Whether to automatically load the first page when the widget is built.
  ///
  /// If false, you must manually call `controller.loadFirstPage()`.
  final bool autoLoadFirstPage;

  /// The expected number of items per page.
  ///
  /// When set, the controller automatically detects the last page by checking
  /// if the returned items count is less than [pageSize]. This eliminates
  /// phantom "loading more" indicators when the final page has fewer items.
  ///
  /// If `null` (default), the last page is only detected when an empty list
  /// is returned from the fetch function.
  final int? pageSize;

  /// Optional retry policy for automatic retry with exponential backoff.
  ///
  /// When set, the controller will automatically retry failed fetches
  /// (load-more by default, optionally first-page) before entering
  /// an error state.
  final RetryPolicy? retryPolicy;

  /// Default configuration.
  static const PaginationConfig defaults = PaginationConfig();

  /// Creates a copy with the given fields replaced.
  PaginationConfig copyWith({
    double? scrollThreshold,
    bool? autoLoadFirstPage,
    int? pageSize,
    RetryPolicy? retryPolicy,
  }) {
    return PaginationConfig(
      scrollThreshold: scrollThreshold ?? this.scrollThreshold,
      autoLoadFirstPage: autoLoadFirstPage ?? this.autoLoadFirstPage,
      pageSize: pageSize ?? this.pageSize,
      retryPolicy: retryPolicy ?? this.retryPolicy,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationConfig &&
        other.scrollThreshold == scrollThreshold &&
        other.autoLoadFirstPage == autoLoadFirstPage &&
        other.pageSize == pageSize &&
        other.retryPolicy == retryPolicy;
  }

  @override
  int get hashCode =>
      Object.hash(scrollThreshold, autoLoadFirstPage, pageSize, retryPolicy);

  @override
  String toString() =>
      'PaginationConfig(scrollThreshold: $scrollThreshold, '
      'autoLoadFirstPage: $autoLoadFirstPage, pageSize: $pageSize, '
      'retryPolicy: $retryPolicy)';
}
