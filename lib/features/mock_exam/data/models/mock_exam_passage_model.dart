import '../../domain/entities/mock_exam_passage.dart';
import 'mock_question_model.dart';

class MockExamPassageModel extends MockExamPassage {
  const MockExamPassageModel({
    required super.id,
    required super.title,
    required super.content,
    required super.sectionNumber,
    required super.questions,
  });

  factory MockExamPassageModel.fromJson(Map<String, dynamic> json) {
    return MockExamPassageModel(
      id: json['id'] as String? ?? 'passage_1',
      title: json['title'] as String? ?? 'Passage Title',
      content: json['content'] as String? ?? '',
      sectionNumber:
          (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (q) => MockQuestionModel.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory MockExamPassageModel.fromEntity(MockExamPassage entity) {
    return MockExamPassageModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      sectionNumber: entity.sectionNumber,
      questions: entity.questions
          .map((q) => MockQuestionModel.fromEntity(q))
          .toList(),
    );
  }

  MockExamPassage toEntity() => this;
}
