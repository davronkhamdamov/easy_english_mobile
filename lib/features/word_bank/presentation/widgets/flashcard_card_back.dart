import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_item.dart';

class FlashcardCardBack extends StatelessWidget {
  final FlashcardItem card;

  const FlashcardCardBack({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.4),
          width: 2.0,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  card.word,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
                _buildCefrBadge(card.cefrLevel),
              ],
            ),
            const Divider(height: 20),
            const Text(
              'DEFINITION',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.definition,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            if (card.collocations.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Text(
                'COLLOCATIONS',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: card.collocations
                    .map(
                      (c) => Chip(
                        label: Text(c, style: const TextStyle(fontSize: 11)),
                        backgroundColor:
                            theme.colorScheme.primary.withValues(alpha: 0.1),
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCefrBadge(String cefr) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.purple,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        cefr,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.white,
          fontSize: 11,
        ),
      ),
    );
  }
}
