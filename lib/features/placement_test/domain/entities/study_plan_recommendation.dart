import 'estimated_band_score.dart';

/// Item entity for daily study schedule items.
class DailyScheduleItem {
  final String day;
  final String focusSkill;
  final int durationMinutes;
  final String topic;
  final String action;

  const DailyScheduleItem({
    required this.day,
    required this.focusSkill,
    required this.durationMinutes,
    required this.topic,
    required this.action,
  });
}

/// Domain entity representing personalized IELTS study plan recommendations.
class StudyPlanRecommendation {
  final double currentOverallBand;
  final double targetBand;
  final int recommendedDailyMinutes;
  final int estimatedWeeksToTarget;
  final List<String> focusAreas;
  final List<DailyScheduleItem> weeklySchedule;
  final List<String> keyMilestones;

  const StudyPlanRecommendation({
    required this.currentOverallBand,
    required this.targetBand,
    required this.recommendedDailyMinutes,
    required this.estimatedWeeksToTarget,
    required this.focusAreas,
    required this.weeklySchedule,
    required this.keyMilestones,
  });

  factory StudyPlanRecommendation.generate({
    required EstimatedBandScore bandScore,
    double targetBand = 7.5,
  }) {
    final gap = (targetBand - bandScore.overallBand).clamp(0.0, 4.0);
    final estimatedWeeks = (gap * 6.0).round().clamp(2, 24);

    final int dailyMins = bandScore.overallBand < 6.0
        ? 60
        : bandScore.overallBand < 7.0
        ? 45
        : 30;

    final schedule = [
      DailyScheduleItem(
        day: 'Monday',
        focusSkill: 'Grammar & Writing',
        durationMinutes: (dailyMins * 0.6).round(),
        topic: 'Complex Sentence Structures & Clause Connectors',
        action: 'Write 1 Task 2 Essay & run AI Grammar evaluation.',
      ),
      DailyScheduleItem(
        day: 'Tuesday',
        focusSkill: 'Vocabulary (Word Bank)',
        durationMinutes: (dailyMins * 0.5).round(),
        topic: 'CEFR C1 Collocations & Topic Idioms',
        action: 'Review 20 spaced repetition flashcards & complete quiz.',
      ),
      DailyScheduleItem(
        day: 'Wednesday',
        focusSkill: 'Reading Comprehension',
        durationMinutes: (dailyMins * 0.6).round(),
        topic: 'Academic Passage Skimming & Speed Drills',
        action: 'Solve 1 Full Reading Passage (14 Questions) under 18 mins.',
      ),
      DailyScheduleItem(
        day: 'Thursday',
        focusSkill: 'Listening & Accent Training',
        durationMinutes: (dailyMins * 0.5).round(),
        topic: 'Connected Speech & Australian/UK Accents',
        action: 'Complete Section 3 & Section 4 listening exercises.',
      ),
      DailyScheduleItem(
        day: 'Friday',
        focusSkill: 'Speaking Practice',
        durationMinutes: (dailyMins * 0.5).round(),
        topic: 'Part 2 Cue Card Fluency & Coherence',
        action: 'Record 2-min response & analyze pause frequency.',
      ),
      DailyScheduleItem(
        day: 'Saturday',
        focusSkill: 'Mock Section Test',
        durationMinutes: (dailyMins * 1.2).round(),
        topic: 'Full Mock Exam Section under timed conditions',
        action: 'Complete full Reading + Writing section back-to-back.',
      ),
      DailyScheduleItem(
        day: 'Sunday',
        focusSkill: 'Review & Error Analysis',
        durationMinutes: (dailyMins * 0.5).round(),
        topic: 'Grammar Mistake Log & Vocabulary Consolidation',
        action: 'Review all flagged mistakes from the week.',
      ),
    ];

    return StudyPlanRecommendation(
      currentOverallBand: bandScore.overallBand,
      targetBand: targetBand,
      recommendedDailyMinutes: dailyMins,
      estimatedWeeksToTarget: estimatedWeeks,
      focusAreas: bandScore.weaknesses,
      weeklySchedule: schedule,
      keyMilestones: [
        'Week 2: Master True/False/Not Given elimination technique',
        'Week 4: Raise lexical resource score with 100+ C1 academic words',
        'Week 6: Achieve consistent Band $targetBand in full-length timed tests',
      ],
    );
  }
}
