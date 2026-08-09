import 'package:flutter/material.dart';

class WritingPromptCard extends StatelessWidget {
  final String prompt;
  final String title;

  const WritingPromptCard({
    super.key,
    required this.prompt,
    this.title = 'Essay Prompt',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(prompt, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
