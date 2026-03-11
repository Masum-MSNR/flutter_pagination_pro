import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates pull-to-refresh and initialItems (cache-first) patterns.
class PullToRefreshScreen extends StatefulWidget {
  const PullToRefreshScreen({super.key});

  @override
  State<PullToRefreshScreen> createState() => _PullToRefreshScreenState();
}

class _PullToRefreshScreenState extends State<PullToRefreshScreen> {
  late final PagedController<MockItem> _controller;
  bool _hasInitialItems = true;

  // Simulated cache
  static final _cachedItems = List.generate(
    5,
    (i) => MockItem(
      id: i + 1,
      title: 'Cached Item ${i + 1}',
      subtitle: 'From local cache',
      category: 'Technology',
    ),
  );

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    final service = MockServicePresets.success();
    _controller = PagedController<MockItem>(
      fetchPage: service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
      initialItems: _hasInitialItems ? _cachedItems : null,
    );
  }

  void _toggleInitialItems() {
    setState(() {
      _hasInitialItems = !_hasInitialItems;
      _controller.dispose();
      _createController();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pull-to-Refresh'),
        actions: [
          IconButton(
            icon: Icon(
              _hasInitialItems ? Icons.cached : Icons.cloud_download,
              color: colorScheme.primary,
            ),
            tooltip: _hasInitialItems
                ? 'Disable initial items'
                : 'Enable initial items',
            onPressed: _toggleInitialItems,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh',
            onPressed: _controller.refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.accentColor.withValues(alpha: 0.1),
                  AppTheme.successColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.accentColor.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.swipe_down,
                        color: AppTheme.accentColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Pull down to refresh. '
                        '${_hasInitialItems ? "Cached items show instantly before network fetch." : "No initial items — loads from network."}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: (_hasInitialItems
                            ? AppTheme.successColor
                            : AppTheme.warningColor)
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _hasInitialItems
                        ? 'initialItems: ${_cachedItems.length} cached'
                        : 'initialItems: none',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: _hasInitialItems
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PagedListView<MockItem>.withController(
              controller: _controller,
              enablePullToRefresh: true,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              separatorBuilder: (context, index) => Divider(
                indent: 84,
                endIndent: 16,
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.only(bottom: 16),
            ),
          ),
        ],
      ),
    );
  }
}
