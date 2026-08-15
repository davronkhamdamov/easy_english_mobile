import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_item.dart';

class WordBankItemCard extends StatelessWidget {
  final FlashcardItem item;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onDelete;

  const WordBankItemCard({
    super.key,
    required this.item,
    this.onPlayAudio,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Word, Phonetic, CEFR Badge & Delete Action
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Flexible(
                        child: Text(
                          item.word,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.phonetic,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                          fontFamily: 'monospace',
                        ),
                      ),
                      if (onPlayAudio != null) ...[
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18),
                          onPressed: onPlayAudio,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: theme.colorScheme.primary,
                        ),
                      ],
                    ],
                  ),
                ),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getCefrColor(item.cefrLevel),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        item.cefrLevel,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    if (onDelete != null)
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'delete') onDelete?.call();
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red, size: 18),
                                SizedBox(width: 8),
                                Text('Delete Word'),
                              ],
                            ),
                          ),
                        ],
                        icon: const Icon(Icons.more_vert, size: 20),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.definition,
              style: theme.textTheme.bodyMedium,
            ),
            if (item.collocations.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: item.collocations
                    .map(
                      (col) => Chip(
                        label: Text(
                          col,
                          style: const TextStyle(fontSize: 11),
                        ),
                        backgroundColor: theme.colorScheme.primary
                            .withValues(alpha: 0.1),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ],
            if (item.example.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1E293B)
                      : theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.format_quote,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.example,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getCefrColor(String cefr) {
    switch (cefr.toUpperCase()) {
      case 'C2':
      case 'C1':
        return Colors.purple;
      case 'B2':
      case 'B1':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}
