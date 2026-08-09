import '../../domain/entities/diagnostic_skill.dart';
import '../../domain/entities/placement_question.dart';

class PlacementQuestionModel {
  final String id;
  final DiagnosticSkill skill;
  final String prompt;
  final String? passage;
  final String? audioUrl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String cefrLevel;

  PlacementQuestionModel({
    required this.id,
    required this.skill,
    required this.prompt,
    this.passage,
    this.audioUrl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.cefrLevel,
  });

  factory PlacementQuestionModel.fromJson(Map<String, dynamic> json) {
    return PlacementQuestionModel(
      id: json['id'] as String? ?? '',
      skill: json['skill'] is DiagnosticSkill
          ? json['skill'] as DiagnosticSkill
          : DiagnosticSkill.fromString(json['skill'] as String? ?? 'grammar'),
      prompt: json['prompt'] as String? ?? '',
      passage: json['passage'] as String?,
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      options:
          (json['options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      correctOptionIndex:
          (json['correct_option_index'] ?? json['correctOptionIndex'] ?? 0)
              as int,
      explanation: json['explanation'] as String? ?? '',
      cefrLevel:
          json['cefr_level'] as String? ?? json['cefrLevel'] as String? ?? 'B1',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill': skill.name,
      'prompt': prompt,
      'passage': passage,
      'audio_url': audioUrl,
      'options': options,
      'correct_option_index': correctOptionIndex,
      'explanation': explanation,
      'cefr_level': cefrLevel,
    };
  }

  PlacementQuestion toEntity() {
    return PlacementQuestion(
      id: id,
      skill: skill,
      prompt: prompt,
      passage: passage,
      audioUrl: audioUrl,
      options: options,
      correctOptionIndex: correctOptionIndex,
      explanation: explanation,
      cefrLevel: cefrLevel,
    );
  }

  factory PlacementQuestionModel.fromEntity(PlacementQuestion entity) {
    return PlacementQuestionModel(
      id: entity.id,
      skill: entity.skill,
      prompt: entity.prompt,
      passage: entity.passage,
      audioUrl: entity.audioUrl,
      options: entity.options,
      correctOptionIndex: entity.correctOptionIndex,
      explanation: entity.explanation,
      cefrLevel: entity.cefrLevel,
    );
  }
}
