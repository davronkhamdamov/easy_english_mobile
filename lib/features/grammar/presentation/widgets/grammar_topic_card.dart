import 'package:flutter/material.dart';
import '../../domain/entities/grammar_topic.dart';

class GrammarTopicCard extends StatelessWidget {
  final GrammarTopic topic;
  final VoidCallback onTap;

  const GrammarTopicCard({
    super.key,
    required this.topic,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isCompleted = topic.isCompleted || topic.status == GrammarTopicStatus.completed || topic.progressPercent >= 100;
    final isUnfinished = topic.status == GrammarTopicStatus.current || (topic.progressPercent > 0 && !isCompleted);

    Color badgeColor;
    Color badgeTextColor;
    String statusText;

    if (isCompleted) {
      badgeColor = isDark ? Colors.green.withValues(alpha: 0.2) : Colors.green.shade100;
      badgeTextColor = isDark ? Colors.green.shade300 : Colors.green.shade900;
      statusText = 'Learnt';
    } else if (isUnfinished) {
      badgeColor = isDark ? theme.colorScheme.primary.withValues(alpha: 0.2) : theme.colorScheme.secondaryContainer;
      badgeTextColor = isDark ? theme.colorScheme.primary : theme.colorScheme.onSecondaryContainer;
      statusText = 'Unfinished';
    } else {
      badgeColor = theme.colorScheme.surfaceContainerHighest;
      badgeTextColor = theme.colorScheme.onSurfaceVariant;
      statusText = 'New';
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      topic.cefrLevel,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusText,
                      style: TextStyle(
                        color: badgeTextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ],
              ),
              if (topic.description.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  topic.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.menu_book_rounded, size: 14, color: theme.colorScheme.primary),
                      const SizedBox(width: 4),
                      Text(
                        'Lesson (${topic.readTime})',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Read Article',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(Icons.arrow_forward_ios_rounded, size: 10, color: theme.colorScheme.primary),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
