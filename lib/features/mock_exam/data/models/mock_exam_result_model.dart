import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_result.dart';
import 'mock_question_model.dart';

class MockExamResultModel extends MockExamResult {
  const MockExamResultModel({
    required super.id,
    required super.userId,
    required super.examPaperId,
    required super.examTitle,
    required super.examType,
    required super.overallBand,
    required super.readingBand,
    required super.listeningBand,
    required super.writingBand,
    required super.speakingBand,
    required super.readingRawScore,
    required super.listeningRawScore,
    required super.totalReadingQuestions,
    required super.totalListeningQuestions,
    required super.timeTakenSeconds,
    required super.userAnswers,
    required super.allQuestions,
    super.detailedFeedback = const {},
    required super.createdAt,
  });

  factory MockExamResultModel.fromJson(Map<String, dynamic> json) {
    return MockExamResultModel(
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
              ?.map(
                (q) => MockQuestionModel.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      detailedFeedback:
          (json['detailed_feedback'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  factory MockExamResultModel.fromEntity(MockExamResult entity) {
    return MockExamResultModel(
      id: entity.id,
      userId: entity.userId,
      examPaperId: entity.examPaperId,
      examTitle: entity.examTitle,
      examType: entity.examType,
      overallBand: entity.overallBand,
      readingBand: entity.readingBand,
      listeningBand: entity.listeningBand,
      writingBand: entity.writingBand,
      speakingBand: entity.speakingBand,
      readingRawScore: entity.readingRawScore,
      listeningRawScore: entity.listeningRawScore,
      totalReadingQuestions: entity.totalReadingQuestions,
      totalListeningQuestions: entity.totalListeningQuestions,
      timeTakenSeconds: entity.timeTakenSeconds,
      userAnswers: entity.userAnswers,
      allQuestions: entity.allQuestions
          .map((q) => MockQuestionModel.fromEntity(q))
          .toList(),
      detailedFeedback: entity.detailedFeedback,
      createdAt: entity.createdAt,
    );
  }

  MockExamResult toEntity() => this;
}
