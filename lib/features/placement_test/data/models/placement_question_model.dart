import '../../domain/entities/diagnostic_skill.dart';
import '../../domain/entities/placement_question.dart';

class PlacementQuestionModel {
  final String id;
  final String section;
  final String questionText;
  final List<String> options;
  final int correctOptionIndex;
  final String? difficultyLevel;
  final String? audioUrl;
  final String? passage;
  final String explanation;

  PlacementQuestionModel({
    required this.id,
    required this.section,
    required this.questionText,
    required this.options,
    required this.correctOptionIndex,
    this.difficultyLevel,
    this.audioUrl,
    this.passage,
    this.explanation = '',
  });

  DiagnosticSkill get skill => DiagnosticSkill.fromString(section);

  factory PlacementQuestionModel.fromJson(Map<String, dynamic> json) {
    return PlacementQuestionModel(
      id: json['id'] as String? ?? '',
      section: json['section'] as String? ?? json['skill']?.toString() ?? 'Grammar',
      questionText: json['question_text'] as String? ?? json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctOptionIndex: (json['correct_option_index'] ?? json['correctOptionIndex'] ?? 0) as int,
      difficultyLevel: json['difficulty_level'] as String? ?? json['cefr_level'] as String?,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      passage: json['passage'] as String?,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'section': section,
      'question_text': questionText,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'difficulty_level': difficultyLevel,
      'audio_url': audioUrl,
      'passage': passage,
      'explanation': explanation,
    };
  }

  PlacementQuestion toEntity() {
    return PlacementQuestion(
      id: id,
      section: section,
      questionText: questionText,
      options: options,
      correctOptionIndex: correctOptionIndex,
      difficultyLevel: difficultyLevel,
      audioUrl: audioUrl,
      passage: passage,
      explanation: explanation,
    );
  }

  factory PlacementQuestionModel.fromEntity(PlacementQuestion entity) {
    return PlacementQuestionModel(
      id: entity.id,
      section: entity.section,
      questionText: entity.questionText,
      options: entity.options,
      correctOptionIndex: entity.correctOptionIndex,
      difficultyLevel: entity.difficultyLevel,
      audioUrl: entity.audioUrl,
      passage: entity.passage,
      explanation: entity.explanation,
    );
  }
}
