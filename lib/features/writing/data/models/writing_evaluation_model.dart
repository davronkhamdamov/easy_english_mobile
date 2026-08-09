import '../../domain/entities/writing_evaluation.dart';

class WritingEvaluationModel {
  final double overallBandScore;
  final double taskAchievementScore;
  final double coherenceCohesionScore;
  final double lexicalResourceScore;
  final double grammaticalRangeScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> grammarCorrections;
  final String improvedSample;

  WritingEvaluationModel({
    required this.overallBandScore,
    required this.taskAchievementScore,
    required this.coherenceCohesionScore,
    required this.lexicalResourceScore,
    required this.grammaticalRangeScore,
    required this.strengths,
    required this.weaknesses,
    required this.grammarCorrections,
    required this.improvedSample,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory WritingEvaluationModel.fromJson(Map<String, dynamic> json) {
    return WritingEvaluationModel(
      overallBandScore:
          (json['overall_band'] ?? json['overall_band_score'] as num?)
              ?.toDouble() ??
          7.0,
      taskAchievementScore:
          (json['task_achievement_band'] ??
                  json['task_achievement_score'] ??
                  json['task_achievement'] as num?)
              ?.toDouble() ??
          7.0,
      coherenceCohesionScore:
          (json['coherence_cohesion_band'] ??
                  json['coherence_cohesion_score'] ??
                  json['coherence_cohesion'] as num?)
              ?.toDouble() ??
          7.0,
      lexicalResourceScore:
          (json['lexical_resource_band'] ??
                  json['lexical_resource_score'] ??
                  json['lexical_resource'] as num?)
              ?.toDouble() ??
          7.0,
      grammaticalRangeScore:
          (json['grammar_accuracy_band'] ??
                  json['grammatical_range_score'] ??
                  json['grammar_accuracy'] as num?)
              ?.toDouble() ??
          7.0,
      strengths: _parseStringList(json['strengths']),
      weaknesses: _parseStringList(json['weaknesses']),
      grammarCorrections: _parseStringList(
        json['grammar_corrections'] ?? json['grammar_errors'],
      ),
      improvedSample: (json['improved_sample'] ?? json['model_answer'] ?? '')
          .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_band': overallBandScore,
      'task_achievement_band': taskAchievementScore,
      'coherence_cohesion_band': coherenceCohesionScore,
      'lexical_resource_band': lexicalResourceScore,
      'grammar_accuracy_band': grammaticalRangeScore,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'grammar_corrections': grammarCorrections,
      'improved_sample': improvedSample,
    };
  }

  WritingEvaluation toEntity() {
    return WritingEvaluation(
      overallBandScore: overallBandScore,
      taskAchievementScore: taskAchievementScore,
      coherenceCohesionScore: coherenceCohesionScore,
      lexicalResourceScore: lexicalResourceScore,
      grammaticalRangeScore: grammaticalRangeScore,
      strengths: strengths,
      weaknesses: weaknesses,
      grammarCorrections: grammarCorrections,
      improvedSample: improvedSample,
    );
  }

  factory WritingEvaluationModel.fromEntity(WritingEvaluation entity) {
    return WritingEvaluationModel(
      overallBandScore: entity.overallBandScore,
      taskAchievementScore: entity.taskAchievementScore,
      coherenceCohesionScore: entity.coherenceCohesionScore,
      lexicalResourceScore: entity.lexicalResourceScore,
      grammaticalRangeScore: entity.grammaticalRangeScore,
      strengths: entity.strengths,
      weaknesses: entity.weaknesses,
      grammarCorrections: entity.grammarCorrections,
      improvedSample: entity.improvedSample,
    );
  }
}
