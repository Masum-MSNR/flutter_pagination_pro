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
  /// it into skeleton shapes.
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
  /// The widget tree is rendered with **transparent backgrounds** (Card,
  /// ListTile, Material surfaces are cleared), then a Gaussian blur merges
  /// individual text characters into solid bands and a uniform colour
  /// overlay is applied. The result looks like hand-crafted skeleton shapes
  /// (avatar rectangle, title bar, subtitle bar, chip pill) without
  /// requiring a separate skeleton widget.
  ///
  /// [overlayColor] defaults to a theme-appropriate grey —
  /// `Colors.grey.shade700` in dark mode, `Colors.grey.shade300` in light.
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

  /// Wraps [child] in a skeleton effect that **automatically** produces
  /// placeholder shapes from the real widget.
  ///
  /// How it works:
  /// 1. **Transparent backgrounds** — Card, ListTile, and Material surface
  ///    colours are temporarily overridden to transparent so that only
  ///    visible content (text, icons, coloured containers) remains.
  /// 2. **Gaussian blur** (σ = 4) — merges individual text characters into
  ///    solid rectangular bands and softens sharp edges.
  /// 3. **Uniform colour overlay** (`BlendMode.srcATop`) — replaces every
  ///    non-transparent pixel with [overlayColor] while keeping the alpha
  ///    channel, producing uniform skeleton shapes.
  ///
  /// The result automatically mirrors the real widget's layout: avatars
  /// become rounded rectangles, titles become horizontal bars, chips
  /// become pills — all in a single skeleton colour.
  ///
  /// [overlayColor] defaults to a theme-appropriate grey:
  /// `Colors.grey.shade700` in dark mode, `Colors.grey.shade300` in light.
  static Widget skeletonize(
    BuildContext context,
    Widget child, {
    Color? overlayColor,
  }) {
    final theme = Theme.of(context);
    final color = overlayColor ??
        (theme.brightness == Brightness.dark
            ? Colors.grey.shade700
            : Colors.grey.shade300);

    return Theme(
      data: theme.copyWith(
        cardTheme: theme.cardTheme.copyWith(
          color: Colors.transparent,
          shadowColor: Colors.transparent,
          elevation: 0,
        ),
        listTileTheme: theme.listTileTheme.copyWith(
          tileColor: Colors.transparent,
        ),
      ),
      child: ClipRect(
        child: ColorFiltered(
          colorFilter: ColorFilter.mode(color, BlendMode.srcATop),
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
