import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('PaginationController', () {
    late PaginationController<int> controller;

    Future<List<int>> mockFetch(int page) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (page <= 3) {
        return List.generate(10, (i) => (page - 1) * 10 + i);
      }
      return [];
    }

    setUp(() {
      controller = PaginationController<int>(fetchPage: mockFetch);
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state is correct', () {
      expect(controller.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);
      expect(controller.currentPage, 0);
      expect(controller.hasMorePages, true);
    });

    test('loadFirstPage loads items correctly', () async {
      await controller.loadFirstPage();

      expect(controller.status, PaginationStatus.loaded);
      expect(controller.items.length, 10);
      expect(controller.currentPage, 1);
      expect(controller.hasMorePages, true);
    });

    test('loadNextPage appends items', () async {
      await controller.loadFirstPage();
      await controller.loadNextPage();

      expect(controller.items.length, 20);
      expect(controller.currentPage, 2);
    });

    test('completed status when no more items', () async {
      await controller.loadFirstPage();
      await controller.loadNextPage();
      await controller.loadNextPage();
      await controller.loadNextPage(); // Page 4 returns empty

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);
    });

    test('refresh resets and reloads', () async {
      await controller.loadFirstPage();
      await controller.loadNextPage();
      expect(controller.items.length, 20);

      await controller.refresh();

      expect(controller.items.length, 10);
      expect(controller.currentPage, 1);
    });

    test('reset clears all state', () {
      controller.reset();

      expect(controller.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);
      expect(controller.currentPage, 0);
    });

    test('error handling works', () async {
      final errorController = PaginationController<int>(
        fetchPage: (_) => throw Exception('Test error'),
      );

      await errorController.loadFirstPage();

      expect(errorController.status, PaginationStatus.firstPageError);
      expect(errorController.state.error, isNotNull);

      errorController.dispose();
    });

    test('updateItems modifies the list', () async {
      await controller.loadFirstPage();
      final originalFirst = controller.items.first;

      // updateItems takes a mapper function that transforms each item
      controller.updateItems((item) => item * 10);

      expect(controller.items.first, originalFirst * 10);
    });

    test('removeWhere removes matching items', () async {
      await controller.loadFirstPage();

      controller.removeWhere((item) => item.isEven);

      expect(controller.items.every((item) => item.isOdd), true);
    });

    test('insertItem adds item at position', () async {
      await controller.loadFirstPage();

      controller.insertItem(0, -1);

      expect(controller.items.first, -1);
    });

    test('removeItemAt removes item at position', () async {
      await controller.loadFirstPage();
      final firstItem = controller.items.first;

      controller.removeItemAt(0);

      expect(controller.items.first, isNot(firstItem));
    });

    test('updateItemAt replaces item', () async {
      await controller.loadFirstPage();

      controller.updateItemAt(0, 999);

      expect(controller.items.first, 999);
    });
  });

  group('PaginationState', () {
    test('copyWith works correctly', () {
      const state = PaginationState<int>(
        items: [1, 2, 3],
        currentPage: 1,
        status: PaginationStatus.loaded,
        hasMorePages: true,
      );

      final newState = state.copyWith(currentPage: 2);

      expect(newState.currentPage, 2);
      expect(newState.items, state.items);
      expect(newState.status, state.status);
    });

    test('reset returns initial state', () {
      const state = PaginationState<int>(
        items: [1, 2, 3],
        currentPage: 5,
        status: PaginationStatus.completed,
        hasMorePages: false,
        error: 'Some error',
      );

      final resetState = state.reset();

      expect(resetState.items, isEmpty);
      expect(resetState.currentPage, 0);
      expect(resetState.status, PaginationStatus.initial);
      expect(resetState.hasMorePages, true);
      expect(resetState.error, isNull);
    });
  });

  group('PaginationStatus extensions', () {
    test('isLoading returns correct values', () {
      expect(PaginationStatus.initial.isLoading, false);
      expect(PaginationStatus.loadingFirstPage.isLoading, true);
      expect(PaginationStatus.loadingMore.isLoading, true);
      expect(PaginationStatus.refreshing.isLoading, true);
      expect(PaginationStatus.loaded.isLoading, false);
    });

    test('isError returns correct values', () {
      expect(PaginationStatus.firstPageError.isError, true);
      expect(PaginationStatus.loadMoreError.isError, true);
      expect(PaginationStatus.loaded.isError, false);
    });

    test('hasItems returns correct values', () {
      expect(PaginationStatus.loaded.hasItems, true);
      expect(PaginationStatus.completed.hasItems, true);
      expect(PaginationStatus.loadingMore.hasItems, true);
      expect(PaginationStatus.empty.hasItems, false);
      expect(PaginationStatus.loadingFirstPage.hasItems, false);
    });

    test('canLoadMore returns correct values', () {
      expect(PaginationStatus.loaded.canLoadMore, true);
      expect(PaginationStatus.loadingMore.canLoadMore, false);
      expect(PaginationStatus.completed.canLoadMore, false);
      expect(PaginationStatus.empty.canLoadMore, false);
    });

    test('isInitialLoading returns correct values', () {
      expect(PaginationStatus.initial.isInitialLoading, false);
      expect(PaginationStatus.loadingFirstPage.isInitialLoading, true);
      expect(PaginationStatus.refreshing.isInitialLoading, true);
    });

    test('isFirstPageError returns correct values', () {
      expect(PaginationStatus.firstPageError.isFirstPageError, true);
      expect(PaginationStatus.loadMoreError.isFirstPageError, false);
    });

    test('isEmpty returns correct values', () {
      expect(PaginationStatus.empty.isEmpty, true);
      expect(PaginationStatus.loaded.isEmpty, false);
    });
  });

  group('PaginationConfig', () {
    test('defaults are sensible', () {
      const config = PaginationConfig.defaults;

      expect(config.initialPage, 1);
      expect(config.invisibleItemsThreshold, 3);
      expect(config.autoLoadFirstPage, true);
    });

    test('custom config works', () {
      const config = PaginationConfig(
        initialPage: 0,
        invisibleItemsThreshold: 5,
        autoLoadFirstPage: false,
      );

      expect(config.initialPage, 0);
      expect(config.invisibleItemsThreshold, 5);
      expect(config.autoLoadFirstPage, false);
    });
  });
}
