import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../data/mock_item.dart';
import '../data/mock_service.dart';
import '../widgets/item_tile.dart';
import '../theme/app_theme.dart';

/// Demonstrates keyboard navigation for paginated lists.
///
/// Wrap any paginated widget with [PaginationKeyboardHandler] to enable
/// Page Up/Down, Home, End, and arrow key scrolling — ideal for desktop & web.
class KeyboardNavScreen extends StatefulWidget {
  const KeyboardNavScreen({super.key});

  @override
  State<KeyboardNavScreen> createState() => _KeyboardNavScreenState();
}

class _KeyboardNavScreenState extends State<KeyboardNavScreen> {
  late final PagedController<MockItem> _controller;
  late final ScrollController _scrollController;
  late MockDataService _service;
  bool _keyboardEnabled = true;

  @override
  void initState() {
    super.initState();
    _service = MockServicePresets.success();
    _scrollController = ScrollController();
    _controller = PagedController<MockItem>(
      fetchPage: _service.fetchPage,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Keyboard Navigation'),
        actions: [
          IconButton(
            icon: Icon(
              _keyboardEnabled ? Icons.keyboard : Icons.keyboard_hide,
              color: colorScheme.primary,
            ),
            tooltip:
                _keyboardEnabled ? 'Disable keyboard' : 'Enable keyboard',
            onPressed: () =>
                setState(() => _keyboardEnabled = !_keyboardEnabled),
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
          // Info box
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
                    Icon(Icons.keyboard_rounded,
                        color: AppTheme.primaryColor, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Click the list, then use keyboard to scroll',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                _shortcutRow('Page Down / Up', 'Scroll one page'),
                _shortcutRow('Home / End', 'Jump to top / bottom'),
                _shortcutRow('Arrow ↑ / ↓', 'Scroll by 50px'),
              ],
            ),
          ),

          // Keyboard-enabled paginated list
          Expanded(
            child: PaginationKeyboardHandler(
              scrollController: _scrollController,
              enabled: _keyboardEnabled,
              onEndReached: _controller.loadNextPage,
              child: PagedListView<MockItem>.withController(
                controller: _controller,
                scrollController: _scrollController,
                itemBuilder: (context, item, index) =>
                    ItemTile(item: item),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _shortcutRow(String key, String action) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          const SizedBox(width: 32),
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          Text(
            action,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
