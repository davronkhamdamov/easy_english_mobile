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
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
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
            color: theme.colorScheme.primary,
          ),
          _buildDivider(isDark),
          _buildStatTile(
            context,
            label: 'Due Today',
            value: dueToday.toString(),
            icon: Icons.timer_outlined,
            color: Colors.orange,
          ),
          _buildDivider(isDark),
          _buildStatTile(
            context,
            label: 'Mastered',
            value: mastered.toString(),
            icon: Icons.verified_outlined,
            color: Colors.green,
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
          style: const TextStyle(fontSize: 11, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      height: 30,
      width: 1,
      color: isDark ? Colors.white24 : Colors.black12,
    );
  }
}
