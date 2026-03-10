import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────
  // 1. Generic Page Key (K) — cursor, offset, and custom key types
  // ────────────────────────────────────────────────────────────────────────

  group('Generic Page Key', () {
    test('cursor-based (String) pagination works', () async {
      // Simulate cursor-based API: each page returns items + a next cursor
      final pages = <String, List<String>>{
        '': ['A', 'B', 'C'],
        'cursor_c': ['D', 'E', 'F'],
        'cursor_f': [],
      };

      final controller = PaginationController<String, String>(
        fetchPage: (cursor) async => pages[cursor] ?? [],
        initialPageKey: '',
        nextPageKeyBuilder: (_, items) =>
            items.isEmpty ? '' : 'cursor_${items.last.toLowerCase()}',
      );

      await controller.loadFirstPage();
      expect(controller.items, ['A', 'B', 'C']);
      expect(controller.currentPageKey, '');
      expect(controller.status, PaginationStatus.loaded);

      await controller.loadNextPage();
      expect(controller.items, ['A', 'B', 'C', 'D', 'E', 'F']);
      expect(controller.currentPageKey, 'cursor_c');

      await controller.loadNextPage();
      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);

      controller.dispose();
    });

    test('offset-based pagination works', () async {
      final allItems = List.generate(25, (i) => 'item_$i');

      final controller = PaginationController<int, String>(
        fetchPage: (offset) async {
          final end = (offset + 10).clamp(0, allItems.length);
          return allItems.sublist(offset, end);
        },
        initialPageKey: 0,
        nextPageKeyBuilder: (offset, items) => offset + items.length,
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();
      expect(controller.items.length, 10);
      expect(controller.currentPageKey, 0);

      await controller.loadNextPage();
      expect(controller.items.length, 20);
      expect(controller.currentPageKey, 10);

      await controller.loadNextPage();
      expect(controller.items.length, 25);
      expect(controller.status, PaginationStatus.completed); // 5 < pageSize 10
      expect(controller.hasMorePages, false);

      controller.dispose();
    });

    test('int key defaults to page+1 without nextPageKeyBuilder', () async {
      final controller = PaginationController<int, int>(
        fetchPage: (page) async => [page * 10],
        initialPageKey: 1,
        // No nextPageKeyBuilder — defaults to (k, _) => k + 1
      );

      await controller.loadFirstPage();
      expect(controller.currentPageKey, 1);

      await controller.loadNextPage();
      expect(controller.currentPageKey, 2);

      controller.dispose();
    });

    test('non-int key without nextPageKeyBuilder throws assert', () {
      expect(
        () => PaginationController<String, String>(
          fetchPage: (_) async => [],
          initialPageKey: 'start',
          // Missing nextPageKeyBuilder for String key
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('refresh resets cursor-based controller', () async {
      int callCount = 0;
      final controller = PaginationController<String, String>(
        fetchPage: (cursor) async {
          callCount++;
          return ['item_$callCount'];
        },
        initialPageKey: '',
        nextPageKeyBuilder: (_, items) => 'cursor_${items.last}',
      );

      await controller.loadFirstPage();
      expect(controller.items, ['item_1']);

      await controller.refresh();
      expect(controller.items, ['item_2']);
      expect(controller.currentPageKey, '');

      controller.dispose();
    });

    test('reset clears cursor-based controller', () async {
      final controller = PaginationController<String, String>(
        fetchPage: (_) async => ['x'],
        initialPageKey: 'start',
        nextPageKeyBuilder: (_, __) => 'next',
      );

      await controller.loadFirstPage();
      expect(controller.items, ['x']);

      controller.reset();
      expect(controller.items, isEmpty);
      expect(controller.currentPageKey, isNull);
      expect(controller.status, PaginationStatus.initial);

      controller.dispose();
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 2. updateFetchPage — search/filter reset
  // ────────────────────────────────────────────────────────────────────────

  group('updateFetchPage', () {
    test('replaces fetch function and reloads from first page', () async {
      final controller = PaginationController<int, String>(
        fetchPage: (page) async => ['original_$page'],
        initialPageKey: 1,
      );

      await controller.loadFirstPage();
      expect(controller.items, ['original_1']);

      await controller.updateFetchPage(
        (page) async => ['updated_$page'],
      );

      expect(controller.items, ['updated_1']);
      expect(controller.currentPageKey, 1);
      expect(controller.status, PaginationStatus.loaded);

      controller.dispose();
    });

    test('cancels ongoing operation before reloading', () async {
      final firstCompleter = Completer<List<String>>();
      final controller = PaginationController<int, String>(
        fetchPage: (_) => firstCompleter.future,
        initialPageKey: 1,
      );

      // Start loading first page (will hang on completer)
      controller.loadFirstPage();

      // updateFetchPage should cancel the first load
      await controller.updateFetchPage(
        (page) async => ['new_$page'],
      );

      expect(controller.items, ['new_1']);

      // Complete the first completer — should have no effect
      firstCompleter.complete(['stale_data']);
      await Future<void>.delayed(Duration.zero);
      expect(controller.items, ['new_1']); // Still new data

      controller.dispose();
    });

    test('resets accumulated items', () async {
      final controller = PaginationController<int, String>(
        fetchPage: (page) async =>
            List.generate(5, (i) => 'item_${page}_$i'),
        initialPageKey: 1,
      );

      await controller.loadFirstPage();
      await controller.loadNextPage();
      expect(controller.items.length, 10);

      await controller.updateFetchPage(
        (page) async => ['fresh_$page'],
      );

      expect(controller.items, ['fresh_1']);
      expect(controller.currentPageKey, 1);

      controller.dispose();
    });

    test('works with cursor-based pagination', () async {
      final controller = PaginationController<String, String>(
        fetchPage: (cursor) async => ['old_$cursor'],
        initialPageKey: '',
        nextPageKeyBuilder: (_, items) => 'next_${items.last}',
      );

      await controller.loadFirstPage();
      expect(controller.items, ['old_']);

      await controller.updateFetchPage(
        (cursor) async => ['new_$cursor'],
      );

      expect(controller.items, ['new_']);

      controller.dispose();
    });

    test('subsequent loadNextPage uses new fetch function', () async {
      final controller = PaginationController<int, String>(
        fetchPage: (page) async => ['old_$page'],
        initialPageKey: 1,
      );

      await controller.loadFirstPage();
      await controller.updateFetchPage(
        (page) async => ['fresh_$page'],
      );

      expect(controller.items, ['fresh_1']);

      await controller.loadNextPage();
      expect(controller.items, ['fresh_1', 'fresh_2']);

      controller.dispose();
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 3. Controlled mode — BYO state management
  // ────────────────────────────────────────────────────────────────────────

  group('Controlled mode - PaginationListView', () {
    testWidgets('renders items from external state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Alice', 'Bob', 'Charlie'],
              status: PaginationStatus.loaded,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);
    });

    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.firstPageError,
              error: Exception('Network error'),
              onRetry: () => retried = true,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.empty,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows completed/end-of-list state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A', 'B'],
              status: PaginationStatus.completed,
              hasMorePages: false,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text("You've reached the end"), findsOneWidget);
    });

    testWidgets('shows load more button in loadMore mode', (tester) async {
      bool loadMoreCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['X', 'Y', 'Z'],
              status: PaginationStatus.loaded,
              hasMorePages: true,
              paginationType: PaginationType.loadMore,
              onLoadMore: () => loadMoreCalled = true,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Load More'), findsOneWidget);

      await tester.tap(find.text('Load More'));
      expect(loadMoreCalled, true);
    });

    testWidgets('updates when external state changes', (tester) async {
      final items = ValueNotifier<List<String>>(['first']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<List<String>>(
              valueListenable: items,
              builder: (context, value, _) {
                return PaginationListView<int, String>.controlled(
                  items: value,
                  status: PaginationStatus.loaded,
                  itemBuilder: (context, item, index) =>
                      ListTile(title: Text(item)),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('first'), findsOneWidget);

      items.value = ['second', 'third'];
      await tester.pumpAndSettle();
      expect(find.text('second'), findsOneWidget);
      expect(find.text('third'), findsOneWidget);

      items.dispose();
    });
  });

  group('Controlled mode - PaginationGridView', () {
    testWidgets('renders grid items from external state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const ['Photo1', 'Photo2', 'Photo3', 'Photo4'],
              status: PaginationStatus.loaded,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) =>
                  Card(child: Center(child: Text(item))),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Photo1'), findsOneWidget);
      expect(find.text('Photo2'), findsOneWidget);
    });

    testWidgets('shows loading in grid controlled mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) =>
                  Card(child: Center(child: Text(item))),
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Controlled mode - SliverPaginatedList', () {
    testWidgets('renders sliver list items from external state',
        (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPaginatedList<int, String>.controlled(
                  items: const ['Sliver1', 'Sliver2'],
                  status: PaginationStatus.loaded,
                  scrollController: scrollController,
                  itemBuilder: (context, item, index) =>
                      ListTile(title: Text(item)),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sliver1'), findsOneWidget);
      expect(find.text('Sliver2'), findsOneWidget);
    });

    testWidgets('shows loading in sliver controlled mode', (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPaginatedList<int, String>.controlled(
                  items: const [],
                  status: PaginationStatus.loadingFirstPage,
                  scrollController: scrollController,
                  itemBuilder: (context, item, index) =>
                      ListTile(title: Text(item)),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  group('Controlled mode - SliverPaginatedGrid', () {
    testWidgets('renders sliver grid items from external state',
        (tester) async {
      final scrollController = ScrollController();
      addTearDown(scrollController.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                SliverPaginatedGrid<int, String>.controlled(
                  items: const ['G1', 'G2', 'G3', 'G4'],
                  status: PaginationStatus.loaded,
                  scrollController: scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, item, index) =>
                      Card(child: Center(child: Text(item))),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('G1'), findsOneWidget);
      expect(find.text('G2'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 4. Widget <K, T> generic type verification
  // ────────────────────────────────────────────────────────────────────────

  group('Widget K,T generics', () {
    testWidgets('PaginationListView with String key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String, String>(
              fetchPage: (cursor) async => ['item_$cursor'],
              initialPageKey: 'start',
              nextPageKeyBuilder: (_, items) => 'next_${items.last}',
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('item_start'), findsOneWidget);
    });

    testWidgets('PaginationGridView with offset key', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>(
              fetchPage: (offset) async =>
                  List.generate(4, (i) => 'off_${offset + i}'),
              initialPageKey: 0,
              nextPageKeyBuilder: (offset, items) => offset + items.length,
              itemBuilder: (context, item, index) =>
                  Card(child: Center(child: Text(item))),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('off_0'), findsOneWidget);
      expect(find.text('off_1'), findsOneWidget);
    });

    testWidgets('withController passes K correctly', (tester) async {
      final controller = PaginationController<String, String>(
        fetchPage: (cursor) async => ['data_$cursor'],
        initialPageKey: 'init',
        nextPageKeyBuilder: (_, __) => 'next',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String, String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('data_init'), findsOneWidget);

      controller.dispose();
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 5. updateFetchPage integration with widgets
  // ────────────────────────────────────────────────────────────────────────

  group('updateFetchPage widget integration', () {
    testWidgets('widget re-renders after updateFetchPage', (tester) async {
      final controller = PaginationController<int, String>(
        fetchPage: (page) async => ['original'],
        initialPageKey: 1,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('original'), findsOneWidget);

      await controller.updateFetchPage(
        (page) async => ['search_result'],
      );
      await tester.pumpAndSettle();

      expect(find.text('search_result'), findsOneWidget);
      expect(find.text('original'), findsNothing);

      controller.dispose();
    });
  });
}
