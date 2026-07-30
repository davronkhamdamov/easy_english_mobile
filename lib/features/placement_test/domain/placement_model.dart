import 'dart:convert';

/// Enum representing the IELTS skills evaluated in the Placement Test.
enum DiagnosticSkill {
  grammar,
  vocabulary,
  reading,
  listening;

  String get displayName {
    switch (this) {
      case DiagnosticSkill.grammar:
        return 'Grammar';
      case DiagnosticSkill.vocabulary:
        return 'Vocabulary';
      case DiagnosticSkill.reading:
        return 'Reading';
      case DiagnosticSkill.listening:
        return 'Listening';
    }
  }

  static DiagnosticSkill fromString(String val) {
    switch (val.toLowerCase()) {
      case 'grammar':
        return DiagnosticSkill.grammar;
      case 'vocabulary':
        return DiagnosticSkill.vocabulary;
      case 'reading':
        return DiagnosticSkill.reading;
      case 'listening':
        return DiagnosticSkill.listening;
      default:
        return DiagnosticSkill.grammar;
    }
  }
}

/// Domain model representing a single placement test diagnostic question.
class PlacementQuestion {
  final String id;
  final DiagnosticSkill skill;
  final String prompt;
  final String? passage;
  final String? audioUrl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String cefrLevel; // e.g. "A2", "B1", "B2", "C1", "C2"

  PlacementQuestion({
    required this.id,
    required this.skill,
    required this.prompt,
    this.passage,
    this.audioUrl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.cefrLevel,
  });

