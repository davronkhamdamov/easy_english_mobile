import 'package:flutter/material.dart';
import '../data/dashboard_api_service.dart';
import '../domain/models/learning_path_model.dart';
import '../domain/models/achievement_motivation_model.dart';
import 'widgets/streak_counter_card.dart';
import 'widgets/motivational_carousel.dart';
import 'widgets/daily_learning_path_widget.dart';
import 'widgets/milestone_badges_widget.dart';

/// Easy IELTS Student Dashboard integrating Learning Path Engine & Achievement/Motivation Engine.
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
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showFreezeDialog() {
    final streakInfo = _motivationOverview?.streakInfo;
    if (streakInfo == null) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.ac_unit, color: Colors.cyan, size: 28),
            SizedBox(width: 8),
            Text('Streak Freeze Shield'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available Shields: ${streakInfo.streakFreezeCount}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              streakInfo.streakFreezeAvailable
                  ? 'Streak Freeze automatically protects your study streak if you miss a single day of practice!'
                  : 'No shields remaining. Complete milestone goals to earn new Streak Freezes.',
              style: const TextStyle(color: Colors.black87, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.cyan.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.cyan.shade200),
              ),
              child: Row(
                children: const [
                  Icon(Icons.shield_outlined, color: Colors.cyan, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Protection active: Your 7-day streak is safe!',
                      style: TextStyle(fontSize: 12, color: Colors.cyan),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleTaskTap(DailyTask task) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starting Task: ${task.title} (${task.durationMinutes} mins)'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
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
                      // 1. Streak & Freeze Counter Card
                      if (_motivationOverview != null)
                        StreakCounterCard(
                          streakInfo: _motivationOverview!.streakInfo,
                          onFreezePressed: _showFreezeDialog,
                        ),
                      const SizedBox(height: 18),

                      // 2. Motivational Cards Carousel
                      if (_motivationOverview != null &&
                          _motivationOverview!.motivationalCards.isNotEmpty)
                        MotivationalCarousel(
                          cards: _motivationOverview!.motivationalCards,
                        ),
                      const SizedBox(height: 18),

                      // 3. Daily Learning Path (Today & Tomorrow)
                      if (_learningPath != null)
                        DailyLearningPathWidget(
                          learningPath: _learningPath!,
                          onTaskTap: _handleTaskTap,
                        ),
                      const SizedBox(height: 18),

                      // 4. Milestone Badges Showcase
                      if (_motivationOverview != null)
                        MilestoneBadgesWidget(
                          unlockedBadges: _motivationOverview!.unlockedBadges,
                          lockedBadges: _motivationOverview!.lockedBadges,
                        ),
                      const SizedBox(height: 24),

                      Text(
                        'Practice Modules',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 5. Practice Modules Grid
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.3,
                        children: [
                          _practiceCard(context, 'Writing Task 1 & 2', 'AI Band Evaluator', Icons.edit_note, Colors.blue),
                          _practiceCard(context, 'Speaking Coach', 'AI Pronunciation', Icons.mic, Colors.purple),
                          _practiceCard(context, 'Word Bank', 'Collocations & CEFR', Icons.menu_book, Colors.amber),
                          _practiceCard(context, 'Full Mock Test', 'Timed Exam Simulation', Icons.assignment, Colors.teal),
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

  Widget _practiceCard(BuildContext context, String title, String subtitle, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Navigating to $title...'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
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
