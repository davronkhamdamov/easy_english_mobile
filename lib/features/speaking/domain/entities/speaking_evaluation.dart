/// Represents an AI evaluation for an IELTS Speaking response.
class SpeakingAIEvaluation {
  final String id;
  final String submissionId;
  final double overallBand;
  final double fluencyCoherenceBand;
  final double lexicalResourceBand;
  final double grammarRangeBand;
  final double pronunciationBand;
  final String transcript;
  final List<String> grammarErrors;
  final List<String> vocabularyTips;
  final List<String> strengths;
  final List<String> areasForImprovement;
  final DateTime evaluatedAt;

  const SpeakingAIEvaluation({
    required this.id,
    required this.submissionId,
    required this.overallBand,
    required this.fluencyCoherenceBand,
    required this.lexicalResourceBand,
    required this.grammarRangeBand,
    required this.pronunciationBand,
    required this.transcript,
    this.grammarErrors = const [],
    this.vocabularyTips = const [],
    this.strengths = const [],
    this.areasForImprovement = const [],
    required this.evaluatedAt,
  });

  SpeakingAIEvaluation copyWith({
    String? id,
    String? submissionId,
    double? overallBand,
    double? fluencyCoherenceBand,
    double? lexicalResourceBand,
    double? grammarRangeBand,
    double? pronunciationBand,
    String? transcript,
    List<String>? grammarErrors,
    List<String>? vocabularyTips,
    List<String>? strengths,
    List<String>? areasForImprovement,
    DateTime? evaluatedAt,
  }) {
    return SpeakingAIEvaluation(
      id: id ?? this.id,
      submissionId: submissionId ?? this.submissionId,
      overallBand: overallBand ?? this.overallBand,
      fluencyCoherenceBand: fluencyCoherenceBand ?? this.fluencyCoherenceBand,
      lexicalResourceBand: lexicalResourceBand ?? this.lexicalResourceBand,
      grammarRangeBand: grammarRangeBand ?? this.grammarRangeBand,
      pronunciationBand: pronunciationBand ?? this.pronunciationBand,
      transcript: transcript ?? this.transcript,
      grammarErrors: grammarErrors ?? this.grammarErrors,
      vocabularyTips: vocabularyTips ?? this.vocabularyTips,
      strengths: strengths ?? this.strengths,
      areasForImprovement: areasForImprovement ?? this.areasForImprovement,
      evaluatedAt: evaluatedAt ?? this.evaluatedAt,
    );
  }
}
