import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../mock_exam/presentation/screens/mock_exam_selection_screen.dart';
import '../../../placement_test/presentation/screens/placement_test_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../../sentence_builder/presentation/screens/sentence_builder_screen.dart';
import '../../../speaking/presentation/screens/speaking_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../../writing/presentation/screens/writing_screen.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../widgets/essential_vocabularies_section_widget.dart';
import '../widgets/grammar_banner_carousel_widget.dart';
import '../widgets/new_dashboard_header_widget.dart';
import '../widgets/quick_actions_grid_widget.dart';

/// Easy IELTS Student Dashboard featuring the Floating Pill Navigation Bar.
class DashboardScreen extends StatefulWidget {
  final DashboardRepository? repository;
  final int initialIndex;

  const DashboardScreen({super.key, this.repository, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  final List<FloatingNavItem> _navItems = const [
    FloatingNavItem(
      icon: Icons.home_outlined,
      activeIcon: Icons.home_rounded,
      label: 'Home',
    ),
    FloatingNavItem(
      icon: Icons.assignment_outlined,
      activeIcon: Icons.assignment_rounded,
      label: 'Practice',
    ),
    FloatingNavItem(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Progress',
    ),
    FloatingNavItem(
      icon: Icons.person_outline_rounded,
      activeIcon: Icons.person_rounded,
      label: 'Profile',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex < _navItems.length ? widget.initialIndex : 0;
  }

  void _navigateTo(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _handleModuleTap(String moduleKey) {
    switch (moduleKey) {
      case 'grammar':
        _navigateTo(const GrammarRoadmapScreen());
        break;
      case 'writing':
        _navigateTo(const WritingScreen());
        break;
      case 'speaking':
        _navigateTo(const SpeakingScreen());
        break;
      case 'word_bank':
        _navigateTo(const WordBankScreen());
        break;
      case 'placement':
      case 'placement_test':
        _navigateTo(const PlacementTestScreen());
        break;
      case 'sentence':
      case 'sentence_builder':
        _navigateTo(const SentenceBuilderScreen());
        break;
      case 'mock_exam':
        _navigateTo(const MockExamSelectionScreen());
        break;
      case 'ai_coach':
      default:
        _navigateTo(const AICoachScreen());
        break;
    }
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardCanvasContent();
      case 1:
        return const PracticeScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return _buildProfileContent();
      default:
        return _buildDashboardCanvasContent();
    }
  }

  Widget _buildDashboardCanvasContent() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Profile avatar & name, single-line "Hello, NAME", & notification bell
            const NewDashboardHeaderWidget(),
            const SizedBox(height: 16),

            // 1. App Store Inspired Grammar Featured Hero Carousel
            GrammarBannerCarouselWidget(
              onSeeAllTap: () => _navigateTo(const GrammarRoadmapScreen()),
            ),
            const SizedBox(height: 24),

            // 2. App Store Inspired Essential Vocabularies Section
            EssentialVocabulariesSectionWidget(
              onSeeAllTap: () => _navigateTo(const WordBankScreen()),
            ),
            const SizedBox(height: 12),

            // 3. Quick Actions Grid
            QuickActionsGridWidget(
              title: 'Quick actions',
              onModuleTap: _handleModuleTap,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent() {
    return const ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey<int>(_currentIndex),
                child: _buildBody(),
              ),
            ),
          ),
          FloatingPillNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: _navItems,
          ),
        ],
      ),
    );
  }
}
