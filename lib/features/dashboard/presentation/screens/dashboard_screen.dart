import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../../ai_coach/presentation/screens/ai_coach_screen.dart';
import '../../../grammar/presentation/screens/grammar_roadmap_screen.dart';
import '../../../mock_exam/presentation/screens/mock_exam_selection_screen.dart';
import '../../../placement_test/presentation/screens/placement_test_screen.dart';
import '../../../practice/presentation/screens/practice_screen.dart';
import '../../../profile/presentation/screens/profile_screen.dart';
import '../../../sentence_builder/presentation/screens/sentence_builder_screen.dart';
import '../../../speaking/presentation/screens/speaking_screen.dart';
import '../../../word_bank/presentation/screens/vocabulary_screen.dart';
import '../../../word_bank/presentation/screens/word_bank_screen.dart';
import '../../../writing/presentation/screens/writing_screen.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../screens/yearly_activity_screen.dart';
import '../widgets/dashboard_stat_cards_widget.dart';
import '../widgets/new_dashboard_header_widget.dart';
import '../widgets/quick_actions_grid_widget.dart';
import '../widgets/skill_activity_progress_card_widget.dart';
import '../widgets/study_time_progress_card_widget.dart';

/// Easy IELTS Student Dashboard featuring platform-native bottom navigation.
///
/// On iOS, navigation uses the native iOS 26 Liquid Glass tab bar
/// (via [IOS26LiquidGlassNavigationBar]). On Android, a Material 3
/// [NavigationBar] is used.
class DashboardScreen extends StatefulWidget {
  final DashboardRepository? repository;
  final int initialIndex;

  const DashboardScreen({super.key, this.repository, this.initialIndex = 0});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late int _currentIndex;

  /// Scroll controller for the active screen — forwarded to native for
  /// tab-bar minimise-on-scroll.
  final ScrollController _dashboardScrollController = ScrollController();

  /// Bottom inset from the native tab bar (updated dynamically).
  double _nativeTabBarInset = 100;

  /// iOS 26 native tab items (SF Symbols).
  static const _ios26NavItems = [
    IOS26NavigationItem(
      id: 'home',
      sfSymbolName: 'house',
      selectedSfSymbolName: 'house.fill',
      label: 'Home',
    ),
    IOS26NavigationItem(
      id: 'practice',
      sfSymbolName: 'doc.text',
      selectedSfSymbolName: 'doc.text.fill',
      label: 'Practice',
    ),
    IOS26NavigationItem(
      id: 'vocabulary',
      sfSymbolName: 'character.book.closed',
      selectedSfSymbolName: 'character.book.closed.fill',
      label: 'Vocabulary',
    ),
    IOS26NavigationItem(
      id: 'textlab',
      sfSymbolName: 'quote.bubble',
      selectedSfSymbolName: 'quote.bubble.fill',
      label: 'Text Lab',
    ),
    IOS26NavigationItem(
      id: 'profile',
      sfSymbolName: 'person',
      selectedSfSymbolName: 'person.fill',
      label: 'Profile',
    ),
  ];

  /// Android Material navigation items.
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
      icon: Icons.menu_book_outlined,
      activeIcon: Icons.menu_book_rounded,
      label: 'Vocabulary',
    ),
    FloatingNavItem(
      icon: Icons.text_snippet_outlined,
      activeIcon: Icons.text_snippet_rounded,
      label: 'Text Lab',
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
    _currentIndex =
        widget.initialIndex < _ios26NavItems.length ? widget.initialIndex : 0;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      _setupNativeTabBarListener();
    }
  }

  void _setupNativeTabBarListener() {
    // Listen for tab-bar geometry changes to update bottom padding
    IOS26NavigationPlatform.instance.onTabBarFrameChanged = (geo) {
      if (mounted) {
        setState(() => _nativeTabBarInset = geo.height);
      }
    };
    // Request initial geometry
    IOS26NavigationPlatform.instance.getTabBarFrame().then((geo) {
      if (mounted && geo != null) {
        setState(() => _nativeTabBarInset = geo.height);
      }
    });
  }

  @override
  void dispose() {
    _dashboardScrollController.dispose();
    super.dispose();
  }

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
      case 'text_lab':
      case 'interactive_text':
        _navigateTo(context, const InteractiveTextPlaygroundScreen());
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

  Widget _buildBody({required bool isIOS}) {
    switch (_currentIndex) {
      case 0:
        return _buildDashboardCanvasContent(isIOS: isIOS);
      case 1:
        return const PracticeScreen();
      case 2:
        return const VocabularyScreen();
      case 3:
        return const InteractiveTextPlaygroundScreen();
      case 4:
        return _buildProfileContent();
      default:
        return _buildDashboardCanvasContent(isIOS: isIOS);
    }
  }

  Widget _buildDashboardCanvasContent({required bool isIOS}) {
    // On iOS, bottom padding is dynamically informed by the native tab bar.
    final bottomPad = isIOS ? _nativeTabBarInset + 16 : 16.0;

    return SafeArea(
      bottom: false, // Let content extend behind the glass tab bar
      child: SingleChildScrollView(
        controller: isIOS ? _dashboardScrollController : null,
        padding: EdgeInsets.fromLTRB(16, 12, 16, bottomPad),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Header: Profile avatar & name, "Hello, NAME", & notification bell
            const NewDashboardHeaderWidget(),
            const SizedBox(height: 16),

            // Top Stats: Learned Grammar & Learned Vocabularies cards
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
                  MaterialPageRoute(
                      builder: (_) => const GrammarRoadmapScreen()),
                );
              },
              onVocabTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const WordBankScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Card 1: Study Time Progress Card
            const StudyTimeProgressCardWidget(
              title: 'Learning time',
              totalTime: '01:47:19',
              grammarTime: '57m',
              vocabTime: '24m',
              practiceTime: '26m',
              listeningTime: '26m',
            ),
            const SizedBox(height: 14),

            // Card 2: Activity Matrix Progress Card
            SkillActivityProgressCardWidget(
              title: 'Learning activity',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (_) => const YearlyActivityScreen()),
                );
              },
            ),
            const SizedBox(height: 14),

            // Card 3: Quick Actions Grid
            QuickActionsGridWidget(
              title: 'Quick actions',
              onModuleTap: (key) => _handleModuleTap(context, key),
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
      // ── iOS: Native Liquid Glass tab bar floating over content ──
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
            IOS26LiquidGlassNavigationBar(
              items: _ios26NavItems,
              selectedIndex: _currentIndex,
              onSelected: (index) => setState(() => _currentIndex = index),
              onGeometryChanged: (geo) {
                if (mounted) setState(() => _nativeTabBarInset = geo.height);
              },
            ),
          ],
        ),
      );
    }

    // ── Android: Material 3 NavigationBar ──
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
        onDestinationSelected: (index) =>
            setState(() => _currentIndex = index),
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
