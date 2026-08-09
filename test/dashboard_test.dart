import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:easy_english/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:easy_english/features/dashboard/domain/entities/achievement_motivation.dart';
import 'package:easy_english/features/dashboard/domain/entities/learning_path.dart';

void main() {
  group('Dashboard Feature Architecture Tests', () {
    late DashboardRemoteDataSource remoteDataSource;
    late DashboardRepositoryImpl repository;

    setUp(() {
      remoteDataSource = DashboardRemoteDataSourceImpl();
      repository = DashboardRepositoryImpl(remoteDataSource: remoteDataSource);
    });

    test(
      'getLearningPathToday returns valid domain LearningPathResponse entity',
      () async {
        final result = await repository.getLearningPathToday();

        expect(result, isA<LearningPathResponse>());
        expect(result.todayPlan.tasks, isNotEmpty);
        expect(result.todayPlan.dailyGoalMinutes, equals(30));
        expect(result.tomorrowPlan.tasks, isNotEmpty);
      },
    );

    test(
      'getMotivationOverview returns valid domain AchievementMotivationOverview entity',
      () async {
        final result = await repository.getMotivationOverview();

        expect(result, isA<AchievementMotivationOverview>());
        expect(result.streakInfo.streakCount, equals(7));
        expect(result.unlockedBadges, isNotEmpty);
        expect(result.lockedBadges, isNotEmpty);
        expect(result.motivationalCards, isNotEmpty);
      },
    );

    test('activateStreakFreeze returns true', () async {
      final result = await repository.activateStreakFreeze();
      expect(result, isTrue);
    });
  });
}
