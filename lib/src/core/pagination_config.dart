/// Pagination configuration
library;

/// The type of pagination behavior.
enum PaginationType {
  /// Infinite scroll - automatically loads more when reaching the bottom.
  infiniteScroll,

  /// Load more button - requires user to tap a button to load more.
  loadMore,
}

/// Configuration options for pagination behavior.
class PaginationConfig {
  /// Creates a pagination configuration.
  const PaginationConfig({
    this.scrollThreshold = 200.0,
    this.autoLoadFirstPage = true,
    this.pageSize,
  });

  /// Distance in pixels from the bottom of the scrollable area that triggers
  /// loading the next page in infinite scroll mode.
  ///
  /// When the user scrolls to within this many pixels of the end,
  /// the next page will be automatically fetched.
  ///
  /// Default is 200.0 pixels.
  final double scrollThreshold;

  /// Whether to automatically load the first page when the widget is built.
  ///
  /// If false, you must manually call `controller.loadFirstPage()`.
  final bool autoLoadFirstPage;

  /// The expected number of items per page.
  ///
  /// When set, the controller automatically detects the last page by checking
  /// if the returned items count is less than [pageSize]. This eliminates
  /// phantom "loading more" indicators when the final page has fewer items.
  ///
  /// If `null` (default), the last page is only detected when an empty list
  /// is returned from the fetch function.
  final int? pageSize;

  /// Default configuration.
  static const PaginationConfig defaults = PaginationConfig();

  /// Creates a copy with the given fields replaced.
  PaginationConfig copyWith({
    double? scrollThreshold,
    bool? autoLoadFirstPage,
    int? pageSize,
  }) {
    return PaginationConfig(
      scrollThreshold: scrollThreshold ?? this.scrollThreshold,
      autoLoadFirstPage: autoLoadFirstPage ?? this.autoLoadFirstPage,
      pageSize: pageSize ?? this.pageSize,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationConfig &&
        other.scrollThreshold == scrollThreshold &&
        other.autoLoadFirstPage == autoLoadFirstPage &&
        other.pageSize == pageSize;
  }

  @override
  int get hashCode =>
      Object.hash(scrollThreshold, autoLoadFirstPage, pageSize);
}
