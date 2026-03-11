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
///     borderRadius: 6.0,
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
    this.borderRadius = 4.0,
    this.shimmerDuration = const Duration(milliseconds: 1500),
  }) : assert(borderRadius >= 0, 'borderRadius must be >= 0');

  /// Base colour for skeleton shapes.
  ///
  /// Made fully opaque internally. Defaults to a theme-appropriate grey.
  final Color? overlayColor;

  /// Corner radius applied to skeleton bones (text bars, containers).
  ///
  /// Containers that already have their own [BorderRadius]
  /// keep their original shape.
  ///
  /// Defaults to `4.0`. Set to `0` for sharp corners.
  final double borderRadius;

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
  String toString() => 'SkeletonConfig(overlayColor: $overlayColor, '
      'borderRadius: $borderRadius, '
      'shimmerDuration: $shimmerDuration)';
}
