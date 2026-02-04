import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates all pagination states using manual simulation
class StateSimulatorScreen extends StatefulWidget {
  const StateSimulatorScreen({super.key});

  @override
  State<StateSimulatorScreen> createState() => _StateSimulatorScreenState();
}

class _StateSimulatorScreenState extends State<StateSimulatorScreen> {
  late PaginationController<MockItem> _controller;
  _SimulationScenario _scenario = _SimulationScenario.success;
  PaginationType _paginationType = PaginationType.infiniteScroll;
  Key _listKey = UniqueKey();

  @override
  void initState() {
    super.initState();
    _createController();
  }

  void _createController() {
    _controller = PaginationController<MockItem>(
      fetchPage: _fetchPage,
    );
  }

  Future<List<MockItem>> _fetchPage(int page) async {
    final service = _scenario.service;
    return service.fetchPage(page);
  }

  void _applyScenario(_SimulationScenario scenario) {
    setState(() {
      _scenario = scenario;
      _controller.dispose();
      _createController();
      _listKey = UniqueKey();
    });
  }

  void _reset() {
    setState(() {
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
        title: const Text('State Simulator'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.primary),
            tooltip: 'Reset',
            onPressed: _reset,
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _SimulationScenario.values.map((scenario) {
                final isSelected = _scenario == scenario;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: isSelected,
                    label: Text(scenario.label),
                    avatar: Icon(
                      scenario.icon,
                      size: 18,
                      color: isSelected
                          ? colorScheme.onSecondaryContainer
                          : colorScheme.onSurfaceVariant,
                    ),
                    onSelected: (_) => _applyScenario(scenario),
                  ),
                );
              }).toList(),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SegmentedButton<PaginationType>(
              segments: const [
                ButtonSegment(
                  value: PaginationType.infiniteScroll,
                  label: Text('Infinite'),
                  icon: Icon(Icons.all_inclusive, size: 18),
                ),
                ButtonSegment(
                  value: PaginationType.loadMore,
                  label: Text('Load More'),
                  icon: Icon(Icons.add_circle_outline, size: 18),
                ),
              ],
              selected: {_paginationType},
              onSelectionChanged: (modes) {
                setState(() {
                  _paginationType = modes.first;
                  _listKey = UniqueKey();
                });
              },
            ),
          ),

          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _scenario.color.withValues(alpha: 0.1),
                  _scenario.color.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _scenario.color.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  _scenario.icon,
                  color: _scenario.color,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _scenario.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _scenario.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _scenario.description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: PaginationListView<MockItem>.withController(
              key: _listKey,
              controller: _controller,
              paginationType: _paginationType,
              itemBuilder: (context, item, index) => ItemTile(item: item),
              separatorBuilder: (context, index) => Divider(
                indent: 84,
                endIndent: 16,
                height: 1,
                color: colorScheme.outlineVariant.withValues(alpha: 0.5),
              ),
              padding: const EdgeInsets.only(bottom: 16),
              loadMoreButtonBuilder: (context, onLoadMore, isLoading) => Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: isLoading ? null : onLoadMore,
                    icon: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(isLoading ? 'Loading...' : 'Load More'),
                  ),
                ),
              ),
              firstPageLoadingBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      'Loading first page...',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              firstPageErrorBuilder: (context, error, onRetry) =>
                  Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Failed to load',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error.toString(),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
              emptyBuilder: (context) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.inbox_outlined,
                      size: 64,
                      color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'There are no items to display',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Simulation scenarios
enum _SimulationScenario {
  success(
    label: 'Success',
    description: 'Normal pagination with multiple pages of data',
    icon: Icons.check_circle_outline,
    color: AppTheme.successColor,
  ),
  empty(
    label: 'Empty',
    description: 'No data available - shows empty state',
    icon: Icons.inbox_outlined,
    color: Colors.grey,
  ),
  firstPageError(
    label: 'First Page Error',
    description: 'Error on first page load - shows error state',
    icon: Icons.error_outline,
    color: AppTheme.errorColor,
  ),
  loadMoreError(
    label: 'Load More Error',
    description: 'Error when loading subsequent pages',
    icon: Icons.warning_amber_outlined,
    color: AppTheme.warningColor,
  ),
  slowLoading(
    label: 'Slow Loading',
    description: 'Simulates slow network (3 second delay)',
    icon: Icons.hourglass_empty,
    color: AppTheme.accentColor,
  ),
  fewItems(
    label: 'Few Items',
    description: 'Only a few items (no pagination needed)',
    icon: Icons.short_text,
    color: AppTheme.primaryColor,
  );

  const _SimulationScenario({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
  });

  final String label;
  final String description;
  final IconData icon;
  final Color color;

  MockDataService get service {
    switch (this) {
      case _SimulationScenario.success:
        return MockServicePresets.success();
      case _SimulationScenario.empty:
        return MockServicePresets.empty();
      case _SimulationScenario.firstPageError:
        return MockServicePresets.firstPageError();
      case _SimulationScenario.loadMoreError:
        return MockServicePresets.loadMoreError();
      case _SimulationScenario.slowLoading:
        return MockServicePresets.slowLoading();
      case _SimulationScenario.fewItems:
        return MockServicePresets.fewItems();
    }
  }
}
