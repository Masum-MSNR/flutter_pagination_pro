import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates controlled mode — the widget receives items and status
/// externally (e.g. from Bloc/Riverpod). No internal controller.
class ControlledModeScreen extends StatefulWidget {
  const ControlledModeScreen({super.key});

  @override
  State<ControlledModeScreen> createState() => _ControlledModeScreenState();
}

class _ControlledModeScreenState extends State<ControlledModeScreen> {
  final _service = MockServicePresets.success();
  List<MockItem> _items = [];
  PaginationStatus _status = PaginationStatus.loadingFirstPage;
  bool _hasMore = true;
  Object? _error;
  int _currentPage = 1;

  @override
  void initState() {
    super.initState();
    _loadPage();
  }

  Future<void> _loadPage() async {
    setState(() {
      _status = _items.isEmpty
          ? PaginationStatus.loadingFirstPage
          : PaginationStatus.loadingMore;
    });

    try {
      final newItems = await _service.fetchPage(_currentPage);
      setState(() {
        _items = [..._items, ...newItems];
        _hasMore = newItems.length >= 15;
        _status =
            newItems.isEmpty ? PaginationStatus.empty : PaginationStatus.loaded;
        _currentPage++;
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = e;
        _status = _items.isEmpty
            ? PaginationStatus.firstPageError
            : PaginationStatus.loadMoreError;
      });
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _items = [];
      _currentPage = 1;
      _hasMore = true;
      _error = null;
    });
    await _loadPage();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Controlled Mode'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh',
            onPressed: _refresh,
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.warningColor.withValues(alpha: 0.1),
                  AppTheme.accentColor.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.warningColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.tune, color: AppTheme.warningColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Uses .controlled() — items & status managed externally. '
                    'Perfect for Bloc, Riverpod, or any state management.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _StatusChip(
                  label: 'Status: ${_status.name}',
                  color: _status.isError ? AppTheme.errorColor : AppTheme.primaryColor,
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: 'Items: ${_items.length}',
                  color: AppTheme.successColor,
                ),
                const SizedBox(width: 8),
                _StatusChip(
                  label: _hasMore ? 'More: yes' : 'More: no',
                  color: AppTheme.accentColor,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PagedListView<MockItem>.controlled(
              items: _items,
              status: _status,
              hasMorePages: _hasMore,
              error: _error,
              onLoadMore: _loadPage,
              onRefresh: _refresh,
              onRetry: _loadPage,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              enablePullToRefresh: true,
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
