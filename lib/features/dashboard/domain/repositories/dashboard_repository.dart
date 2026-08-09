import '../entities/achievement_motivation.dart';
import '../entities/learning_path.dart';

abstract class DashboardRepository {
  Future<LearningPathResponse> getLearningPathToday();
  Future<AchievementMotivationOverview> getMotivationOverview();
  Future<bool> activateStreakFreeze();
}
