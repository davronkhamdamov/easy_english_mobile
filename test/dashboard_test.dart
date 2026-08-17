import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:easy_english/features/dashboard/data/datasources/dashboard_remote_datasource.dart';
import 'package:easy_english/features/dashboard/data/repositories/dashboard_repository_impl.dart';
import 'package:easy_english/features/dashboard/domain/entities/achievement_motivation.dart';
import 'package:easy_english/features/dashboard/domain/entities/learning_path.dart';
import 'package:easy_english/features/dashboard/presentation/screens/yearly_activity_screen.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/dashboard_stat_cards_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/essential_vocabularies_section_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/grammar_banner_carousel_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/monthly_progress_card_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/new_dashboard_header_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/quick_action_item_tile.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/quick_actions_grid_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/skill_activity_progress_card_widget.dart';
import 'package:easy_english/features/dashboard/presentation/widgets/study_time_progress_card_widget.dart';
import 'package:easy_english/features/dashboard/presentation/screens/dashboard_screen.dart';
import 'package:easy_english/design_system/design_system.dart';

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

    testWidgets(
      'DashboardStatCardsWidget renders Learned Grammar and Learned Vocabularies cards',
      (WidgetTester tester) async {
        bool grammarTapped = false;
        bool vocabTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: DashboardStatCardsWidget(
                grammarCount: '14',
                grammarUnit: 'topics',
                grammarTitle: 'Learned Grammar',
                grammarSubtitle: 'Updated today',
                vocabCount: '190',
                vocabUnit: 'words',
                vocabTitle: 'Learned Vocabularies',
                vocabSubtitle: '31 min ago',
                onGrammarTap: () => grammarTapped = true,
                onVocabTap: () => vocabTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Learned Grammar'), findsOneWidget);
        expect(find.text('14'), findsOneWidget);
        expect(find.text('topics'), findsOneWidget);
        expect(find.text('Updated today'), findsOneWidget);

        expect(find.text('Learned Vocabularies'), findsOneWidget);
        expect(find.text('31 min ago'), findsOneWidget);
        expect(find.text('190'), findsOneWidget);
        expect(find.text('words'), findsOneWidget);

        await tester.tap(find.text('Learned Grammar'));
        expect(grammarTapped, isTrue);

        await tester.tap(find.text('Learned Vocabularies'));
        expect(vocabTapped, isTrue);
      },
    );

    testWidgets(
      'MonthlyProgressCardWidget renders month labels, glowing dot matrix, gauge and title',
      (WidgetTester tester) async {
        bool cardTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MonthlyProgressCardWidget(
                months: const ['Jan', 'Feb', 'Mar'],
                gaugeNumber: '2',
                title: 'Monthly Progress',
                subtitle: '18 active days this term',
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Jan'), findsOneWidget);
        expect(find.text('Feb'), findsOneWidget);
        expect(find.text('Mar'), findsOneWidget);
        expect(find.text('Monthly Progress'), findsOneWidget);
        expect(find.text('18 active days this term'), findsOneWidget);
        expect(find.text('2'), findsOneWidget);

        await tester.tap(find.text('Monthly Progress'));
        expect(cardTapped, isTrue);
      },
    );

    testWidgets(
      'StudyTimeProgressCardWidget renders digital time readout, category breakdown and handles tap',
      (WidgetTester tester) async {
        bool cardTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: StudyTimeProgressCardWidget(
                totalTime: '01:47:19',
                grammarTime: '57m',
                vocabTime: '24m',
                practiceTime: '26m',
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('01:47:19'), findsOneWidget);
        expect(find.text('57m'), findsOneWidget);
        expect(find.text('24m'), findsOneWidget);
        expect(find.text('26m'), findsOneWidget);

        await tester.tap(find.text('01:47:19'));
        expect(cardTapped, isTrue);
      },
    );

    testWidgets(
      'SkillActivityProgressCardWidget renders title and activity grid',
      (WidgetTester tester) async {
        bool cardTapped = false;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SkillActivityProgressCardWidget(
                title: 'Learning activity',
                onTap: () => cardTapped = true,
              ),
            ),
          ),
        );

        expect(find.text('Learning activity'), findsOneWidget);

        await tester.tap(find.text('Learning activity'));
        expect(cardTapped, isTrue);
      },
    );

    testWidgets(
      'YearlyActivityScreen renders title, year label and 12 month activity grids',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: YearlyActivityScreen(
              title: 'Learning Activity',
              year: '2026',
            ),
          ),
        );

        expect(find.text('Learning Activity'), findsAtLeastNWidgets(1));
        expect(find.text('2026'), findsOneWidget);
        expect(find.text('Jan'), findsOneWidget);
        expect(find.text('Dec'), findsOneWidget);
      },
    );

    testWidgets(
      'DashboardScreen renders native IosNativeTabBar when TargetPlatform.iOS',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.iOS),
            home: const DashboardScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(IosNativeTabBar), findsOneWidget);
        expect(find.byType(NavigationBar), findsNothing);
      },
    );

    testWidgets(
      'DashboardScreen renders Material NavigationBar when TargetPlatform.android',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(platform: TargetPlatform.android),
            home: const DashboardScreen(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.byType(NavigationBar), findsOneWidget);
        expect(find.byType(IosNativeTabBar), findsNothing);
      },
    );
  });
}
