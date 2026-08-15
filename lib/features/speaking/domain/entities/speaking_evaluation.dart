import 'pronunciation_tip.dart';

/// Represents an AI evaluation for an IELTS Speaking response.
class SpeakingAIEvaluation {
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
  final DateTime evaluatedAt;

  // Compatibility getters
  double get overallBand => overallScore;
  double get fluencyCoherenceBand => fluencyScore;
  double get pronunciationBand => pronunciationScore;
  double get lexicalResourceBand => lexicalScore;
  double get grammarRangeBand => grammarScore;

  const SpeakingAIEvaluation({
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
    required this.evaluatedAt,
  });
}
