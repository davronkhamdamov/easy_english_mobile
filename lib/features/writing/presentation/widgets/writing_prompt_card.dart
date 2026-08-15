import 'package:flutter/material.dart';
import '../../domain/entities/writing_prompt.dart';

class WritingPromptCard extends StatelessWidget {
  final WritingPrompt? prompt;
  final String fallbackPromptText;
  final List<WritingPrompt> availablePrompts;
  final ValueChanged<WritingPrompt>? onPromptSelected;

  const WritingPromptCard({
    super.key,
    this.prompt,
    this.fallbackPromptText = '',
    this.availablePrompts = const [],
    this.onPromptSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final p = prompt;

    if (p == null && fallbackPromptText.isEmpty) {
      return const SizedBox.shrink();
    }

    final promptText = p?.promptText ?? fallbackPromptText;
    final title = p?.title ?? 'IELTS Writing Prompt';
    final topic = p?.topic ?? 'General';
    final minWords = p?.minWordCount ?? 250;
    final difficulty = p?.difficulty ?? 'Intermediate';

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Chip(
                  avatar: const Icon(Icons.category_outlined, size: 14),
                  label: Text(topic, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.primaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
                const SizedBox(width: 8),
                Chip(
                  avatar: const Icon(Icons.speed, size: 14),
                  label: Text(difficulty, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.secondaryContainer,
                  visualDensity: VisualDensity.compact,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Target: $minWords+ words',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            if (availablePrompts.length > 1 && onPromptSelected != null) ...[
              DropdownButton<WritingPrompt>(
                isExpanded: true,
                value: prompt,
                underline: const SizedBox(),
                icon: const Icon(Icons.arrow_drop_down_circle_outlined),
                items: availablePrompts.map((item) {
                  return DropdownMenuItem<WritingPrompt>(
                    value: item,
                    child: Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) onPromptSelected!(val);
                },
              ),
              const Divider(height: 16),
            ] else ...[
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
            ],

            Text(
              promptText,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
