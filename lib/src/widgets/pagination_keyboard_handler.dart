/// PaginationKeyboardHandler — Adds keyboard navigation to paginated lists
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A widget that wraps a paginated list and adds keyboard navigation.
///
/// Handles **Page Up**, **Page Down**, **Home**, **End**, and arrow keys
/// for smooth keyboard-driven scrolling — essential for desktop and web.
///
/// ```dart
/// PaginationKeyboardHandler(
///   scrollController: _scrollController,
///   onEndReached: controller.loadNextPage,
///   child: PagedListView<User>.withController(
///     controller: controller,
///     scrollController: _scrollController,
///     itemBuilder: (context, user, index) => UserTile(user: user),
///   ),
/// )
/// ```
///
/// ## Keyboard Shortcuts
///
/// | Key | Action |
/// |-----|--------|
/// | Page Down | Scroll one viewport height down |
/// | Page Up | Scroll one viewport height up |
/// | Home | Scroll to top |
/// | End | Scroll to bottom + trigger load |
/// | Arrow Down | Scroll down by [arrowScrollAmount] |
/// | Arrow Up | Scroll up by [arrowScrollAmount] |
class PaginationKeyboardHandler extends StatefulWidget {
  /// Creates a keyboard handler for paginated lists.
  ///
  /// [scrollController] must be the same controller used by the child list.
  const PaginationKeyboardHandler({
    super.key,
    required this.scrollController,
    required this.child,
    this.onEndReached,
    this.autofocus = true,
    this.arrowScrollAmount = 50.0,
    this.scrollAnimationDuration = const Duration(milliseconds: 200),
    this.scrollAnimationCurve = Curves.easeInOut,
    this.enabled = true,
  });

  /// The scroll controller used by the child paginated list.
  final ScrollController scrollController;

  /// The paginated list or any scrollable child widget.
  final Widget child;

  /// Called when the End key is pressed or Page Down reaches the end.
  /// Typically wired to `controller.loadNextPage`.
  final VoidCallback? onEndReached;

  /// Whether the widget should request keyboard focus automatically.
  final bool autofocus;

  /// Pixels scrolled per arrow key press.
  final double arrowScrollAmount;

  /// Duration for animated scroll transitions.
  final Duration scrollAnimationDuration;

  /// Curve for animated scroll transitions.
  final Curve scrollAnimationCurve;

  /// Whether keyboard handling is enabled.
  /// Set to `false` to temporarily disable keyboard navigation.
  final bool enabled;

  @override
  State<PaginationKeyboardHandler> createState() =>
      _PaginationKeyboardHandlerState();
}

class _PaginationKeyboardHandlerState
    extends State<PaginationKeyboardHandler> {
  final _focusNode = FocusNode(debugLabel: 'PaginationKeyboardHandler');

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  void _animateTo(double offset) {
    final position = widget.scrollController.position;
    final clamped = offset.clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    widget.scrollController.animateTo(
      clamped,
      duration: widget.scrollAnimationDuration,
      curve: widget.scrollAnimationCurve,
    );
  }

  KeyEventResult _handleKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled) return KeyEventResult.ignored;
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }

    if (!widget.scrollController.hasClients) {
      return KeyEventResult.ignored;
    }

    final position = widget.scrollController.position;
    final viewportHeight = position.viewportDimension;
    final currentPixels = position.pixels;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.pageDown) {
      _animateTo(currentPixels + viewportHeight);
      // If near end, trigger load more
      if (currentPixels + viewportHeight >= position.maxScrollExtent) {
        widget.onEndReached?.call();
      }
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.pageUp) {
      _animateTo(currentPixels - viewportHeight);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.home) {
      _animateTo(position.minScrollExtent);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.end) {
      _animateTo(position.maxScrollExtent);
      widget.onEndReached?.call();
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowDown) {
      _animateTo(currentPixels + widget.arrowScrollAmount);
      return KeyEventResult.handled;
    }

    if (key == LogicalKeyboardKey.arrowUp) {
      _animateTo(currentPixels - widget.arrowScrollAmount);
      return KeyEventResult.handled;
    }

    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _focusNode,
      autofocus: widget.autofocus,
      onKeyEvent: _handleKeyEvent,
      child: widget.child,
    );
  }
}
