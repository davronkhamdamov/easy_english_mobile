import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_result.dart';

class MockExamResultModel extends MockExamResult {
  const MockExamResultModel({
    required super.id,
    super.userId = 'user_default',
    required super.examPaperId,
    super.examTitle = 'Mock Exam',
    super.examType = ExamType.academic,
    required super.overallBand,
    super.readingBand = 0.0,
    super.listeningBand = 0.0,
    super.writingBand = 0.0,
    super.speakingBand = 0.0,
    super.readingRawScore = 0,
    super.listeningRawScore = 0,
    super.totalReadingQuestions = 40,
    super.totalListeningQuestions = 40,
    super.timeTakenSeconds = 3600,
    super.userAnswers = const {},
    super.allQuestions = const [],
    super.answerAnalysis = const [],
    super.detailedFeedback = const {},
    required super.createdAt,
  });

  factory MockExamResultModel.fromJson(Map<String, dynamic> json) {
    final parsed = MockExamResult.fromJson(json);
    return MockExamResultModel(
      id: parsed.id,
      userId: parsed.userId,
      examPaperId: parsed.examPaperId,
      examTitle: parsed.examTitle,
      examType: parsed.examType,
      overallBand: parsed.overallBand,
      readingBand: parsed.readingBand,
      listeningBand: parsed.listeningBand,
      writingBand: parsed.writingBand,
      speakingBand: parsed.speakingBand,
      readingRawScore: parsed.readingRawScore,
      listeningRawScore: parsed.listeningRawScore,
      totalReadingQuestions: parsed.totalReadingQuestions,
      totalListeningQuestions: parsed.totalListeningQuestions,
      timeTakenSeconds: parsed.timeTakenSeconds,
      userAnswers: parsed.userAnswers,
      allQuestions: parsed.allQuestions,
      answerAnalysis: parsed.answerAnalysis,
      detailedFeedback: parsed.detailedFeedback,
      createdAt: parsed.createdAt,
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
      allQuestions: entity.allQuestions,
      answerAnalysis: entity.answerAnalysis,
      detailedFeedback: entity.detailedFeedback,
      createdAt: entity.createdAt,
    );
  }

  MockExamResult toEntity() => this;
}
