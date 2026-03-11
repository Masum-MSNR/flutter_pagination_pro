import 'package:flutter/material.dart';

import '../widgets/demo_card.dart';
import '../theme/app_theme.dart';
import 'animated_list_screen.dart';
import 'bidirectional_screen.dart';
import 'controlled_mode_screen.dart';
import 'cursor_pagination_screen.dart';
import 'custom_builders_screen.dart';
import 'grid_view_screen.dart';
import 'header_footer_screen.dart';
import 'infinite_scroll_screen.dart';
import 'item_mutations_screen.dart';
import 'keyboard_nav_screen.dart';
import 'load_more_screen.dart';
import 'numbered_pagination_screen.dart';
import 'pull_to_refresh_screen.dart';
import 'search_filter_screen.dart';
import 'sliver_demo_screen.dart';
import 'state_simulator_screen.dart';

/// Home screen with navigation to all demo screens
class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    this.themeMode = ThemeMode.system,
    this.onToggleTheme,
  });

  final ThemeMode themeMode;
  final VoidCallback? onToggleTheme;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar.large(
            expandedHeight: 200,
            pinned: true,
            actions: [
              if (onToggleTheme != null)
                IconButton(
                  icon: Icon(
                    themeMode == ThemeMode.light
                        ? Icons.light_mode
                        : themeMode == ThemeMode.dark
                            ? Icons.dark_mode
                            : Icons.brightness_auto,
                  ),
                  tooltip: themeMode == ThemeMode.light
                      ? 'Switch to Dark Mode'
                      : themeMode == ThemeMode.dark
                          ? 'Switch to System Mode'
                          : 'Switch to Light Mode',
                  onPressed: onToggleTheme,
                ),
              const SizedBox(width: 8),
            ],
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
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
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
                  subtitle: 'Paginated grid with configurable columns',
                  icon: Icons.grid_view_rounded,
                  gradientColors: const [
                    AppTheme.secondaryColor,
                    Color(0xFFA78BFA),
                  ],
                  onTap: () => _navigate(context, const GridViewScreen()),
                ),
                DemoCard(
                  title: 'Cursor-Based',
                  subtitle: 'String page keys — GraphQL / Firestore style',
                  icon: Icons.link,
                  gradientColors: const [
                    Color(0xFF0EA5E9),
                    Color(0xFF38BDF8),
                  ],
                  onTap: () =>
                      _navigate(context, const CursorPaginationScreen()),
                ),
                DemoCard(
                  title: 'Pull-to-Refresh & Cache',
                  subtitle: 'Refresh + initialItems (cache-first) pattern',
                  icon: Icons.swipe_down,
                  gradientColors: const [
                    AppTheme.successColor,
                    Color(0xFF34D399),
                  ],
                  onTap: () =>
                      _navigate(context, const PullToRefreshScreen()),
                ),
                DemoCard(
                  title: 'Search & Filter',
                  subtitle: 'updateFetchPage() to swap data source live',
                  icon: Icons.search,
                  gradientColors: const [
                    Color(0xFFF97316),
                    Color(0xFFFBBF24),
                  ],
                  onTap: () =>
                      _navigate(context, const SearchFilterScreen()),
                ),

                const SectionHeader(
                  title: 'ADVANCED WIDGETS',
                  subtitle: 'Slivers, animated list, bidirectional & keyboard',
                ),
                DemoCard(
                  title: 'Sliver Demo',
                  subtitle: 'SliverPaginatedList & Grid in CustomScrollView',
                  icon: Icons.layers,
                  gradientColors: const [
                    Color(0xFF8B5CF6),
                    Color(0xFFC084FC),
                  ],
                  onTap: () =>
                      _navigate(context, const SliverDemoScreen()),
                ),
                DemoCard(
                  title: 'Header / Footer',
                  subtitle: 'Header, footer & skeleton loading builder',
                  icon: Icons.view_agenda_outlined,
                  gradientColors: const [
                    Color(0xFFEC4899),
                    Color(0xFFF472B6),
                  ],
                  onTap: () =>
                      _navigate(context, const HeaderFooterScreen()),
                ),
                DemoCard(
                  title: 'Bidirectional',
                  subtitle: 'Two-way scroll — chat-style older/newer',
                  icon: Icons.swap_vert_rounded,
                  gradientColors: const [
                    Color(0xFFEF4444),
                    Color(0xFFF87171),
                  ],
                  onTap: () =>
                      _navigate(context, const BidirectionalScreen()),
                ),
                DemoCard(
                  title: 'Animated List',
                  subtitle: 'Slide+fade on insert & swipe to dismiss',
                  icon: Icons.animation_rounded,
                  gradientColors: const [
                    AppTheme.primaryColor,
                    AppTheme.secondaryColor,
                  ],
                  onTap: () =>
                      _navigate(context, const AnimatedListScreen()),
                ),
                DemoCard(
                  title: 'Keyboard Navigation',
                  subtitle: 'Page Up/Down, Home/End & arrow keys',
                  icon: Icons.keyboard_rounded,
                  gradientColors: const [
                    AppTheme.accentColor,
                    Color(0xFF22D3EE),
                  ],
                  onTap: () =>
                      _navigate(context, const KeyboardNavScreen()),
                ),

                const SectionHeader(
                  title: 'CONTROLLER & MUTATIONS',
                  subtitle: 'Programmatic control, mutations, and custom builders',
                ),
                DemoCard(
                  title: 'Item Mutations',
                  subtitle: 'insert, remove, update, removeWhere, setTotalItems',
                  icon: Icons.edit_note,
                  gradientColors: const [
                    AppTheme.successColor,
                    AppTheme.accentColor,
                  ],
                  onTap: () =>
                      _navigate(context, const ItemMutationsScreen()),
                ),
                DemoCard(
                  title: 'Controlled Mode',
                  subtitle: '.controlled() — BYO state (Bloc/Riverpod)',
                  icon: Icons.tune,
                  gradientColors: const [
                    AppTheme.warningColor,
                    Color(0xFFFBBF24),
                  ],
                  onTap: () =>
                      _navigate(context, const ControlledModeScreen()),
                ),
                DemoCard(
                  title: 'Custom Builders',
                  subtitle: 'Override every state widget (error, empty, loading…)',
                  icon: Icons.widgets,
                  gradientColors: const [
                    AppTheme.secondaryColor,
                    AppTheme.primaryColor,
                  ],
                  onTap: () =>
                      _navigate(context, const CustomBuildersScreen()),
                ),

                const SectionHeader(
                  title: 'NUMBERED PAGINATION',
                  subtitle: 'Traditional page navigation with page numbers',
                ),
                DemoCard(
                  title: 'Numbered Pagination',
                  subtitle: 'Page numbers with first/last & prev/next',
                  icon: Icons.format_list_numbered,
                  gradientColors: const [
                    Color(0xFF10B981),
                    Color(0xFF34D399),
                  ],
                  onTap: () =>
                      _navigate(context, const NumberedPaginationScreen()),
                ),
                const SectionHeader(
                  title: 'TESTING & STATES',
                  subtitle: 'Test all pagination states and edge cases',
                ),
                DemoCard(
                  title: 'State Simulator',
                  subtitle: 'Test loading, error, empty, auto-retry & more',
                  icon: Icons.science_outlined,
                  gradientColors: const [
                    AppTheme.warningColor,
                    AppTheme.errorColor,
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
