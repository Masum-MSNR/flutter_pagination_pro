import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';
import '../theme/app_theme.dart';
import 'infinite_scroll_screen.dart';
import 'load_more_screen.dart';
import 'grid_view_screen.dart';
import 'numbered_pagination_screen.dart';
import 'state_simulator_screen.dart';

/// Home screen with navigation to all demo screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // App bar
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: const Text('Flutter Pagination Pro'),
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryColor.withValues(alpha: 0.1),
                      AppTheme.secondaryColor.withValues(alpha: 0.05),
                      colorScheme.surface,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Stack(
                  children: [
                    // Decorative elements
                    Positioned(
                      top: -50,
                      right: -50,
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.primaryColor.withValues(alpha: 0.2),
                              AppTheme.primaryColor.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: -30,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppTheme.accentColor.withValues(alpha: 0.15),
                              AppTheme.accentColor.withValues(alpha: 0),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                // Package info
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.secondaryColor,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.layers_rounded,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Comprehensive Pagination',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Zero dependencies • Pure Flutter • Easy to use',
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
                // Scroll-based section
                const SectionHeader(
                  title: 'SCROLL-BASED PAGINATION',
                  subtitle: 'ListView and GridView with automatic or manual loading',
                ),
                DemoCard(
                  title: 'Infinite Scroll',
                  subtitle: 'Auto-loads when scrolling near the bottom',
                  icon: Icons.all_inclusive,
                  gradientColors: const [
                    AppTheme.primaryColor,
                    Color(0xFF818CF8),
                  ],
                  onTap: () => _navigate(context, const InfiniteScrollScreen()),
                ),
                DemoCard(
                  title: 'Load More Button',
                  subtitle: 'Manual trigger to fetch next page',
                  icon: Icons.add_circle_outline,
                  gradientColors: const [
                    AppTheme.accentColor,
                    Color(0xFF22D3EE),
                  ],
                  onTap: () => _navigate(context, const LoadMoreScreen()),
                ),
                DemoCard(
                  title: 'Grid View',
                  subtitle: 'Paginated grid layout with configurable columns',
                  icon: Icons.grid_view_rounded,
                  gradientColors: const [
                    AppTheme.secondaryColor,
                    Color(0xFFA78BFA),
                  ],
                  onTap: () => _navigate(context, const GridViewScreen()),
                ),
                // Numbered pagination section
                const SectionHeader(
                  title: 'NUMBERED PAGINATION',
                  subtitle: 'Traditional page navigation with page numbers',
                ),
                DemoCard(
                  title: 'Numbered Pagination',
                  subtitle: 'Page numbers with first/last & prev/next buttons',
                  icon: Icons.format_list_numbered,
                  gradientColors: const [
                    AppTheme.successColor,
                    Color(0xFF34D399),
                  ],
                  onTap: () =>
                      _navigate(context, const NumberedPaginationScreen()),
                ),
                // Testing section
                const SectionHeader(
                  title: 'TESTING & STATES',
                  subtitle: 'Test all pagination states and edge cases',
                ),
                DemoCard(
                  title: 'State Simulator',
                  subtitle: 'Test loading, error, empty & success states',
                  icon: Icons.science_outlined,
                  gradientColors: const [
                    AppTheme.warningColor,
                    Color(0xFFFBBF24),
                  ],
                  onTap: () => _navigate(context, const StateSimulatorScreen()),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _navigate(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }
}
