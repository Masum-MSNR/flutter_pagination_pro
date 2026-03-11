import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates custom builders for every state:
/// firstPageLoading, firstPageError, loadMoreLoading, loadMoreError,
/// empty, endOfList, loadMoreButton.
class CustomBuildersScreen extends StatefulWidget {
  const CustomBuildersScreen({super.key});

  @override
  State<CustomBuildersScreen> createState() => _CustomBuildersScreenState();
}

class _CustomBuildersScreenState extends State<CustomBuildersScreen> {
  late PagedController<MockItem> _controller;
  _BuilderScenario _scenario = _BuilderScenario.success;
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = PagedController<MockItem>(
      fetchPage: _scenario.service.fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  void _applyScenario(_BuilderScenario scenario) {
    setState(() {
      _scenario = scenario;
      _controller.dispose();
      _createController();
      _listKey = UniqueKey();
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
        title: const Text('Custom Builders'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Reset',
            onPressed: () {
              _controller.dispose();
              _createController();
              setState(() => _listKey = UniqueKey());
            },
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
                Icon(Icons.widgets, color: AppTheme.secondaryColor, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'All builder overrides in action. '
                    'Select a scenario to trigger each builder.',
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
              children: _BuilderScenario.values.map((s) {
                final selected = _scenario == s;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ChoiceChip(
                    selected: selected,
                    label: Text(s.label),
                    onSelected: (_) => _applyScenario(s),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: PagedListView<MockItem>.withController(
              key: _listKey,
              controller: _controller,
              paginationType: _scenario == _BuilderScenario.loadMoreButton
                  ? PaginationType.loadMore
                  : PaginationType.infiniteScroll,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              separatorBuilder: (context, index) => Divider(
                indent: 84,
                endIndent: 16,
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              // Custom first-page loading
              firstPageLoadingBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 48,
                      height: 48,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '🔄 Custom loading...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom first-page error
              firstPageErrorBuilder: (context, error, retry) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppTheme.errorColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.wifi_off_rounded,
                          size: 40,
                          color: AppTheme.errorColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '🚨 Custom Error Widget',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        error.toString(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 24),
                      OutlinedButton.icon(
                        onPressed: retry,
                        icon: const Icon(Icons.replay),
                        label: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
              // Custom empty state
              emptyBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.warningColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 40,
                        color: AppTheme.warningColor,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '📭 Custom Empty State',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Nothing here — this is a custom emptyBuilder',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom load-more loading
              loadMoreLoadingBuilder: (context) => Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppTheme.accentColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Fetching more items...',
                      style: TextStyle(
                        color: AppTheme.accentColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom load-more error
              loadMoreErrorBuilder: (context, error, retry) => Container(
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error, color: AppTheme.errorColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Failed — ${error.toString()}',
                        style: const TextStyle(fontSize: 13),
                      ),
                    ),
                    TextButton(
                      onPressed: retry,
                      child: const Text('RETRY'),
                    ),
                  ],
                ),
              ),
              // Custom end-of-list
              endOfListBuilder: (context) => Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.celebration_outlined,
                      size: 32,
                      color: AppTheme.successColor,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '🎉 You\'ve reached the end!',
                      style: TextStyle(
                        color: AppTheme.successColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // Custom load-more button
              loadMoreButtonBuilder: (context, onLoadMore, isLoading) =>
                  Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: isLoading ? null : onLoadMore,
                    icon: isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.expand_more),
                    label: Text(isLoading ? 'Loading...' : 'Show More'),
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

enum _BuilderScenario {
  success(label: 'Success'),
  empty(label: 'Empty'),
  firstPageError(label: '1st Page Error'),
  loadMoreError(label: 'Load More Error'),
  loadMoreButton(label: 'Load More Button'),
  fewItems(label: 'Few Items');

  const _BuilderScenario({required this.label});

  final String label;

  MockDataService get service {
    switch (this) {
      case success:
        return MockServicePresets.success();
      case empty:
        return MockServicePresets.empty();
      case firstPageError:
        return MockServicePresets.firstPageError();
      case loadMoreError:
        return MockServicePresets.loadMoreError();
      case loadMoreButton:
        return MockServicePresets.success();
      case fewItems:
        return MockServicePresets.fewItems();
    }
  }
}
