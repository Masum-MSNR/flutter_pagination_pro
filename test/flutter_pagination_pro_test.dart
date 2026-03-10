import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  group('Library exports', () {
    test('PaginationController is accessible', () {
      final controller = PaginationController<String>(
        fetchPage: (_) async => [],
      );
      expect(controller, isNotNull);
      expect(controller.status, PaginationStatus.initial);
      controller.dispose();
    });

    test('PaginationConfig defaults are accessible', () {
      const config = PaginationConfig.defaults;
      expect(config.initialPage, 1);
      expect(config.scrollThreshold, 200.0);
      expect(config.autoLoadFirstPage, true);
    });

    test('PaginationConfig copyWith works', () {
      const config = PaginationConfig.defaults;
      final custom = config.copyWith(scrollThreshold: 500.0);
      expect(custom.scrollThreshold, 500.0);
      expect(custom.initialPage, 1);
    });

    test('PaginationStatus values are accessible', () {
      expect(PaginationStatus.values, isNotEmpty);
      expect(PaginationStatus.initial.isLoading, false);
      expect(PaginationStatus.loadingFirstPage.isLoading, true);
    });

    test('PaginationType values are accessible', () {
      expect(PaginationType.infiniteScroll, isNotNull);
      expect(PaginationType.loadMore, isNotNull);
    });

    test('NumberedPaginationConfig has equality', () {
      const config1 = NumberedPaginationConfig(buttonSize: 40.0);
      const config2 = NumberedPaginationConfig(buttonSize: 40.0);
      const config3 = NumberedPaginationConfig(buttonSize: 50.0);

      expect(config1, equals(config2));
      expect(config1, isNot(equals(config3)));
      expect(config1.hashCode, config2.hashCode);
    });

    test('PaginationState reset works', () {
      const state = PaginationState<int>(
        items: [1, 2, 3],
        currentPage: 5,
        status: PaginationStatus.completed,
      );
      final reset = state.reset();
      expect(reset.items, isEmpty);
      expect(reset.status, PaginationStatus.initial);
    });
  });
}
