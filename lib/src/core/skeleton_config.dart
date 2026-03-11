/// Configuration for automatic skeleton/shimmer placeholder loading.
library;

import 'package:flutter/material.dart';

/// Configures the appearance and behaviour of the auto-generated skeleton
/// placeholders shown while the first page (or more items) is loading.
///
/// Pass a [SkeletonConfig] to any paginated widget's `skeletonConfig`
/// parameter (alongside a `placeholderItem`) to customise the skeleton:
///
/// ```dart
/// PagedListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => UserTile(user: user),
///   placeholderItem: User.placeholder(),
///   skeletonConfig: const SkeletonConfig(
///     borderRadius: BorderRadius.all(Radius.circular(12)),
///     overlayColor: Colors.blueGrey,
///     shimmerDuration: Duration(milliseconds: 2000),
///   ),
/// )
/// ```
@immutable
class SkeletonConfig {
  /// Creates a skeleton configuration.
  ///
  /// All parameters are optional and fall back to sensible defaults.
  const SkeletonConfig({
    this.overlayColor,
    this.borderRadius = const BorderRadius.all(Radius.circular(8)),
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  /// Base colour used for the skeleton shapes.
  ///
  /// Defaults to `Colors.grey.shade700` in dark mode and
  /// `Colors.grey.shade300` in light mode.
  final Color? overlayColor;

  /// Border radius applied to each skeleton placeholder item via
  /// [ClipRRect].
  ///
  /// Defaults to `BorderRadius.all(Radius.circular(8))`.
  /// Set to [BorderRadius.zero] for sharp corners.
  final BorderRadius borderRadius;

  /// Duration of one full shimmer animation sweep.
  ///
  /// Defaults to 1500 ms.
  final Duration shimmerDuration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SkeletonConfig &&
          runtimeType == other.runtimeType &&
          overlayColor == other.overlayColor &&
          borderRadius == other.borderRadius &&
          shimmerDuration == other.shimmerDuration;

  @override
  int get hashCode => Object.hash(overlayColor, borderRadius, shimmerDuration);

  @override
  String toString() =>
      'SkeletonConfig(overlayColor: $overlayColor, '
      'borderRadius: $borderRadius, '
      'shimmerDuration: $shimmerDuration)';
}
