class GrammarRule {
  final String id;
  final String topicId;
  final String title;
  final String summary;
  final String detailedExplanation;
  final List<String> examples;
  final List<String> commonPitfalls;
  final String? explanation;
  final String? tip;

  const GrammarRule({
    required this.id,
    this.topicId = '',
    required this.title,
    this.summary = '',
    this.detailedExplanation = '',
    this.examples = const [],
    this.commonPitfalls = const [],
    this.explanation,
    this.tip,
  });

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String? ?? 'rule_1',
      topicId: json['topic_id'] as String? ?? json['topicId'] as String? ?? '',
      title: json['title'] as String? ?? 'Rule Title',
      summary: json['summary'] as String? ?? '',
      detailedExplanation: json['detailed_explanation'] as String? ?? json['explanation'] as String? ?? '',
      examples: (json['examples'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      commonPitfalls: (json['common_pitfalls'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      explanation: json['explanation'] as String?,
      tip: json['tip'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'summary': summary,
      'detailed_explanation': detailedExplanation,
      'examples': examples,
      'common_pitfalls': commonPitfalls,
      'explanation': explanation,
      'tip': tip,
    };
  }

  GrammarRule copyWith({
    String? id,
    String? topicId,
    String? title,
    String? summary,
    String? detailedExplanation,
    List<String>? examples,
    List<String>? commonPitfalls,
    String? explanation,
    String? tip,
  }) {
    return GrammarRule(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      detailedExplanation: detailedExplanation ?? this.detailedExplanation,
      examples: examples ?? List.from(this.examples),
      commonPitfalls: commonPitfalls ?? List.from(this.commonPitfalls),
      explanation: explanation ?? this.explanation,
      tip: tip ?? this.tip,
    );
  }
}
