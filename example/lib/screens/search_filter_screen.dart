import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates search/filter with updateFetchPage, pull-to-refresh,
/// and initialItems (cache-first) patterns.
class SearchFilterScreen extends StatefulWidget {
  const SearchFilterScreen({super.key});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  late final PagedController<MockItem> _controller;
  final _searchController = TextEditingController();
  String _activeCategory = 'All';
  Key _listKey = UniqueKey();

  static const _categories = [
    'All',
    'Technology',
    'Science',
    'Design',
    'Business',
    'Art',
  ];

  @override
  void initState() {
    super.initState();
    _controller = PagedController<MockItem>(
      fetchPage: _fetchPage,
      config: const PaginationConfig(pageSize: 15),
    );
  }

  Future<List<MockItem>> _fetchPage(int page) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final items = List.generate(15, (i) {
      final id = (page - 1) * 15 + i + 1;
      return MockItem.generate(id, page);
    });

    var filtered = items;

    if (_activeCategory != 'All') {
      filtered = filtered
          .where((item) =>
              item.category?.toLowerCase() ==
              _activeCategory.toLowerCase())
          .toList();
    }

    final query = _searchController.text.toLowerCase().trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((item) =>
              item.title.toLowerCase().contains(query) ||
              item.subtitle.toLowerCase().contains(query))
          .toList();
    }

    if (page > 4) return [];
    return filtered;
  }

  void _onSearch() {
    _controller.updateFetchPage(_fetchPage);
    setState(() => _listKey = UniqueKey());
  }

  void _setCategory(String cat) {
    setState(() => _activeCategory = cat);
    _controller.updateFetchPage(_fetchPage);
    setState(() => _listKey = UniqueKey());
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Search & Filter')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search items...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _onSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
              ),
              onSubmitted: (_) => _onSearch(),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: _categories.map((cat) {
                final selected = _activeCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    selected: selected,
                    label: Text(cat),
                    onSelected: (_) => _setCategory(cat),
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryColor.withValues(alpha: 0.08),
                  AppTheme.accentColor.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Uses updateFetchPage() to swap data source on search/filter. '
              'Pull down to refresh.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: PagedListView<MockItem>.withController(
              key: _listKey,
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
