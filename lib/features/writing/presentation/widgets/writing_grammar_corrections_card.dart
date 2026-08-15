import 'package:flutter/material.dart';
import '../../domain/entities/writing_evaluation.dart';

class WritingGrammarCorrectionsCard extends StatelessWidget {
  final List<GrammarCorrection> corrections;

  const WritingGrammarCorrectionsCard({
    super.key,
    required this.corrections,
  });

  @override
  Widget build(BuildContext context) {
    if (corrections.isEmpty) return const SizedBox.shrink();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: const Icon(Icons.spellcheck, color: Colors.redAccent),
        title: Text(
          'Grammar & Spelling Corrections (${corrections.length})',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: corrections.map((corr) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Original: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                      Expanded(
                        child: Text(
                          corr.original,
                          style: const TextStyle(decoration: TextDecoration.lineThrough),
                        ),
                      ),
                    ],
                  ),
                  if (corr.corrected.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Text('Corrected: ', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Expanded(
                          child: Text(
                            corr.corrected,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (corr.explanation.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      corr.explanation,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
