import '../../domain/entities/grammar_rule.dart';

class GrammarRuleModel {
  final String id;
  final String topicId;
  final String title;
  final String summary;
  final String detailedExplanation;
  final List<String> examples;
  final List<String> commonPitfalls;

  const GrammarRuleModel({
    required this.id,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.detailedExplanation,
    required this.examples,
    required this.commonPitfalls,
  });

  factory GrammarRuleModel.fromJson(Map<String, dynamic> json) {
    return GrammarRuleModel(
      id: json['id'] as String? ?? '',
      topicId: json['topic_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      detailedExplanation: json['detailed_explanation'] as String? ?? '',
      examples: List<String>.from(json['examples'] as List? ?? []),
      commonPitfalls: List<String>.from(json['common_pitfalls'] as List? ?? []),
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
    };
  }

  GrammarRule toEntity() {
    return GrammarRule(
      id: id,
      topicId: topicId,
      title: title,
      summary: summary,
      detailedExplanation: detailedExplanation,
      examples: examples,
      commonPitfalls: commonPitfalls,
    );
  }

  factory GrammarRuleModel.fromEntity(GrammarRule entity) {
    return GrammarRuleModel(
      id: entity.id,
      topicId: entity.topicId,
      title: entity.title,
      summary: entity.summary,
      detailedExplanation: entity.detailedExplanation,
      examples: entity.examples,
      commonPitfalls: entity.commonPitfalls,
    );
  }
}
