import '../../domain/entities/estimated_band_score.dart';

class EstimatedBandScoreModel {
  final double overallBand;
  final double grammarBand;
  final double vocabularyBand;
  final double readingBand;
  final double listeningBand;
  final String cefrEquivalent;
  final Map<String, double> skillBreakdown;
  final List<String> strengths;
  final List<String> weaknesses;

  EstimatedBandScoreModel({
    required this.overallBand,
    required this.grammarBand,
    required this.vocabularyBand,
    required this.readingBand,
    required this.listeningBand,
    required this.cefrEquivalent,
    required this.skillBreakdown,
    required this.strengths,
    required this.weaknesses,
  });

  factory EstimatedBandScoreModel.fromJson(Map<String, dynamic> json) {
    return EstimatedBandScoreModel(
      overallBand: (json['overall_band'] as num?)?.toDouble() ?? 6.0,
      grammarBand: (json['grammar_band'] as num?)?.toDouble() ?? 6.0,
      vocabularyBand: (json['vocabulary_band'] as num?)?.toDouble() ?? 6.0,
      readingBand: (json['reading_band'] as num?)?.toDouble() ?? 6.0,
      listeningBand: (json['listening_band'] as num?)?.toDouble() ?? 6.0,
      cefrEquivalent:
          json['cefr_equivalent'] as String? ?? 'B2 Upper Intermediate',
      skillBreakdown:
          (json['skill_breakdown'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, (v as num).toDouble()),
          ) ??
          {},
      strengths:
          (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      weaknesses:
          (json['weaknesses'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall_band': overallBand,
      'grammar_band': grammarBand,
      'vocabulary_band': vocabularyBand,
      'reading_band': readingBand,
      'listening_band': listeningBand,
      'cefr_equivalent': cefrEquivalent,
      'skill_breakdown': skillBreakdown,
      'strengths': strengths,
      'weaknesses': weaknesses,
    };
  }

  EstimatedBandScore toEntity() {
    return EstimatedBandScore(
      overallBand: overallBand,
      grammarBand: grammarBand,
      vocabularyBand: vocabularyBand,
      readingBand: readingBand,
      listeningBand: listeningBand,
      cefrEquivalent: cefrEquivalent,
      skillBreakdown: skillBreakdown,
      strengths: strengths,
      weaknesses: weaknesses,
    );
  }

  factory EstimatedBandScoreModel.fromEntity(EstimatedBandScore entity) {
    return EstimatedBandScoreModel(
      overallBand: entity.overallBand,
      grammarBand: entity.grammarBand,
      vocabularyBand: entity.vocabularyBand,
      readingBand: entity.readingBand,
      listeningBand: entity.listeningBand,
      cefrEquivalent: entity.cefrEquivalent,
      skillBreakdown: entity.skillBreakdown,
      strengths: entity.strengths,
      weaknesses: entity.weaknesses,
    );
  }
}
