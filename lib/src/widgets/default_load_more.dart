/// Default load more button widget
library;

import 'package:flutter/material.dart';

/// Default button for loading more items.
class DefaultLoadMoreButton extends StatelessWidget {
  const DefaultLoadMoreButton({
    super.key,
    required this.onPressed,
    this.label = 'Load More',
    this.isLoading = false,
  });

  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  /// The button label.
  final String label;

  /// Whether currently loading.
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
      child: SizedBox(
        width: double.infinity,
        child: isLoading
            ? const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator.adaptive(strokeWidth: 2.5),
                ),
              )
            : OutlinedButton(
                onPressed: onPressed,
                child: Text(label),
              ),
      ),
    );
  }
}
