class GrammarCorrection {
  final String original;
  final String corrected;
  final String explanation;

  const GrammarCorrection({
    required this.original,
    required this.corrected,
    required this.explanation,
  });
}

class VocabularySuggestion {
  final String usedWord;
  final List<String> suggestedAlternatives;

  const VocabularySuggestion({
    required this.usedWord,
    required this.suggestedAlternatives,
  });
}

class WritingCriterionScore {
  final double score;
  final String feedback;

  const WritingCriterionScore({
    required this.score,
    required this.feedback,
  });
}

class WritingEvaluation {
  final String id;
  final double overallBandScore;
  final WritingCriterionScore taskAchievement;
  final WritingCriterionScore coherenceCohesion;
  final WritingCriterionScore lexicalResource;
  final WritingCriterionScore grammaticalRange;
  final int wordCount;
  final List<GrammarCorrection> grammarCorrections;
  final List<VocabularySuggestion> vocabularySuggestions;
  final String sampleAnswer;

  const WritingEvaluation({
    required this.id,
    required this.overallBandScore,
    required this.taskAchievement,
    required this.coherenceCohesion,
    required this.lexicalResource,
    required this.grammaticalRange,
    required this.wordCount,
    required this.grammarCorrections,
    required this.vocabularySuggestions,
    required this.sampleAnswer,
  });

  double get taskAchievementScore => taskAchievement.score;
  double get coherenceCohesionScore => coherenceCohesion.score;
  double get lexicalResourceScore => lexicalResource.score;
  double get grammaticalRangeScore => grammaticalRange.score;
  String get improvedSample => sampleAnswer;
  List<String> get strengths => const [];
  List<String> get weaknesses => const [];

  WritingEvaluation copyWith({
    String? id,
    double? overallBandScore,
    WritingCriterionScore? taskAchievement,
    WritingCriterionScore? coherenceCohesion,
    WritingCriterionScore? lexicalResource,
    WritingCriterionScore? grammaticalRange,
    int? wordCount,
    List<GrammarCorrection>? grammarCorrections,
    List<VocabularySuggestion>? vocabularySuggestions,
    String? sampleAnswer,
  }) {
    return WritingEvaluation(
      id: id ?? this.id,
      overallBandScore: overallBandScore ?? this.overallBandScore,
      taskAchievement: taskAchievement ?? this.taskAchievement,
      coherenceCohesion: coherenceCohesion ?? this.coherenceCohesion,
      lexicalResource: lexicalResource ?? this.lexicalResource,
      grammaticalRange: grammaticalRange ?? this.grammaticalRange,
      wordCount: wordCount ?? this.wordCount,
      grammarCorrections: grammarCorrections ?? this.grammarCorrections,
      vocabularySuggestions: vocabularySuggestions ?? this.vocabularySuggestions,
      sampleAnswer: sampleAnswer ?? this.sampleAnswer,
    );
  }
}
