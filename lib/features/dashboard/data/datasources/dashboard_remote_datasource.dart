import '../../../../core/network/api_client.dart';
import '../models/achievement_motivation_model.dart';
import '../models/learning_path_model.dart';

abstract class DashboardRemoteDataSource {
  Future<LearningPathResponseModel> fetchLearningPathToday();
  Future<AchievementMotivationOverviewModel> fetchMotivationOverview();
  Future<bool> activateStreakFreeze();
}

class DashboardRemoteDataSourceImpl implements DashboardRemoteDataSource {
  final ApiClient _apiClient;

  ApiClient get apiClient => _apiClient;

  DashboardRemoteDataSourceImpl({ApiClient? apiClient})
    : _apiClient = apiClient ?? ApiClient();

  @override
  Future<LearningPathResponseModel> fetchLearningPathToday() async {
    await Future.delayed(const Duration(milliseconds: 250));
    return LearningPathResponseModel(
      todayPlan: DailyPlanModel(
        date: DateTime.now().toIso8601String().split('T')[0],
        focusSkill: 'Writing Task 2 & Grammar Remediation',
        dailyGoalMinutes: 30,
        tasks: const [
          DailyTaskModel(
            id: 'task_today_vocab',
            moduleType: 'vocabulary',
            title: 'Spaced Repetition Flashcards',
            description: 'Review 15 C1/C2 academic vocabulary flashcards.',
            durationMinutes: 10,
            targetObjective: 'Maintain >85% recall accuracy',
            isCompleted: true,
            actionRoute: '/word_bank',
          ),
          DailyTaskModel(
            id: 'task_today_grammar',
            moduleType: 'grammar',
            title: 'Grammar Focus: Conditionals & Inversion',
            description:
                'Complete interactive exercises targeting 3rd and mixed conditionals.',
            durationMinutes: 10,
            targetObjective: 'Scoring >=80% on targeted exercises',
            isCompleted: false,
            actionRoute: '/grammar',
          ),
          DailyTaskModel(
            id: 'task_today_writing',
            moduleType: 'writing',
            title: 'IELTS Writing Task 2 Practice',
            description:
                'Draft an academic essay response & evaluate with AI Band Examiner.',
            durationMinutes: 10,
            targetObjective: 'Targeting Band 7.5 Cohesion & Vocabulary',
            isCompleted: false,
            actionRoute: '/writing',
          ),
          DailyTaskModel(
            id: 'task_today_sentence',
            moduleType: 'sentence_builder',
            title: 'Sentence Builder Prompt',
            description:
                'Construct advanced complex sentences using active target vocabulary.',
            durationMinutes: 5,
            targetObjective: 'Use passive voice and conditional clauses',
            isCompleted: false,
            actionRoute: '/sentence_builder',
          ),
        ],
        totalEstimatedMinutes: 35,
        completedTasksCount: 1,
        totalTasksCount: 4,
        completionPercentage: 25.0,
      ),
      tomorrowPlan: DailyPlanModel(
        date: DateTime.now()
            .add(const Duration(days: 1))
            .toIso8601String()
            .split('T')[0],
        focusSkill: 'Speaking Fluency & Reading Comprehension',
        dailyGoalMinutes: 30,
        tasks: const [
          DailyTaskModel(
            id: 'task_tom_vocab',
            moduleType: 'vocabulary',
            title: 'C1 Academic Collocations',
            description:
                'Learn 10 new high-frequency IELTS academic collocations.',
            durationMinutes: 10,
            targetObjective: 'Memorize collocations with contextual examples',
            isCompleted: false,
            actionRoute: '/word_bank',
          ),
          DailyTaskModel(
            id: 'task_tom_speaking',
            moduleType: 'speaking',
            title: 'Speaking Part 2 AI Cue Card',
            description:
                'Record 2-minute response & get instant AI pronunciation and lexical feedback.',
            durationMinutes: 10,
            targetObjective: 'Achieve Band 7.5 fluency & minimal pause time',
            isCompleted: false,
            actionRoute: '/speaking',
          ),
          DailyTaskModel(
            id: 'task_tom_reading',
            moduleType: 'reading',
            title: 'Academic Reading Passage',
            description:
                'Solve passage exercises focusing on True/False/Not Given statement differentiation.',
            durationMinutes: 15,
            targetObjective: 'Complete passage under 18 minutes',
            isCompleted: false,
            actionRoute: '/reading',
          ),
        ],
        totalEstimatedMinutes: 35,
        completedTasksCount: 0,
        totalTasksCount: 3,
        completionPercentage: 0.0,
      ),
    );
  }

