import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import 'mock_exam_section_model.dart';

class MockExamPaperModel extends MockExamPaper {
  const MockExamPaperModel({
    required super.id,
    required super.title,
    required super.examType,
    required super.description,
    required super.difficulty,
    required super.sections,
  });

  factory MockExamPaperModel.fromJson(Map<String, dynamic> json) {
    return MockExamPaperModel(
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
              ?.map(
                (s) => MockExamSectionModel.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  factory MockExamPaperModel.fromEntity(MockExamPaper entity) {
    return MockExamPaperModel(
      id: entity.id,
      title: entity.title,
      examType: entity.examType,
      description: entity.description,
      difficulty: entity.difficulty,
      sections: entity.sections
          .map((s) => MockExamSectionModel.fromEntity(s))
          .toList(),
    );
  }

  MockExamPaper toEntity() => this;
}
