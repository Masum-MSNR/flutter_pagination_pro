import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates Phase 3 features: header/footer, skeleton loading
class HeaderFooterScreen extends StatefulWidget {
  const HeaderFooterScreen({super.key});

  @override
  State<HeaderFooterScreen> createState() => _HeaderFooterScreenState();
}

class _HeaderFooterScreenState extends State<HeaderFooterScreen> {
  late final PagedController<MockItem> _controller;
  late MockDataService _service;
  bool _showHeader = true;
  bool _showFooter = true;
  bool _useSkeletonLoading = true;

  @override
  void initState() {
    super.initState();
    _service = MockServicePresets.success();
    _controller = PagedController<MockItem>(
      fetchPage: _service.fetchPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _reload() {
    _controller.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Header / Footer'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Refresh',
            onPressed: _reload,
          ),
        ],
      ),
      body: Column(
        children: [
          // Control toggles
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: colorScheme.outlineVariant.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Features',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Header'),
                  subtitle: const Text('Banner above the list'),
                  value: _showHeader,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _showHeader = v),
                ),
                SwitchListTile(
                  title: const Text('Footer'),
                  subtitle: const Text('Widget below all items'),
                  value: _showFooter,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) => setState(() => _showFooter = v),
                ),
                SwitchListTile(
                  title: const Text('Skeleton loading'),
                  subtitle: const Text(
                      'DefaultFirstPageLoading.builder()'),
                  value: _useSkeletonLoading,
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  onChanged: (v) =>
                      setState(() => _useSkeletonLoading = v),
                ),
              ],
            ),
          ),

          // Paginated list with header/footer
          Expanded(
            child: PagedListView<MockItem>.withController(
              controller: _controller,
              header: _showHeader
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppTheme.primaryColor.withValues(alpha: 0.15),
                            AppTheme.secondaryColor
                                .withValues(alpha: 0.08),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star_rounded,
                                  color: AppTheme.warningColor, size: 28),
                              const SizedBox(width: 8),
                              Text(
                                'Featured Items',
                                style:
                                    theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'This header scrolls with the list content',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              footer: _showFooter
                  ? Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      color: colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.3),
                      child: Column(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: colorScheme.primary,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'End of content',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : null,
              firstPageLoadingBuilder: _useSkeletonLoading
                  ? (context) => DefaultFirstPageLoading.builder(
                        itemBuilder: (context, index) => _SkeletonTile(),
                        itemCount: 8,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1),
                      )
                  : null,
              separatorBuilder: (context, index) =>
                  const Divider(height: 1),
              itemBuilder: (context, item, index) => ItemTile(item: item),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple skeleton placeholder tile
class _SkeletonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 14,
                  width: 160,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 10,
                  width: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
