class WritingEvaluation {
  final double overallBandScore;
  final double taskAchievementScore;
  final double coherenceCohesionScore;
  final double lexicalResourceScore;
  final double grammaticalRangeScore;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> grammarCorrections;
  final String improvedSample;

  const WritingEvaluation({
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

  WritingEvaluation copyWith({
    double? overallBandScore,
    double? taskAchievementScore,
    double? coherenceCohesionScore,
    double? lexicalResourceScore,
    double? grammaticalRangeScore,
    List<String>? strengths,
    List<String>? weaknesses,
    List<String>? grammarCorrections,
    String? improvedSample,
  }) {
    return WritingEvaluation(
      overallBandScore: overallBandScore ?? this.overallBandScore,
      taskAchievementScore: taskAchievementScore ?? this.taskAchievementScore,
      coherenceCohesionScore:
          coherenceCohesionScore ?? this.coherenceCohesionScore,
      lexicalResourceScore: lexicalResourceScore ?? this.lexicalResourceScore,
      grammaticalRangeScore:
          grammaticalRangeScore ?? this.grammaticalRangeScore,
      strengths: strengths ?? this.strengths,
      weaknesses: weaknesses ?? this.weaknesses,
      grammarCorrections: grammarCorrections ?? this.grammarCorrections,
      improvedSample: improvedSample ?? this.improvedSample,
    );
  }
}
