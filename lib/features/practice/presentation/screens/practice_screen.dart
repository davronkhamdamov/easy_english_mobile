import 'package:flutter/material.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../../dashboard/presentation/widgets/essential_vocabularies_section_widget.dart';
import '../../../dashboard/presentation/widgets/grammar_banner_carousel_widget.dart';

/// Practice Screen featuring Grammar Roadmap & Essential Vocabularies.
class PracticeScreen extends StatelessWidget {
  const PracticeScreen({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'Practice',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
        backgroundColor: backgroundColor,
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

              // 2. App Store Inspired Essential Vocabularies Section
              EssentialVocabulariesSectionWidget(
                onSeeAllTap: () =>
                    _navigateTo(context, const WordBankScreen()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
