import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('NumberedPagination', () {
    testWidgets('renders correctly with basic config', (tester) async {
      int selectedPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 10,
              currentPage: selectedPage,
              onPageChanged: (page) => selectedPage = page,
            ),
          ),
        ),
      );

      // Should show navigation buttons and page numbers
      expect(find.byIcon(Icons.first_page), findsOneWidget);
      expect(find.byIcon(Icons.chevron_left), findsOneWidget);
      expect(find.byIcon(Icons.chevron_right), findsOneWidget);
      expect(find.byIcon(Icons.last_page), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows ellipsis for many pages', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 100,
              currentPage: 50,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      // Should show ellipsis
      expect(find.text('...'), findsWidgets);
      // Should show first and last page
      expect(find.text('1'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('calls onPageChanged when page is tapped', (tester) async {
      int selectedPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberedPagination(
                  totalPages: 10,
                  currentPage: selectedPage,
                  onPageChanged: (page) {
                    setState(() => selectedPage = page);
                  },
                );
              },
            ),
          ),
        ),
      );

      // Tap on page 2
      await tester.tap(find.text('2'));
      await tester.pump();

      expect(selectedPage, 2);
    });

    testWidgets('next button advances page', (tester) async {
      int selectedPage = 1;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberedPagination(
                  totalPages: 10,
                  currentPage: selectedPage,
                  onPageChanged: (page) {
                    setState(() => selectedPage = page);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_right));
      await tester.pump();

      expect(selectedPage, 2);
    });

    testWidgets('previous button decrements page', (tester) async {
      int selectedPage = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberedPagination(
                  totalPages: 10,
                  currentPage: selectedPage,
                  onPageChanged: (page) {
                    setState(() => selectedPage = page);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.chevron_left));
      await tester.pump();

      expect(selectedPage, 4);
    });

    testWidgets('first button goes to page 1', (tester) async {
      int selectedPage = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberedPagination(
                  totalPages: 10,
                  currentPage: selectedPage,
                  onPageChanged: (page) {
                    setState(() => selectedPage = page);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.first_page));
      await tester.pump();

      expect(selectedPage, 1);
    });

    testWidgets('last button goes to last page', (tester) async {
      int selectedPage = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return NumberedPagination(
                  totalPages: 10,
                  currentPage: selectedPage,
                  onPageChanged: (page) {
                    setState(() => selectedPage = page);
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.last_page));
      await tester.pump();

      expect(selectedPage, 10);
    });

    testWidgets('disabled state prevents interaction', (tester) async {
      int selectedPage = 5;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 10,
              currentPage: selectedPage,
              onPageChanged: (page) => selectedPage = page,
              enabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.text('6'));
      await tester.pump();

      // Page should not change
      expect(selectedPage, 5);
    });

    testWidgets('shows nothing when totalPages is 0', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 0,
              currentPage: 1,
              onPageChanged: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(NumberedPagination), findsOneWidget);
      expect(find.byIcon(Icons.first_page), findsNothing);
    });

    testWidgets('respects visiblePages setting', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 50,
              currentPage: 25,
              onPageChanged: (_) {},
              visiblePages: 5,
            ),
          ),
        ),
      );

      // With visiblePages=5 and currentPage=25, we should see:
      // 1 ... 24 25 26 ... 50 (approximately)
      // Find should not find too many page numbers
      expect(find.text('1'), findsOneWidget);
      expect(find.text('50'), findsOneWidget);
    });

    testWidgets('hides navigation buttons when configured', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NumberedPagination(
              totalPages: 10,
              currentPage: 5,
              onPageChanged: (_) {},
              config: const NumberedPaginationConfig(
                showFirstLastButtons: false,
                showNavigationButtons: false,
              ),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.first_page), findsNothing);
      expect(find.byIcon(Icons.last_page), findsNothing);
      expect(find.byIcon(Icons.chevron_left), findsNothing);
      expect(find.byIcon(Icons.chevron_right), findsNothing);
    });
  });

  group('NumberedPaginationConfig', () {
    test('copyWith works correctly', () {
      const config = NumberedPaginationConfig(
        buttonSize: 40.0,
        spacing: 4.0,
      );

      final newConfig = config.copyWith(buttonSize: 50.0);

      expect(newConfig.buttonSize, 50.0);
      expect(newConfig.spacing, 4.0);
    });

    test('default values are sensible', () {
      const config = NumberedPaginationConfig();

      expect(config.buttonSize, 40.0);
      expect(config.spacing, 4.0);
      expect(config.borderRadius, 8.0);
      expect(config.showFirstLastButtons, true);
      expect(config.showNavigationButtons, true);
    });
  });
}
