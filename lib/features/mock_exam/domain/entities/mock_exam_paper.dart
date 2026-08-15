import 'exam_enums.dart';
import 'mock_exam_section.dart';
import 'mock_question.dart';

/// IELTS Mock Exam Paper domain entity.
class MockExamPaper {
  final String id;
  final String title;
  final ExamType examType;
  final String description;
  final String difficulty;
  final int durationMinutes;
  final int totalQuestions;
  final String? audioUrl;
  final String? passageText;
  final List<MockQuestion> questions;
  final List<MockExamSection> sections;

  const MockExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.description,
    required this.difficulty,
    this.durationMinutes = 60,
    this.totalQuestions = 40,
    this.audioUrl,
    this.passageText,
    this.questions = const [],
    this.sections = const [],
  });

  String get type => examType.name;

  factory MockExamPaper.fromJson(Map<String, dynamic> json) {
    final parsedQuestions = (json['questions'] as List<dynamic>?)
            ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
            .toList() ??
        [];
    final parsedSections = (json['sections'] as List<dynamic>?)
            ?.map((s) => MockExamSection.fromJson(s as Map<String, dynamic>))
            .toList() ??
        [];

    return MockExamPaper(
      id: json['id'] as String? ?? 'paper_1',
      title: json['title'] as String? ?? 'Mock Exam Paper',
      examType: ExamType.fromString(
        json['type'] as String? ??
            json['exam_type'] as String? ??
            json['examType'] as String? ??
            'academic',
      ),
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      durationMinutes: (json['duration_minutes'] ?? json['durationMinutes'] ?? 60) as int,
      totalQuestions: (json['total_questions'] ?? json['totalQuestions'] ?? parsedQuestions.length) as int,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      passageText: json['passage_text'] as String? ?? json['passageText'] as String?,
      questions: parsedQuestions,
      sections: parsedSections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'type': type,
      'exam_type': examType.name,
      'description': description,
      'difficulty': difficulty,
      'duration_minutes': durationMinutes,
      'total_questions': totalQuestions,
      'audio_url': audioUrl,
      'passage_text': passageText,
      'questions': questions.map((q) => q.toJson()).toList(),
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}
