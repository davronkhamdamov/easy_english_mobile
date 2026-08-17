import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../progress/presentation/screens/progress_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../screens/yearly_activity_screen.dart';
import '../widgets/dashboard_stat_cards_widget.dart';
import '../widgets/new_dashboard_header_widget.dart';
import '../widgets/skill_activity_progress_card_widget.dart';
import '../widgets/study_time_progress_card_widget.dart';

/// Easy IELTS Student Dashboard featuring platform-native bottom navigation.
class DashboardScreen extends StatefulWidget {
  final DashboardRepository? repository;
  final int initialIndex;

  const DashboardScreen({super.key, this.repository, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  final List<FloatingNavItem> _iosNavItems = const [
    FloatingNavItem(
      icon: CupertinoIcons.house,
      activeIcon: CupertinoIcons.house_fill,
      label: 'Home',
    ),
    FloatingNavItem(
      icon: CupertinoIcons.doc_text,
      activeIcon: CupertinoIcons.doc_text_fill,
      label: 'Practice',
    ),
    FloatingNavItem(
      icon: CupertinoIcons.chart_bar,
      activeIcon: CupertinoIcons.chart_bar_fill,
      label: 'Progress',
    ),
    FloatingNavItem(
      icon: CupertinoIcons.person,
      activeIcon: CupertinoIcons.person_fill,
      label: 'Profile',
    ),
  ];

  final List<FloatingNavItem> _androidNavItems = const [
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
    _currentIndex = widget.initialIndex < _iosNavItems.length ? widget.initialIndex : 0;
  }

  Widget _buildBody({required bool isIOS}) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardCanvasContent(isIOS: isIOS);
      case 1:
        return const PracticeScreen();
      case 2:
        return const ProgressScreen();
      case 3:
        return _buildProfileContent();
      default:
        return _buildDashboardCanvasContent(isIOS: isIOS);
    }
  }

  Widget _buildDashboardCanvasContent({required bool isIOS}) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 12, 16, isIOS ? 100 : 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Profile avatar & name, single-line "Hello, NAME", & notification bell
            const NewDashboardHeaderWidget(),
            const SizedBox(height: 16),

            // Top Stats: Learned Grammar & Learned Vocabularies cards (Untouched)
            DashboardStatCardsWidget(
              grammarCount: '14',
              grammarUnit: 'topics',
              grammarTitle: 'Learned Grammar',
              grammarSubtitle: 'Updated today',
              vocabCount: '190',
              vocabUnit: 'words',
              vocabTitle: 'Learned Vocabularies',
              vocabSubtitle: '31 min ago',
              onGrammarTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const GrammarRoadmapScreen()),
                );
              },
              onVocabTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WordBankScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Card 1: Study Time Progress Card (Static display, no navigation)
            const StudyTimeProgressCardWidget(
              totalTime: '01:47:19',
              grammarTime: '57m',
              vocabTime: '24m',
              practiceTime: '26m',
            ),
            const SizedBox(height: 14),

            // Card 5: Activity Matrix Progress Card -> Opens 12-Month Yearly Activity Screen
            SkillActivityProgressCardWidget(
              title: 'Learning activity',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const YearlyActivityScreen()),
                );
              },
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
    final isIOS = Theme.of(context).platform == TargetPlatform.iOS;

    if (isIOS) {
      return Scaffold(
        body: Stack(
          children: [
            Positioned.fill(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: KeyedSubtree(
                  key: ValueKey<int>(_currentIndex),
                  child: _buildBody(isIOS: true),
                ),
              ),
            ),
            FloatingPillNavBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              items: _iosNavItems,
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: KeyedSubtree(
          key: ValueKey<int>(_currentIndex),
          child: _buildBody(isIOS: false),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) => setState(() => _currentIndex = index),
        destinations: _androidNavItems.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon),
            selectedIcon: Icon(item.activeIcon ?? item.icon),
            label: item.label,
          );
        }).toList(),
      ),
    );
  }
}
