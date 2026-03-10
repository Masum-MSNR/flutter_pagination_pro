import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('BidirectionalPaginationState', () {
    test('default state', () {
      const state = BidirectionalPaginationState<int, String>();
      expect(state.forwardItems, isEmpty);
      expect(state.backwardItems, isEmpty);
      expect(state.status, PaginationStatus.initial);
      expect(state.isLoadingForward, false);
      expect(state.isLoadingBackward, false);
      expect(state.hasMoreForward, true);
      expect(state.hasMoreBackward, true);
      expect(state.items, isEmpty);
      expect(state.itemCount, 0);
      expect(state.isEmpty, true);
    });

    test('items getter combines backward + forward in display order', () {
      const state = BidirectionalPaginationState<int, String>(
        backwardItems: ['a', 'b'],
        forwardItems: ['c', 'd', 'e'],
      );
      expect(state.items, ['a', 'b', 'c', 'd', 'e']);
      expect(state.itemCount, 5);
      expect(state.isEmpty, false);
      expect(state.isNotEmpty, true);
    });

    test('copyWith updates fields', () {
      const state = BidirectionalPaginationState<int, String>();
      final updated = state.copyWith(
        forwardItems: ['x'],
        isLoadingForward: true,
        hasMoreBackward: false,
      );
      expect(updated.forwardItems, ['x']);
      expect(updated.isLoadingForward, true);
      expect(updated.hasMoreBackward, false);
      expect(updated.status, PaginationStatus.initial); // unchanged
    });

    test('copyWith clearError', () {
      final state = BidirectionalPaginationState<int, String>(
        error: Exception('oops'),
        forwardError: Exception('fwd'),
        backwardError: Exception('bwd'),
      );
      final cleared = state.copyWith(
        clearError: true,
        clearForwardError: true,
        clearBackwardError: true,
      );
      expect(cleared.error, isNull);
      expect(cleared.forwardError, isNull);
      expect(cleared.backwardError, isNull);
    });

    test('equality and hashCode', () {
      const a = BidirectionalPaginationState<int, String>(
        forwardItems: ['x'],
        hasMoreForward: false,
      );
      const b = BidirectionalPaginationState<int, String>(
        forwardItems: ['x'],
        hasMoreForward: false,
      );
      const c = BidirectionalPaginationState<int, String>(
        forwardItems: ['y'],
      );
      expect(a, equals(b));
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(equals(c)));
    });

    test('isInitialized check', () {
      const initial = BidirectionalPaginationState<int, String>();
      expect(initial.isInitialized, false);

      const loaded = BidirectionalPaginationState<int, String>(
        status: PaginationStatus.loaded,
      );
      expect(loaded.isInitialized, true);
    });
  });

  group('BidirectionalPaginationController', () {
    late BidirectionalPaginationController<int, String> controller;

    // Pages: 1=[a,b,c], 2=[d,e,f], 3=[g,h,i], 4=[]
    Future<List<String>> forwardFetch(int page) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (page > 3) return [];
      final base = (page - 1) * 3;
      return [
        String.fromCharCode(97 + base), // a, d, g
        String.fromCharCode(98 + base), // b, e, h
        String.fromCharCode(99 + base), // c, f, i
      ];
    }

    // Backward pages from anchor: page 4=[j,k,l], page 3=[m,n,o], etc.
    // For simplicity, let's just reverse the forward: page 0=[], page -1=[]
    Future<List<String>> backwardFetch(int page) async {
      await Future<void>.delayed(const Duration(milliseconds: 10));
      if (page < 1) return [];
      return ['bwd_${page}_1', 'bwd_${page}_2'];
    }

    setUp(() {
      controller = BidirectionalPaginationController<int, String>(
        fetchPage: forwardFetch,
        fetchPreviousPage: backwardFetch,
        initialPageKey: 2, // Start at page 2
        config: const PaginationConfig(pageSize: 3),
      );
    });

    tearDown(() {
      controller.dispose();
    });

    test('initial state', () {
      expect(controller.state.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);
    });

    test('loadInitialPage loads forward items', () async {
      await controller.loadInitialPage();

      expect(controller.state.status, PaginationStatus.loaded);
      expect(controller.state.forwardItems, ['d', 'e', 'f']); // page 2
      expect(controller.state.backwardItems, isEmpty);
      expect(controller.state.hasMoreForward, true);
      expect(controller.state.hasMoreBackward, true);
    });

    test('loadNextPage appends forward items', () async {
      await controller.loadInitialPage();
      await controller.loadNextPage();

      expect(controller.state.forwardItems, ['d', 'e', 'f', 'g', 'h', 'i']);
      expect(controller.state.hasMoreForward, true); // page 3 has 3 items

      await controller.loadNextPage(); // page 4 = empty
      expect(controller.state.hasMoreForward, false);
    });

    test('loadPreviousPage prepends backward items', () async {
      await controller.loadInitialPage(); // page 2
      await controller.loadPreviousPage(); // backward to page 1

      expect(controller.state.backwardItems, ['bwd_1_1', 'bwd_1_2']);
      expect(controller.state.hasMoreBackward, false); // key would be 0
    });

    test('items combines backward + forward correctly', () async {
      await controller.loadInitialPage();
      await controller.loadPreviousPage();

      final items = controller.items;
      // backward [bwd_1_1, bwd_1_2] + forward [d, e, f]
      expect(items, ['bwd_1_1', 'bwd_1_2', 'd', 'e', 'f']);
    });

    test('loadPreviousPage does nothing without fetchPreviousPage', () async {
      final forwardOnly = BidirectionalPaginationController<int, String>(
        fetchPage: forwardFetch,
        initialPageKey: 1,
        config: const PaginationConfig(pageSize: 3),
      );

      await forwardOnly.loadInitialPage();
      expect(forwardOnly.state.hasMoreBackward, false);

      await forwardOnly.loadPreviousPage(); // no-op
      expect(forwardOnly.state.backwardItems, isEmpty);

      forwardOnly.dispose();
    });

    test('loadNextPage does nothing before initial load', () async {
      await controller.loadNextPage();
      expect(controller.state.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);
    });

    test('handles initial page error', () async {
      final errorController = BidirectionalPaginationController<int, String>(
        fetchPage: (page) => throw Exception('fail'),
        initialPageKey: 1,
      );

      await errorController.loadInitialPage();

      expect(errorController.state.status, PaginationStatus.firstPageError);
      expect(errorController.state.error, isNotNull);

      errorController.dispose();
    });

    test('handles forward load error', () async {
      var callCount = 0;
      final errorController = BidirectionalPaginationController<int, String>(
        fetchPage: (page) async {
          callCount++;
          if (callCount == 1) return ['a', 'b'];
          throw Exception('forward fail');
        },
        initialPageKey: 1,
      );

      await errorController.loadInitialPage();
      await errorController.loadNextPage();

      expect(errorController.state.forwardError, isNotNull);
      expect(errorController.state.isLoadingForward, false);

      errorController.dispose();
    });

    test('handles backward load error', () async {
      final errorController = BidirectionalPaginationController<int, String>(
        fetchPage: (page) async => ['a', 'b'],
        fetchPreviousPage: (page) => throw Exception('backward fail'),
        initialPageKey: 5,
      );

      await errorController.loadInitialPage();
      await errorController.loadPreviousPage();

      expect(errorController.state.backwardError, isNotNull);
      expect(errorController.state.isLoadingBackward, false);

      errorController.dispose();
    });

    test('refresh resets and reloads', () async {
      await controller.loadInitialPage();
      await controller.loadNextPage();
      await controller.loadPreviousPage();

      expect(controller.items.length, greaterThan(3));

      await controller.refresh();

      // Should be back to just the initial page
      expect(controller.state.forwardItems, ['d', 'e', 'f']);
      expect(controller.state.backwardItems, isEmpty);
      expect(controller.state.status, PaginationStatus.loaded);
    });

    test('reset clears everything', () {
      controller.reset();
      expect(controller.state.status, PaginationStatus.initial);
      expect(controller.items, isEmpty);
    });

    test('retry retries the appropriate error', () async {
      var callCount = 0;
      final errorController = BidirectionalPaginationController<int, String>(
        fetchPage: (page) async {
          callCount++;
          if (callCount == 1) throw Exception('fail');
          return ['a'];
        },
        initialPageKey: 1,
      );

      await errorController.loadInitialPage();
      expect(errorController.state.status, PaginationStatus.firstPageError);

      await errorController.retry();
      expect(errorController.state.status, PaginationStatus.loaded);

      errorController.dispose();
    });

    test('empty initial page yields empty status', () async {
      final emptyController = BidirectionalPaginationController<int, String>(
        fetchPage: (page) async => [],
        initialPageKey: 1,
      );

      await emptyController.loadInitialPage();
      expect(emptyController.state.status, PaginationStatus.empty);

      emptyController.dispose();
    });
  });

  group('BidirectionalPaginationListView', () {
    Future<List<String>> mockFetch(int page) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (page > 3) return [];
      return List.generate(5, (i) => 'Item ${(page - 1) * 5 + i + 1}');
    }

    Future<List<String>> mockBackwardFetch(int page) async {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      if (page < 1) return [];
      return List.generate(3, (i) => 'Old ${page}_$i');
    }

    testWidgets('shows loading then items', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>(
            fetchPage: mockFetch,
            initialPageKey: 1,
            config: const PaginationConfig(pageSize: 5),
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      // Loading state
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for fetch (50ms) + rebuild
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Items should be visible
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 5'), findsOneWidget);
    });

    testWidgets('shows empty state', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>(
            fetchPage: (page) async => <String>[],
            initialPageKey: 1,
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.byType(DefaultEmpty), findsOneWidget);
    });

    testWidgets('shows error state with retry', (tester) async {
      var callCount = 0;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>(
            fetchPage: (page) async {
              callCount++;
              if (callCount == 1) throw Exception('Network error');
              return ['Item 1'];
            },
            initialPageKey: 1,
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.byType(DefaultFirstPageError), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Try Again'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('Item 1'), findsOneWidget);
    });

    testWidgets('.withController uses provided controller', (tester) async {
      final ctrl = BidirectionalPaginationController<int, String>(
        fetchPage: mockFetch,
        initialPageKey: 1,
        config: const PaginationConfig(pageSize: 5),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>.withController(
            controller: ctrl,
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Item 1'), findsOneWidget);

      ctrl.dispose();
    });

    test('bidirectional loads backward items (controller only)', () async {
      // Use a plain test (not testWidgets) so Future.delayed works normally
      final ctrl = BidirectionalPaginationController<int, String>(
        fetchPage: mockFetch,
        fetchPreviousPage: mockBackwardFetch,
        initialPageKey: 2,
        config: const PaginationConfig(pageSize: 5),
      );

      await ctrl.loadInitialPage();
      await ctrl.loadPreviousPage();

      expect(ctrl.state.forwardItems.length, 5);
      expect(ctrl.state.backwardItems.length, 3);
      expect(ctrl.items, [
        'Old 1_0', 'Old 1_1', 'Old 1_2', // backward
        'Item 6', 'Item 7', 'Item 8', 'Item 9', 'Item 10', // forward
      ]);

      ctrl.dispose();
    });

    testWidgets('uses convenience typedefs', (tester) async {
      final ctrl = BidirectionalPagedController<String>(
        fetchPage: mockFetch,
        initialPageKey: 1,
        config: const PaginationConfig(pageSize: 5),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPagedListView<String>.withController(
            controller: ctrl,
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();
      expect(find.text('Item 1'), findsOneWidget);

      ctrl.dispose();
    });

    testWidgets('separator builder works', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>(
            fetchPage: (page) async => ['A', 'B', 'C'],
            initialPageKey: 1,
            config: const PaginationConfig(pageSize: 3),
            itemBuilder: (context, item, index) => Text(item),
            separatorBuilder: (context, index) =>
                const Divider(key: Key('sep')),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      // 2 separators between 3 items
      expect(find.byKey(const Key('sep')), findsNWidgets(2));
    });

    testWidgets('reverse mode works (chat-style)', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BidirectionalPaginationListView<int, String>(
            fetchPage: mockFetch,
            initialPageKey: 1,
            reverse: true,
            config: const PaginationConfig(pageSize: 5),
            itemBuilder: (context, item, index) => ListTile(
              title: Text(item),
            ),
          ),
        ),
      ));

      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump();

      // Items should be present (reverse just flips scroll direction)
      expect(find.text('Item 1'), findsOneWidget);
    });
  });
}
