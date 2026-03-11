import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';
import 'package:flutter_pagination_pro/testing.dart';

void main() {
  // ═══════════════════════════════════════════════════════════════════════════
  // Feature 8: Skeleton / Shimmer First-Page Loading
  // ═══════════════════════════════════════════════════════════════════════════

  group('DefaultFirstPageLoading.builder()', () {
    testWidgets('renders correct number of skeleton items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.builder(
              itemBuilder: (context, index) => Container(
                key: ValueKey('skeleton-$index'),
                height: 60,
                color: Colors.grey.shade300,
              ),
              itemCount: 5,
            ),
          ),
        ),
      );

      for (int i = 0; i < 5; i++) {
        expect(find.byKey(ValueKey('skeleton-$i')), findsOneWidget);
      }
    });

    testWidgets('defaults to 6 items when itemCount not specified',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.builder(
              itemBuilder: (context, index) => Container(
                key: ValueKey('skeleton-$index'),
                height: 60,
              ),
            ),
          ),
        ),
      );

      // Default is 6 items
      for (int i = 0; i < 6; i++) {
        expect(find.byKey(ValueKey('skeleton-$i')), findsOneWidget);
      }
    });

    testWidgets('renders separators between items when separatorBuilder given',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.builder(
              itemBuilder: (context, index) => Container(
                key: ValueKey('skeleton-$index'),
                height: 40,
              ),
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(
                key: ValueKey('separator-$index'),
              ),
            ),
          ),
        ),
      );

      // 3 items
      for (int i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('skeleton-$i')), findsOneWidget);
      }
      // 2 separators (between items)
      expect(find.byKey(ValueKey('separator-0')), findsOneWidget);
      expect(find.byKey(ValueKey('separator-1')), findsOneWidget);
    });

    testWidgets('applies padding when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.builder(
              itemBuilder: (context, index) => Container(height: 60),
              itemCount: 3,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.padding, const EdgeInsets.all(16));
    });

    testWidgets('uses NeverScrollableScrollPhysics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.builder(
              itemBuilder: (context, index) => Container(height: 60),
              itemCount: 3,
            ),
          ),
        ),
      );

      final listView = tester.widget<ListView>(find.byType(ListView));
      expect(listView.physics, isA<NeverScrollableScrollPhysics>());
    });

    testWidgets('original DefaultFirstPageLoading still shows spinner',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('used as firstPageLoadingBuilder in PaginationListView',
        (tester) async {
      // Use controlled mode in loading state to avoid async fetch issues
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              firstPageLoadingBuilder: (context) =>
                  DefaultFirstPageLoading.builder(
                itemBuilder: (_, index) => Container(
                  key: ValueKey('shimmer-$index'),
                  height: 60,
                ),
                itemCount: 4,
              ),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      for (int i = 0; i < 4; i++) {
        expect(find.byKey(ValueKey('shimmer-$i')), findsOneWidget);
      }
    });
  });

  group('DefaultFirstPageLoading.fromItemBuilder()', () {
    testWidgets('renders real item builder with placeholder data as skeleton',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.fromItemBuilder<String>(
              itemBuilder: (context, item, index) => ListTile(
                key: ValueKey('item-$index'),
                title: Text(item),
                subtitle: Text('subtitle $index'),
              ),
              placeholderItem: 'Placeholder',
              itemCount: 5,
            ),
          ),
        ),
      );

      // All 5 items rendered
      for (int i = 0; i < 5; i++) {
        expect(find.byKey(ValueKey('item-$i')), findsOneWidget);
      }

      // Each item is wrapped in the skeletonize shimmer pipeline
      expect(find.byType(ShaderMask), findsNWidgets(5));
    });

    testWidgets('applies overlay color as shimmer base', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.fromItemBuilder<String>(
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'Test',
              itemCount: 3,
              overlayColor: Colors.blue.shade200,
            ),
          ),
        ),
      );

      // Shimmer uses ShaderMask with srcATop
      final shaderMask =
          tester.widget<ShaderMask>(find.byType(ShaderMask).first);
      expect(shaderMask.blendMode, BlendMode.srcATop);
    });

    testWidgets('defaults to theme-appropriate grey when no overlayColor given',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.light(),
          home: Scaffold(
            body: DefaultFirstPageLoading.fromItemBuilder<String>(
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
              itemCount: 1,
            ),
          ),
        ),
      );

      // Shimmer pipeline present
      expect(find.byType(ShaderMask), findsOneWidget);
    });

    testWidgets('supports separators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.fromItemBuilder<String>(
              itemBuilder: (context, item, index) => Container(
                key: ValueKey('item-$index'),
                height: 50,
                child: Text(item),
              ),
              placeholderItem: 'Dummy',
              itemCount: 3,
              separatorBuilder: (context, index) => Divider(
                key: ValueKey('sep-$index'),
                height: 1,
              ),
            ),
          ),
        ),
      );

      // 3 items + 2 separators
      for (int i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('item-$i')), findsOneWidget);
      }
      expect(find.byKey(ValueKey('sep-0')), findsOneWidget);
      expect(find.byKey(ValueKey('sep-1')), findsOneWidget);
    });

    testWidgets('used as firstPageLoadingBuilder with controlled mode',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              firstPageLoadingBuilder: (context) =>
                  DefaultFirstPageLoading.fromItemBuilder<String>(
                itemBuilder: (context, item, index) => ListTile(
                  key: ValueKey('skeleton-$index'),
                  title: Text(item),
                ),
                placeholderItem: '',
                itemCount: 4,
              ),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Skeletons rendered
      for (int i = 0; i < 4; i++) {
        expect(find.byKey(ValueKey('skeleton-$i')), findsOneWidget);
      }
      // All wrapped in skeletonize pipeline
      expect(find.byType(ShaderMask), findsNWidgets(4));
    });

    testWidgets('works with complex widget trees', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DefaultFirstPageLoading.fromItemBuilder<Map<String, String>>(
              itemBuilder: (context, item, index) => Card(
                key: ValueKey('card-$index'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] ?? ''),
                      const SizedBox(height: 8),
                      Text(item['subtitle'] ?? ''),
                    ],
                  ),
                ),
              ),
              placeholderItem: const {'title': 'Loading...', 'subtitle': '...'},
              itemCount: 3,
            ),
          ),
        ),
      );

      for (int i = 0; i < 3; i++) {
        expect(find.byKey(ValueKey('card-$i')), findsOneWidget);
      }
      expect(find.byType(ShaderMask), findsNWidgets(3));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature 9: Header / Footer Convenience Parameters
  // ═══════════════════════════════════════════════════════════════════════════

  group('Header / Footer — PaginationListView', () {
    testWidgets('header renders above items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Item 1', 'Item 2', 'Item 3'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              header: const Text('My Header'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('My Header'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);

      // Header should appear before items visually
      final headerOffset = tester.getTopLeft(find.text('My Header'));
      final item1Offset = tester.getTopLeft(find.text('Item 1'));
      expect(headerOffset.dy, lessThan(item1Offset.dy));
    });

    testWidgets('footer renders below items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Item 1', 'Item 2'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              footer: const Text('My Footer'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('My Footer'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);

      // Footer should appear below items
      final item2Offset = tester.getTopLeft(find.text('Item 2'));
      final footerOffset = tester.getTopLeft(find.text('My Footer'));
      expect(footerOffset.dy, greaterThan(item2Offset.dy));
    });

    testWidgets('both header and footer render together', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Item 1'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              header: const Text('Header'),
              footer: const Text('Footer'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);

      final headerY = tester.getTopLeft(find.text('Header')).dy;
      final itemY = tester.getTopLeft(find.text('Item 1')).dy;
      final footerY = tester.getTopLeft(find.text('Footer')).dy;

      expect(headerY, lessThan(itemY));
      expect(itemY, lessThan(footerY));
    });

    testWidgets('no header/footer uses plain ListView.builder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Item 1'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Without header/footer, should use ListView (not CustomScrollView)
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(CustomScrollView), findsNothing);
    });

    testWidgets('with header uses CustomScrollView', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['Item 1'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              header: const Text('Header'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.byType(CustomScrollView), findsOneWidget);
    });

    testWidgets('header works with separatorBuilder', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A', 'B', 'C'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              header: const Text('Header'),
              separatorBuilder: (context, index) => const Divider(
                key: ValueKey('divider'),
                height: 1,
              ),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
    });

    testWidgets('header/footer work with .withController constructor',
        (tester) async {
      final controller = PaginationController<int, String>(
        fetchPage: (_) async => ['X', 'Y'],
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.withController(
              controller: controller,
              header: const Text('Header'),
              footer: const Text('Footer'),
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Wait for first page to load
      await tester.pumpAndSettle();

      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      expect(find.text('X'), findsOneWidget);
      expect(find.text('Y'), findsOneWidget);
    });
  });

  group('Header / Footer — PaginationGridView', () {
    testWidgets('header renders above grid items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const ['A', 'B', 'C', 'D'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              header: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Grid Header'),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) => Center(child: Text(item)),
            ),
          ),
        ),
      );

      expect(find.text('Grid Header'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);

      final headerY = tester.getTopLeft(find.text('Grid Header')).dy;
      final itemY = tester.getTopLeft(find.text('A')).dy;
      expect(headerY, lessThan(itemY));
    });

    testWidgets('footer renders below grid items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const ['A', 'B'],
              status: PaginationStatus.loaded,
              hasMorePages: false,
              footer: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Grid Footer'),
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) => Center(child: Text(item)),
            ),
          ),
        ),
      );

      expect(find.text('Grid Footer'), findsOneWidget);
      expect(find.text('A'), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // Feature 10: Testing Utilities
  // ═══════════════════════════════════════════════════════════════════════════

  group('testPaginationController()', () {
    test('creates controller with specified items', () {
      final controller = testPaginationController<int, String>(
        items: ['a', 'b', 'c'],
        currentPageKey: 1,
      );
      addTearDown(controller.dispose);

      expect(controller.items, ['a', 'b', 'c']);
      expect(controller.items.length, 3);
    });

    test('creates controller with specified status', () {
      final controller = testPaginationController<int, String>(
        items: ['a'],
        status: PaginationStatus.loaded,
        currentPageKey: 1,
      );
      addTearDown(controller.dispose);

      expect(controller.status, PaginationStatus.loaded);
    });

    test('creates controller with page key', () {
      final controller = testPaginationController<int, String>(
        items: ['a'],
        currentPageKey: 3,
      );
      addTearDown(controller.dispose);

      expect(controller.currentPageKey, 3);
    });

    test('creates controller with error', () {
      final controller = testPaginationController<int, String>(
        status: PaginationStatus.firstPageError,
        error: 'Test error',
        currentPageKey: 1,
      );
      addTearDown(controller.dispose);

      expect(controller.state.error, 'Test error');
    });

    test('creates controller with hasMorePages false', () {
      final controller = testPaginationController<int, String>(
        items: ['x'],
        status: PaginationStatus.completed,
        hasMorePages: false,
        currentPageKey: 1,
      );
      addTearDown(controller.dispose);

      expect(controller.hasMorePages, false);
    });

    test('creates controller with totalItems', () {
      final controller = testPaginationController<int, String>(
        items: ['x', 'y'],
        currentPageKey: 1,
        totalItems: 100,
      );
      addTearDown(controller.dispose);

      expect(controller.state.totalItems, 100);
    });

    test('works with non-int key types', () {
      final controller = testPaginationController<String, int>(
        items: [1, 2, 3],
        currentPageKey: 'cursor_abc',
      );
      addTearDown(controller.dispose);

      expect(controller.currentPageKey, 'cursor_abc');
      expect(controller.items, [1, 2, 3]);
    });
  });

  group('Custom Matchers', () {
    late PaginationController<int, String> controller;

    setUp(() {
      controller = testPaginationController<int, String>(
        items: ['a', 'b', 'c'],
        status: PaginationStatus.loaded,
        currentPageKey: 2,
        hasMorePages: true,
      );
    });

    tearDown(() => controller.dispose());

    test('hasItemCount matches correct item count', () {
      expect(controller, hasItemCount(3));
    });

    test('hasItemCount fails on wrong count', () {
      expect(controller, isNot(hasItemCount(5)));
    });

    test('isOnPage matches correct page', () {
      expect(controller, isOnPage(2));
    });

    test('isOnPage fails on wrong page', () {
      expect(controller, isNot(isOnPage(1)));
    });

    test('hasStatus matches correct status', () {
      expect(controller, hasStatus(PaginationStatus.loaded));
    });

    test('hasStatus fails on wrong status', () {
      expect(controller, isNot(hasStatus(PaginationStatus.completed)));
    });

    test('isPaginationCompleted matches completed controller', () {
      final completed = testPaginationController<int, String>(
        items: ['x'],
        status: PaginationStatus.completed,
        hasMorePages: false,
        currentPageKey: 5,
      );
      addTearDown(completed.dispose);

      expect(completed, isPaginationCompleted);
    });

    test('isPaginationCompleted fails on non-completed controller', () {
      expect(controller, isNot(isPaginationCompleted));
    });

    test('hasPaginationError matches controller with error', () {
      final errController = testPaginationController<int, String>(
        status: PaginationStatus.firstPageError,
        error: 'oops',
        currentPageKey: 1,
      );
      addTearDown(errController.dispose);

      expect(errController, hasPaginationError());
      expect(errController, hasPaginationError('oops'));
    });

    test('hasPaginationError fails on controller without error', () {
      expect(controller, isNot(hasPaginationError()));
    });

    test('hasPaginationError matches loadMoreError too', () {
      final errController = testPaginationController<int, String>(
        items: ['a'],
        status: PaginationStatus.loadMoreError,
        error: Exception('network'),
        currentPageKey: 1,
      );
      addTearDown(errController.dispose);

      expect(errController, hasPaginationError());
    });

    test('isPaginationEmpty matches empty controller', () {
      final empty = testPaginationController<int, String>(
        items: [],
        status: PaginationStatus.empty,
        currentPageKey: 1,
      );
      addTearDown(empty.dispose);

      expect(empty, isPaginationEmpty);
    });

    test('isPaginationEmpty fails when items exist', () {
      expect(controller, isNot(isPaginationEmpty));
    });
  });

  group('Matcher descriptions', () {
    test('hasItemCount has descriptive message', () {
      final matcher = hasItemCount(5);
      expect(matcher.describe(StringDescription()).toString(),
          contains('5 items'));
    });

    test('isOnPage has descriptive message', () {
      final matcher = isOnPage(3);
      expect(matcher.describe(StringDescription()).toString(),
          contains('page 3'));
    });

    test('hasStatus has descriptive message', () {
      final matcher = hasStatus(PaginationStatus.loaded);
      expect(matcher.describe(StringDescription()).toString(),
          contains('loaded'));
    });
  });

  group('Testing utilities integration', () {
    testWidgets('test controller works with PaginationListView.withController',
        (tester) async {
      final controller = testPaginationController<int, String>(
        items: ['Alpha', 'Beta', 'Gamma'],
        status: PaginationStatus.loaded,
        currentPageKey: 1,
        hasMorePages: false,
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.withController(
              controller: controller,
              itemBuilder: (context, item, index) => ListTile(
                title: Text(item),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Alpha'), findsOneWidget);
      expect(find.text('Beta'), findsOneWidget);
      expect(find.text('Gamma'), findsOneWidget);
      expect(controller, hasItemCount(3));
      expect(controller, hasStatus(PaginationStatus.loaded));
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // placeholderItem widget param — auto-skeleton from itemBuilder
  // ═══════════════════════════════════════════════════════════════════════════

  group('placeholderItem on widget constructors', () {
    testWidgets('PaginationListView shows skeleton via placeholderItem',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) => ListTile(
                key: ValueKey('item-$index'),
                title: Text(item),
              ),
              placeholderItem: 'Placeholder',
              placeholderCount: 4,
            ),
          ),
        ),
      );

      // Each item is rendered (via the real itemBuilder) and wrapped in ShaderMask shimmer
      expect(find.byType(ShaderMask), findsNWidgets(4));
      expect(find.text('Placeholder'), findsNWidgets(4));
    });

    testWidgets('PaginationListView defaults to 6 placeholders',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNWidgets(6));
    });

    testWidgets('firstPageLoadingBuilder takes priority over placeholderItem',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
              firstPageLoadingBuilder: (context) =>
                  const Text('Custom Loading'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Loading'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('PaginationGridView shows skeleton via placeholderItem',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'Grid',
              placeholderCount: 4,
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNWidgets(4));
      expect(find.text('Grid'), findsNWidgets(4));
    });

    testWidgets('SliverPaginatedList shows skeleton via placeholderItem',
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
                  items: const [],
                  status: PaginationStatus.loadingFirstPage,
                  scrollController: scrollController,
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                  placeholderItem: 'Sliver',
                  placeholderCount: 3,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNWidgets(3));
      expect(find.text('Sliver'), findsNWidgets(3));
    });

    testWidgets('SliverPaginatedGrid shows skeleton via placeholderItem',
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
                  items: const [],
                  status: PaginationStatus.loadingFirstPage,
                  scrollController: scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, item, index) => Text(item),
                  placeholderItem: 'SliverGrid',
                  placeholderCount: 4,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(ShaderMask), findsNWidgets(4));
      expect(find.text('SliverGrid'), findsNWidgets(4));
    });

    testWidgets('skeletonConfig is applied', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
              placeholderCount: 2,
              skeletonConfig: const SkeletonConfig(overlayColor: Colors.red),
            ),
          ),
        ),
      );

      final shaderMasks = tester.widgetList<ShaderMask>(
        find.byType(ShaderMask),
      );
      for (final widget in shaderMasks) {
        // Each skeleton item uses srcATop blend mode
        expect(widget.blendMode, BlendMode.srcATop);
      }
      expect(find.byType(ShaderMask), findsNWidgets(2));
      // ClipRRect with default borderRadius
      expect(find.byType(ClipRRect), findsNWidgets(2));
    });

    testWidgets('no skeleton when placeholderItem is null', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const [],
              status: PaginationStatus.loadingFirstPage,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Should show default spinner, not skeleton
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ═══════════════════════════════════════════════════════════════════════════
  // placeholderItem load-more skeleton — inline skeleton items when loading more
  // ═══════════════════════════════════════════════════════════════════════════

  group('load-more skeleton items via placeholderItem', () {
    testWidgets('PaginationListView shows skeleton items when loading more',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A', 'B', 'C'],
              status: PaginationStatus.loadingMore,
              itemBuilder: (context, item, index) => ListTile(
                key: ValueKey('item-$index'),
                title: Text(item),
              ),
              placeholderItem: 'Placeholder',
              placeholderCount: 3,
            ),
          ),
        ),
      );

      // Real items rendered
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.text('C'), findsOneWidget);
      // Skeleton items appended
      expect(find.byType(ShaderMask), findsNWidgets(3));
      expect(find.text('Placeholder'), findsNWidgets(3));
      // No default spinner footer
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('no load-more skeleton when placeholderItem is null',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A', 'B'],
              status: PaginationStatus.loadingMore,
              itemBuilder: (context, item, index) => Text(item),
            ),
          ),
        ),
      );

      // Default spinner footer, no skeleton
      expect(find.byType(ShaderMask), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loadMoreLoadingBuilder takes priority over skeleton',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A'],
              status: PaginationStatus.loadingMore,
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
              placeholderCount: 3,
              loadMoreLoadingBuilder: (context) =>
                  const Text('Custom Load More'),
            ),
          ),
        ),
      );

      expect(find.text('Custom Load More'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNothing);
    });

    testWidgets('PaginationGridView shows skeleton grid items when loading more',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationGridView<int, String>.controlled(
              items: const ['A', 'B'],
              status: PaginationStatus.loadingMore,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
              ),
              itemBuilder: (context, item, index) => Center(
                key: ValueKey('grid-$index'),
                child: Text(item),
              ),
              placeholderItem: 'Skeleton',
              placeholderCount: 2,
            ),
          ),
        ),
      );

      // Real items
      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      // Skeleton items in the grid (at least some visible)
      expect(find.byType(ShaderMask), findsAtLeast(1));
      expect(find.text('Skeleton'), findsAtLeast(1));
    });

    testWidgets('SliverPaginatedList shows skeleton items when loading more',
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
                  items: const ['A', 'B'],
                  status: PaginationStatus.loadingMore,
                  scrollController: scrollController,
                  itemBuilder: (context, item, index) => ListTile(
                    title: Text(item),
                  ),
                  placeholderItem: 'Sk',
                  placeholderCount: 2,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNWidgets(2));
      expect(find.text('Sk'), findsNWidgets(2));
    });

    testWidgets('SliverPaginatedGrid shows skeleton items when loading more',
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
                  items: const ['A', 'B'],
                  status: PaginationStatus.loadingMore,
                  scrollController: scrollController,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, item, index) => Center(
                    child: Text(item),
                  ),
                  placeholderItem: 'Sk',
                  placeholderCount: 2,
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
      expect(find.byType(ShaderMask), findsNWidgets(2));
    });

    testWidgets('no skeleton for loadMore paginationType even with placeholderItem',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PaginationListView<int, String>.controlled(
              items: const ['A'],
              status: PaginationStatus.loadingMore,
              paginationType: PaginationType.loadMore,
              itemBuilder: (context, item, index) => Text(item),
              placeholderItem: 'X',
              placeholderCount: 3,
            ),
          ),
        ),
      );

      // loadMore mode shows button, not skeleton
      expect(find.byType(ShaderMask), findsNothing);
    });
  });
}
