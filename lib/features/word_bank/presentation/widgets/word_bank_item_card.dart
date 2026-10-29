import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_item.dart';
import '../screens/word_definition_screen.dart';

class WordBankItemCard extends StatelessWidget {
  final FlashcardItem item;
  final VoidCallback? onPlayAudio;
  final VoidCallback? onDelete;
  final VoidCallback? onTapWord;

  const WordBankItemCard({
    super.key,
    required this.item,
    this.onPlayAudio,
    this.onDelete,
    this.onTapWord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 12.0),
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
      ),
      elevation: 0,
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
                        child: InkWell(
                          onTap: onTapWord ??
                              () => WordDefinitionScreen.open(context, word: item.word),
                          borderRadius: BorderRadius.circular(6),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 2.0),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Flexible(
                                  child: Text(
                                    item.word,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.onSurface,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.open_in_new_rounded,
                                  size: 13,
                                  color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        item.phonetic,
                        style: TextStyle(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontFamily: 'monospace',
                          fontSize: 13,
                        ),
                      ),
                      if (onPlayAudio != null) ...[
                        IconButton(
                          icon: const Icon(Icons.volume_up, size: 18),
                          onPressed: onPlayAudio,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          color: theme.colorScheme.onSurface,
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
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.15),
                        ),
                      ),
                      child: Text(
                        item.cefrLevel,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
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
                                Icon(Icons.delete_outline, color: Colors.redAccent, size: 18),
                                SizedBox(width: 8),
                                Text('Delete Word'),
                              ],
                            ),
                          ),
                        ],
                        icon: Icon(Icons.more_vert, size: 20, color: theme.colorScheme.onSurface),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              item.definition,
              style: TextStyle(
                color: theme.colorScheme.onSurface,
                fontSize: 14,
              ),
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
                          style: TextStyle(
                            fontSize: 11,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        side: BorderSide(
                          color: theme.colorScheme.outline.withValues(alpha: 0.2),
                        ),
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
                  color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.format_quote,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        item.example,
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          color: theme.colorScheme.onSurfaceVariant,
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
}
