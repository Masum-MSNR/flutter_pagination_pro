/// Default loading indicator widgets
library;

import 'package:flutter/material.dart';
import '../core/skeleton_config.dart';
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
    SkeletonConfig? config,
    IndexedWidgetBuilder? separatorBuilder,
    EdgeInsetsGeometry? padding,
    Axis scrollDirection = Axis.vertical,
  }) {
    final effectiveConfig = config ??
        (overlayColor != null
            ? SkeletonConfig(overlayColor: overlayColor)
            : null);
    return DefaultFirstPageLoading.builder(
      key: key,
      itemCount: itemCount,
      separatorBuilder: separatorBuilder,
      padding: padding,
      scrollDirection: scrollDirection,
      itemBuilder: (context, index) => skeletonize(
        context,
        itemBuilder(context, placeholderItem, index),
        config: effectiveConfig,
      ),
    );
  }

  /// Wraps [child] in an animated shimmer skeleton effect that turns every
  /// element into a solid rectangular block with an animated shimmer sweep.
  ///
  /// How it works:
  /// 1. **Transparent backgrounds** — Card, ListTile, and Material surface
  ///    colours are overridden to transparent so only content remains.
  /// 2. **Text → solid bars** — Every [TextTheme] style gets
  ///    `backgroundColor` set to the base colour and `color` set to
  ///    transparent, so each text span renders as a solid filled rectangle
  ///    matching the text's exact bounding box.
  /// 3. **Solid fill** — `ColorFiltered(srcATop)` unifies all remaining
  ///    visible pixels (icons, containers, avatars) into the base colour.
  /// 4. **Animated shimmer** — `ShaderMask` sweeps a highlight gradient
  ///    across those solid shapes.
  ///
  /// The result: text → solid bar, avatar → solid rectangle,
  /// chip → solid pill, icon → solid shape — all with shimmer animation.
  /// Matches the look of a hand-crafted skeleton without writing one.
  ///
  /// [overlayColor] sets the base skeleton colour.
  /// Defaults to `Colors.grey.shade700` in dark, `Colors.grey.shade300`
  /// in light mode.
  static Widget skeletonize(
    BuildContext context,
    Widget child, {
    Color? overlayColor,
    SkeletonConfig? config,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveConfig = config ??
        (overlayColor != null
            ? SkeletonConfig(overlayColor: overlayColor)
            : const SkeletonConfig());
    // Always force opaque so ColorFiltered fully replaces all pixels.
    // Semi-transparent overlay would let original content bleed through.
    final rawColor = effectiveConfig.overlayColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade300);
    final baseColor = rawColor.withAlpha(255);

    final radius = effectiveConfig.borderRadius;
    final skeletonTextTheme =
        _toSkeletonTextTheme(theme.textTheme, baseColor, radius);

    return Theme(
      data: theme.copyWith(
        textTheme: skeletonTextTheme,
        primaryTextTheme:
            _toSkeletonTextTheme(theme.primaryTextTheme, baseColor, radius),
        cardTheme: theme.cardTheme.copyWith(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          tileColor: Colors.transparent,
        ),
        iconTheme: theme.iconTheme.copyWith(color: baseColor),
      ),
      child: DefaultTextStyle.merge(
        style: radius > 0
            ? TextStyle(
                color: Colors.transparent,
                decorationColor: Colors.transparent,
                background: Paint()
                  ..color = baseColor
                  ..maskFilter =
                      MaskFilter.blur(BlurStyle.solid, radius * 0.5),
              )
            : TextStyle(
                color: Colors.transparent,
                backgroundColor: baseColor,
                decorationColor: Colors.transparent,
              ),
        child: _SkeletonShimmer(
          baseColor: baseColor,
          duration: effectiveConfig.shimmerDuration,
          child: ColorFiltered(
            colorFilter: ColorFilter.mode(baseColor, BlendMode.srcATop),
            child: IgnorePointer(child: child),
          ),
        ),
      ),
    );
  }

  /// Converts a [TextTheme] so every style renders as a rounded solid bar.
  ///
  /// When [borderRadius] > 0, uses [BlurStyle.solid] mask-filter so the
  /// interior stays fully opaque while only the outer edge is softened —
  /// visually identical to CSS `border-radius`. When [borderRadius] is 0
  /// the plain [backgroundColor] path is used for sharp rectangles.
  static TextTheme _toSkeletonTextTheme(
    TextTheme t,
    Color color,
    double borderRadius,
  ) {
    TextStyle? s(TextStyle? style) {
      if (style == null) return null;
      if (borderRadius > 0) {
        // BlurStyle.solid keeps the fill fully opaque inside the original
        // rectangle and only softens the outer edge, giving each text bar
        // rounded-looking corners without any visible blur on the content.
        final sigma = borderRadius * 0.5;
        return style.copyWith(
          color: Colors.transparent,
          decorationColor: Colors.transparent,
          background: Paint()
            ..color = color
            ..maskFilter = MaskFilter.blur(BlurStyle.solid, sigma),
        );
      }
      return style.copyWith(
        color: Colors.transparent,
        backgroundColor: color,
        decorationColor: Colors.transparent,
      );
    }

    return TextTheme(
      displayLarge: s(t.displayLarge),
      displayMedium: s(t.displayMedium),
      displaySmall: s(t.displaySmall),
      headlineLarge: s(t.headlineLarge),
      headlineMedium: s(t.headlineMedium),
      headlineSmall: s(t.headlineSmall),
      titleLarge: s(t.titleLarge),
      titleMedium: s(t.titleMedium),
      titleSmall: s(t.titleSmall),
      bodyLarge: s(t.bodyLarge),
      bodyMedium: s(t.bodyMedium),
      bodySmall: s(t.bodySmall),
      labelLarge: s(t.labelLarge),
      labelMedium: s(t.labelMedium),
      labelSmall: s(t.labelSmall),
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
    this.duration = const Duration(milliseconds: 1500),
  });

  final Color baseColor;
  final Duration duration;
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
      duration: widget.duration,
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
