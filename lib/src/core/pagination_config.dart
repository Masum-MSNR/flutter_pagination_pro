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
    this.initialPage = 1,
    this.invisibleItemsThreshold = 3,
    this.autoLoadFirstPage = true,
  });

  /// The initial page number (default: 1).
  final int initialPage;

  /// Number of items before the end to trigger preloading (default: 3).
  ///
  /// When the user scrolls to within this many items from the end,
  /// the next page will be automatically fetched (in infiniteScroll mode).
  final int invisibleItemsThreshold;

  /// Whether to automatically load the first page when the widget is built.
  ///
  /// If false, you must manually call `controller.loadFirstPage()`.
  final bool autoLoadFirstPage;

  /// Default configuration.
  static const PaginationConfig defaults = PaginationConfig();

  /// Creates a copy with the given fields replaced.
  PaginationConfig copyWith({
    int? initialPage,
    int? invisibleItemsThreshold,
    bool? autoLoadFirstPage,
  }) {
    return PaginationConfig(
      initialPage: initialPage ?? this.initialPage,
      invisibleItemsThreshold: invisibleItemsThreshold ?? this.invisibleItemsThreshold,
      autoLoadFirstPage: autoLoadFirstPage ?? this.autoLoadFirstPage,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PaginationConfig &&
        other.initialPage == initialPage &&
        other.invisibleItemsThreshold == invisibleItemsThreshold &&
        other.autoLoadFirstPage == autoLoadFirstPage;
  }

  @override
  int get hashCode => Object.hash(initialPage, invisibleItemsThreshold, autoLoadFirstPage);
}
