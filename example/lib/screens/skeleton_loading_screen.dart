import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates all skeleton / shimmer loading approaches:
/// 1. placeholderItem (zero-config — reuses your itemBuilder with grey overlay)
/// 2. DefaultFirstPageLoading.builder() (custom skeleton tiles)
/// 3. DefaultFirstPageLoading.fromItemBuilder() (overlay on real widget)
class SkeletonLoadingScreen extends StatefulWidget {
  const SkeletonLoadingScreen({super.key});

  @override
  State<SkeletonLoadingScreen> createState() => _SkeletonLoadingScreenState();
}

class _SkeletonLoadingScreenState extends State<SkeletonLoadingScreen> {
  late PagedController<MockItem> _controller;
  _SkeletonMode _mode = _SkeletonMode.placeholderItem;
  int _rebuildCounter = 0;

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    // Use slow loading so users can see the skeleton effect
    final service = MockServicePresets.slowLoading();
    _controller = PagedController<MockItem>(
      fetchPage: service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  void _switchMode(_SkeletonMode mode) {
    setState(() {
      _mode = mode;
      _controller.dispose();
      _createController();
      _rebuildCounter++;
    });
  }

  void _reload() {
    _controller.dispose();
    _createController();
    setState(() => _rebuildCounter++);
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
        title: const Text('Skeleton Loading'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Reload (see skeleton again)',
            onPressed: _reload,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.view_day_outlined,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Skeleton placeholders while the first page loads. '
                        'Tap refresh to see it again.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _mode.description,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mode selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: _SkeletonMode.values.map((mode) {
                final selected = _mode == mode;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(mode.label),
                    avatar: Icon(mode.icon, size: 16),
                    onSelected: (_) => _switchMode(mode),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // List with different skeleton modes
          Expanded(
            child: _buildList(context),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (_mode) {
      // Approach 1: placeholderItem — zero config, uses itemBuilder with overlay
      case _SkeletonMode.placeholderItem:
        return PagedListView<MockItem>.withController(
          key: ValueKey(_rebuildCounter),
          controller: _controller,
          itemBuilder: (context, item, index) => ItemTile(item: item),
          placeholderItem: const MockItem(
            id: 0,
            title: 'Loading...',
            subtitle: 'Please wait',
            category: 'Technology',
          ),
          placeholderCount: 8,
          separatorBuilder: (context, index) => Divider(
            indent: 84,
            endIndent: 16,
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.only(bottom: 16),
        );

      // Approach 2: Custom overlay color
      case _SkeletonMode.customOverlay:
        return PagedListView<MockItem>.withController(
          key: ValueKey(_rebuildCounter),
          controller: _controller,
          itemBuilder: (context, item, index) => ItemTile(item: item),
          placeholderItem: const MockItem(
            id: 0,
            title: 'Loading...',
            subtitle: 'Please wait',
            category: 'Design',
          ),
          placeholderCount: 8,
          skeletonOverlayColor: AppTheme.primaryColor.withValues(alpha: 0.15),
          separatorBuilder: (context, index) => Divider(
            indent: 84,
            endIndent: 16,
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.only(bottom: 16),
        );

      // Approach 3: DefaultFirstPageLoading.builder()
      case _SkeletonMode.customBuilder:
        return PagedListView<MockItem>.withController(
          key: ValueKey(_rebuildCounter),
          controller: _controller,
          itemBuilder: (context, item, index) => ItemTile(item: item),
          firstPageLoadingBuilder: (context) =>
              DefaultFirstPageLoading.builder(
            itemCount: 10,
            itemBuilder: (context, index) => _SkeletonTile(),
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 72),
          ),
          separatorBuilder: (context, index) => Divider(
            indent: 84,
            endIndent: 16,
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.only(bottom: 16),
        );

      // Approach 4: DefaultFirstPageLoading.fromItemBuilder()
      case _SkeletonMode.fromItemBuilder:
        return PagedListView<MockItem>.withController(
          key: ValueKey(_rebuildCounter),
          controller: _controller,
          itemBuilder: (context, item, index) => ItemTile(item: item),
          firstPageLoadingBuilder: (context) =>
              DefaultFirstPageLoading.fromItemBuilder<MockItem>(
            itemBuilder: (context, item, index) => ItemTile(item: item),
            placeholderItem: const MockItem(
              id: 0,
              title: 'Sample Title',
              subtitle: 'Sample subtitle text here',
              category: 'Science',
            ),
            itemCount: 8,
            overlayColor: Colors.grey.shade300,
            separatorBuilder: (context, index) =>
                const Divider(height: 1, indent: 84),
          ),
          separatorBuilder: (context, index) => Divider(
            indent: 84,
            endIndent: 16,
            height: 1,
            color: colorScheme.outlineVariant.withValues(alpha: 0.5),
          ),
          padding: const EdgeInsets.only(bottom: 16),
        );
    }
  }
}

/// A hand-crafted skeleton placeholder tile with animated shimmer feel.
class _SkeletonTile extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final baseColor = colorScheme.surfaceContainerHighest;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Avatar placeholder
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: baseColor,
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 16,
                  width: 180,
                  decoration: BoxDecoration(
                    color: baseColor,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle placeholder
                Container(
                  height: 12,
                  width: 120,
                  decoration: BoxDecoration(
                    color: baseColor.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
          // Category chip placeholder
          Container(
            width: 60,
            height: 24,
            decoration: BoxDecoration(
              color: baseColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ],
      ),
    );
  }
}

enum _SkeletonMode {
  placeholderItem(
    label: 'placeholderItem',
    description: 'placeholderItem: MockItem(...) — zero-config overlay',
    icon: Icons.auto_fix_high,
  ),
  customOverlay(
    label: 'Custom Color',
    description: 'skeletonOverlayColor: primaryColor.withOpacity(0.15)',
    icon: Icons.palette,
  ),
  customBuilder(
    label: 'Custom Builder',
    description: 'firstPageLoadingBuilder → DefaultFirstPageLoading.builder()',
    icon: Icons.construction,
  ),
  fromItemBuilder(
    label: 'fromItemBuilder',
    description: 'DefaultFirstPageLoading.fromItemBuilder<T>()',
    icon: Icons.layers,
  );

  const _SkeletonMode({
    required this.label,
    required this.description,
    required this.icon,
  });

  final String label;
  final String description;
  final IconData icon;
}
