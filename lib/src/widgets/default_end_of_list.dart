/// Default end of list widget
library;

import 'package:flutter/material.dart';

/// Default widget shown at the end of the list when all items are loaded.
class DefaultEndOfList extends StatelessWidget {
  const DefaultEndOfList({
    super.key,
    this.message = 'You\'ve reached the end',
  });

  /// The message to display.
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.outline,
                ),
              ),
            ),
            Expanded(
              child: Divider(color: colorScheme.outlineVariant),
            ),
          ],
        ),
      ),
    );
  }
}
