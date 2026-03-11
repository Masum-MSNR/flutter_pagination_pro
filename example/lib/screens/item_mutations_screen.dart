import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates item mutation APIs: insertItem, removeItemAt, updateItemAt,
/// updateItems, removeWhere, and setTotalItems.
class ItemMutationsScreen extends StatefulWidget {
  const ItemMutationsScreen({super.key});

  @override
  State<ItemMutationsScreen> createState() => _ItemMutationsScreenState();
}

class _ItemMutationsScreenState extends State<ItemMutationsScreen> {
  late final PagedController<MockItem> _controller;
  int _nextId = 1000;

  @override
  void initState() {
    super.initState();
    final service = MockServicePresets.success();
    _controller = PagedController<MockItem>(
      fetchPage: service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _insertAtTop() {
    _controller.insertItem(
      0,
      MockItem(
        id: _nextId++,
        title: 'Inserted Item ✨',
        subtitle: 'Added at index 0',
        category: 'Technology',
      ),
    );
  }

  void _removeFirst() {
    if (_controller.items.isNotEmpty) {
      _controller.removeItemAt(0);
    }
  }

  void _updateFirst() {
    if (_controller.items.isNotEmpty) {
      _controller.updateItemAt(
        0,
        MockItem(
          id: _controller.items[0].id,
          title: '${_controller.items[0].title} (edited)',
          subtitle: 'Updated via updateItemAt()',
          category: _controller.items[0].category,
        ),
      );
    }
  }

  void _uppercaseAll() {
    _controller.updateItems(
      (item) => MockItem(
        id: item.id,
        title: item.title.toUpperCase(),
        subtitle: item.subtitle,
        category: item.category,
      ),
    );
  }

  void _removeByCategory() {
    _controller
        .removeWhere((item) => item.category?.toLowerCase() == 'technology');
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Removed all "Technology" items')),
    );
  }

  void _setTotal() {
    _controller.setTotalItems(50);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content: Text('Set totalItems = 50 (auto-completes at 50)')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Item Mutations'),
        actions: [
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
                  AppTheme.successColor.withValues(alpha: 0.1),
                  AppTheme.accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.successColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.edit_note, color: AppTheme.successColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tap buttons below to mutate items in the loaded list.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _ActionChip(
                  label: 'Insert top',
                  icon: Icons.add,
                  color: AppTheme.successColor,
                  onTap: _insertAtTop,
                ),
                _ActionChip(
                  label: 'Remove first',
                  icon: Icons.remove,
                  color: AppTheme.errorColor,
                  onTap: _removeFirst,
                ),
                _ActionChip(
                  label: 'Update first',
                  icon: Icons.edit,
                  color: AppTheme.primaryColor,
                  onTap: _updateFirst,
                ),
                _ActionChip(
                  label: 'UPPERCASE all',
                  icon: Icons.text_fields,
                  color: AppTheme.secondaryColor,
                  onTap: _uppercaseAll,
                ),
                _ActionChip(
                  label: 'Remove Tech',
                  icon: Icons.filter_alt_off,
                  color: AppTheme.warningColor,
                  onTap: _removeByCategory,
                ),
                _ActionChip(
                  label: 'Set total=50',
                  icon: Icons.pin,
                  color: AppTheme.accentColor,
                  onTap: _setTotal,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<PaginationState<int, MockItem>>(
            valueListenable: _controller,
            builder: (context, state, _) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Text(
                      'Items: ${state.itemCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (state.totalItems != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Total: ${state.totalItems}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ],
                    const SizedBox(width: 12),
                    Text(
                      'Status: ${state.status.name}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PagedListView<MockItem>.withController(
              controller: _controller,
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

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ActionChip(
        avatar: Icon(icon, size: 16, color: color),
        label: Text(label, style: TextStyle(fontSize: 12)),
        onPressed: onTap,
      ),
    );
  }
}
