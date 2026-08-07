import 'package:flutter/material.dart';
import '../../ai_coach/presentation/ai_coach_screen.dart';
import '../../grammar/presentation/grammar_roadmap_screen.dart';
import '../../mock_exam/presentation/mock_exam_selection_screen.dart';
import '../../placement_test/presentation/placement_test_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../sentence_builder/presentation/sentence_builder_screen.dart';
import '../../speaking/presentation/speaking_screen.dart';
import '../../word_bank/presentation/word_bank_screen.dart';
import '../../writing/presentation/writing_screen.dart';
import '../data/dashboard_api_service.dart';
import '../domain/models/achievement_motivation_model.dart';
import '../domain/models/learning_path_model.dart';
import 'new_dashboard_screen.dart';
import 'widgets/daily_learning_path_widget.dart';
import 'widgets/milestone_badges_widget.dart';

/// Easy IELTS Student Dashboard connecting all 9 IELTS Practice Modules & Profile Management.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardApiService _apiService = DashboardApiService();

  bool _isLoading = true;
  LearningPathResponse? _learningPath;
  AchievementMotivationOverview? _motivationOverview;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    try {
      final path = await _apiService.fetchLearningPathToday();
      final motivation = await _apiService.fetchMotivationOverview();

      if (mounted) {
        setState(() {
          _learningPath = path;
          _motivationOverview = motivation;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleTaskTap(DailyTask task) {
    final module = task.moduleType.toLowerCase();
    Widget targetScreen;

    if (module.contains('vocab') || module.contains('flashcard')) {
      targetScreen = const WordBankScreen();
    } else if (module.contains('grammar')) {
      targetScreen = const GrammarRoadmapScreen();
    } else if (module.contains('write') || module.contains('essay')) {
      targetScreen = const WritingScreen();
    } else if (module.contains('speak')) {
      targetScreen = const SpeakingScreen();
    } else if (module.contains('sentence') || module.contains('builder')) {
      targetScreen = const SentenceBuilderScreen();
    } else if (module.contains('mock') || module.contains('read') || module.contains('listen')) {
      targetScreen = const MockExamSelectionScreen();
    } else {
      targetScreen = const AICoachScreen();
    }

    _navigateTo(targetScreen);
  }

  void _navigateTo(Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: CustomScrollView(
          slivers: [
            // Dashboard Header
            SliverAppBar(
              expandedHeight: 180.0,
              floating: false,
              pinned: true,
              actions: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const NewDashboardScreen()),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome, size: 16, color: Colors.amberAccent),
                    label: const Text(
                      'New Design',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.person_outline, color: Colors.white),
                  tooltip: 'User Profile',
                  onPressed: () => _navigateTo(const ProfileScreen()),
                ),
              ],
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Easy IELTS Dashboard', style: TextStyle(fontWeight: FontWeight.bold)),
                background: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SizedBox(height: 30),
                      Text('Target Score: Band 7.5', style: TextStyle(color: Colors.white70, fontSize: 14)),
                      Text('"Stop memorizing. Start using."', style: TextStyle(color: Colors.white, fontSize: 16, fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
              ),
            ),

            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Daily Learning Path
                      if (_learningPath != null)
                        DailyLearningPathWidget(
                          learningPath: _learningPath!,
                          onTaskTap: _handleTaskTap,
                        ),
                      const SizedBox(height: 18),

                      // 2. Milestone Badges Showcase
                      if (_motivationOverview != null)
                        MilestoneBadgesWidget(
                          unlockedBadges: _motivationOverview!.unlockedBadges,
                          lockedBadges: _motivationOverview!.lockedBadges,
                        ),
                      const SizedBox(height: 24),

                      Text(
                        'IELTS Feature Modules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 3. Complete Feature Modules Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.25,
                        children: [
                          _practiceCard(
                            context,
                            'AI Coach Tutor',
                            '24/7 Guidance & Insights',
                            Icons.psychology,
                            Colors.indigo,
                            () => _navigateTo(const AICoachScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Writing Lab',
                            'Task 1 & Task 2 AI Feedback',
                            Icons.edit_note,
                            Colors.blue,
                            () => _navigateTo(const WritingScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Speaking Coach',
                            'Whisper AI & Band Score',
                            Icons.mic,
                            Colors.purple,
                            () => _navigateTo(const SpeakingScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Placement Test',
                            'Diagnostic Band Evaluator',
                            Icons.assessment_outlined,
                            Colors.deepOrange,
                            () => _navigateTo(const PlacementTestScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Grammar Master',
                            'Interactive Drills & Error Taxonomy',
                            Icons.rule,
                            Colors.green,
                            () => _navigateTo(const GrammarRoadmapScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Sentence Builder',
                            'Syntax & Complex Structures',
                            Icons.build_outlined,
                            Colors.cyan,
                            () => _navigateTo(const SentenceBuilderScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Word Bank',
                            'Spaced Repetition Flashcards',
                            Icons.menu_book,
                            Colors.amber,
                            () => _navigateTo(const WordBankScreen()),
                          ),
                          _practiceCard(
                            context,
                            'Mock Exams',
                            'Timed Exam Simulation',
                            Icons.assignment,
                            Colors.teal,
                            () => _navigateTo(const MockExamSelectionScreen()),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _practiceCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: 0.15),
                child: Icon(icon, color: color),
              ),
              const SizedBox(height: 8),
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}
