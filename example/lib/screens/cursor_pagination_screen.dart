import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../theme/app_theme.dart';

/// Demonstrates cursor-based pagination with String keys.
///
/// Simulates a GraphQL/Firestore-style API that returns items with cursors.
class CursorPaginationScreen extends StatefulWidget {
  const CursorPaginationScreen({super.key});

  @override
  State<CursorPaginationScreen> createState() => _CursorPaginationScreenState();
}

class _CursorPaginationScreenState extends State<CursorPaginationScreen> {
  late final PaginationController<String, _CursorItem> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<String, _CursorItem>(
      fetchPage: _fetchPage,
      initialPageKey: '',
      nextPageKeyBuilder: (_, items) => items.last.cursor,
    );
  }

  Future<List<_CursorItem>> _fetchPage(String cursor) async {
    await Future.delayed(const Duration(milliseconds: 600));
    final startIndex = cursor.isEmpty ? 0 : int.parse(cursor.split('_').last);
    if (startIndex >= 60) return [];
    return List.generate(15, (i) {
      final id = startIndex + i + 1;
      return _CursorItem(
        id: id,
        cursor: 'cursor_$id',
        title: 'Document $id',
        subtitle: 'Cursor: cursor_$id',
        color: _colors[id % _colors.length],
      );
    });
  }

  static const _colors = [
    AppTheme.primaryColor,
    AppTheme.secondaryColor,
    AppTheme.accentColor,
    AppTheme.successColor,
    AppTheme.warningColor,
  ];

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
        title: const Text('Cursor-Based'),
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
          _InfoBanner(
            icon: Icons.link,
            text: 'Uses String page keys (cursors). Each page returns a '
                'cursor used to fetch the next page — like GraphQL or Firestore.',
            colors: [
              AppTheme.accentColor.withValues(alpha: 0.1),
              AppTheme.primaryColor.withValues(alpha: 0.1),
            ],
            borderColor: AppTheme.accentColor,
          ),
          Expanded(
            child: PaginationListView<String, _CursorItem>.withController(
              controller: _controller,
              itemBuilder: (context, item, index) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: item.color.withValues(alpha: 0.15),
                    child: Icon(Icons.description, color: item.color, size: 20),
                  ),
                  title: Text(item.title),
                  subtitle: Text(
                    item.subtitle,
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: Text(
                    '#${item.id}',
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              separatorBuilder: (context, index) => Divider(
                indent: 72,
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

class _CursorItem {
  const _CursorItem({
    required this.id,
    required this.cursor,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final int id;
  final String cursor;
  final String title;
  final String subtitle;
  final Color color;
}

/// Reusable info banner for demo screens.
class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.colors,
    required this.borderColor,
  });

  final IconData icon;
  final String text;
  final List<Color> colors;
  final Color borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: borderColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
