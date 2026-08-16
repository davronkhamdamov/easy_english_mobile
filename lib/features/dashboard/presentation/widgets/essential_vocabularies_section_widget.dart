import 'package:flutter/material.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';

// TODO: Replace mock vocabulary essentials with WordBank repository data
class VocabularyEssentialItem {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final Color iconBackgroundColor;

  const VocabularyEssentialItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    required this.iconBackgroundColor,
  });
}

/// App Store inspired "Vocabularies >" section displaying horizontally scrollable
/// lists of vocabulary packs and flashcard decks.
class EssentialVocabulariesSectionWidget extends StatelessWidget {
  final List<VocabularyEssentialItem> items;
  final VoidCallback? onSeeAllTap;

  // TODO: Replace mock items with WordBank domain entities
  static const List<VocabularyEssentialItem> mockVocabularies = [
    VocabularyEssentialItem(
      id: 'v1',
      title: 'Academic Band 8+ Words',
      subtitle: '50 High-frequency terms for Task 2 essays',
      actionLabel: 'Practice',
      icon: Icons.style_outlined,
      iconBackgroundColor: Color(0xFFFF9500),
    ),
    VocabularyEssentialItem(
      id: 'v2',
      title: 'Topic Collocations: Environment',
      subtitle: 'Essential phrasal verbs & idiom pairs',
      actionLabel: 'Open',
      icon: Icons.auto_stories_rounded,
      iconBackgroundColor: Color(0xFF5856D6),
    ),
    VocabularyEssentialItem(
      id: 'v3',
      title: 'Speaking Part 2 Descriptors',
      subtitle: 'Fluency phrases & connector vocabulary',
      actionLabel: 'Learn',
      icon: Icons.record_voice_over_outlined,
      iconBackgroundColor: Color(0xFF007AFF),
    ),
    VocabularyEssentialItem(
      id: 'v4',
      title: 'Writing Task 1 Data Verbs',
      subtitle: 'Fluctuation, trend & percentage verbs',
      actionLabel: 'Practice',
      icon: Icons.show_chart_rounded,
      iconBackgroundColor: Color(0xFF34C759),
    ),
    VocabularyEssentialItem(
      id: 'v5',
      title: 'Formal Synonym Replace',
      subtitle: 'Swap informal words for C1/C2 terms',
      actionLabel: 'Open',
      icon: Icons.find_replace_rounded,
      iconBackgroundColor: Color(0xFFAF52DE),
    ),
    VocabularyEssentialItem(
      id: 'v6',
      title: 'Pronunciation & Intonation',
      subtitle: 'Stress patterns & silent letters',
      actionLabel: 'Start',
      icon: Icons.volume_up_outlined,
      iconBackgroundColor: Color(0xFFFF2D55),
    ),
  ];

  const EssentialVocabulariesSectionWidget({
    super.key,
    this.items = mockVocabularies,
    this.onSeeAllTap,
  });

  void _openWordBank(BuildContext context) {
    if (onSeeAllTap != null) {
      onSeeAllTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const WordBankScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Group items into columns of 3 (App Store layout)
    final List<List<VocabularyEssentialItem>> pages = [];
    for (var i = 0; i < items.length; i += 3) {
      pages.add(items.sublist(i, (i + 3 > items.length) ? items.length : i + 3));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header ("Vocabularies >")
        InkWell(
          onTap: () => _openWordBank(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Vocabularies',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),

        // Horizontal Scrolling 3-row Pages
        SizedBox(
          height: 216,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: pages.length,
            separatorBuilder: (context, index) => const SizedBox(width: 16),
            itemBuilder: (context, pageIndex) {
              final pageItems = pages[pageIndex];
              return SizedBox(
                width: 320,
                child: Column(
                  children: pageItems
                      .map((item) => _buildVocabularyRow(context, item))
                      .toList(),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildVocabularyRow(
    BuildContext context,
    VocabularyEssentialItem item,
  ) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _openWordBank(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // App-icon style rounded container
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: item.iconBackgroundColor,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(
                item.icon,
                color: Colors.white,
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Action Pill Button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.6,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                item.actionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
