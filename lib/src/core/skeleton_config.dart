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

  /// Base colour used for the skeleton shapes.
  ///
  /// If the colour has an alpha channel (semi-transparent), it is
  /// automatically made fully opaque internally so that the skeleton
  /// shapes are solid and the original content is completely hidden.
  ///
  /// Defaults to `Colors.grey.shade700` in dark mode and
  /// `Colors.grey.shade300` in light mode.
  final Color? overlayColor;

  /// Corner radius applied to skeleton text bars.
  ///
  /// Each text span's bounding-box gets softened edges that look
  /// like rounded corners. Containers that already have their own
  /// [BorderRadius] (avatars, chips, etc.) keep their original shape.
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
  String toString() =>
      'SkeletonConfig(overlayColor: $overlayColor, '
      'borderRadius: $borderRadius, '
      'shimmerDuration: $shimmerDuration)';
}
