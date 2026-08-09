import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_section.dart';
import 'mock_exam_passage_model.dart';
import 'mock_question_model.dart';

class MockExamSectionModel extends MockExamSection {
  const MockExamSectionModel({
    required super.id,
    required super.skill,
    required super.title,
    required super.timeLimitMinutes,
    super.passages = const [],
    super.questions = const [],
    super.audioUrl,
    super.transcript,
  });

  factory MockExamSectionModel.fromJson(Map<String, dynamic> json) {
    return MockExamSectionModel(
      id: json['id'] as String? ?? 'section_1',
      skill: MockSkill.fromString(json['skill'] as String? ?? 'reading'),
      title: json['title'] as String? ?? 'Section Title',
      timeLimitMinutes:
          (json['time_limit_minutes'] ?? json['timeLimitMinutes'] ?? 60) as int,
      passages:
          (json['passages'] as List<dynamic>?)
              ?.map(
                (p) => MockExamPassageModel.fromJson(p as Map<String, dynamic>),
              )
              .toList() ??
          [],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map(
                (q) => MockQuestionModel.fromJson(q as Map<String, dynamic>),
              )
              .toList() ??
          [],
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      transcript: json['transcript'] as String?,
    );
  }

  factory MockExamSectionModel.fromEntity(MockExamSection entity) {
    return MockExamSectionModel(
      id: entity.id,
      skill: entity.skill,
      title: entity.title,
      timeLimitMinutes: entity.timeLimitMinutes,
      passages: entity.passages
          .map((p) => MockExamPassageModel.fromEntity(p))
          .toList(),
      questions: entity.questions
          .map((q) => MockQuestionModel.fromEntity(q))
          .toList(),
      audioUrl: entity.audioUrl,
      transcript: entity.transcript,
    );
  }

  MockExamSection toEntity() => this;
}
