import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  // ── Helper to create a mock fetch ─────────────────────────────────────

  FetchPage<int, String> mockFetch({
    int pageSize = 5,
    int totalItems = 20,
    int delayMs = 10,
    int? errorOnPage,
  }) {
    return (int page) async {
      await Future.delayed(Duration(milliseconds: delayMs));
      if (errorOnPage != null && page == errorOnPage) {
        throw Exception('Error on page $page');
      }
      final start = (page - 1) * pageSize;
      if (start >= totalItems) return [];
      final end = (start + pageSize).clamp(0, totalItems);
      return List.generate(end - start, (i) => 'Item ${start + i + 1}');
    };
  }

  Widget buildApp({
    PaginationController<int, String>? controller,
    FetchPage<int, String>? fetchPage,
    PaginatedAnimatedItemBuilder<String>? itemBuilder,
    ItemBuilder<String>? plainItemBuilder,
    PaginatedAnimatedItemBuilder<String>? removeItemBuilder,
    Duration insertDuration = const Duration(milliseconds: 100),
    Duration removeDuration = const Duration(milliseconds: 100),
    Duration staggerDelay = Duration.zero,
    WidgetBuilder? firstPageLoadingBuilder,
    WidgetBuilder? emptyBuilder,
    Widget Function(BuildContext, Object, VoidCallback)?
        firstPageErrorBuilder,
    WidgetBuilder? loadMoreLoadingBuilder,
    Widget Function(BuildContext, Object, VoidCallback)?
        loadMoreErrorBuilder,
    WidgetBuilder? endOfListBuilder,
    PaginationConfig config = const PaginationConfig(pageSize: 5),
  }) {
    final effectiveItemBuilder =
        itemBuilder ?? (plainItemBuilder != null ? null : null);
    final effectivePlainBuilder = plainItemBuilder ??
        (BuildContext context, String item, int index) =>
            ListTile(key: ValueKey(item), title: Text(item));

    if (controller != null) {
      return MaterialApp(
        home: Scaffold(
          body: AnimatedPaginationListView<int, String>.withController(
            controller: controller,
            itemBuilder: effectiveItemBuilder,
            plainItemBuilder:
                effectiveItemBuilder == null ? effectivePlainBuilder : null,
            removeItemBuilder: removeItemBuilder,
            insertDuration: insertDuration,
            removeDuration: removeDuration,
            staggerDelay: staggerDelay,
            firstPageLoadingBuilder: firstPageLoadingBuilder,
            firstPageErrorBuilder: firstPageErrorBuilder,
            emptyBuilder: emptyBuilder,
            loadMoreLoadingBuilder: loadMoreLoadingBuilder,
            loadMoreErrorBuilder: loadMoreErrorBuilder,
            endOfListBuilder: endOfListBuilder,
          ),
        ),
      );
    }

    return MaterialApp(
      home: Scaffold(
        body: AnimatedPaginationListView<int, String>(
          fetchPage: fetchPage ?? mockFetch(),
          itemBuilder: effectiveItemBuilder,
          plainItemBuilder:
              effectiveItemBuilder == null ? effectivePlainBuilder : null,
          removeItemBuilder: removeItemBuilder,
          insertDuration: insertDuration,
          removeDuration: removeDuration,
          staggerDelay: staggerDelay,
          firstPageLoadingBuilder: firstPageLoadingBuilder,
          firstPageErrorBuilder: firstPageErrorBuilder,
          emptyBuilder: emptyBuilder,
          loadMoreLoadingBuilder: loadMoreLoadingBuilder,
          loadMoreErrorBuilder: loadMoreErrorBuilder,
          endOfListBuilder: endOfListBuilder,
          config: config,
        ),
      ),
    );
  }

  group('AnimatedPaginationListView', () {
    testWidgets('shows loading then items', (tester) async {
      await tester.pumpWidget(buildApp());

      // Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for data to load
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      // Items should appear
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
    });

    testWidgets('shows first page error', (tester) async {
      await tester.pumpWidget(buildApp(
        fetchPage: mockFetch(errorOnPage: 1),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.textContaining('Error on page 1'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(buildApp(
        fetchPage: mockFetch(totalItems: 0),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('custom first page loading builder', (tester) async {
      await tester.pumpWidget(buildApp(
        firstPageLoadingBuilder: (_) => const Text('Custom Loading'),
      ));

      expect(find.text('Custom Loading'), findsOneWidget);

      // Pump to settle the pending fetch timer
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
    });

    testWidgets('custom empty builder', (tester) async {
      await tester.pumpWidget(buildApp(
        fetchPage: mockFetch(totalItems: 0),
        emptyBuilder: (_) => const Text('Nothing here'),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('Nothing here'), findsOneWidget);
    });

    testWidgets('custom error builder', (tester) async {
      await tester.pumpWidget(buildApp(
        fetchPage: mockFetch(errorOnPage: 1),
        firstPageErrorBuilder: (_, error, retry) =>
            Text('Custom Error: $error'),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.textContaining('Custom Error'), findsOneWidget);
    });

    testWidgets('uses plainItemBuilder with default animation',
        (tester) async {
      await tester.pumpWidget(buildApp(
        plainItemBuilder: (context, item, index) =>
            Text('Plain $item', key: ValueKey(item)),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Plain Item 1'), findsOneWidget);
    });

    testWidgets('uses custom itemBuilder with animation', (tester) async {
      await tester.pumpWidget(buildApp(
        itemBuilder: (context, item, index, animation) => FadeTransition(
          opacity: animation,
          child: Text('Animated $item', key: ValueKey(item)),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Animated Item 1'), findsOneWidget);
    });

    testWidgets('withController shows pre-loaded items', (tester) async {
      final items = List.generate(5, (i) => 'Item ${i + 1}');
      final controller = PaginationController<int, String>(
        fetchPage: mockFetch(),
        config: const PaginationConfig(pageSize: 5),
        initialItems: items,
      );

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('shows end of list widget when completed', (tester) async {
      await tester.pumpWidget(buildApp(
        fetchPage: mockFetch(totalItems: 3, pageSize: 5),
      ));

      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      // Should show default end of list since totalItems < pageSize
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
      // PaginationStatus.completed shows DefaultEndOfList
      expect(find.byType(DefaultEndOfList), findsOneWidget);
    });

    testWidgets('controller insertItem animates', (tester) async {
      final items = List.generate(5, (i) => 'Item ${i + 1}');
      final controller = PaginationController<int, String>(
        fetchPage: mockFetch(),
        config: const PaginationConfig(pageSize: 5),
        initialItems: items,
      );

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);

      // Insert an item
      controller.insertItem(0, 'New Item');

      await tester.pump(); // Trigger rebuild
      await tester.pump(const Duration(milliseconds: 200)); // Animation

      expect(find.text('New Item'), findsOneWidget);
      expect(controller.items.first, 'New Item');

      controller.dispose();
    });

    testWidgets('controller removeItemAt animates removal', (tester) async {
      final items = List.generate(5, (i) => 'Item ${i + 1}');
      final controller = PaginationController<int, String>(
        fetchPage: mockFetch(),
        config: const PaginationConfig(pageSize: 5),
        initialItems: items,
      );

      await tester.pumpWidget(buildApp(controller: controller));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);

      // Remove the first item
      controller.removeItemAt(0);

      await tester.pump(); // Trigger rebuild
      await tester.pump(const Duration(milliseconds: 200)); // Animation

      expect(controller.items, isNot(contains('Item 1')));

      controller.dispose();
    });

    testWidgets('stagger delay spaces out insert animations', (tester) async {
      final controller = PaginationController<int, String>(
        fetchPage: mockFetch(),
        config: const PaginationConfig(pageSize: 5),
      );

      await tester.pumpWidget(buildApp(
        controller: controller,
        staggerDelay: const Duration(milliseconds: 30),
        insertDuration: const Duration(milliseconds: 100),
      ));

      // Load first page — triggers staggered insert
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();
      // Let all stagger animations settle
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('retry first page error reloads', (tester) async {
      var shouldFail = true;
      final fetch = (int page) async {
        await Future.delayed(const Duration(milliseconds: 10));
        if (shouldFail && page == 1) {
          throw Exception('Failed');
        }
        return ['A', 'B', 'C'];
      };

      await tester.pumpWidget(buildApp(fetchPage: fetch));

      // Wait for error
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump();

      expect(find.text('Try Again'), findsOneWidget);

      // Fix and retry
      shouldFail = false;
      await tester.tap(find.text('Try Again'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('uses convenience typedef', (tester) async {
      // Verify AnimatedPagedListView<T> compiles and works
      final items = List.generate(5, (i) => 'Item ${i + 1}');
      final controller = PagedController<String>(
        fetchPage: mockFetch(),
        config: const PaginationConfig(pageSize: 5),
        initialItems: items,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: AnimatedPagedListView<String>.withController(
            controller: controller,
            plainItemBuilder: (context, item, index) => Text(item),
          ),
        ),
      ));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);

      controller.dispose();
    });
  });
}
