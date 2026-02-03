/// Pagination status enumeration
library;

/// Represents the current status of pagination.
enum PaginationStatus {
  /// Initial state, no data loaded yet.
  initial,

  /// Loading the first page.
  loadingFirstPage,

  /// First page loaded successfully with data.
  loaded,

  /// Loading subsequent pages (not the first page).
  loadingMore,

  /// Error occurred while loading the first page.
  firstPageError,

  /// Error occurred while loading subsequent pages.
  loadMoreError,

  /// No items found (empty state).
  empty,

  /// All pages have been loaded (end of list).
  completed,

  /// Refreshing the list (reloading from first page).
  refreshing,
}

/// Extension methods for [PaginationStatus].
extension PaginationStatusX on PaginationStatus {
  /// Whether the status indicates loading (first page or more).
  bool get isLoading => switch (this) {
        PaginationStatus.loadingFirstPage ||
        PaginationStatus.loadingMore ||
        PaginationStatus.refreshing =>
          true,
        _ => false,
      };

  /// Whether the status indicates an error occurred.
  bool get isError => switch (this) {
        PaginationStatus.firstPageError || PaginationStatus.loadMoreError => true,
        _ => false,
      };

  /// Whether there are items to display.
  bool get hasItems => switch (this) {
        PaginationStatus.loaded ||
        PaginationStatus.loadingMore ||
        PaginationStatus.loadMoreError ||
        PaginationStatus.completed ||
        PaginationStatus.refreshing =>
          true,
        _ => false,
      };

  /// Whether more pages can be loaded.
  bool get canLoadMore => switch (this) {
        PaginationStatus.loaded || PaginationStatus.loadMoreError => true,
        _ => false,
      };

  /// Whether in first page loading state (no items yet).
  bool get isInitialLoading => switch (this) {
        PaginationStatus.loadingFirstPage || PaginationStatus.refreshing => true,
        _ => false,
      };

  /// Whether showing first page error (no items to show).
  bool get isFirstPageError => this == PaginationStatus.firstPageError;

  /// Whether showing empty state.
  bool get isEmpty => this == PaginationStatus.empty;

  /// Whether all data has been loaded.
  bool get isCompleted => this == PaginationStatus.completed;
}
