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

  int get questionNumber => orderIndex;
  String get questionText => prompt;
  String get type => questionType.name;

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    return MockQuestion(
      id: json['id'] as String? ?? 'q_${json['question_number'] ?? json['order_index'] ?? 1}',
      orderIndex: (json['question_number'] ?? json['order_index'] ?? json['orderIndex'] ?? 1) as int,
      questionType: QuestionType.fromString(
        json['type'] as String? ??
            json['question_type'] as String? ??
            json['questionType'] as String? ??
            'multipleChoice',
      ),
      prompt: json['question_text'] as String? ?? json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correct_answer'] as String? ?? json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      passageId: json['passage_id'] as String? ?? json['passageId'] as String?,
      sectionNumber: (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'question_number': orderIndex,
      'order_index': orderIndex,
      'type': type,
      'question_type': questionType.name,
      'question_text': prompt,
      'prompt': prompt,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'passage_id': passageId,
      'section_number': sectionNumber,
    };
  }
}
