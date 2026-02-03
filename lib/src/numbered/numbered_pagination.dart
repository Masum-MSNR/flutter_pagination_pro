/// NumberedPagination - A numbered page navigation widget
library;

import 'package:flutter/material.dart';

/// Configuration for [NumberedPagination] appearance.
class NumberedPaginationConfig {
  const NumberedPaginationConfig({
    this.selectedButtonColor,
    this.unselectedButtonColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.navigationButtonColor,
    this.navigationIconColor,
    this.disabledButtonColor,
    this.disabledIconColor,
    this.buttonSize = 40.0,
    this.spacing = 4.0,
    this.borderRadius = 8.0,
    this.elevation = 0.0,
    this.fontSize = 14.0,
    this.fontWeight = FontWeight.w500,
    this.showFirstLastButtons = true,
    this.showNavigationButtons = true,
    this.navigationIconSize = 20.0,
    this.firstIcon,
    this.lastIcon,
    this.previousIcon,
    this.nextIcon,
  });

  /// Color of the selected page button.
  final Color? selectedButtonColor;

  /// Color of unselected page buttons.
  final Color? unselectedButtonColor;

  /// Text color of the selected page.
  final Color? selectedTextColor;

  /// Text color of unselected pages.
  final Color? unselectedTextColor;

  /// Color of navigation buttons (first, last, prev, next).
  final Color? navigationButtonColor;

  /// Icon color of navigation buttons.
  final Color? navigationIconColor;

  /// Color of disabled navigation buttons.
  final Color? disabledButtonColor;

  /// Icon color of disabled navigation buttons.
  final Color? disabledIconColor;

  /// Size of each button (width and height).
  final double buttonSize;

  /// Spacing between buttons.
  final double spacing;

  /// Border radius of buttons.
  final double borderRadius;

  /// Elevation of buttons.
  final double elevation;

  /// Font size of page numbers.
  final double fontSize;

  /// Font weight of page numbers.
  final FontWeight fontWeight;

  /// Whether to show first/last page buttons.
  final bool showFirstLastButtons;

  /// Whether to show previous/next buttons.
  final bool showNavigationButtons;

  /// Size of navigation icons.
  final double navigationIconSize;

  /// Custom icon for first page button.
  final Widget? firstIcon;

  /// Custom icon for last page button.
  final Widget? lastIcon;

  /// Custom icon for previous page button.
  final Widget? previousIcon;

  /// Custom icon for next page button.
  final Widget? nextIcon;

  /// Creates a copy with the given fields replaced.
  NumberedPaginationConfig copyWith({
    Color? selectedButtonColor,
    Color? unselectedButtonColor,
    Color? selectedTextColor,
    Color? unselectedTextColor,
    Color? navigationButtonColor,
    Color? navigationIconColor,
    Color? disabledButtonColor,
    Color? disabledIconColor,
    double? buttonSize,
    double? spacing,
    double? borderRadius,
    double? elevation,
    double? fontSize,
    FontWeight? fontWeight,
    bool? showFirstLastButtons,
    bool? showNavigationButtons,
    double? navigationIconSize,
    Widget? firstIcon,
    Widget? lastIcon,
    Widget? previousIcon,
    Widget? nextIcon,
  }) {
    return NumberedPaginationConfig(
      selectedButtonColor: selectedButtonColor ?? this.selectedButtonColor,
      unselectedButtonColor: unselectedButtonColor ?? this.unselectedButtonColor,
      selectedTextColor: selectedTextColor ?? this.selectedTextColor,
      unselectedTextColor: unselectedTextColor ?? this.unselectedTextColor,
      navigationButtonColor: navigationButtonColor ?? this.navigationButtonColor,
      navigationIconColor: navigationIconColor ?? this.navigationIconColor,
      disabledButtonColor: disabledButtonColor ?? this.disabledButtonColor,
      disabledIconColor: disabledIconColor ?? this.disabledIconColor,
      buttonSize: buttonSize ?? this.buttonSize,
      spacing: spacing ?? this.spacing,
      borderRadius: borderRadius ?? this.borderRadius,
      elevation: elevation ?? this.elevation,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      showFirstLastButtons: showFirstLastButtons ?? this.showFirstLastButtons,
      showNavigationButtons: showNavigationButtons ?? this.showNavigationButtons,
      navigationIconSize: navigationIconSize ?? this.navigationIconSize,
      firstIcon: firstIcon ?? this.firstIcon,
      lastIcon: lastIcon ?? this.lastIcon,
      previousIcon: previousIcon ?? this.previousIcon,
      nextIcon: nextIcon ?? this.nextIcon,
    );
  }
}

