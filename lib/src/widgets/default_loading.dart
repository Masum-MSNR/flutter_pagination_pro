/// Default loading indicator widgets
library;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
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

  /// Creates a skeleton from the real [itemBuilder] by rendering it with
  /// a [placeholderItem] and converting it into shimmer bones.
  ///
  /// ```dart
  /// DefaultFirstPageLoading.fromItemBuilder<User>(
  ///   itemBuilder: (context, user, index) => UserTile(user: user),
  ///   placeholderItem: User(name: '', email: ''),
  ///   itemCount: 8,
  /// )
  /// ```
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

  /// Converts [child] into an animated shimmer skeleton.
  ///
  /// The child is laid out but never painted. A custom render object
  /// walks the tree and draws rounded-rectangle bones where text and
  /// decorated containers appear, then a shimmer gradient sweeps across.
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
    final rawColor = effectiveConfig.overlayColor ??
        (isDark ? Colors.grey.shade700 : Colors.grey.shade300);
    final baseColor = rawColor.withAlpha(255);
    final radius = effectiveConfig.borderRadius;

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
      child: _SkeletonShimmer(
        baseColor: baseColor,
        duration: effectiveConfig.shimmerDuration,
        child: _SkeletonBoneLayer(
          baseColor: baseColor,
          borderRadius: radius,
          child: IgnorePointer(child: child),
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
    final totalCount =
        hasSeparator && _itemCount > 0 ? _itemCount * 2 - 1 : _itemCount;

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

/// Paints rounded-rectangle bones at every [RenderParagraph] and
/// visible [RenderDecoratedBox] in the child tree. The child is
/// laid out for positioning but never painted.
class _SkeletonBoneLayer extends SingleChildRenderObjectWidget {
  const _SkeletonBoneLayer({
    required super.child,
    required this.baseColor,
    required this.borderRadius,
  });

  final Color baseColor;
  final double borderRadius;

  @override
  _RenderSkeletonBones createRenderObject(BuildContext context) =>
      _RenderSkeletonBones(baseColor: baseColor, borderRadius: borderRadius);

  @override
  void updateRenderObject(
      BuildContext context, _RenderSkeletonBones renderObject) {
    renderObject
      ..baseColor = baseColor
      ..borderRadius = borderRadius;
  }
}

class _RenderSkeletonBones extends RenderProxyBox {
  _RenderSkeletonBones({
    required Color baseColor,
    required double borderRadius,
  })  : _baseColor = baseColor,
        _borderRadius = borderRadius;

  Color _baseColor;
  set baseColor(Color value) {
    if (_baseColor == value) return;
    _baseColor = value;
    markNeedsPaint();
  }

  double _borderRadius;
  set borderRadius(double value) {
    if (_borderRadius == value) return;
    _borderRadius = value;
    markNeedsPaint();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child == null) return;
    final paint = Paint()..color = _baseColor;
    _paintBones(context.canvas, child!, offset, paint);
  }

  void _paintBones(
    Canvas canvas,
    RenderObject obj,
    Offset paintOffset,
    Paint paint,
  ) {
    if (obj is RenderParagraph) {
      _paintTextBone(canvas, obj, paintOffset, paint);
    } else if (obj is RenderDecoratedBox) {
      _paintDecorationBone(canvas, obj, paintOffset, paint);
    }
    obj.visitChildren(
      (child) => _paintBones(canvas, child, paintOffset, paint),
    );
  }

  void _paintTextBone(
    Canvas canvas,
    RenderParagraph paragraph,
    Offset paintOffset,
    Paint paint,
  ) {
    final text = paragraph.text.toPlainText();
    if (text.isEmpty) return;

    final transform = paragraph.getTransformTo(this);
    final clipRect = Offset.zero & paragraph.size;
    final boxes = paragraph.getBoxesForSelection(
      TextSelection(baseOffset: 0, extentOffset: text.length),
    );

    for (final box in boxes) {
      var rect = box.toRect().intersect(clipRect);
      if (rect.isEmpty) continue;
      final topLeft = MatrixUtils.transformPoint(transform, rect.topLeft);
      final bottomRight =
          MatrixUtils.transformPoint(transform, rect.bottomRight);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromPoints(topLeft, bottomRight).shift(paintOffset),
          Radius.circular(_borderRadius),
        ),
        paint,
      );
    }
  }

  void _paintDecorationBone(
    Canvas canvas,
    RenderDecoratedBox box,
    Offset paintOffset,
    Paint paint,
  ) {
    final decoration = box.decoration;
    if (decoration is! BoxDecoration) return;
    if (!_hasVisibleFill(decoration)) return;

    final transform = box.getTransformTo(this);
    final topLeft = MatrixUtils.transformPoint(transform, Offset.zero);
    final bottomRight = MatrixUtils.transformPoint(
      transform,
      Offset(box.size.width, box.size.height),
    );
    final rect = Rect.fromPoints(topLeft, bottomRight).shift(paintOffset);

    if (decoration.shape == BoxShape.circle) {
      canvas.drawOval(rect, paint);
    } else if (decoration.borderRadius != null) {
      final br = decoration.borderRadius!.resolve(TextDirection.ltr);
      canvas.drawRRect(br.toRRect(rect), paint);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, Radius.circular(_borderRadius)),
        paint,
      );
    }
  }

  static bool _hasVisibleFill(BoxDecoration d) {
    if (d.color != null && (d.color!.a * 255).round() > 0) return true;
    if (d.gradient != null) return true;
    if (d.image != null) return true;
    return false;
  }
}

/// Sweeps an animated highlight gradient across [child] using [ShaderMask].
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

/// Translates a gradient so the highlight sweeps across the bounds.
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
