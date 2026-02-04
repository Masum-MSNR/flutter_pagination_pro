import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/grid_card.dart';
import '../theme/app_theme.dart';

/// Demonstrates grid view pagination with both modes
class GridViewScreen extends StatefulWidget {
  const GridViewScreen({super.key});

  @override
  State<GridViewScreen> createState() => _GridViewScreenState();
}

class _GridViewScreenState extends State<GridViewScreen> {
  late final PaginationController<MockItem> _controller;
  late MockDataService _service;
  PaginationType _paginationType = PaginationType.infiniteScroll;
  int _crossAxisCount = 2;

  @override
  void initState() {
    super.initState();
    _service = MockServicePresets.success();
    _controller = PaginationController<MockItem>(
      fetchPage: _fetchPage,
    );
  }

  Future<List<MockItem>> _fetchPage(int page) {
    return _service.fetchPage(page);
  }

  void _refresh() {
    _controller.refresh();
  }

  void _toggleColumns() {
    setState(() {
      _crossAxisCount = _crossAxisCount == 2 ? 3 : 2;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid View'),
        actions: [
          IconButton(
            icon: Icon(
              _crossAxisCount == 2 ? Icons.grid_view : Icons.grid_3x3,
              color: colorScheme.primary,
            ),
            tooltip: _crossAxisCount == 2 ? '3 columns' : '2 columns',
            onPressed: _toggleColumns,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: SegmentedButton<PaginationType>(
                    segments: const [
                      ButtonSegment(
                        value: PaginationType.infiniteScroll,
                        label: Text('Infinite Scroll'),
                        icon: Icon(Icons.all_inclusive, size: 18),
                      ),
                      ButtonSegment(
                        value: PaginationType.loadMore,
                        label: Text('Load More'),
                        icon: Icon(Icons.add_circle_outline, size: 18),
                      ),
                    ],
                    selected: {_paginationType},
                    onSelectionChanged: (modes) {
                      setState(() {
                        _paginationType = modes.first;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.grid_view_rounded,
                  color: AppTheme.secondaryColor,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _paginationType == PaginationType.infiniteScroll
                        ? 'Scroll to load more grid items automatically'
                        : 'Tap the button below to load more grid items',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: PaginationGridView<MockItem>.withController(
              controller: _controller,
              paginationType: _paginationType,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: _crossAxisCount,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemBuilder: (context, item, index) => GridCard(item: item),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              loadMoreButtonBuilder: _paginationType == PaginationType.loadMore
                  ? (context, onLoadMore, isLoading) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: FilledButton.icon(
                          onPressed: isLoading ? null : onLoadMore,
                          icon: isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add, size: 20),
                          label: Text(isLoading ? 'Loading...' : 'Load More'),
                        ),
                      )
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}
