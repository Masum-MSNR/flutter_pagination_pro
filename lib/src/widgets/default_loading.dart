/// Default loading indicator widgets
library;

import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../core/typedefs.dart';

/// Default loading indicator for first page loading.
///
/// Shows a centered [CircularProgressIndicator].
///
/// Use the [DefaultFirstPageLoading.builder] constructor to show
/// skeleton / shimmer placeholder items instead of a spinner:
///
/// ```dart
/// PaginationListView<User>(
///   fetchPage: (page) => api.getUsers(page: page),
///   itemBuilder: (context, user, index) => UserTile(user: user),
///   firstPageLoadingBuilder: (context) => DefaultFirstPageLoading.builder(
///     itemBuilder: (context, index) => const ShimmerUserTile(),
///     itemCount: 10,
///   ),
/// )
/// ```
class DefaultFirstPageLoading extends StatelessWidget {
  /// Shows a centered [CircularProgressIndicator].
  const DefaultFirstPageLoading({super.key})
      : _itemBuilder = null,
        _itemCount = 0,
        _separatorBuilder = null,
        _padding = null,
        _scrollDirection = Axis.vertical;

  /// Creates a skeleton / shimmer placeholder list.
  ///
  /// [itemBuilder] builds each placeholder widget (e.g. a shimmer tile).
  /// [itemCount] is the number of placeholders to show (default 6).
  /// [separatorBuilder] optionally adds separators between placeholders.
  /// [padding] is the padding around the list.
  /// [scrollDirection] is the scroll direction of the list.
  const DefaultFirstPageLoading.builder({
    super.key,
    required IndexedWidgetBuilder itemBuilder,
    int itemCount = 6,
    IndexedWidgetBuilder? separatorBuilder,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
  })  : assert(itemCount > 0, 'itemCount must be > 0'),
        _itemBuilder = itemBuilder,
        _itemCount = itemCount,
        _separatorBuilder = separatorBuilder,
        _padding = padding,
        _scrollDirection = scrollDirection;

  final IndexedWidgetBuilder? _itemBuilder;
  final int _itemCount;
  final IndexedWidgetBuilder? _separatorBuilder;
  final EdgeInsetsGeometry? _padding;
  final Axis _scrollDirection;

  /// Creates a skeleton placeholder from the **real** [itemBuilder]
  /// by rendering it with a [placeholderItem] and automatically converting
  /// it into animated shimmer skeleton shapes.
  ///
  /// This lets you reuse your existing item widget without building a
  /// separate skeleton widget — just provide a dummy instance of `T`:
  ///
  /// ```dart
  /// PagedListView<User>(
  ///   fetchPage: (page) => api.getUsers(page: page),
  ///   itemBuilder: (context, user, index) => UserTile(user: user),
  ///   firstPageLoadingBuilder: (context) =>
  ///       DefaultFirstPageLoading.fromItemBuilder<User>(
  ///     itemBuilder: (context, user, index) => UserTile(user: user),
  ///     placeholderItem: User(name: '', email: ''),
  ///     itemCount: 8,
  ///   ),
  /// )
  /// ```
  ///
  /// Background surfaces (Card, ListTile) are made transparent so only
  /// visible content remains. A Gaussian blur merges text characters into
  /// solid bars, and an animated shimmer gradient sweeps across the shapes.
  ///
  /// [overlayColor] sets the base skeleton colour. Defaults to a
  /// theme-appropriate grey.
  static Widget fromItemBuilder<T>({
    Key? key,
    required ItemBuilder<T> itemBuilder,
    required T placeholderItem,
    int itemCount = 6,
    Color? overlayColor,
    IndexedWidgetBuilder? separatorBuilder,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
  }) {
    return DefaultFirstPageLoading.builder(
      key: key,
      itemCount: itemCount,
      separatorBuilder: separatorBuilder,
      padding: padding,
      scrollDirection: scrollDirection,
      itemBuilder: (context, index) => skeletonize(
        context,
        itemBuilder(context, placeholderItem, index),
        overlayColor: overlayColor,
      ),
    );
  }

  /// Wraps [child] in an animated shimmer skeleton effect.
  ///
  /// How it works:
  /// 1. **Transparent backgrounds** — Card, ListTile, and Material surface
  ///    colours are overridden to transparent so only visible content
  ///    (text, icons, coloured containers) remains.
  /// 2. **Gaussian blur** (σ = 4) — merges individual text characters into
  ///    solid rectangular bands.
  /// 3. **Animated shimmer** — a `ShaderMask` with a sliding
  ///    `LinearGradient` sweeps a highlight band across the shapes,
  ///    using `BlendMode.srcATop` so only non-transparent pixels show.
  ///
  /// The result automatically mirrors the real widget's layout with an
  /// animated shimmer: avatars → rounded rectangles, titles → bars,
  /// chips → pills.
  ///
  /// [overlayColor] sets the base skeleton colour.
  /// Defaults to `Colors.grey.shade700` in dark, `Colors.grey.shade300`
  /// in light mode.
  static Widget skeletonize(
    BuildContext context,
    Widget child, {
    Color? overlayColor,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final baseColor = overlayColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade300);

    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          tileColor: Colors.transparent,
        ),
      ),
      child: ClipRect(
        child: _SkeletonShimmer(
          baseColor: baseColor,
          child: ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 4, sigmaY: 4),
            child: IgnorePointer(child: child),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_itemBuilder == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator.adaptive(),
        ),
      );
    }

    final hasSeparator = _separatorBuilder != null;
    final totalCount = hasSeparator && _itemCount > 0
        ? _itemCount * 2 - 1
        : _itemCount;

    return ListView.builder(
      padding: _padding,
      physics: const NeverScrollableScrollPhysics(),
      scrollDirection: _scrollDirection,
      itemCount: totalCount,
      itemBuilder: (context, index) {
        if (hasSeparator) {
          if (index.isOdd) return _separatorBuilder!(context, index ~/ 2);
          return _itemBuilder!(context, index ~/ 2);
        }
        return _itemBuilder!(context, index);
      },
    );
  }
}

/// Default loading indicator for loading more items.
///
/// Shows a smaller centered indicator at the bottom of the list.
class DefaultLoadMoreLoading extends StatelessWidget {
  const DefaultLoadMoreLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 16.0),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
        ),
      ),
    );
  }
}

/// Animated shimmer that sweeps a highlight gradient across [child].
///
/// Uses [ShaderMask] with [BlendMode.srcATop] so the gradient only paints
/// on non-transparent pixels — producing the skeleton shimmer effect.
class _SkeletonShimmer extends StatefulWidget {
  const _SkeletonShimmer({
    required this.baseColor,
    required this.child,
  });

  final Color baseColor;
  final Widget child;

  @override
  State<_SkeletonShimmer> createState() => _SkeletonShimmerState();
}

class _SkeletonShimmerState extends State<_SkeletonShimmer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final highlightColor = Color.lerp(
      widget.baseColor,
      isDark ? Colors.grey.shade500 : Colors.white,
      0.4,
    )!;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              colors: [
                widget.baseColor,
                highlightColor,
                widget.baseColor,
              ],
              stops: const [0.35, 0.5, 0.65],
              begin: const Alignment(-1, 0),
              end: const Alignment(1, 0),
              transform: _SlidingGradientTransform(
                slidePercent: _controller.value,
              ),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Translates a gradient by [slidePercent] × 2 × bounds.width so the
/// highlight band sweeps from off-screen left to off-screen right.
class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(
      bounds.width * (slidePercent * 2 - 1),
      0,
      0,
    );
  }
}
