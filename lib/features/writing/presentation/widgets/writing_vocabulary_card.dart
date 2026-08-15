import 'package:flutter/material.dart';
import '../../domain/entities/writing_evaluation.dart';

class WritingVocabularyCard extends StatelessWidget {
  final List<VocabularySuggestion> vocabularySuggestions;

  const WritingVocabularyCard({
    super.key,
    required this.vocabularySuggestions,
  });

  @override
  Widget build(BuildContext context) {
    if (vocabularySuggestions.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.auto_fix_high, color: Colors.purple),
        title: Text(
          'Vocabulary Enhancements (${vocabularySuggestions.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: vocabularySuggestions.map((vocab) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Used: "${vocab.usedWord}"',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: vocab.suggestedAlternatives.map((alt) {
                      return Chip(
                        label: Text(alt, style: const TextStyle(fontSize: 12)),
                        backgroundColor: Colors.purple.withValues(alpha: 0.1),
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
