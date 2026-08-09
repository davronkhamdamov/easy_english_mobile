import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_question.dart';

class MockQuestionModel extends MockQuestion {
  const MockQuestionModel({
    required super.id,
    required super.orderIndex,
    required super.questionType,
    required super.prompt,
    required super.options,
    required super.correctAnswer,
    required super.explanation,
    super.passageId,
    super.sectionNumber = 1,
  });

  factory MockQuestionModel.fromJson(Map<String, dynamic> json) {
    return MockQuestionModel(
      id: json['id'] as String? ?? 'q_${json['order_index'] ?? 1}',
      orderIndex: (json['order_index'] ?? json['orderIndex'] ?? 1) as int,
      questionType: QuestionType.fromString(
        json['question_type'] as String? ??
            json['questionType'] as String? ??
            'multipleChoice',
      ),
      prompt: json['prompt'] as String? ?? '',
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctAnswer:
          json['correct_answer'] as String? ??
          json['correctAnswer'] as String? ??
          '',
      explanation: json['explanation'] as String? ?? '',
      passageId: json['passage_id'] as String? ?? json['passageId'] as String?,
      sectionNumber:
          (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
    );
  }

  factory MockQuestionModel.fromEntity(MockQuestion entity) {
    return MockQuestionModel(
      id: entity.id,
      orderIndex: entity.orderIndex,
      questionType: entity.questionType,
      prompt: entity.prompt,
      options: entity.options,
      correctAnswer: entity.correctAnswer,
      explanation: entity.explanation,
      passageId: entity.passageId,
      sectionNumber: entity.sectionNumber,
    );
  }

  MockQuestion toEntity() => this;
}
