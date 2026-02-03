import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates load more button pagination (manual trigger)
class LoadMoreScreen extends StatefulWidget {
  const LoadMoreScreen({super.key});

  @override
  State<LoadMoreScreen> createState() => _LoadMoreScreenState();
}

class _LoadMoreScreenState extends State<LoadMoreScreen> {
  late final PaginationController<MockItem> _controller;
  late MockDataService _service;
  bool _useSeparator = true;

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

  void _toggleSeparator() {
    setState(() {
      _useSeparator = !_useSeparator;
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
        title: const Text('Load More Button'),
        actions: [
          IconButton(
            icon: Icon(
              _useSeparator ? Icons.view_list : Icons.view_agenda,
              color: colorScheme.primary,
            ),
            tooltip: _useSeparator ? 'Without separator' : 'With separator',
            onPressed: _toggleSeparator,
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
          // Info banner
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withValues(alpha: 0.1),
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.touch_app_outlined,
                  color: AppTheme.accentColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap the "Load More" button at the bottom to fetch more items',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // List
          Expanded(
            child: PaginationListView<MockItem>.withController(
              controller: _controller,
              paginationType: PaginationType.loadMore,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              separatorBuilder: _useSeparator
                  ? (context, index) => Divider(
                        indent: 84,
                        endIndent: 16,
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      )
                  : null,
              loadMoreButtonBuilder: (context, onLoadMore, isLoading) => Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onLoadMore,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(isLoading ? 'Loading...' : 'Load More Items'),
                  ),
                ),
              ),
              padding: const EdgeInsets.only(bottom: 8),
            ),
          ),
        ],
      ),
    );
  }
}