  @override
  Future<AchievementMotivationOverviewModel> fetchMotivationOverview() async {
    await Future.delayed(const Duration(milliseconds: 250));
    final todayDate = DateTime.now();

    final weeklyBreakdown = List.generate(7, (index) {
      final daysNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
      final startOfWeek = todayDate.subtract(
        Duration(days: todayDate.weekday - 1),
      );
      final d = startOfWeek.add(Duration(days: index));
      final isToday =
          d.year == todayDate.year &&
          d.month == todayDate.month &&
          d.day == todayDate.day;
      final isFuture = d.isAfter(todayDate);
      final isActive = !isFuture && (index < todayDate.weekday);

      return DayStreakInfoModel(
        day: daysNames[index],
        date: d.toIso8601String().split('T')[0],
        isActive: isActive,
        isToday: isToday,
        isFuture: isFuture,
        isFrozen: index == 2 && isActive,
      );
    });

    return AchievementMotivationOverviewModel(
      streakInfo: StreakInfoModel(
        streakCount: 7,
        isActiveToday: true,
        lastActiveDate: todayDate.toIso8601String().split('T')[0],
        streakFreezeCount: 1,
        streakFreezeAvailable: true,
        lastFreezeUsedDate: null,
        freezeProtectedYesterday: false,
        weeklyBreakdown: weeklyBreakdown,
        weeklyActiveDaysCount: 5,
      ),
      unlockedBadges: const [
        MilestoneBadgeModel(
          id: 'badge_streak_3',
          title: 'Flame Starter',
          description: 'Maintain a 3-day study streak',
          badgeIcon: 'local_fire_department',
          category: 'streak',
          isUnlocked: true,
          progressPercentage: 100.0,
          currentValue: 3,
          targetValue: 3,
        ),
        MilestoneBadgeModel(
          id: 'badge_streak_7',
          title: 'Consistency Champion',
          description: 'Maintain a 7-day study streak',
          badgeIcon: 'bolt',
          category: 'streak',
          isUnlocked: true,
          progressPercentage: 100.0,
          currentValue: 7,
          targetValue: 7,
        ),
        MilestoneBadgeModel(
          id: 'badge_placement',
          title: 'Diagnostic Pioneer',
          description: 'Complete Placement Diagnostic Test',
          badgeIcon: 'explore',
          category: 'diagnostic',
          isUnlocked: true,
          progressPercentage: 100.0,
          currentValue: 1,
          targetValue: 1,
        ),
      ],
      lockedBadges: const [
        MilestoneBadgeModel(
          id: 'badge_streak_30',
          title: 'IELTS Warrior',
          description: 'Maintain a 30-day study streak',
          badgeIcon: 'security',
          category: 'streak',
          isUnlocked: false,
          progressPercentage: 23.3,
          currentValue: 7,
          targetValue: 30,
        ),
        MilestoneBadgeModel(
          id: 'badge_vocab_50',
          title: 'Vocabulary Master',
          description: 'Master 50 C1/C2 academic words',
          badgeIcon: 'stars',
          category: 'vocabulary',
          isUnlocked: false,
          progressPercentage: 70.0,
          currentValue: 35,
          targetValue: 50,
        ),
        MilestoneBadgeModel(
          id: 'badge_mock_1',
          title: 'Mock Challenger',
          description: 'Complete 1 Full IELTS Mock Exam',
          badgeIcon: 'emoji_events',
          category: 'mock',
          isUnlocked: false,
          progressPercentage: 0.0,
          currentValue: 0,
          targetValue: 1,
        ),
      ],
      motivationalCards: const [
        MotivationalCardModel(
          id: 'card_streak_fire',
          title: '🔥 7-Day Streak Active!',
          message:
              'Consistency is the #1 predictor of scoring Band 7.5+. You are building mastery every single day.',
          cardType: 'streak_milestone',
          iconName: 'local_fire_department',
          accentColor: 'orange',
          actionLabel: 'Keep Streak Alive',
        ),
        MotivationalCardModel(
          id: 'card_freeze_status',
          title: '🛡️ Streak Freeze Protection Active',
          message:
              'You have 1 Streak Freeze shield available. Missed days won\'t reset your hard-earned progress.',
          cardType: 'freeze_status',
          iconName: 'shield',
          accentColor: 'indigo',
          actionLabel: 'Shield Info',
        ),
        MotivationalCardModel(
          id: 'card_quote',
          title: '💡 Coach IELTS Tip',
          message:
              '"Do not memorize canned answers. Focus on natural cohesion, precise vocabulary, and accurate grammar."',
          cardType: 'ai_coach_tip',
          iconName: 'lightbulb',
          accentColor: 'purple',
          actionLabel: 'Got It',
        ),
      ],
    );
  }

  @override
  Future<bool> activateStreakFreeze() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
