import 'mock_question.dart';

/// Reading passage entity containing text and associated questions.
class MockExamPassage {
  final String id;
  final String title;
  final String content;
  final int sectionNumber;
  final List<MockQuestion> questions;

  const MockExamPassage({
    required this.id,
    required this.title,
    required this.content,
    required this.sectionNumber,
    required this.questions,
  });

  factory MockExamPassage.fromJson(Map<String, dynamic> json) {
    return MockExamPassage(
      id: json['id'] as String? ?? 'passage_1',
      title: json['title'] as String? ?? 'Passage Title',
      content: json['content'] as String? ?? '',
      sectionNumber:
          (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'section_number': sectionNumber,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}