/// A numbered pagination widget for navigating between pages.
///
/// Displays page numbers with ellipsis for large page counts.
///
/// ## Simple Usage
///
/// ```dart
/// NumberedPagination(
///   totalPages: 20,
///   currentPage: 1,
///   onPageChanged: (page) {
///     setState(() => _currentPage = page);
///     _loadPage(page);
///   },
/// )
/// ```
///
/// ## With Configuration
///
/// ```dart
/// NumberedPagination(
///   totalPages: 50,
///   currentPage: _currentPage,
///   onPageChanged: _onPageChanged,
///   config: NumberedPaginationConfig(
///     selectedButtonColor: Colors.blue,
///     buttonSize: 36,
///     showFirstLastButtons: true,
///   ),
/// )
/// ```
///
/// ## Responsive Mode
///
/// ```dart
/// NumberedPagination(
///   totalPages: 100,
///   currentPage: _currentPage,
///   onPageChanged: _onPageChanged,
///   visiblePages: 5, // Show 5 page buttons on mobile
/// )
/// ```
class NumberedPagination extends StatelessWidget {
  const NumberedPagination({
    super.key,
    required this.totalPages,
    required this.currentPage,
    required this.onPageChanged,
    this.visiblePages = 7,
    this.config = const NumberedPaginationConfig(),
    this.enabled = true,
  })  : assert(totalPages >= 0, 'totalPages must be >= 0'),
        assert(currentPage >= 1 || totalPages == 0, 'currentPage must be >= 1'),
        assert(
          currentPage <= totalPages || totalPages == 0,
          'currentPage must be <= totalPages',
        ),
        assert(visiblePages >= 3, 'visiblePages must be >= 3');

  /// Total number of pages.
  final int totalPages;

  /// Current selected page (1-indexed).
  final int currentPage;

  /// Callback when a page is selected.
  final ValueChanged<int> onPageChanged;

  /// Number of page buttons visible (excluding navigation buttons).
  /// Must be at least 3. Default is 7.
  final int visiblePages;

  /// Configuration for appearance customization.
  final NumberedPaginationConfig config;

  /// Whether the pagination is enabled.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (totalPages == 0) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve colors from theme
    final selectedButtonColor = config.selectedButtonColor ?? colorScheme.primary;
    final unselectedButtonColor =
        config.unselectedButtonColor ?? colorScheme.surfaceContainerHighest;
    final selectedTextColor = config.selectedTextColor ?? colorScheme.onPrimary;
    final unselectedTextColor =
        config.unselectedTextColor ?? colorScheme.onSurfaceVariant;
    final navigationButtonColor =
        config.navigationButtonColor ?? colorScheme.surfaceContainerHighest;
    final navigationIconColor =
        config.navigationIconColor ?? colorScheme.onSurfaceVariant;
    final disabledButtonColor =
        config.disabledButtonColor ?? colorScheme.surfaceContainerHighest.withValues(alpha: 0.5);
    final disabledIconColor =
        config.disabledIconColor ?? colorScheme.onSurfaceVariant.withValues(alpha: 0.38);

    final pageNumbers = _generatePageNumbers();
    final isFirstPage = currentPage == 1;
    final isLastPage = currentPage == totalPages;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // First page button
        if (config.showFirstLastButtons) ...[
          _NavigationButton(
            icon: config.firstIcon ??
                Icon(Icons.first_page, size: config.navigationIconSize),
            onPressed: isFirstPage || !enabled ? null : () => onPageChanged(1),
            size: config.buttonSize,
            borderRadius: config.borderRadius,
            elevation: config.elevation,
            color: isFirstPage || !enabled
                ? disabledButtonColor
                : navigationButtonColor,
            iconColor: isFirstPage || !enabled
                ? disabledIconColor
                : navigationIconColor,
          ),
          SizedBox(width: config.spacing),
        ],

        // Previous button
        if (config.showNavigationButtons) ...[
          _NavigationButton(
            icon: config.previousIcon ??
                Icon(Icons.chevron_left, size: config.navigationIconSize),
            onPressed: isFirstPage || !enabled
                ? null
                : () => onPageChanged(currentPage - 1),
            size: config.buttonSize,
            borderRadius: config.borderRadius,
            elevation: config.elevation,
            color: isFirstPage || !enabled
                ? disabledButtonColor
                : navigationButtonColor,
            iconColor: isFirstPage || !enabled
                ? disabledIconColor
                : navigationIconColor,
          ),
          SizedBox(width: config.spacing),
        ],

