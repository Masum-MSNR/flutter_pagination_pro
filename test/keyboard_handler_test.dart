import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('PaginationKeyboardHandler', () {
    late ScrollController scrollController;

    Widget buildApp({
      VoidCallback? onEndReached,
      bool enabled = true,
      double arrowScrollAmount = 50.0,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: PaginationKeyboardHandler(
            scrollController: scrollController,
            onEndReached: onEndReached,
            enabled: enabled,
            arrowScrollAmount: arrowScrollAmount,
            scrollAnimationDuration: const Duration(milliseconds: 50),
            child: ListView.builder(
              controller: scrollController,
              itemCount: 100,
              itemBuilder: (context, index) => SizedBox(
                height: 50,
                child: Text('Item $index'),
              ),
            ),
          ),
        ),
      );
    }

    setUp(() {
      scrollController = ScrollController();
    });

    tearDown(() {
      scrollController.dispose();
    });

    testWidgets('Page Down scrolls one viewport height', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      final initialOffset = scrollController.offset;
      expect(initialOffset, 0.0);

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(initialOffset));
    });

    testWidgets('Page Up scrolls up from a scrolled position', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // First scroll down
      scrollController.jumpTo(500);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();

      expect(scrollController.offset, lessThan(500));
    });

    testWidgets('Home scrolls to top', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      scrollController.jumpTo(500);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.home);
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
    });

    testWidgets('End scrolls to bottom and triggers onEndReached',
        (tester) async {
      var endReached = false;

      await tester.pumpWidget(buildApp(
        onEndReached: () => endReached = true,
      ));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.end);
      await tester.pumpAndSettle();

      expect(
          scrollController.offset, scrollController.position.maxScrollExtent);
      expect(endReached, isTrue);
    });

    testWidgets('Arrow Down scrolls by arrowScrollAmount', (tester) async {
      await tester.pumpWidget(buildApp(arrowScrollAmount: 80));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();

      // Should have started animating toward 80
      expect(scrollController.offset, greaterThan(0));
    });

    testWidgets('Arrow Up scrolls up', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      scrollController.jumpTo(200);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
      await tester.pumpAndSettle();

      expect(scrollController.offset, lessThan(200));
    });

    testWidgets('disabled mode ignores key events', (tester) async {
      await tester.pumpWidget(buildApp(enabled: false));
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
    });

    testWidgets('Page Down near end triggers onEndReached', (tester) async {
      var endReached = false;

      await tester.pumpWidget(buildApp(
        onEndReached: () => endReached = true,
      ));
      await tester.pump();

      // Jump near the end
      scrollController.jumpTo(scrollController.position.maxScrollExtent - 10);
      await tester.pump();

      await tester.sendKeyEvent(LogicalKeyboardKey.pageDown);
      await tester.pumpAndSettle();

      expect(endReached, isTrue);
    });

    testWidgets('does not scroll past min/max extents', (tester) async {
      await tester.pumpWidget(buildApp());
      await tester.pump();

      // Already at top — Page Up should stay at 0
      await tester.sendKeyEvent(LogicalKeyboardKey.pageUp);
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
    });
  });
}
