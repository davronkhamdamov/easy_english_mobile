import '../../domain/entities/speaking_evaluation.dart';

class SpeakingEvaluationModel {
  final String transcription;
  final double overallBandScore;
  final double fluencyScore;
  final double pronunciationScore;
  final double lexicalResourceScore;
  final double grammarScore;
  final List<String> grammarErrors;
  final List<String> vocabularyTips;
  final List<String> strengths;
  final List<String> areasForImprovement;

  SpeakingEvaluationModel({
    required this.transcription,
    required this.overallBandScore,
    required this.fluencyScore,
    required this.pronunciationScore,
    required this.lexicalResourceScore,
    required this.grammarScore,
    required this.grammarErrors,
    required this.vocabularyTips,
    required this.strengths,
    required this.areasForImprovement,
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory SpeakingEvaluationModel.fromJson(Map<String, dynamic> json) {
    return SpeakingEvaluationModel(
      transcription: (json['transcript'] ?? json['transcription'] ?? '')
          .toString(),
      overallBandScore:
          (json['overall_band'] ?? json['overall_band_score'] as num?)
              ?.toDouble() ??
          7.0,
      fluencyScore:
          (json['fluency_coherence_band'] ?? json['fluency_score'] as num?)
              ?.toDouble() ??
          7.0,
      pronunciationScore:
          (json['pronunciation_band'] ?? json['pronunciation_score'] as num?)
              ?.toDouble() ??
          7.5,
      lexicalResourceScore:
          (json['lexical_resource_band'] ??
                  json['lexical_resource_score'] as num?)
              ?.toDouble() ??
          7.0,
      grammarScore:
          (json['grammar_range_band'] ?? json['grammar_score'] as num?)
              ?.toDouble() ??
          7.0,
      grammarErrors: _parseStringList(
        json['grammar_errors'] ?? json['grammar_corrections'],
      ),
      vocabularyTips: _parseStringList(json['vocabulary_tips']),
      strengths: _parseStringList(json['strengths']),
      areasForImprovement: _parseStringList(
        json['areas_for_improvement'] ?? json['weaknesses'],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transcript': transcription,
      'overall_band': overallBandScore,
      'fluency_coherence_band': fluencyScore,
      'pronunciation_band': pronunciationScore,
      'lexical_resource_band': lexicalResourceScore,
      'grammar_range_band': grammarScore,
      'grammar_errors': grammarErrors,
      'vocabulary_tips': vocabularyTips,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
    };
  }

  SpeakingAIEvaluation toEntity({
    String? id,
    String? submissionId,
    DateTime? evaluatedAt,
  }) {
    final now = DateTime.now();
    return SpeakingAIEvaluation(
      id: id ?? 'eval_${now.millisecondsSinceEpoch}',
      submissionId: submissionId ?? 'sub_${now.millisecondsSinceEpoch}',
      overallBand: overallBandScore,
      fluencyCoherenceBand: fluencyScore,
      lexicalResourceBand: lexicalResourceScore,
      grammarRangeBand: grammarScore,
      pronunciationBand: pronunciationScore,
      transcript: transcription,
      grammarErrors: grammarErrors,
      vocabularyTips: vocabularyTips,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      evaluatedAt: evaluatedAt ?? now,
    );
  }
}
