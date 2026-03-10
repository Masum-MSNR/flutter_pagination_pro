import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  // ────────────────────────────────────────────────────────────────────────
  // 1. pageSize auto last-page detection
  // ────────────────────────────────────────────────────────────────────────

  group('pageSize auto-detection', () {
    test('detects last page when first page returns fewer items than pageSize',
        () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [1, 2, 3], // 3 items, pageSize = 10
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);
      expect(controller.items.length, 3);

      controller.dispose();
    });

    test('does not mark last page when items == pageSize', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();

      expect(controller.status, PaginationStatus.loaded);
      expect(controller.hasMorePages, true);

      controller.dispose();
    });

    test('detects last page on subsequent loadNextPage', () async {
      int callCount = 0;
      final controller = PaginationController<int>(
        fetchPage: (page) async {
          callCount++;
          if (callCount == 1) return List.generate(10, (i) => i);
          return [100, 101, 102]; // partial page
        },
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();
      expect(controller.status, PaginationStatus.loaded);
      expect(controller.hasMorePages, true);

      await controller.loadNextPage();
      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);
      expect(controller.items.length, 13);

      controller.dispose();
    });

    test('detects last page on refresh with partial page', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [1, 2, 3],
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();
      await controller.refresh();

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);

      controller.dispose();
    });

    test('empty first page still returns empty status (not completed)',
        () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [],
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();

      expect(controller.status, PaginationStatus.empty);
      expect(controller.hasMorePages, false);

      controller.dispose();
    });

    test('without pageSize, full-page responses still show loaded', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(5, (i) => i),
        // No pageSize — default behavior
      );

      await controller.loadFirstPage();

      expect(controller.status, PaginationStatus.loaded);
      expect(controller.hasMorePages, true);

      controller.dispose();
    });

    test('PaginationConfig stores pageSize', () {
      const config = PaginationConfig(pageSize: 20);
      expect(config.pageSize, 20);

      const defaults = PaginationConfig.defaults;
      expect(defaults.pageSize, isNull);
    });

    test('PaginationConfig equality includes pageSize', () {
      const a = PaginationConfig(pageSize: 20);
      const b = PaginationConfig(pageSize: 20);
      const c = PaginationConfig(pageSize: 30);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('PaginationConfig copyWith preserves pageSize', () {
      const config = PaginationConfig(pageSize: 20);
      final copied = config.copyWith(scrollThreshold: 500.0);

      expect(copied.pageSize, 20);
      expect(copied.scrollThreshold, 500.0);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 2. initialItems support
  // ────────────────────────────────────────────────────────────────────────

  group('initialItems', () {
    test('starts in loaded state with initial items', () {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
        initialItems: ['a', 'b', 'c'],
      );

      expect(controller.status, PaginationStatus.loaded);
      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.currentPage, 1); // config.initialPage
      expect(controller.hasMorePages, true);

      controller.dispose();
    });

    test('empty initialItems list is treated as no initial items', () {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
        initialItems: [],
      );

      expect(controller.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);

      controller.dispose();
    });

    test('null initialItems is treated as no initial items', () {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );

      expect(controller.status, PaginationStatus.initial);

      controller.dispose();
    });

    test('initialItems with custom initialPage uses config page', () {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [],
        config: const PaginationConfig(initialPage: 0),
        initialItems: [10, 20, 30],
      );

      expect(controller.currentPage, 0);
      expect(controller.items, [10, 20, 30]);

      controller.dispose();
    });

    test('autoLoadFirstPage does not fire when initialItems provided',
        () async {
      // With initialItems, status is `loaded` (not `initial`),
      // so the auto-load guard skips.
      int fetchCallCount = 0;
      final controller = PaginationController<int>(
        fetchPage: (_) async {
          fetchCallCount++;
          return [1, 2, 3];
        },
        initialItems: [10, 20],
      );

      // Give time for any post-frame callbacks
      await Future<void>.delayed(Duration.zero);

      expect(fetchCallCount, 0);
      expect(controller.items, [10, 20]);

      controller.dispose();
    });

    test('loadNextPage works after initialItems', () async {
      final controller = PaginationController<int>(
        fetchPage: (page) async {
          return List.generate(5, (i) => page * 100 + i);
        },
        initialItems: [1, 2, 3],
      );

      expect(controller.currentPage, 1);

      await controller.loadNextPage();

      expect(controller.currentPage, 2);
      expect(controller.items.length, 8); // 3 initial + 5 from page 2
      expect(controller.items.sublist(0, 3), [1, 2, 3]);

      controller.dispose();
    });

    test('refresh replaces initialItems with fresh data', () async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => ['fresh1', 'fresh2'],
        initialItems: ['cached1', 'cached2'],
      );

      expect(controller.items, ['cached1', 'cached2']);

      await controller.refresh();

      expect(controller.items, ['fresh1', 'fresh2']);

      controller.dispose();
    });

    test('initialItems are defensively copied', () {
      final original = ['a', 'b', 'c'];
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
        initialItems: original,
      );

      // Mutating the original list should not affect controller
      original.add('d');

      expect(controller.items.length, 3);

      controller.dispose();
    });

    testWidgets('widget skips initial load with initialItems', (tester) async {
      int fetchCount = 0;
      final controller = PaginationController<String>(
        fetchPage: (_) async {
          fetchCount++;
          return ['fetched'];
        },
        initialItems: ['cached item 1', 'cached item 2'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Items should display immediately without fetch
      expect(find.text('cached item 1'), findsOneWidget);
      expect(find.text('cached item 2'), findsOneWidget);
      expect(fetchCount, 0);

      controller.dispose();
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 3. findChildIndexCallback passthrough
  // ────────────────────────────────────────────────────────────────────────

  group('findChildIndexCallback', () {
    testWidgets('PaginationListView passes findChildIndexCallback',
        (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => ['A', 'B', 'C'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(key: ValueKey(item), title: Text(item)),
              findChildIndexCallback: (Key key) {
                return null;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Items should render regardless
      expect(find.text('A'), findsOneWidget);
      // The callback existing doesn't break anything
      expect(controller.items.length, 3);

      controller.dispose();
    });

    testWidgets('PaginationGridView passes findChildIndexCallback',
        (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => ['A', 'B', 'C', 'D'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<String>.withController(
              controller: controller,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) =>
                  Card(key: ValueKey(item), child: Center(child: Text(item))),
              findChildIndexCallback: (Key key) {
                if (key is ValueKey<String>) {
                  final items = ['A', 'B', 'C', 'D'];
                  return items.indexOf(key.value);
                }
                return null;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('D'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('PaginationListView null findChildIndexCallback works',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (_) async => ['X', 'Y'],
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              // findChildIndexCallback not provided (null)
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // 4. totalItems / setTotalItems
  // ────────────────────────────────────────────────────────────────────────

  group('totalItems / setTotalItems', () {
    test('totalItems is null by default', () {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [],
      );

      expect(controller.state.totalItems, isNull);

      controller.dispose();
    });

    test('setTotalItems stores the value', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
      );

      await controller.loadFirstPage();
      controller.setTotalItems(50);

      expect(controller.state.totalItems, 50);
      expect(controller.hasMorePages, true);

      controller.dispose();
    });

    test('setTotalItems sets completed when all items loaded', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
      );

      await controller.loadFirstPage();
      expect(controller.items.length, 10);

      controller.setTotalItems(10);

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);
      expect(controller.state.totalItems, 10);

      controller.dispose();
    });

    test('setTotalItems keeps loaded status when more items exist', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
      );

      await controller.loadFirstPage();
      controller.setTotalItems(100);

      expect(controller.status, PaginationStatus.loaded);
      expect(controller.hasMorePages, true);

      controller.dispose();
    });

    test('totalItems preserved through loadNextPage', () async {
      int callCount = 0;
      final controller = PaginationController<int>(
        fetchPage: (_) async {
          callCount++;
          return List.generate(10, (i) => callCount * 100 + i);
        },
      );

      await controller.loadFirstPage();
      controller.setTotalItems(25);
      expect(controller.state.totalItems, 25);

      await controller.loadNextPage();
      // totalItems should survive the copyWith in loadNextPage
      expect(controller.state.totalItems, 25);

      controller.dispose();
    });

    test('totalItems cleared on reset', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [1, 2, 3],
      );

      await controller.loadFirstPage();
      controller.setTotalItems(50);
      expect(controller.state.totalItems, 50);

      controller.reset();
      expect(controller.state.totalItems, isNull);

      controller.dispose();
    });

    test('PaginationState.copyWith preserves totalItems', () {
      const state = PaginationState<int>(
        items: [1, 2],
        totalItems: 100,
      );

      final updated = state.copyWith(currentPage: 2);

      expect(updated.totalItems, 100);
    });

    test('PaginationState.copyWith can update totalItems', () {
      const state = PaginationState<int>(
        items: [1, 2],
      );

      final updated = state.copyWith(totalItems: 50);

      expect(updated.totalItems, 50);
    });

    test('PaginationState equality includes totalItems', () {
      const a = PaginationState<int>(items: [1], totalItems: 50);
      const b = PaginationState<int>(items: [1], totalItems: 50);
      const c = PaginationState<int>(items: [1], totalItems: 100);

      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('PaginationState.toString includes totalItems', () {
      const state = PaginationState<int>(items: [1, 2], totalItems: 42);
      expect(state.toString(), contains('totalItems: 42'));
    });

    test('setTotalItems does not loop infinitely', () async {
      // Regression: setTotalItems triggers _onStateChanged → onPageLoaded →
      // user calls setTotalItems again → should be a no-op (state unchanged).
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
      );

      await controller.loadFirstPage();

      int notifyCount = 0;
      controller.addListener(() => notifyCount++);

      // First call: sets totalItems=10, transitions to completed
      controller.setTotalItems(10);
      expect(notifyCount, 1);

      // Second call: same state → ValueNotifier skips notification
      controller.setTotalItems(10);
      expect(notifyCount, 1); // no additional notification

      controller.dispose();
    });

    testWidgets('totalItems accessible in widget via controller',
        (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => ['A', 'B', 'C'],
      );

      String? displayText;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              onPageLoaded: (page, items) {
                controller.setTotalItems(100);
                displayText =
                    'Showing ${controller.items.length} of ${controller.state.totalItems}';
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(displayText, 'Showing 3 of 100');

      controller.dispose();
    });
  });

  // ────────────────────────────────────────────────────────────────────────
  // Integration: pageSize + initialItems combo
  // ────────────────────────────────────────────────────────────────────────

  group('Feature combinations', () {
    test('initialItems + pageSize: loadNextPage detects partial page',
        () async {
      final controller = PaginationController<int>(
        fetchPage: (page) async {
          if (page == 2) return [100, 101]; // partial page
          return List.generate(10, (i) => i);
        },
        config: const PaginationConfig(pageSize: 10),
        initialItems: List.generate(10, (i) => i),
      );

      expect(controller.status, PaginationStatus.loaded);

      await controller.loadNextPage();

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);
      expect(controller.items.length, 12);

      controller.dispose();
    });

    test('initialItems + setTotalItems', () {
      final controller = PaginationController<int>(
        fetchPage: (_) async => [],
        initialItems: [1, 2, 3],
      );

      controller.setTotalItems(3);

      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);

      controller.dispose();
    });

    test('pageSize + setTotalItems: both mechanisms coexist', () async {
      final controller = PaginationController<int>(
        fetchPage: (_) async => List.generate(10, (i) => i),
        config: const PaginationConfig(pageSize: 10),
      );

      await controller.loadFirstPage();
      controller.setTotalItems(10);

      // Both agree: all loaded
      expect(controller.status, PaginationStatus.completed);
      expect(controller.hasMorePages, false);

      controller.dispose();
    });
  });
}
