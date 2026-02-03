import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pagination Pro Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pagination Pro Demo'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _DemoCard(
            title: 'Infinite Scroll ListView',
            subtitle: 'Auto-loads on scroll',
            icon: Icons.view_list,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InfiniteScrollDemo(),
              ),
            ),
          ),
          _DemoCard(
            title: 'Load More Button',
            subtitle: 'Manual load with button',
            icon: Icons.touch_app,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LoadMoreButtonDemo(),
              ),
            ),
          ),
          _DemoCard(
            title: 'Grid View',
            subtitle: 'Paginated grid layout',
            icon: Icons.grid_view,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const GridViewDemo(),
              ),
            ),
          ),
          _DemoCard(
            title: 'Numbered Pagination',
            subtitle: 'Page number navigation',
            icon: Icons.numbers,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NumberedPaginationDemo(),
              ),
            ),
          ),
          _DemoCard(
            title: 'State Simulator',
            subtitle: 'Test all pagination states',
            icon: Icons.science,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const StateSimulatorDemo(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DemoCard extends StatelessWidget {
  const _DemoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

// ============================================================================
// MOCK DATA SERVICE
// ============================================================================

/// Simulates API responses with configurable behavior
class MockDataService {
  MockDataService({
    this.pageSize = 15,
    this.totalItems = 100,
    this.delayMs = 800,
    this.errorOnPage,
    this.emptyResponse = false,
  });

  final int pageSize;
  final int totalItems;
  final int delayMs;
  final int? errorOnPage;
  final bool emptyResponse;

  Future<List<MockItem>> fetchPage(int page) async {
    await Future.delayed(Duration(milliseconds: delayMs));

    if (emptyResponse) return [];

    if (errorOnPage != null && page == errorOnPage) {
      throw Exception('Simulated error on page $page');
    }

    final startIndex = (page - 1) * pageSize;
    if (startIndex >= totalItems) return [];

    final endIndex = (startIndex + pageSize).clamp(0, totalItems);
    return List.generate(
      endIndex - startIndex,
      (i) => MockItem(
        id: startIndex + i + 1,
        title: 'Item ${startIndex + i + 1}',
        subtitle: 'Page $page • Index $i',
      ),
    );
  }

  int get totalPages => (totalItems / pageSize).ceil();
}

class MockItem {
  const MockItem({
    required this.id,
    required this.title,
    required this.subtitle,
  });

  final int id;
  final String title;
  final String subtitle;
}

// ============================================================================
// INFINITE SCROLL DEMO
// ============================================================================

class InfiniteScrollDemo extends StatefulWidget {
  const InfiniteScrollDemo({super.key});

  @override
  State<InfiniteScrollDemo> createState() => _InfiniteScrollDemoState();
}

class _InfiniteScrollDemoState extends State<InfiniteScrollDemo> {
  final _service = MockDataService();
  late final PaginationController<MockItem> _controller;

  @override
  void initState() {
    super.initState();
    _controller = PaginationController<MockItem>(
      fetchPage: _service.fetchPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Infinite Scroll'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _controller.refresh,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: PaginationListView<MockItem>.withController(
        controller: _controller,
        itemBuilder: (context, item, index) => _ItemTile(item: item),
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}

// ============================================================================
// LOAD MORE BUTTON DEMO
// ============================================================================

class LoadMoreButtonDemo extends StatelessWidget {
  const LoadMoreButtonDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockDataService(pageSize: 10);

    return Scaffold(
      appBar: AppBar(title: const Text('Load More Button')),
      body: PaginationListView<MockItem>(
        fetchPage: service.fetchPage,
        paginationType: PaginationType.loadMore,
        itemBuilder: (context, item, index) => _ItemTile(item: item),
        separatorBuilder: (context, index) => const Divider(height: 1),
      ),
    );
  }
}

// ============================================================================
// GRID VIEW DEMO
// ============================================================================

class GridViewDemo extends StatelessWidget {
  const GridViewDemo({super.key});

  @override
  Widget build(BuildContext context) {
    final service = MockDataService(pageSize: 12);

    return Scaffold(
      appBar: AppBar(title: const Text('Grid View')),
      body: PaginationGridView<MockItem>(
        fetchPage: service.fetchPage,
        paginationType: PaginationType.loadMore,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.5,
        ),
        padding: const EdgeInsets.all(8),
        itemBuilder: (context, item, index) => _GridCard(item: item),
      ),
    );
  }
}

// ============================================================================
// NUMBERED PAGINATION DEMO
// ============================================================================

class NumberedPaginationDemo extends StatefulWidget {
  const NumberedPaginationDemo({super.key});

  @override
  State<NumberedPaginationDemo> createState() => _NumberedPaginationDemoState();
}

class _NumberedPaginationDemoState extends State<NumberedPaginationDemo> {
  final _service = MockDataService(pageSize: 10, totalItems: 150);
  int _currentPage = 1;
  List<MockItem> _items = [];
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPage(1);
  }

  Future<void> _loadPage(int page) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final items = await _service.fetchPage(page);
      setState(() {
        _items = items;
        _currentPage = page;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Numbered Pagination')),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(child: Text('Error: $_error'))
                    : ListView.separated(
                        itemCount: _items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) =>
                            _ItemTile(item: _items[index]),
                      ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: NumberedPagination(
              totalPages: _service.totalPages,
              currentPage: _currentPage,
              onPageChanged: _loadPage,
              enabled: !_isLoading,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// STATE SIMULATOR DEMO - Test all states
// ============================================================================

enum SimulatedState {
  success('Success', 'Normal pagination flow'),
  empty('Empty', 'No items returned'),
  firstPageError('First Page Error', 'Error on page 1'),
  loadMoreError('Load More Error', 'Error on page 2'),
  slowLoading('Slow Loading', '3 second delay'),
  fewItems('Few Items', 'Only 5 items total');

  const SimulatedState(this.label, this.description);
  final String label;
  final String description;
}

class StateSimulatorDemo extends StatefulWidget {
  const StateSimulatorDemo({super.key});

  @override
  State<StateSimulatorDemo> createState() => _StateSimulatorDemoState();
}

class _StateSimulatorDemoState extends State<StateSimulatorDemo> {
  SimulatedState _selectedState = SimulatedState.success;
  PaginationType _paginationType = PaginationType.infiniteScroll;
  Key _listKey = UniqueKey();

  MockDataService _createService() {
    switch (_selectedState) {
      case SimulatedState.success:
        return MockDataService();
      case SimulatedState.empty:
        return MockDataService(emptyResponse: true);
      case SimulatedState.firstPageError:
        return MockDataService(errorOnPage: 1);
      case SimulatedState.loadMoreError:
        return MockDataService(errorOnPage: 2);
      case SimulatedState.slowLoading:
        return MockDataService(delayMs: 3000);
      case SimulatedState.fewItems:
        return MockDataService(totalItems: 5, pageSize: 10);
    }
  }

  void _rebuildList() {
    setState(() {
      _listKey = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = _createService();

    return Scaffold(
      appBar: AppBar(
        title: const Text('State Simulator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _rebuildList,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          // Configuration panel
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Simulate State',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: SimulatedState.values.map((state) {
                    final isSelected = state == _selectedState;
                    return FilterChip(
                      label: Text(state.label),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() => _selectedState = state);
                        _rebuildList();
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  'Pagination Type',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                SegmentedButton<PaginationType>(
                  segments: const [
                    ButtonSegment(
                      value: PaginationType.infiniteScroll,
                      label: Text('Infinite'),
                      icon: Icon(Icons.all_inclusive),
                    ),
                    ButtonSegment(
                      value: PaginationType.loadMore,
                      label: Text('Load More'),
                      icon: Icon(Icons.add_circle_outline),
                    ),
                  ],
                  selected: {_paginationType},
                  onSelectionChanged: (selected) {
                    setState(() => _paginationType = selected.first);
                    _rebuildList();
                  },
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedState.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              ],
            ),
          ),

          // Pagination list
          Expanded(
            child: PaginationListView<MockItem>(
              key: _listKey,
              fetchPage: service.fetchPage,
              paginationType: _paginationType,
              itemBuilder: (context, item, index) => _ItemTile(item: item),
              separatorBuilder: (context, index) => const Divider(height: 1),
              onPageLoaded: (page, items) {
                debugPrint('✅ Page $page loaded with ${items.length} items');
              },
              onError: (error) {
                debugPrint('❌ Error: $error');
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// SHARED WIDGETS
// ============================================================================

class _ItemTile extends StatelessWidget {
  const _ItemTile({required this.item});

  final MockItem item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: Text(
          '${item.id}',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSecondaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(item.title),
      subtitle: Text(item.subtitle),
    );
  }
}

class _GridCard extends StatelessWidget {
  const _GridCard({required this.item});

  final MockItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
              child: Text(
                '${item.id}',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSecondaryContainer,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              item.title,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              item.subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
