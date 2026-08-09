class GrammarRule {
  final String id;
  final String topicId;
  final String title;
  final String summary;
  final String detailedExplanation;
  final List<String> examples;
  final List<String> commonPitfalls;

  const GrammarRule({
    required this.id,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.detailedExplanation,
    required this.examples,
    required this.commonPitfalls,
  });

  GrammarRule copyWith({
    String? id,
    String? topicId,
    String? title,
    String? summary,
    String? detailedExplanation,
    List<String>? examples,
    List<String>? commonPitfalls,
  }) {
    return GrammarRule(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      detailedExplanation: detailedExplanation ?? this.detailedExplanation,
      examples: examples ?? List.from(this.examples),
      commonPitfalls: commonPitfalls ?? List.from(this.commonPitfalls),
    );
  }
}