        // Page numbers
        ...pageNumbers.map((page) {
          if (page == -1) {
            // Ellipsis
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: config.spacing / 2),
              child: SizedBox(
                width: config.buttonSize,
                height: config.buttonSize,
                child: Center(
                  child: Text(
                    '...',
                    style: TextStyle(
                      color: unselectedTextColor,
                      fontSize: config.fontSize,
                      fontWeight: config.fontWeight,
                    ),
                  ),
                ),
              ),
            );
          }

          final isSelected = page == currentPage;
          return Padding(
            padding: EdgeInsets.only(right: config.spacing),
            child: _PageButton(
              page: page,
              isSelected: isSelected,
              enabled: enabled,
              onPressed: () => onPageChanged(page),
              size: config.buttonSize,
              borderRadius: config.borderRadius,
              elevation: config.elevation,
              backgroundColor:
                  isSelected ? selectedButtonColor : unselectedButtonColor,
              textColor: isSelected ? selectedTextColor : unselectedTextColor,
              fontSize: config.fontSize,
              fontWeight: config.fontWeight,
            ),
          );
        }),

        // Next button
        if (config.showNavigationButtons) ...[
          _NavigationButton(
            icon: config.nextIcon ??
                Icon(Icons.chevron_right, size: config.navigationIconSize),
            onPressed: isLastPage || !enabled
                ? null
                : () => onPageChanged(currentPage + 1),
            size: config.buttonSize,
            borderRadius: config.borderRadius,
            elevation: config.elevation,
            color: isLastPage || !enabled
                ? disabledButtonColor
                : navigationButtonColor,
            iconColor: isLastPage || !enabled
                ? disabledIconColor
                : navigationIconColor,
          ),
          SizedBox(width: config.spacing),
        ],

        // Last page button
        if (config.showFirstLastButtons)
          _NavigationButton(
            icon: config.lastIcon ??
                Icon(Icons.last_page, size: config.navigationIconSize),
            onPressed:
                isLastPage || !enabled ? null : () => onPageChanged(totalPages),
            size: config.buttonSize,
            borderRadius: config.borderRadius,
            elevation: config.elevation,
            color: isLastPage || !enabled
                ? disabledButtonColor
                : navigationButtonColor,
            iconColor: isLastPage || !enabled
                ? disabledIconColor
                : navigationIconColor,
          ),
      ],
    );
  }

  /// Generates the list of page numbers to display.
  /// Returns -1 for ellipsis.
  List<int> _generatePageNumbers() {
    if (totalPages <= visiblePages) {
      // Show all pages
      return List.generate(totalPages, (i) => i + 1);
    }

    final List<int> pages = [];
    final int half = (visiblePages - 2) ~/ 2; // Pages on each side (excluding first/last)
    final int start;
    final int end;

    if (currentPage <= half + 1) {
      // Near the beginning
      start = 1;
      end = visiblePages - 2;
      pages.addAll(List.generate(end, (i) => i + 1));
      pages.add(-1); // Ellipsis
      pages.add(totalPages);
    } else if (currentPage >= totalPages - half) {
      // Near the end
      start = totalPages - visiblePages + 3;
      end = totalPages;
      pages.add(1);
      pages.add(-1); // Ellipsis
      pages.addAll(List.generate(visiblePages - 2, (i) => start + i));
    } else {
      // In the middle
      start = currentPage - half + 1;
      end = currentPage + half - 1;
      pages.add(1);
      pages.add(-1); // Ellipsis
      pages.addAll(List.generate(end - start + 1, (i) => start + i));
      pages.add(-1); // Ellipsis
      pages.add(totalPages);
    }

    return pages;
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.page,
    required this.isSelected,
    required this.enabled,
    required this.onPressed,
    required this.size,
    required this.borderRadius,
    required this.elevation,
    required this.backgroundColor,
    required this.textColor,
    required this.fontSize,
    required this.fontWeight,
  });

  final int page;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onPressed;
  final double size;
  final double borderRadius;
  final double elevation;
  final Color backgroundColor;
  final Color textColor;
  final double fontSize;
  final FontWeight fontWeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: backgroundColor,
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: enabled && !isSelected ? onPressed : null,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: Text(
              '$page',
              style: TextStyle(
                color: textColor,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.icon,
    required this.onPressed,
    required this.size,
    required this.borderRadius,
    required this.elevation,
    required this.color,
    required this.iconColor,
  });

  final Widget icon;
  final VoidCallback? onPressed;
  final double size;
  final double borderRadius;
  final double elevation;
  final Color color;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Material(
        color: color,
        elevation: elevation,
        borderRadius: BorderRadius.circular(borderRadius),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(
            child: IconTheme(
              data: IconThemeData(color: iconColor),
              child: icon,
            ),
          ),
        ),
      ),
    );
  }
}
