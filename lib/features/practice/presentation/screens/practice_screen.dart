import 'package:flutter/material.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../../dashboard/presentation/widgets/essential_vocabularies_section_widget.dart';
import '../../../dashboard/presentation/widgets/grammar_banner_carousel_widget.dart';
import '../../../youtube_listening/presentation/screens/youtube_listening_screen.dart';
import '../../../youtube_listening/presentation/widgets/youtube_listening_feature_card.dart';
import '../widgets/polysemy_featured_banner_widget.dart';

/// Practice Screen featuring Grammar Roadmap, IELTS Multi-Meaning Vocabularies & YouListen Video Pronunciation.
/// Styled using the global ThemeData and AppColors design tokens.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Practice',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: -0.4,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. App Store Inspired Grammar Featured Hero Carousel
              GrammarBannerCarouselWidget(
                onSeeAllTap: () =>
                    _navigateTo(context, const GrammarRoadmapScreen()),
              ),
              const SizedBox(height: 24),

              // 2. IELTS Multi-Meaning Vocabulary Practice (Top 100 & 200 MCQ Context Tests)
              const PolysemyFeaturedBannerWidget(),
              const SizedBox(height: 24),

              // 3. App Store Inspired Essential Vocabularies Section
              EssentialVocabulariesSectionWidget(
                onSeeAllTap: () =>
                    _navigateTo(context, const WordBankScreen()),
              ),
              const SizedBox(height: 24),

              // 4. YouListen YouTube Video & Pronunciation Listening Feature
              YoutubeListeningFeatureCard(
                onTap: () =>
                    _navigateTo(context, const YoutubeListeningScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
