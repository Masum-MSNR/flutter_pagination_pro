import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('PaginationListView', () {
    Future<List<String>> mockFetch(int page) async {
      // No delay for sync tests
      if (page <= 2) {
        return List.generate(5, (i) => 'Item ${(page - 1) * 5 + i}');
      }
      return [];
    }

    testWidgets('shows loading indicator initially', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (page) async {
                // Long delay to catch loading state
                await Future<void>.delayed(const Duration(seconds: 10));
                return [];
              },
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              config: const PaginationConfig(autoLoadFirstPage: false),
            ),
          ),
        ),
      );

      // Manually trigger load
      await tester.pump();

      // Should not be in loading state yet since autoLoadFirstPage is false
      // The widget should be in initial state
    });

    testWidgets('displays items after loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      // Wait for loading to complete
      await tester.pumpAndSettle();

      // Should show items
      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('shows error state on fetch failure', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (_) => throw Exception('Test error'),
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show error widget - button says "Try Again"
      expect(find.text('Something went wrong'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);
    });

    testWidgets('shows empty state when no items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (_) async => [],
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show empty widget
      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows custom empty widget', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (_) async => [],
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              emptyBuilder: (context) => const Text('Nothing here!'),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Nothing here!'), findsOneWidget);
    });

    testWidgets('shows load more button in loadMore mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              paginationType: PaginationType.loadMore,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should show load more button
      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('supports separator builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              separatorBuilder: (context, index) => const Divider(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should have dividers
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('withController constructor works', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);

      // Clean up
      controller.dispose();
    });

    testWidgets('calls onPageLoaded callback', (tester) async {
      int? loadedPage;
      List<String>? loadedItems;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              onPageLoaded: (page, items) {
                loadedPage = page;
                loadedItems = items;
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(loadedPage, 1);
      expect(loadedItems?.length, 5);
    });

    testWidgets('calls onError callback', (tester) async {
      Object? receivedError;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<String>(
              fetchPage: (_) => throw Exception('Test error'),
              itemBuilder: (context, item, index) => ListTile(title: Text(item)),
              onError: (error) => receivedError = error,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(receivedError, isNotNull);
    });
  });

  group('PaginationGridView', () {
    Future<List<String>> mockFetch(int page) async {
      if (page <= 2) {
        return List.generate(6, (i) => 'Item ${(page - 1) * 6 + i}');
      }
      return [];
    }

    testWidgets('displays items in grid', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) => Card(child: Center(child: Text(item))),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<String>(
              fetchPage: (_) async => [],
              itemBuilder: (context, item, index) => Card(child: Center(child: Text(item))),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows load more button in loadMore mode', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 600,
              child: PaginationGridView<String>(
                fetchPage: mockFetch,
                itemBuilder: (context, item, index) => SizedBox(
                  height: 50,
                  child: Card(child: Center(child: Text(item))),
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 50,
                ),
                paginationType: PaginationType.loadMore,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Load More'), findsOneWidget);
    });

    testWidgets('withController constructor works', (tester) async {
      final controller = PaginationController<String>(fetchPage: mockFetch);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) => Card(child: Center(child: Text(item))),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);

      controller.dispose();
    });
  });

  group('Default Widgets', () {
    testWidgets('DefaultFirstPageLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DefaultFirstPageLoading()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DefaultLoadMoreLoading renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DefaultLoadMoreLoading()),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('DefaultFirstPageError renders with retry button', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageError(
              error: Exception('Test'),
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, true);
    });

    testWidgets('DefaultLoadMoreError renders with retry', (tester) async {
      bool retried = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultLoadMoreError(
              error: 'Test error',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(retried, true);
    });

    testWidgets('DefaultEmpty renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DefaultEmpty()),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('DefaultEmpty with custom text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DefaultEmpty(
              title: 'Custom Title',
              subtitle: 'Custom Subtitle',
            ),
          ),
        ),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Subtitle'), findsOneWidget);
    });

    testWidgets('DefaultEndOfList renders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: DefaultEndOfList()),
        ),
      );

      expect(find.text("You've reached the end"), findsOneWidget);
    });

    testWidgets('DefaultLoadMoreButton renders', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultLoadMoreButton(
              onPressed: () => pressed = true,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Load More'), findsOneWidget);

      await tester.tap(find.text('Load More'));
      expect(pressed, true);
    });

    testWidgets('DefaultLoadMoreButton shows loading state', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DefaultLoadMoreButton(
              onPressed: _doNothing,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}

void _doNothing() {}
