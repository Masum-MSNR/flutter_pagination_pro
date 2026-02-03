import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates infinite scroll pagination (auto-loads on scroll)
class InfiniteScrollScreen extends StatefulWidget {
  const InfiniteScrollScreen({super.key});

  @override
  State<InfiniteScrollScreen> createState() => _InfiniteScrollScreenState();
}

class _InfiniteScrollScreenState extends State<InfiniteScrollScreen> {
  late final PaginationController<MockItem> _controller;
  late MockDataService _service;
  bool _useSeparator = false;

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
        title: const Text('Infinite Scroll'),
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
                  AppTheme.primaryColor.withValues(alpha: 0.1),
                  AppTheme.secondaryColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Scroll down to automatically load more items',
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
              paginationType: PaginationType.infiniteScroll,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              separatorBuilder: _useSeparator
                  ? (context, index) => Divider(
                        indent: 84,
                        endIndent: 16,
                        height: 1,
                        color: colorScheme.outlineVariant.withValues(alpha: 0.5),
                      )
                  : null,
              padding: const EdgeInsets.only(bottom: 16),
            ),
          ),
        ],
      ),
    );
  }
}
