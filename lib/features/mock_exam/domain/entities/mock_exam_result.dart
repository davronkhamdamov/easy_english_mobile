import 'answer_analysis.dart';
import 'exam_enums.dart';
import 'mock_question.dart';

/// Result domain model for completed section or full mock exam.
class MockExamResult {
  final String id;
  final String userId;
  final String examPaperId;
  final String examTitle;
  final ExamType examType;
  final double overallBand;
  final double readingBand;
  final double listeningBand;
  final double writingBand;
  final double speakingBand;
  final int readingRawScore;
  final int listeningRawScore;
  final int totalReadingQuestions;
  final int totalListeningQuestions;
  final int timeTakenSeconds;
  final Map<String, String> userAnswers;
  final List<MockQuestion> allQuestions;
  final List<AnswerAnalysis> answerAnalysis;
  final Map<String, dynamic> detailedFeedback;
  final DateTime createdAt;

  const MockExamResult({
    required this.id,
    this.userId = 'user_default',
    required this.examPaperId,
    this.examTitle = 'Mock Exam',
    this.examType = ExamType.academic,
    required this.overallBand,
    this.readingBand = 0.0,
    this.listeningBand = 0.0,
    this.writingBand = 0.0,
    this.speakingBand = 0.0,
    this.readingRawScore = 0,
    this.listeningRawScore = 0,
    this.totalReadingQuestions = 40,
    this.totalListeningQuestions = 40,
    this.timeTakenSeconds = 3600,
    this.userAnswers = const {},
    this.allQuestions = const [],
    this.answerAnalysis = const [],
    this.detailedFeedback = const {},
    required this.createdAt,
  });

  String get paperId => examPaperId;
  double get overallBandScore => overallBand;
  double get listeningBandScore => listeningBand;
  double get readingBandScore => readingBand;
  int get correctCount => readingRawScore > 0 ? readingRawScore : listeningRawScore;
  int get totalQuestions => totalReadingQuestions > 0 ? totalReadingQuestions : totalListeningQuestions;
  int get timeSpentSeconds => timeTakenSeconds;

  factory MockExamResult.fromJson(Map<String, dynamic> json) {
    final parsedAnalysis = (json['answer_analysis'] as List<dynamic>?)
            ?.map((a) => AnswerAnalysis.fromJson(a as Map<String, dynamic>))
            .toList() ??
        [];

    final overall = (json['overall_band_score'] ?? json['overall_band'] ?? json['overallBand'] ?? 0.0) as num;
    final listening = (json['listening_band_score'] ?? json['listening_band'] ?? json['listeningBand'] ?? 0.0) as num;
    final reading = (json['reading_band_score'] ?? json['reading_band'] ?? json['readingBand'] ?? 0.0) as num;

    final correct = (json['correct_count'] ?? json['reading_raw_score'] ?? 0) as int;
    final total = (json['total_questions'] ?? json['total_reading_questions'] ?? 40) as int;

    return MockExamResult(
      id: json['id'] as String? ?? 'result_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? 'user_default',
      examPaperId: json['paper_id'] as String? ?? json['exam_paper_id'] as String? ?? json['examPaperId'] as String? ?? 'paper_1',
      examTitle: json['exam_title'] as String? ?? json['examTitle'] as String? ?? 'Mock Exam',
      examType: ExamType.fromString(json['exam_type'] as String? ?? json['examType'] as String? ?? 'academic'),
      overallBand: overall.toDouble(),
      readingBand: reading.toDouble(),
      listeningBand: listening.toDouble(),
      writingBand: (json['writing_band'] ?? json['writingBand'] ?? 0.0 as num).toDouble(),
      speakingBand: (json['speaking_band'] ?? json['speakingBand'] ?? 0.0 as num).toDouble(),
      readingRawScore: correct,
      listeningRawScore: (json['listening_raw_score'] ?? json['listeningRawScore'] ?? correct) as int,
      totalReadingQuestions: total,
      totalListeningQuestions: (json['total_listening_questions'] ?? json['totalListeningQuestions'] ?? total) as int,
      timeTakenSeconds: (json['time_spent_seconds'] ?? json['time_taken_seconds'] ?? json['timeTakenSeconds'] ?? 3600) as int,
      userAnswers: (json['user_answers'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ?? {},
      allQuestions: (json['all_questions'] as List<dynamic>?)?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>)).toList() ?? [],
      answerAnalysis: parsedAnalysis,
      detailedFeedback: (json['detailed_feedback'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'paper_id': examPaperId,
      'exam_paper_id': examPaperId,
      'exam_title': examTitle,
      'exam_type': examType.name,
      'overall_band_score': overallBand,
      'overall_band': overallBand,
      'reading_band_score': readingBand,
      'reading_band': readingBand,
      'listening_band_score': listeningBand,
      'listening_band': listeningBand,
      'writing_band': writingBand,
      'speaking_band': speakingBand,
      'correct_count': correctCount,
      'reading_raw_score': readingRawScore,
      'listening_raw_score': listeningRawScore,
      'total_questions': totalQuestions,
      'total_reading_questions': totalReadingQuestions,
      'total_listening_questions': totalListeningQuestions,
      'time_spent_seconds': timeTakenSeconds,
      'time_taken_seconds': timeTakenSeconds,
      'user_answers': userAnswers,
      'all_questions': allQuestions.map((q) => q.toJson()).toList(),
      'answer_analysis': answerAnalysis.map((a) => a.toJson()).toList(),
      'detailed_feedback': detailedFeedback,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
