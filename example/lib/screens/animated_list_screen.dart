import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../theme/app_theme.dart';

/// Demonstrates animated pagination — items slide+fade in on load,
/// and animate out on removal via swipe-to-dismiss.
class AnimatedListScreen extends StatefulWidget {
  const AnimatedListScreen({super.key});

  @override
  State<AnimatedListScreen> createState() => _AnimatedListScreenState();
}

class _AnimatedListScreenState extends State<AnimatedListScreen> {
  late final PaginationController<int, MockItem> _controller;
  late MockDataService _service;

  @override
  void initState() {
    super.initState();
    _service = MockServicePresets.success();
    _controller = PaginationController<int, MockItem>(
      fetchPage: _service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
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
        title: const Text('Animated List'),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: colorScheme.primary),
            tooltip: 'Insert item at top',
            onPressed: () {
              _controller.insertItem(
                0,
                MockItem(
                  id: DateTime.now().millisecondsSinceEpoch,
                  title: 'New Item ✨',
                  subtitle: 'Inserted just now',
                  category: 'Tech',
                ),
              );
            },
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
                    'Items slide+fade in with stagger. '
                    'Swipe to dismiss or tap + to insert.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Animated paginated list
          Expanded(
            child: AnimatedPaginationListView<int, MockItem>.withController(
              controller: _controller,
              insertDuration: const Duration(milliseconds: 300),
              removeDuration: const Duration(milliseconds: 250),
              staggerDelay: const Duration(milliseconds: 40),
              plainItemBuilder: (context, item, index) => Dismissible(
                key: ValueKey(item.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red.shade400,
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) {
                  _controller.removeItemAt(index);
                },
                child: _AnimatedItemTile(item: item),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedItemTile extends StatelessWidget {
  const _AnimatedItemTile({required this.item});

  final MockItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = item.category ?? 'Other';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _gradientFor(category),
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  item.title.substring(0, 1).toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _gradientFor(category).first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 11,
                  color: _gradientFor(category).first,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static List<Color> _gradientFor(String category) {
    switch (category) {
      case 'Tech':
        return [AppTheme.primaryColor, const Color(0xFF818CF8)];
      case 'Design':
        return [AppTheme.secondaryColor, const Color(0xFFA78BFA)];
      case 'Business':
        return [AppTheme.accentColor, const Color(0xFF22D3EE)];
      case 'Science':
        return [AppTheme.successColor, const Color(0xFF34D399)];
      case 'Art':
        return [AppTheme.warningColor, const Color(0xFFFBBF24)];
      default:
        return [Colors.grey, Colors.blueGrey];
    }
  }
}
