import 'package:flutter/material.dart';

class WordBankHeaderStats extends StatelessWidget {
  final int totalWords;
  final int dueToday;
  final int mastered;

  const WordBankHeaderStats({
    super.key,
    required this.totalWords,
    required this.dueToday,
    required this.mastered,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatTile(
            context,
            label: 'Total Words',
            value: totalWords.toString(),
            icon: Icons.bookmark_outline,
            color: theme.colorScheme.onSurface,
          ),
          _buildDivider(theme),
          _buildStatTile(
            context,
            label: 'Due Today',
            value: dueToday.toString(),
            icon: Icons.timer_outlined,
            color: theme.colorScheme.onSurface,
          ),
          _buildDivider(theme),
          _buildStatTile(
            context,
            label: 'Mastered',
            value: mastered.toString(),
            icon: Icons.verified_outlined,
            color: theme.colorScheme.onSurface,
          ),
        ],
      ),
    );
  }

  Widget _buildStatTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 32,
      width: 1,
      color: theme.colorScheme.outline.withValues(alpha: 0.2),
    );
  }
}
