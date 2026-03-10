import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

/// Tests for the convenience API: optional initialPageKey, PagedXxx typedefs.
void main() {
  group('Optional initialPageKey', () {
    test('defaults to 1 for int keys', () {
      final controller = PaginationController<int, String>(
        fetchPage: (_) async => [],
      );
      expect(controller, isNotNull);
      expect(controller.status, PaginationStatus.initial);
      controller.dispose();
    });

    test('explicit initialPageKey still works', () {
      final controller = PaginationController<int, String>(
        fetchPage: (_) async => [],
        initialPageKey: 5,
      );
      expect(controller, isNotNull);
      controller.dispose();
    });

    test('throws for non-int key without initialPageKey', () {
      expect(
        () => PaginationController<String, String>(
          fetchPage: (_) async => [],
          nextPageKeyBuilder: (_, items) => '',
        ),
        throwsArgumentError,
      );
    });

    test('non-int key works when initialPageKey provided', () {
      final controller = PaginationController<String, String>(
        fetchPage: (_) async => [],
        initialPageKey: 'start',
        nextPageKeyBuilder: (_, items) => 'next',
      );
      expect(controller, isNotNull);
      controller.dispose();
    });

    test('loads first page correctly with default initialPageKey', () async {
      int? receivedPage;
      final controller = PaginationController<int, String>(
        fetchPage: (page) async {
          receivedPage = page;
          return ['a', 'b', 'c'];
        },
      );

      await controller.loadFirstPage();

      expect(receivedPage, 1);
      expect(controller.items, ['a', 'b', 'c']);
      controller.dispose();
    });
  });

  group('PagedController typedef', () {
    test('creates PaginationController<int, T>', () {
      final controller = PagedController<String>(
        fetchPage: (_) async => [],
      );
      expect(controller, isA<PaginationController<int, String>>());
      controller.dispose();
    });

    test('loads pages correctly', () async {
      final controller = PagedController<String>(
        fetchPage: (page) async {
          if (page <= 2) return List.generate(3, (i) => 'p${page}i$i');
          return [];
        },
      );

      await controller.loadFirstPage();
      expect(controller.items.length, 3);
      expect(controller.items.first, 'p1i0');

      await controller.loadNextPage();
      expect(controller.items.length, 6);

      controller.dispose();
    });
  });

  group('PagedListView typedef', () {
    Future<List<String>> mockFetch(int page) async {
      if (page <= 2) {
        return List.generate(5, (i) => 'Item ${(page - 1) * 5 + i}');
      }
      return [];
    }

    testWidgets('renders items without initialPageKey', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PagedListView<String>(
              fetchPage: mockFetch,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 0'), findsOneWidget);
      expect(find.text('Item 4'), findsOneWidget);
    });

    testWidgets('shows loading indicator initially', (tester) async {
      final completer = Completer<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PagedListView<String>(
              fetchPage: (_) => completer.future,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      completer.complete([]);
      await tester.pumpAndSettle();
    });

    testWidgets('.withController works', (tester) async {
      final controller = PagedController<String>(
        fetchPage: mockFetch,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PagedListView<String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('Item 0'), findsOneWidget);

      controller.dispose();
    });
  });

  group('PagedGridView typedef', () {
    Future<List<String>> mockFetch(int page) async {
      if (page <= 2) {
        return List.generate(4, (i) => 'Grid ${(page - 1) * 4 + i}');
      }
      return [];
    }

    testWidgets('renders items without initialPageKey', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PagedGridView<String>(
              fetchPage: mockFetch,
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
      expect(find.text('Grid 0'), findsOneWidget);
    });
  });

  group('PaginationListView without initialPageKey', () {
    testWidgets('works with explicit <int, T> and no initialPageKey',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>(
              fetchPage: (_) async => ['a', 'b'],
              itemBuilder: (context, item, index) =>
                  ListTile(title: Text(item)),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('a'), findsOneWidget);
      expect(find.text('b'), findsOneWidget);
    });
  });
}
