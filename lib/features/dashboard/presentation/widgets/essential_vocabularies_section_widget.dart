import 'package:flutter/material.dart';
import '../../../practice/data/datasources/polysemy_vocab_data.dart';
import '../../../practice/presentation/screens/polysemy_category_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';

// TODO: Replace mock vocabulary essentials with WordBank repository data
class VocabularyEssentialItem {
  final String id;
  final String title;
  final String subtitle;
  final String actionLabel;
  final IconData icon;
  final String? categoryId;

  const VocabularyEssentialItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.actionLabel,
    required this.icon,
    this.categoryId,
  });
}

/// App Store inspired "Vocabularies >" section displaying horizontally scrollable
/// lists of vocabulary packs and flashcard decks using global theme tokens.
class EssentialVocabulariesSectionWidget extends StatelessWidget {
  final List<VocabularyEssentialItem> items;
  final VoidCallback? onSeeAllTap;

  // Curated IELTS vocabulary collections with dedicated polysemy practice
  static const List<VocabularyEssentialItem> mockVocabularies = [
    VocabularyEssentialItem(
      id: 'v100',
      title: 'Top 100 IELTS Words',
      subtitle: 'Multi-meaning words tested in Reading & Task 2',
      actionLabel: 'Practice',
      icon: Icons.menu_book_rounded,
      categoryId: 'ielts_100',
    ),
    VocabularyEssentialItem(
      id: 'v200',
      title: 'Top 200 Academic Words',
      subtitle: 'Band 7.5–9.0 polysemes & contextual usage',
      actionLabel: 'Practice',
      icon: Icons.psychology_rounded,
      categoryId: 'ielts_200',
    ),
    VocabularyEssentialItem(
      id: 'v1',
      title: 'Academic Band 8+ Words',
      subtitle: '50 High-frequency terms for Task 2 essays',
      actionLabel: 'Practice',
      icon: Icons.style_outlined,
      categoryId: 'ielts_100',
    ),
    VocabularyEssentialItem(
      id: 'v2',
      title: 'Topic Collocations: Environment',
      subtitle: 'Essential phrasal verbs & idiom pairs',
      actionLabel: 'Open',
      icon: Icons.auto_stories_rounded,
    ),
    VocabularyEssentialItem(
      id: 'v3',
      title: 'Speaking Part 2 Descriptors',
      subtitle: 'Fluency phrases & connector vocabulary',
      actionLabel: 'Learn',
      icon: Icons.record_voice_over_outlined,
    ),
    VocabularyEssentialItem(
      id: 'v4',
      title: 'Writing Task 1 Data Verbs',
      subtitle: 'Fluctuation, trend & percentage verbs',
      actionLabel: 'Practice',
      icon: Icons.show_chart_rounded,
    ),
    VocabularyEssentialItem(
      id: 'v5',
      title: 'Formal Synonym Replace',
      subtitle: 'Swap informal words for C1/C2 terms',
      actionLabel: 'Open',
      icon: Icons.find_replace_rounded,
    ),
    VocabularyEssentialItem(
      id: 'v6',
      title: 'Pronunciation & Intonation',
      subtitle: 'Stress patterns & silent letters',
      actionLabel: 'Start',
      icon: Icons.volume_up_outlined,
    ),
  ];

  const EssentialVocabulariesSectionWidget({
    super.key,
    this.items = mockVocabularies,
    this.onSeeAllTap,
  });

  void _handleItemTap(BuildContext context, VocabularyEssentialItem item) {
    if (item.categoryId != null) {
      final category = PolysemyVocabData.getCategoryById(item.categoryId!);
      if (category != null) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => PolysemyCategoryScreen(category: category),
          ),
        );
        return;
      }
    }
    _openWordBank(context);
  }

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
      onTap: () => _handleItemTap(context, item),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Row(
          children: [
            // Global theme styled icon container
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(
                item.icon,
                color: theme.colorScheme.onSurface,
                size: 24,
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
                      color: theme.colorScheme.onSurface,
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

            // Global theme Action Pill Button
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                item.actionLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurface,
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
