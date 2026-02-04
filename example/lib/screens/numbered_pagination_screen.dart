import 'package:flutter/material.dart';
import 'package:flutter_pagination_pro/flutter_pagination_pro.dart';

import '../theme/app_theme.dart';

/// Demonstrates numbered pagination widget
class NumberedPaginationScreen extends StatefulWidget {
  const NumberedPaginationScreen({super.key});

  @override
  State<NumberedPaginationScreen> createState() =>
      _NumberedPaginationScreenState();
}

class _NumberedPaginationScreenState extends State<NumberedPaginationScreen> {
  int _currentPage = 1;
  int _totalPages = 10;
  bool _showFirstLast = true;
  int _visiblePages = 5;

  List<String> get _pageContent => List.generate(
        8,
        (i) => 'Item ${(_currentPage - 1) * 8 + i + 1}',
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Numbered Pagination'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Settings',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Total Pages',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _totalPages.toDouble(),
                          min: 3,
                          max: 50,
                          divisions: 47,
                          label: '$_totalPages',
                          onChanged: (value) {
                            setState(() {
                              _totalPages = value.toInt();
                              if (_currentPage > _totalPages) {
                                _currentPage = _totalPages;
                              }
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_totalPages',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      SizedBox(
                        width: 100,
                        child: Text(
                          'Visible',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: Slider(
                          value: _visiblePages.toDouble(),
                          min: 3,
                          max: 9,
                          divisions: 6,
                          label: '$_visiblePages',
                          onChanged: (value) {
                            setState(() {
                              _visiblePages = value.toInt();
                            });
                          },
                        ),
                      ),
                      SizedBox(
                        width: 32,
                        child: Text(
                          '$_visiblePages',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Text(
                        'Show First/Last buttons',
                        style: theme.textTheme.bodyMedium,
                      ),
                      const Spacer(),
                      Switch(
                        value: _showFirstLast,
                        onChanged: (value) {
                          setState(() {
                            _showFirstLast = value;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Page $_currentPage of $_totalPages',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                NumberedPagination(
                  currentPage: _currentPage,
                  totalPages: _totalPages,
                  onPageChanged: (page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  visiblePages: _visiblePages,
                  config: NumberedPaginationConfig(
                    buttonSize: 40,
                    spacing: 6,
                    showFirstLastButtons: _showFirstLast,
                    selectedButtonColor: AppTheme.primaryColor,
                    unselectedButtonColor: colorScheme.surfaceContainerHigh,
                    selectedTextColor: Colors.white,
                    unselectedTextColor: colorScheme.onSurface,
                    navigationButtonColor: colorScheme.surfaceContainerHigh,
                    navigationIconColor: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _pageContent.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorScheme.primaryContainer,
                      child: Text(
                        '${(_currentPage - 1) * 8 + index + 1}',
                        style: TextStyle(
                          color: colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    title: Text(_pageContent[index]),
                    subtitle: Text(
                      'Content from page $_currentPage',
                      style: TextStyle(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
