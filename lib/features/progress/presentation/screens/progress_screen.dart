import 'package:flutter/material.dart';
import '../../../ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../../dashboard/presentation/widgets/quick_actions_grid_widget.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../mock_exam/presentation/screens/mock_exam_selection_screen.dart';
import '../../../placement_test/presentation/screens/placement_test_screen.dart';
import '../../../sentence_builder/presentation/screens/sentence_builder_screen.dart';
import '../../../speaking/presentation/screens/speaking_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../../writing/presentation/screens/writing_screen.dart';

/// Progress Screen featuring Quick Actions Grid.
class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _handleModuleTap(BuildContext context, String moduleKey) {
    switch (moduleKey) {
      case 'grammar':
        _navigateTo(context, const GrammarRoadmapScreen());
        break;
      case 'writing':
        _navigateTo(context, const WritingScreen());
        break;
      case 'speaking':
        _navigateTo(context, const SpeakingScreen());
        break;
      case 'word_bank':
        _navigateTo(context, const WordBankScreen());
        break;
      case 'placement':
      case 'placement_test':
        _navigateTo(context, const PlacementTestScreen());
        break;
      case 'sentence':
      case 'sentence_builder':
        _navigateTo(context, const SentenceBuilderScreen());
        break;
      case 'mock_exam':
        _navigateTo(context, const MockExamSelectionScreen());
        break;
      case 'ai_coach':
      default:
        _navigateTo(context, const AICoachScreen());
        break;
    }
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
          'Progress',
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
              QuickActionsGridWidget(
                title: 'Quick actions',
                onModuleTap: (key) => _handleModuleTap(context, key),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
