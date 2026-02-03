import 'package:flutter/material.dart';
import '../data/mock_item.dart';
import '../theme/app_theme.dart';

/// A stylish list item tile for displaying mock items
class ItemTile extends StatelessWidget {
  const ItemTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final MockItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = item.category ?? 'Other';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Avatar with gradient
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getCategoryGradient(category),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    item.title.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Category chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(category).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  category,
                  style: TextStyle(
                    color: _getCategoryColor(category),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Color> _getCategoryGradient(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return [AppTheme.primaryColor, const Color(0xFF818CF8)];
      case 'science':
        return [AppTheme.accentColor, const Color(0xFF22D3EE)];
      case 'design':
        return [AppTheme.secondaryColor, const Color(0xFFA78BFA)];
      case 'business':
        return [AppTheme.successColor, const Color(0xFF34D399)];
      case 'art':
        return [const Color(0xFFEC4899), const Color(0xFFF472B6)];
      default:
        return [AppTheme.warningColor, const Color(0xFFFBBF24)];
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'technology':
        return AppTheme.primaryColor;
      case 'science':
        return AppTheme.accentColor;
      case 'design':
        return AppTheme.secondaryColor;
      case 'business':
        return AppTheme.successColor;
      case 'art':
        return const Color(0xFFEC4899);
      default:
        return AppTheme.warningColor;
    }
  }
}

/// A compact item tile variant
class CompactItemTile extends StatelessWidget {
  const CompactItemTile({
    super.key,
    required this.item,
    this.onTap,
  });

  final MockItem item;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final category = item.category ?? 'Other';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          '#${item.id}',
          style: TextStyle(
            color: colorScheme.onPrimaryContainer,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      title: Text(
        item.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        category,
        style: TextStyle(
          color: colorScheme.primary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: onTap,
    );
  }
}
