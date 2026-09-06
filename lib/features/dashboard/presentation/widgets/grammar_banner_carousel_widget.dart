import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../grammar/domain/entities/grammar_topic.dart';
import '../../../grammar/presentation/providers/grammar_provider.dart';
import '../../../grammar/presentation/screens/grammar_article_screen.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';

/// Grammar Featured Banner Carousel dynamically powered by actual [GrammarTopic]s.
/// Redesigned with a clean monochrome aesthetic.
class GrammarBannerCarouselWidget extends StatefulWidget {
  final List<GrammarTopic>? topics;
  final GrammarProvider? provider;
  final VoidCallback? onSeeAllTap;

  const GrammarBannerCarouselWidget({
    super.key,
    this.topics,
    this.provider,
    this.onSeeAllTap,
  });

  @override
  State<GrammarBannerCarouselWidget> createState() =>
      _GrammarBannerCarouselWidgetState();
}

class _GrammarBannerCarouselWidgetState
    extends State<GrammarBannerCarouselWidget> {
  late GrammarProvider _provider;
  bool _isLocalProvider = false;

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _provider = widget.provider!;
    } else {
      _provider = GrammarProvider();
      _isLocalProvider = true;
    }
    _provider.addListener(_onProviderChange);
    if (widget.topics == null && _provider.topics.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _provider.loadRoadmap();
      });
    }
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    if (_isLocalProvider) {
      _provider.dispose();
    }
    super.dispose();
  }

  void _openGrammarRoadmap(BuildContext context) {
    if (widget.onSeeAllTap != null) {
      widget.onSeeAllTap!();
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GrammarRoadmapScreen(provider: _provider),
        ),
      );
    }
  }

  void _openGrammarArticle(
      BuildContext context, GrammarTopic topic, List<GrammarTopic> allTopics) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GrammarArticleScreen(
          topic: topic,
          allTopics: allTopics,
        ),
      ),
    );
  }

  IconData _getTopicIcon(GrammarTopic topic) {
    final lower =
        '${topic.iconName} ${topic.title} ${topic.category}'.toLowerCase();
    if (lower.contains('condition') || lower.contains('flash')) {
      return Icons.auto_awesome_rounded;
    }
    if (lower.contains('relative') ||
        lower.contains('clause') ||
        lower.contains('link')) {
      return Icons.rule_rounded;
    }
    if (lower.contains('passive') || lower.contains('science')) {
      return Icons.science_rounded;
    }
    if (lower.contains('subject') ||
        lower.contains('spell') ||
        lower.contains('verb')) {
      return Icons.spellcheck_rounded;
    }
    if (lower.contains('article')) {
      return Icons.article_rounded;
    }
    return Icons.menu_book_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final actualTopics = widget.topics ?? _provider.topics;

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
          child: actualTopics.isEmpty
              ? (_provider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Center(
                      child: Text(
                        'No grammar topics available',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ))
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: actualTopics.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(width: 14),
                  itemBuilder: (context, index) {
                    final topic = actualTopics[index];
                    return _buildGrammarCard(
                        context, topic, actualTopics, isDark);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildGrammarCard(BuildContext context, GrammarTopic topic,
      List<GrammarTopic> allTopics, bool isDark) {
    final theme = Theme.of(context);
    final icon = _getTopicIcon(topic);
    final eyebrow = topic.category.isNotEmpty
        ? topic.category.toUpperCase()
        : 'CEFR ${topic.cefrLevel}';

    return Container(
      width: 300,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color:
              theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openGrammarArticle(context, topic, allTopics),
          borderRadius: BorderRadius.circular(22),
          child: Stack(
            children: [
              // Background Decorative Monochrome Icon
              Positioned(
                right: -10,
                top: -10,
                child: Icon(
                  icon,
                  size: 140,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.04),
                ),
              ),

              // Content Layout
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Eyebrow label + CEFR badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: isDark ? 0.15 : 0.2),
                            ),
                          ),
                          child: Text(
                            eyebrow,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            topic.cefrLevel,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Main Title
                    Text(
                      topic.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                        letterSpacing: -0.3,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      topic.description.isNotEmpty
                          ? topic.description
                          : 'Master key grammar patterns for IELTS.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 12,
                        height: 1.35,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),

                    // Bottom Monochrome Glass Pill Action Card
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
                            color: theme.colorScheme.surfaceContainerHighest
                                .withValues(alpha: 0.3),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: isDark ? 0.15 : 0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.menu_book_rounded,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  topic.readTime,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.onSurface,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Lesson',
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.surface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
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
