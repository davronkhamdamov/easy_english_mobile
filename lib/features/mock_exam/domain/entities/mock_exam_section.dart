import 'exam_enums.dart';
import 'mock_exam_passage.dart';
import 'mock_question.dart';

/// Individual section entity inside a Mock Exam Paper.
class MockExamSection {
  final String id;
  final MockSkill skill;
  final String title;
  final int timeLimitMinutes;
  final List<MockExamPassage> passages;
  final List<MockQuestion> questions;
  final String? audioUrl;
  final String? transcript;

  const MockExamSection({
    required this.id,
    required this.skill,
    required this.title,
    required this.timeLimitMinutes,
    this.passages = const [],
    this.questions = const [],
    this.audioUrl,
    this.transcript,
  });

  factory MockExamSection.fromJson(Map<String, dynamic> json) {
    return MockExamSection(
      id: json['id'] as String? ?? 'section_1',
      skill: MockSkill.fromString(json['skill'] as String? ?? 'reading'),
      title: json['title'] as String? ?? 'Section Title',
      timeLimitMinutes:
          (json['time_limit_minutes'] ?? json['timeLimitMinutes'] ?? 60) as int,
      passages:
          (json['passages'] as List<dynamic>?)
              ?.map((p) => MockExamPassage.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      questions:
          (json['questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      transcript: json['transcript'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill': skill.name,
      'title': title,
      'time_limit_minutes': timeLimitMinutes,
      'passages': passages.map((p) => p.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'audio_url': audioUrl,
      'transcript': transcript,
    };
  }

  /// Helper getter to aggregate all questions across passages or direct list.
  List<MockQuestion> get allQuestions {
    if (questions.isNotEmpty) return questions;
    final list = <MockQuestion>[];
    for (final p in passages) {
      list.addAll(p.questions);
    }
    return list;
  }
}
