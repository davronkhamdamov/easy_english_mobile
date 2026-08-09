import 'exam_enums.dart';

/// Single Question entity in a Mock Exam section or passage.
class MockQuestion {
  final String id;
  final int orderIndex;
  final QuestionType questionType;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? passageId;
  final int sectionNumber;

  const MockQuestion({
    required this.id,
    required this.orderIndex,
    required this.questionType,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.passageId,
    this.sectionNumber = 1,
  });

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    return MockQuestion(
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_index': orderIndex,
      'question_type': questionType.name,
      'prompt': prompt,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'passage_id': passageId,
      'section_number': sectionNumber,
    };
  }
}
