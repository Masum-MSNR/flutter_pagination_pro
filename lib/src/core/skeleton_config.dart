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
    this.shimmerDuration = const Duration(milliseconds: 1500),
  });

  /// Base colour used for the skeleton shapes.
  ///
  /// If the colour has an alpha channel (semi-transparent), it is
  /// automatically made fully opaque internally so that the skeleton
  /// shapes are solid and the original content is completely hidden.
  ///
  /// Defaults to `Colors.grey.shade700` in dark mode and
  /// `Colors.grey.shade300` in light mode.
  final Color? overlayColor;

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
          shimmerDuration == other.shimmerDuration;

  @override
  int get hashCode => Object.hash(overlayColor, shimmerDuration);

  @override
  String toString() =>
      'SkeletonConfig(overlayColor: $overlayColor, '
      'shimmerDuration: $shimmerDuration)';
}
