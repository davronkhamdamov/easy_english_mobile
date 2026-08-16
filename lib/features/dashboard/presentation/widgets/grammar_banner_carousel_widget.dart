import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';

// TODO: Replace mock grammar featured lessons with remote API data
class GrammarBannerItem {
  final String id;
  final String eyebrow;
  final String title;
  final String description;
  final String actionLabel;
  final List<Color> gradientColors;
  final IconData icon;

  const GrammarBannerItem({
    required this.id,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.gradientColors,
    required this.icon,
  });
}

/// App Store inspired Grammar Featured Banner Carousel.
/// Displays grammar topic hero cards scrolling horizontally.
class GrammarBannerCarouselWidget extends StatelessWidget {
  final List<GrammarBannerItem> items;
  final VoidCallback? onSeeAllTap;

  // TODO: Replace mock grammar items with domain repository call
  static const List<GrammarBannerItem> mockGrammarItems = [
    GrammarBannerItem(
      id: 'g1',
      eyebrow: 'HAPPENING NOW',
      title: 'Conditionals & Inversion',
      description: 'Master Band 8+ complex structures for Task 2',
      actionLabel: 'Start',
      gradientColors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
      icon: Icons.auto_awesome_rounded,
    ),
    GrammarBannerItem(
      id: 'g2',
      eyebrow: 'GRAMMAR FOCUS',
      title: 'Relative & Noun Clauses',
      description: 'Avoid run-on sentences & boost cohesion',
      actionLabel: 'Practice',
      gradientColors: [Color(0xFF0F2027), Color(0xFF2C5364)],
      icon: Icons.rule_rounded,
    ),
    GrammarBannerItem(
      id: 'g3',
      eyebrow: 'BAND 8+ ACCURACY',
      title: 'Passive Voice Mastery',
      description: 'Academic reporting verbs for Task 1 reports',
      actionLabel: 'Explore',
      gradientColors: [Color(0xFF4A00E0), Color(0xFF8E2DE2)],
      icon: Icons.spellcheck_rounded,
    ),
  ];

  const GrammarBannerCarouselWidget({
    super.key,
    this.items = mockGrammarItems,
    this.onSeeAllTap,
  });

  void _openGrammarRoadmap(BuildContext context) {
    if (onSeeAllTap != null) {
      onSeeAllTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GrammarRoadmapScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title Header with clickable arrow/button
        InkWell(
          onTap: () => _openGrammarRoadmap(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 6.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Grammars',
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

        // Horizontal Banner Carousel
        SizedBox(
          height: 220,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: items.length,
            separatorBuilder: (context, index) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return _buildGrammarCard(context, item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildGrammarCard(BuildContext context, GrammarBannerItem item) {
    final theme = Theme.of(context);

    return Container(
      width: 300,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: item.gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: item.gradientColors.first.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGrammarRoadmap(context),
          borderRadius: BorderRadius.circular(20),
          child: Stack(
            children: [
              // Background Decorative Icon
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  item.icon,
                  size: 140,
                  color: Colors.white.withValues(alpha: 0.12),
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow label
                    Text(
                      item.eyebrow,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Main Title
                    Text(
                      item.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Bottom Glass Pill Action Card
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.2),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  item.title,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.25),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  item.actionLabel,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
