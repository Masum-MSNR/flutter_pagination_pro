/// Default error widgets
library;

import 'package:flutter/material.dart';

/// Default error widget for first page errors.
///
/// Shows a centered error message with a retry button.
class DefaultFirstPageError extends StatelessWidget {
  const DefaultFirstPageError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  /// The error that occurred.
  final Object error;

  /// Callback when retry is pressed.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _formatError(error),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  String _formatError(Object error) {
    final message = error.toString();
    // Remove "Exception: " prefix if present
    if (message.startsWith('Exception: ')) {
      return message.substring(11);
    }
    return message;
  }
}

/// Default error widget for load more errors.
///
/// Shows an inline error message with a retry button.
class DefaultLoadMoreError extends StatelessWidget {
  const DefaultLoadMoreError({
    super.key,
    required this.error,
    required this.onRetry,
  });

  /// The error that occurred.
  final Object error;

  /// Callback when retry is pressed.
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 20,
            color: colorScheme.error,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Failed to load more',
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
