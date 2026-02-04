import 'package:flutter/material.dart';
import '../data/mock_item.dart';

/// A clean, modern grid card for displaying mock items
class GridCard extends StatelessWidget {
  const GridCard({super.key, required this.item, this.onTap});

  final MockItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final cardColor = _getCardColor(item.id);

    return Material(
      color: colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(_getIcon(item.id), color: cardColor, size: 18),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Text(
                    '#${item.id}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cardColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.category ?? 'Other',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cardColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getCardColor(int id) {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFFF59E0B),
      const Color(0xFF10B981),
      const Color(0xFF06B6D4),
      const Color(0xFFEF4444),
      const Color(0xFF3B82F6),
    ];
    return colors[id % colors.length];
  }

  IconData _getIcon(int id) {
    final icons = [
      Icons.bolt_rounded,
      Icons.star_rounded,
      Icons.favorite_rounded,
      Icons.diamond_rounded,
      Icons.rocket_launch_rounded,
      Icons.auto_awesome_rounded,
      Icons.whatshot_rounded,
      Icons.emoji_objects_rounded,
    ];
    return icons[id % icons.length];
  }
}
