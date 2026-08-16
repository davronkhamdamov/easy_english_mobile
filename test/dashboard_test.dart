import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:easy_english/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:easy_english/features/dashboard/domain/entities/achievement_motivation.dart';
import 'package:easy_english/features/dashboard/domain/entities/learning_path.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/essential_vocabularies_section_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/grammar_banner_carousel_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/new_dashboard_header_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/quick_action_item_tile.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/quick_actions_grid_widget.dart';

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

  group('Quick Actions Widget Tests', () {
    testWidgets('QuickActionItemTile renders label and icon and handles tap', (
      WidgetTester tester,
    ) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: QuickActionItemTile(
              label: 'Writing',
              icon: Icons.edit_note_rounded,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Writing'), findsOneWidget);
      expect(find.byIcon(Icons.edit_note_rounded), findsOneWidget);

      await tester.tap(find.text('Writing'));
      expect(tapped, isTrue);
    });

    testWidgets(
      'QuickActionsGridWidget renders 8 IELTS feature module quick actions',
      (WidgetTester tester) async {
        String? tappedModule;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: QuickActionsGridWidget(
                title: 'Quick actions',
                onModuleTap: (key) => tappedModule = key,
              ),
            ),
          ),
        );

        expect(find.text('Quick actions'), findsOneWidget);

        expect(find.text('AI Coach'), findsOneWidget);
        expect(find.text('Writing'), findsOneWidget);
        expect(find.text('Speaking'), findsOneWidget);
        expect(find.text('Placement'), findsOneWidget);
        expect(find.text('Grammar'), findsOneWidget);
        expect(find.text('Sentence'), findsOneWidget);
        expect(find.text('Word Bank'), findsOneWidget);
        expect(find.text('Mock Exam'), findsOneWidget);

        await tester.tap(find.text('AI Coach'));
        expect(tappedModule, equals('ai_coach'));
      },
    );
  });

  group('App Store Inspired Dashboard Widgets Tests', () {
    testWidgets(
      'NewDashboardHeaderWidget renders greeting name and handles notification tap',
      (WidgetTester tester) async {
        bool notificationTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NewDashboardHeaderWidget(
                userName: 'VICTOR',
                onNotificationTap: () => notificationTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Hello, VICTOR'), findsOneWidget);
        expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);

        await tester.tap(find.byIcon(Icons.notifications_none_rounded));
        expect(notificationTapped, isTrue);
      },
    );

    testWidgets(
      'GrammarBannerCarouselWidget renders section header and grammar cards',
      (WidgetTester tester) async {
        bool headerTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: GrammarBannerCarouselWidget(
                  onSeeAllTap: () => headerTapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Grammars'), findsOneWidget);
        expect(find.text('Conditionals & Inversion'), findsAtLeastNWidgets(1));

        await tester.tap(find.text('Grammars'));
        expect(headerTapped, isTrue);
      },
    );

    testWidgets(
      'EssentialVocabulariesSectionWidget renders section header and vocabulary rows',
      (WidgetTester tester) async {
        bool headerTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SingleChildScrollView(
                child: EssentialVocabulariesSectionWidget(
                  onSeeAllTap: () => headerTapped = true,
                ),
              ),
            ),
          ),
        );

        expect(find.text('Vocabularies'), findsOneWidget);
        expect(find.text('Academic Band 8+ Words'), findsOneWidget);

        await tester.tap(find.text('Vocabularies'));
        expect(headerTapped, isTrue);
      },
    );
  });
}
