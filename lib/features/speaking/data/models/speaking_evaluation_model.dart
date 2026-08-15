import '../../domain/entities/pronunciation_tip.dart';
import '../../domain/entities/speaking_evaluation.dart';

class SpeakingEvaluationModel {
  final String id;
  final double overallScore;
  final double fluencyScore;
  final double pronunciationScore;
  final double lexicalScore;
  final double grammarScore;
  final String fluencyFeedback;
  final String pronunciationFeedback;
  final String lexicalFeedback;
  final String grammarFeedback;
  final String transcript;
  final List<PronunciationTip> pronunciationTips;
  final int pauseCount;
  final String sampleAnswer;
  final List<String> grammarErrors;
  final List<String> vocabularyTips;
  final List<String> strengths;
  final List<String> areasForImprovement;

  SpeakingEvaluationModel({
    required this.id,
    required this.overallScore,
    required this.fluencyScore,
    required this.pronunciationScore,
    required this.lexicalScore,
    required this.grammarScore,
    this.fluencyFeedback = '',
    this.pronunciationFeedback = '',
    this.lexicalFeedback = '',
    this.grammarFeedback = '',
    required this.transcript,
    this.pronunciationTips = const [],
    this.pauseCount = 0,
    this.sampleAnswer = '',
    this.grammarErrors = const [],
    this.vocabularyTips = const [],
    this.strengths = const [],
    this.areasForImprovement = const [],
  });

  static List<String> _parseStringList(dynamic raw) {
    if (raw is List) {
      return raw.map((e) => e.toString()).toList();
    }
    return <String>[];
  }

  factory SpeakingEvaluationModel.fromJson(Map<String, dynamic> json) {
    final criteria = json['criteria'] as Map<String, dynamic>? ?? {};
    final fc = criteria['fluency_coherence'] as Map<String, dynamic>? ?? {};
    final pr = criteria['pronunciation'] as Map<String, dynamic>? ?? {};
    final lr = criteria['lexical_resource'] as Map<String, dynamic>? ?? {};
    final gr = criteria['grammatical_range'] as Map<String, dynamic>? ?? {};

    final fcScore = (fc['score'] as num?)?.toDouble() ??
        (json['fluency_coherence_band'] as num?)?.toDouble() ??
        (json['fluency_score'] as num?)?.toDouble() ??
        7.0;

    final prScore = (pr['score'] as num?)?.toDouble() ??
        (json['pronunciation_band'] as num?)?.toDouble() ??
        (json['pronunciation_score'] as num?)?.toDouble() ??
        7.0;

    final lrScore = (lr['score'] as num?)?.toDouble() ??
        (json['lexical_resource_band'] as num?)?.toDouble() ??
        (json['lexical_resource_score'] as num?)?.toDouble() ??
        7.0;

    final grScore = (gr['score'] as num?)?.toDouble() ??
        (json['grammar_range_band'] as num?)?.toDouble() ??
        (json['grammar_score'] as num?)?.toDouble() ??
        7.0;

    final overall = (json['overall_band_score'] as num?)?.toDouble() ??
        (json['overall_band'] as num?)?.toDouble() ??
        (json['overallScore'] as num?)?.toDouble() ??
        7.0;

    final rawTips = json['pronunciation_tips'] as List<dynamic>? ?? [];
    final tips = rawTips
        .whereType<Map<String, dynamic>>()
        .map((e) => PronunciationTip.fromJson(e))
        .toList();

    return SpeakingEvaluationModel(
      id: json['id'] as String? ?? 'eval_${DateTime.now().millisecondsSinceEpoch}',
      overallScore: overall,
      fluencyScore: fcScore,
      pronunciationScore: prScore,
      lexicalScore: lrScore,
      grammarScore: grScore,
      fluencyFeedback: fc['feedback'] as String? ?? '',
      pronunciationFeedback: pr['feedback'] as String? ?? '',
      lexicalFeedback: lr['feedback'] as String? ?? '',
      grammarFeedback: gr['feedback'] as String? ?? '',
      transcript: (json['transcription'] ?? json['transcript'] ?? '').toString(),
      pronunciationTips: tips,
      pauseCount: (json['fluency_pauses_count'] as num?)?.toInt() ??
          (json['pauseCount'] as num?)?.toInt() ??
          0,
      sampleAnswer: (json['band_9_sample_answer'] ??
              json['sampleAnswer'] ??
              json['sample_answer'] ??
              '')
          .toString(),
      grammarErrors: _parseStringList(json['grammar_errors'] ?? json['grammar_corrections']),
      vocabularyTips: _parseStringList(json['vocabulary_tips']),
      strengths: _parseStringList(json['strengths']),
      areasForImprovement: _parseStringList(json['areas_for_improvement'] ?? json['weaknesses']),
    );
  }

  SpeakingAIEvaluation toEntity() {
    return SpeakingAIEvaluation(
      id: id,
      overallScore: overallScore,
      fluencyScore: fluencyScore,
      pronunciationScore: pronunciationScore,
      lexicalScore: lexicalScore,
      grammarScore: grammarScore,
      fluencyFeedback: fluencyFeedback,
      pronunciationFeedback: pronunciationFeedback,
      lexicalFeedback: lexicalFeedback,
      grammarFeedback: grammarFeedback,
      transcript: transcript,
      pronunciationTips: pronunciationTips,
      pauseCount: pauseCount,
      sampleAnswer: sampleAnswer,
      grammarErrors: grammarErrors,
      vocabularyTips: vocabularyTips,
      strengths: strengths,
      areasForImprovement: areasForImprovement,
      evaluatedAt: DateTime.now(),
    );
  }
}