  factory PlacementQuestion.fromJson(Map<String, dynamic> json) {
    return PlacementQuestion(
      id: json['id'] as String,
      skill: json['skill'] is DiagnosticSkill
          ? json['skill'] as DiagnosticSkill
          : DiagnosticSkill.fromString(json['skill'] as String? ?? 'grammar'),
      prompt: json['prompt'] as String? ?? '',
      passage: json['passage'] as String?,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      options: (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOptionIndex: (json['correct_option_index'] ?? json['correctOptionIndex'] ?? 0) as int,
      explanation: json['explanation'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? json['cefrLevel'] as String? ?? 'B1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill': skill.name,
      'prompt': prompt,
      'passage': passage,
      'audio_url': audioUrl,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'cefr_level': cefrLevel,
    };
  }
}

/// Domain model representing an active or finished Placement Test Diagnostic Session.
class DiagnosticSession {
  final String id;
  final DateTime startTime;
  final int durationSeconds;
  final List<PlacementQuestion> questions;
  final Map<String, int> userAnswers; // questionID -> selectedOptionIndex
  int currentQuestionIndex;
  bool isCompleted;
  int remainingSeconds;

  DiagnosticSession({
    required this.id,
    required this.startTime,
    required this.durationSeconds,
    required this.questions,
    Map<String, int>? userAnswers,
    this.currentQuestionIndex = 0,
    this.isCompleted = false,
    int? remainingSeconds,
  })  : userAnswers = userAnswers ?? {},
        remainingSeconds = remainingSeconds ?? durationSeconds;

  PlacementQuestion get currentQuestion => questions[currentQuestionIndex];

  double get progressPercentage => questions.isEmpty
      ? 0.0
      : (userAnswers.length / questions.length).clamp(0.0, 1.0);

  int get answeredCount => userAnswers.length;
  int get totalQuestions => questions.length;

  factory DiagnosticSession.fromJson(Map<String, dynamic> json) {
    return DiagnosticSession(
      id: json['id'] as String? ?? 'session_${DateTime.now().millisecondsSinceEpoch}',
      startTime: json['start_time'] != null
          ? DateTime.parse(json['start_time'] as String)
          : DateTime.now(),
      durationSeconds: (json['duration_seconds'] ?? 600) as int,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => PlacementQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      userAnswers: (json['user_answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toInt()),
          ) ??
          {},
      currentQuestionIndex: (json['current_question_index'] ?? 0) as int,
      isCompleted: (json['is_completed'] ?? false) as bool,
      remainingSeconds: json['remaining_seconds'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'start_time': startTime.toIso8601String(),
      'duration_seconds': durationSeconds,
      'questions': questions.map((q) => q.toJson()).toList(),
      'user_answers': userAnswers,
      'current_question_index': currentQuestionIndex,
      'is_completed': isCompleted,
      'remaining_seconds': remainingSeconds,
    };
  }
}

/// Domain model representing calculated IELTS Estimated Band Score result.
class EstimatedBandScore {
  final double overallBand;
  final double grammarBand;
  final double vocabularyBand;
  final double readingBand;
  final double listeningBand;
  final String cefrEquivalent;
  final Map<String, double> skillBreakdown;
  final List<String> strengths;
  final List<String> weaknesses;

  EstimatedBandScore({
    required this.overallBand,
    required this.grammarBand,
    required this.vocabularyBand,
    required this.readingBand,
    required this.listeningBand,
    required this.cefrEquivalent,
    required this.skillBreakdown,
    required this.strengths,
    required this.weaknesses,
  });

  /// Calculates band score based on correctness per skill category.
  factory EstimatedBandScore.fromSession(DiagnosticSession session) {
    final Map<DiagnosticSkill, int> correctCounts = {
      DiagnosticSkill.grammar: 0,
      DiagnosticSkill.vocabulary: 0,
      DiagnosticSkill.reading: 0,
      DiagnosticSkill.listening: 0,
    };

    final Map<DiagnosticSkill, int> totalCounts = {
      DiagnosticSkill.grammar: 0,
      DiagnosticSkill.vocabulary: 0,
      DiagnosticSkill.reading: 0,
      DiagnosticSkill.listening: 0,
    };

    for (final q in session.questions) {
      totalCounts[q.skill] = (totalCounts[q.skill] ?? 0) + 1;
      if (session.userAnswers[q.id] == q.correctOptionIndex) {
        correctCounts[q.skill] = (correctCounts[q.skill] ?? 0) + 1;
      }
    }

    double calcBand(DiagnosticSkill skill) {
      final total = totalCounts[skill] ?? 0;
      if (total == 0) return 5.5;
      final ratio = (correctCounts[skill] ?? 0) / total;
      // Convert ratio to IELTS Band (range 4.0 - 9.0)
      final rawBand = 4.0 + (ratio * 5.0);
      // Round to nearest 0.5
      return (rawBand * 2).round() / 2.0;
    }

    final grammarBand = calcBand(DiagnosticSkill.grammar);
    final vocabBand = calcBand(DiagnosticSkill.vocabulary);
    final readingBand = calcBand(DiagnosticSkill.reading);
    final listeningBand = calcBand(DiagnosticSkill.listening);

    final rawOverall = (grammarBand + vocabBand + readingBand + listeningBand) / 4.0;
    final overallBand = (rawOverall * 2).round() / 2.0;

    String cefr;
    if (overallBand >= 8.0) {
      cefr = 'C2 Expert';
    } else if (overallBand >= 7.0) {
      cefr = 'C1 Advanced';
    } else if (overallBand >= 6.0) {
      cefr = 'B2 Upper Intermediate';
    } else if (overallBand >= 5.0) {
      cefr = 'B1 Intermediate';
    } else {
      cefr = 'A2 Elementary';
    }

    final List<String> strengths = [];
    final List<String> weaknesses = [];

    if (grammarBand >= 7.0) {
      strengths.add('Strong grammatical accuracy and sentence structure.');
    } else {
      weaknesses.add('Complex sentence structure and article usage.');
    }

    if (vocabBand >= 7.0) {
      strengths.add('Broad academic vocabulary and precise collocations.');
    } else {
      weaknesses.add('CEFR B2/C1 academic vocabulary range.');
    }

    if (readingBand >= 7.0) {
      strengths.add('Excellent passage scanning and inference speed.');
    } else {
      weaknesses.add('True/False/Not Given statement differentiation.');
    }

    if (listeningBand >= 7.0) {
      strengths.add('High comprehension of connected speech and accents.');
    } else {
      weaknesses.add('Distractor identification in fast-paced dialogues.');
    }

    return EstimatedBandScore(
      overallBand: overallBand,
      grammarBand: grammarBand,
      vocabularyBand: vocabBand,
      readingBand: readingBand,
      listeningBand: listeningBand,
      cefrEquivalent: cefr,
      skillBreakdown: {
        'Grammar': grammarBand,
        'Vocabulary': vocabBand,
        'Reading': readingBand,
        'Listening': listeningBand,
      },
      strengths: strengths.isEmpty ? ['Consistent effort across basic questions.'] : strengths,
      weaknesses: weaknesses.isEmpty ? ['Targeted vocabulary expansion for Band 8+'] : weaknesses,
    );
  }

  factory EstimatedBandScore.fromJson(Map<String, dynamic> json) {
    return EstimatedBandScore(
      overallBand: (json['overall_band'] as num).toDouble(),
      grammarBand: (json['grammar_band'] as num).toDouble(),
      vocabularyBand: (json['vocabulary_band'] as num).toDouble(),
      readingBand: (json['reading_band'] as num).toDouble(),
      listeningBand: (json['listening_band'] as num).toDouble(),
      cefrEquivalent: json['cefr_equivalent'] as String? ?? 'B2 Upper Intermediate',
      skillBreakdown: (json['skill_breakdown'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      strengths: (json['strengths'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      weaknesses: (json['weaknesses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_band': overallBand,
      'grammar_band': grammarBand,
      'vocabulary_band': vocabularyBand,
      'reading_band': readingBand,
      'listening_band': listeningBand,
      'cefr_equivalent': cefrEquivalent,
      'skill_breakdown': skillBreakdown,
      'strengths': strengths,
      'weaknesses': weaknesses,
    };
  }
}

/// Item model for daily study schedule items.
class DailyScheduleItem {
  final String day;
  final String focusSkill;
  final int durationMinutes;
  final String topic;
  final String action;

  DailyScheduleItem({
    required this.day,
    required this.focusSkill,
    required this.durationMinutes,
    required this.topic,
    required this.action,
  });

  factory DailyScheduleItem.fromJson(Map<String, dynamic> json) {
    return DailyScheduleItem(
      day: json['day'] as String? ?? 'Day 1',
      focusSkill: json['focus_skill'] as String? ?? 'Reading',
      durationMinutes: (json['duration_minutes'] ?? 30) as int,
      topic: json['topic'] as String? ?? '',
      action: json['action'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'focus_skill': focusSkill,
      'duration_minutes': durationMinutes,
      'topic': topic,
      'action': action,
    };
  }
}

/// Domain model representing personalized IELTS study plan recommendations.
class StudyPlanRecommendation {
  final double currentOverallBand;
  final double targetBand;
  final int recommendedDailyMinutes;
  final int estimatedWeeksToTarget;
  final List<String> focusAreas;
  final List<DailyScheduleItem> weeklySchedule;
  final List<String> keyMilestones;

  StudyPlanRecommendation({
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

  factory StudyPlanRecommendation.fromJson(Map<String, dynamic> json) {
    return StudyPlanRecommendation(
      currentOverallBand: (json['current_overall_band'] as num).toDouble(),
      targetBand: (json['target_band'] as num).toDouble(),
      recommendedDailyMinutes: (json['recommended_daily_minutes'] as num).toInt(),
      estimatedWeeksToTarget: (json['estimated_weeks_to_target'] as num).toInt(),
      focusAreas: (json['focus_areas'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      weeklySchedule: (json['weekly_schedule'] as List<dynamic>?)
              ?.map((item) => DailyScheduleItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      keyMilestones: (json['key_milestones'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'current_overall_band': currentOverallBand,
      'target_band': targetBand,
      'recommended_daily_minutes': recommendedDailyMinutes,
      'estimated_weeks_to_target': estimatedWeeksToTarget,
      'focus_areas': focusAreas,
      'weekly_schedule': weeklySchedule.map((s) => s.toJson()).toList(),
      'key_milestones': keyMilestones,
    };
  }
}
