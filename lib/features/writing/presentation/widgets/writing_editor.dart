import 'package:flutter/material.dart';

class WritingEditor extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final int minWordCount;
  final String? validationError;

  const WritingEditor({
    super.key,
    required this.controller,
    this.onChanged,
    this.minWordCount = 250,
    this.validationError,
  });

  int get _wordCount {
    final text = controller.text.trim();
    if (text.isEmpty) return 0;
    return text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length;
  }

  Color _getCounterColor(BuildContext context) {
    final count = _wordCount;
    if (count >= minWordCount) {
      return Colors.green;
    } else if (count >= 50) {
      return Colors.amber.shade800;
    } else {
      return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final count = _wordCount;
    final counterColor = _getCounterColor(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          maxLines: 12,
          minLines: 8,
          onTapOutside: (_) => FocusScope.of(context).unfocus(),
          decoration: InputDecoration(
            hintText: 'Type your essay response here (min. 50 words for AI evaluation)...',
            alignLabelWithHint: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: validationError != null ? Colors.red : Colors.grey.shade400,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: validationError != null ? Colors.red : theme.colorScheme.primary,
                width: 2,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
        const SizedBox(height: 8),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (count < 50 && count > 0)
              Text(
                'Requires at least 50 words (${50 - count} more needed)',
                style: const TextStyle(fontSize: 12, color: Colors.orange),
              )
            else if (count >= minWordCount)
              Row(
                children: const [
                  Icon(Icons.check_circle, size: 14, color: Colors.green),
                  SizedBox(width: 4),
                  Text(
                    'Target word count reached!',
                    style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold),
                  ),
                ],
              )
            else
              const SizedBox.shrink(),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: counterColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: counterColor.withValues(alpha: 0.4)),
              ),
              child: Text(
                '$count / $minWordCount words',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: counterColor,
                ),
              ),
            ),
          ],
        ),

        if (validationError != null) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, size: 18, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    validationError!,
                    style: const TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
