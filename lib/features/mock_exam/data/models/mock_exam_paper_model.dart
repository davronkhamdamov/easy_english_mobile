import '../../domain/entities/mock_exam_paper.dart';

class MockExamPaperModel extends MockExamPaper {
  const MockExamPaperModel({
    required super.id,
    required super.title,
    required super.examType,
    required super.description,
    required super.difficulty,
    super.durationMinutes = 60,
    super.totalQuestions = 40,
    super.audioUrl,
    super.passageText,
    super.questions = const [],
    super.sections = const [],
  });

  factory MockExamPaperModel.fromJson(Map<String, dynamic> json) {
    final parsedPaper = MockExamPaper.fromJson(json);
    return MockExamPaperModel(
      id: parsedPaper.id,
      title: parsedPaper.title,
      examType: parsedPaper.examType,
      description: parsedPaper.description,
      difficulty: parsedPaper.difficulty,
      durationMinutes: parsedPaper.durationMinutes,
      totalQuestions: parsedPaper.totalQuestions,
      audioUrl: parsedPaper.audioUrl,
      passageText: parsedPaper.passageText,
      questions: parsedPaper.questions,
      sections: parsedPaper.sections,
    );
  }

  factory MockExamPaperModel.fromEntity(MockExamPaper entity) {
    return MockExamPaperModel(
      id: entity.id,
      title: entity.title,
      examType: entity.examType,
      description: entity.description,
      difficulty: entity.difficulty,
      durationMinutes: entity.durationMinutes,
      totalQuestions: entity.totalQuestions,
      audioUrl: entity.audioUrl,
      passageText: entity.passageText,
      questions: entity.questions,
      sections: entity.sections,
    );
  }

  MockExamPaper toEntity() => this;
}
