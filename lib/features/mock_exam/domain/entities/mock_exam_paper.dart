import 'exam_enums.dart';
import 'mock_exam_section.dart';

/// Complete Full IELTS Mock Exam Paper entity.
class MockExamPaper {
  final String id;
  final String title;
  final ExamType examType;
  final String description;
  final String difficulty;
  final List<MockExamSection> sections;

  const MockExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.description,
    required this.difficulty,
    required this.sections,
  });

  factory MockExamPaper.fromJson(Map<String, dynamic> json) {
    return MockExamPaper(
      id: json['id'] as String? ?? 'paper_1',
      title: json['title'] as String? ?? 'Mock Exam Paper',
      examType: ExamType.fromString(
        json['exam_type'] as String? ??
            json['examType'] as String? ??
            'academic',
      ),
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      sections:
          (json['sections'] as List<dynamic>?)
              ?.map((s) => MockExamSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'exam_type': examType.name,
      'description': description,
      'difficulty': difficulty,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}
