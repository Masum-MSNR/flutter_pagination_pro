import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/grid_card.dart';
import '../theme/app_theme.dart';

/// Demonstrates sliver variants — SliverPaginatedList and SliverPaginatedGrid
/// inside a CustomScrollView with SliverAppBar.
class SliverDemoScreen extends StatefulWidget {
  const SliverDemoScreen({super.key});

  @override
  State<SliverDemoScreen> createState() => _SliverDemoScreenState();
}

class _SliverDemoScreenState extends State<SliverDemoScreen> {
  late PaginationController<int, MockItem> _controller;
  late final ScrollController _scrollController;
  bool _useGrid = false;
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    final service = MockServicePresets.success();
    _controller = PaginationController<int, MockItem>(
      fetchPage: service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  void _toggleMode() {
    setState(() {
      _useGrid = !_useGrid;
      _controller.dispose();
      final service = MockServicePresets.success();
      _controller = PaginationController<int, MockItem>(
        fetchPage: service.fetchPage,
        config: const PaginationConfig(pageSize: 15),
      );
      _listKey = UniqueKey();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        key: _listKey,
        controller: _scrollController,
        slivers: [
          SliverAppBar.large(
            title: const Text('Sliver Demo'),
            actions: [
              IconButton(
                icon: Icon(
                  _useGrid ? Icons.view_list : Icons.grid_view,
                  color: colorScheme.primary,
                ),
                tooltip: _useGrid ? 'Switch to list' : 'Switch to grid',
                onPressed: _toggleMode,
              ),
              IconButton(
                icon: Icon(Icons.refresh, color: colorScheme.primary),
                tooltip: 'Refresh',
                onPressed: _controller.refresh,
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor.withValues(alpha: 0.1),
                    AppTheme.primaryColor.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.layers, color: AppTheme.secondaryColor, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _useGrid
                          ? 'SliverPaginatedGrid inside CustomScrollView '
                              'with SliverAppBar.large'
                          : 'SliverPaginatedList inside CustomScrollView '
                              'with SliverAppBar.large',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_useGrid)
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              sliver: SliverPaginatedGrid<int, MockItem>(
                controller: _controller,
                scrollController: _scrollController,
                itemBuilder: (context, item, index) => GridCard(item: item),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                ),
              ),
            )
          else
            SliverPaginatedList<int, MockItem>(
              controller: _controller,
              scrollController: _scrollController,
              itemBuilder: (context, item, index) => Card(
                margin:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      '#${item.id}',
                      style: TextStyle(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    item.subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
