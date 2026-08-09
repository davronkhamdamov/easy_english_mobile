class GrammarEvaluation {
  final bool isCorrect;
  final String feedback;
  final List<String> corrections;
  final List<String> modelExpressions;

  const GrammarEvaluation({
    required this.isCorrect,
    required this.feedback,
    required this.corrections,
    required this.modelExpressions,
  });
}
