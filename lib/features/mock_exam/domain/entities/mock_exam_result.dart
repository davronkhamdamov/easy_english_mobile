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
  final Map<String, dynamic> detailedFeedback;
  final DateTime createdAt;

  const MockExamResult({
    required this.id,
    required this.userId,
    required this.examPaperId,
    required this.examTitle,
    required this.examType,
    required this.overallBand,
    required this.readingBand,
    required this.listeningBand,
    required this.writingBand,
    required this.speakingBand,
    required this.readingRawScore,
    required this.listeningRawScore,
    required this.totalReadingQuestions,
    required this.totalListeningQuestions,
    required this.timeTakenSeconds,
    required this.userAnswers,
    required this.allQuestions,
    this.detailedFeedback = const {},
    required this.createdAt,
  });

  factory MockExamResult.fromJson(Map<String, dynamic> json) {
    return MockExamResult(
      id:
          json['id'] as String? ??
          'result_${DateTime.now().millisecondsSinceEpoch}',
      userId:
          json['user_id'] as String? ??
          json['userId'] as String? ??
          'user_default',
      examPaperId:
          json['exam_paper_id'] as String? ??
          json['examPaperId'] as String? ??
          'paper_1',
      examTitle:
          json['exam_title'] as String? ??
          json['examTitle'] as String? ??
          'Mock Exam',
      examType: ExamType.fromString(
        json['exam_type'] as String? ??
            json['examType'] as String? ??
            'academic',
      ),
      overallBand:
          (json['overall_band'] ?? json['overallBand'] ?? 6.5) as double,
      readingBand:
          (json['reading_band'] ?? json['readingBand'] ?? 6.5) as double,
      listeningBand:
          (json['listening_band'] ?? json['listeningBand'] ?? 6.5) as double,
      writingBand:
          (json['writing_band'] ?? json['writingBand'] ?? 6.5) as double,
      speakingBand:
          (json['speaking_band'] ?? json['speakingBand'] ?? 6.5) as double,
      readingRawScore:
          (json['reading_raw_score'] ?? json['readingRawScore'] ?? 0) as int,
      listeningRawScore:
          (json['listening_raw_score'] ?? json['listeningRawScore'] ?? 0)
              as int,
      totalReadingQuestions:
          (json['total_reading_questions'] ??
                  json['totalReadingQuestions'] ??
                  40)
              as int,
      totalListeningQuestions:
          (json['total_listening_questions'] ??
                  json['totalListeningQuestions'] ??
                  40)
              as int,
      timeTakenSeconds:
          (json['time_taken_seconds'] ?? json['timeTakenSeconds'] ?? 3600)
              as int,
      userAnswers:
          (json['user_answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      allQuestions:
          (json['all_questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      detailedFeedback:
          (json['detailed_feedback'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exam_paper_id': examPaperId,
      'exam_title': examTitle,
      'exam_type': examType.name,
      'overall_band': overallBand,
      'reading_band': readingBand,
      'listening_band': listeningBand,
      'writing_band': writingBand,
      'speaking_band': speakingBand,
      'reading_raw_score': readingRawScore,
      'listening_raw_score': listeningRawScore,
      'total_reading_questions': totalReadingQuestions,
      'total_listening_questions': totalListeningQuestions,
      'time_taken_seconds': timeTakenSeconds,
      'user_answers': userAnswers,
      'all_questions': allQuestions.map((q) => q.toJson()).toList(),
      'detailed_feedback': detailedFeedback,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
