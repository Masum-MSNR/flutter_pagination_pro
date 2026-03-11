import 'mock_item.dart';

/// Simulates API responses with configurable behavior
class MockDataService {
  MockDataService({
    this.pageSize = 15,
    this.totalItems = 100,
    this.delayMs = 800,
    this.errorOnPage,
    this.emptyResponse = false,
    this.failFirstNTimes = 0,
  });

  final int pageSize;
  final int totalItems;
  final int delayMs;
  final int? errorOnPage;
  final bool emptyResponse;

  /// Number of times each page-2+ request should fail before succeeding.
  ///
  /// Use this to demo auto-retry: set to 2 so the first 2 load-more attempts
  /// fail, then succeed on the 3rd attempt after retries.
  final int failFirstNTimes;

  int _loadMoreAttempts = 0;

  Future<List<MockItem>> fetchPage(int page) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    if (emptyResponse) return [];

    if (errorOnPage != null && page == errorOnPage) {
      throw Exception(
          'Simulated network error on page $page. Please try again.');
    }

    // Intermittent failure for auto-retry demo
    if (failFirstNTimes > 0 && page > 1) {
      _loadMoreAttempts++;
      if (_loadMoreAttempts <= failFirstNTimes) {
        throw Exception(
          'Intermittent network error (attempt $_loadMoreAttempts/$failFirstNTimes)',
        );
      }
      // Reset for next page load
      _loadMoreAttempts = 0;
    }

    if (emptyResponse) return [];

    if (errorOnPage != null && page == errorOnPage) {
      throw Exception(
          'Simulated network error on page $page. Please try again.');
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= totalItems) return [];

    final endIndex = (startIndex + pageSize).clamp(0, totalItems);
    return List.generate(
      endIndex - startIndex,
      (i) => MockItem.generate(startIndex + i, page),
    );
  }

  int get totalPages => (totalItems / pageSize).ceil();
}

/// Predefined service configurations for different demo scenarios
class MockServicePresets {
  static MockDataService success() => MockDataService();

  static MockDataService empty() => MockDataService(emptyResponse: true);

  static MockDataService firstPageError() => MockDataService(errorOnPage: 1);

  static MockDataService loadMoreError() => MockDataService(errorOnPage: 2);

  static MockDataService slowLoading() => MockDataService(delayMs: 3000);

  static MockDataService fewItems() =>
      MockDataService(totalItems: 5, pageSize: 10);

  static MockDataService manyPages() =>
      MockDataService(totalItems: 500, pageSize: 10);

  /// Intermittent errors on load-more — first 2 attempts fail, 3rd succeeds.
  /// Perfect for demoing auto-retry with exponential backoff.
  static MockDataService intermittentError() =>
      MockDataService(failFirstNTimes: 2, delayMs: 300);
}
