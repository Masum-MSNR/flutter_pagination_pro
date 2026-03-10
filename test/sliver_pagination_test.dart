import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  // ── Helpers ───────────────────────────────────────────────────────────

  Future<List<String>> mockFetch(int page) async {
    if (page <= 2) {
      return List.generate(5, (i) => 'Item ${(page - 1) * 5 + i}');
    }
    return [];
  }

  Widget buildSliverList({
    required PaginationController<String> controller,
    ScrollController? scrollController,
    PaginationType paginationType = PaginationType.infiniteScroll,
    SeparatorBuilder? separatorBuilder,
    LoadingBuilder? firstPageLoadingBuilder,
    ErrorBuilder? firstPageErrorBuilder,
    EmptyBuilder? emptyBuilder,
    EndOfListBuilder? endOfListBuilder,
    LoadMoreBuilder? loadMoreButtonBuilder,
  }) {
    final sc = scrollController ?? ScrollController();
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          controller: sc,
          slivers: [
            SliverPaginatedList<String>(
              controller: controller,
              scrollController: sc,
              paginationType: paginationType,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
              separatorBuilder: separatorBuilder,
              firstPageLoadingBuilder: firstPageLoadingBuilder,
              firstPageErrorBuilder: firstPageErrorBuilder,
              emptyBuilder: emptyBuilder,
              endOfListBuilder: endOfListBuilder,
              loadMoreButtonBuilder: loadMoreButtonBuilder,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSliverGrid({
    required PaginationController<String> controller,
    ScrollController? scrollController,
    PaginationType paginationType = PaginationType.infiniteScroll,
    LoadingBuilder? firstPageLoadingBuilder,
    ErrorBuilder? firstPageErrorBuilder,
    EmptyBuilder? emptyBuilder,
  }) {
    final sc = scrollController ?? ScrollController();
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          controller: sc,
          slivers: [
            SliverPaginatedGrid<String>(
              controller: controller,
              scrollController: sc,
              paginationType: paginationType,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) =>
                  Card(child: Center(child: Text(item))),
              firstPageLoadingBuilder: firstPageLoadingBuilder,
              firstPageErrorBuilder: firstPageErrorBuilder,
              emptyBuilder: emptyBuilder,
            ),
          ],
        ),
      ),
    );
  }

  // ── SliverPaginatedList ─────────────────────────────────────────────

  group('SliverPaginatedList', () {
    testWidgets('shows loading indicator while first page loads',
        (tester) async {
      final completer = Completer<List<String>>();
      final controller = PaginationController<String>(
        fetchPage: (_) => completer.future,
      );
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete([]);
        }
        controller.dispose();
      });

      await tester.pumpWidget(buildSliverList(controller: controller));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending timer
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays fetched items', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverList(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) => throw Exception('Test error'),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverList(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows empty state when no items returned', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverList(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows custom empty widget', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildSliverList(
          controller: controller,
          emptyBuilder: (_) => const Text('Custom empty'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Custom empty'), findsOneWidget);
    });

    testWidgets('shows custom error widget', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) => throw Exception('Boom'),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildSliverList(
          controller: controller,
          firstPageErrorBuilder: (_, error, retry) =>
              Text('Error: $error'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('Error:'), findsOneWidget);
    });

    testWidgets('renders separators between items', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildSliverList(
          controller: controller,
          separatorBuilder: (_, __) => const Divider(key: Key('sep')),
        ),
      );
      await tester.pumpAndSettle();

      // There should be separators between items
      expect(find.byKey(const Key('sep')), findsWidgets);
    });

    testWidgets('shows load more button in loadMore mode', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildSliverList(
          controller: controller,
          paginationType: PaginationType.loadMore,
        ),
      );
      await tester.pumpAndSettle();

      // Items loaded, load more button should be visible
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('controller refresh reloads data', (tester) async {
      int callCount = 0;
      final controller = PaginationController<String>(
        fetchPage: (page) async {
          callCount++;
          return ['Call $callCount'];
        },
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverList(controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('Call 1'), findsOneWidget);

      controller.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Call 2'), findsOneWidget);
    });
  });

  // ── SliverPaginatedGrid ─────────────────────────────────────────────

  group('SliverPaginatedGrid', () {
    testWidgets('shows loading indicator while first page loads',
        (tester) async {
      final completer = Completer<List<String>>();
      final controller = PaginationController<String>(
        fetchPage: (_) => completer.future,
      );
      addTearDown(() {
        if (!completer.isCompleted) {
          completer.complete([]);
        }
        controller.dispose();
      });

      await tester.pumpWidget(buildSliverGrid(controller: controller));
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete to avoid pending timer
      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('displays fetched items in grid', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverGrid(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      // Item 4 may be off-screen in a 2-column grid, just check first items
      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) => throw Exception('Grid error'),
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverGrid(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows empty state when no items returned', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverGrid(controller: controller));
      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows custom empty widget', (tester) async {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildSliverGrid(
          controller: controller,
          emptyBuilder: (_) => const Text('Grid empty'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Grid empty'), findsOneWidget);
    });

    testWidgets('controller refresh reloads data', (tester) async {
      int callCount = 0;
      final controller = PaginationController<String>(
        fetchPage: (page) async {
          callCount++;
          return ['Grid $callCount'];
        },
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(buildSliverGrid(controller: controller));
      await tester.pumpAndSettle();
      expect(find.text('Grid 1'), findsOneWidget);

      controller.refresh();
      await tester.pumpAndSettle();
      expect(find.text('Grid 2'), findsOneWidget);
    });
  });

  // ── Composability ───────────────────────────────────────────────────

  group('Sliver composability', () {
    testWidgets('SliverPaginatedList works alongside other slivers',
        (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      final scrollController = ScrollController();
      addTearDown(() {
        controller.dispose();
        scrollController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                const SliverAppBar(title: Text('Header'), floating: true),
                SliverPaginatedList<String>(
                  controller: controller,
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

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('SliverPaginatedGrid works alongside other slivers',
        (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);
      final scrollController = ScrollController();
      addTearDown(() {
        controller.dispose();
        scrollController.dispose();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollView(
              controller: scrollController,
              slivers: [
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Banner'),
                  ),
                ),
                SliverPaginatedGrid<String>(
                  controller: controller,
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

      expect(find.text('Banner'), findsOneWidget);
      expect(find.text('Item 0'), findsOneWidget);
    });
  });
}
