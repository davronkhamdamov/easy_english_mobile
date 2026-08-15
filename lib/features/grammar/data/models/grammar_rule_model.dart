import '../../domain/entities/grammar_rule.dart';

class GrammarRuleModel extends GrammarRule {
  const GrammarRuleModel({
    required super.id,
    super.topicId = '',
    required super.title,
    super.summary = '',
    super.detailedExplanation = '',
    super.examples = const [],
    super.commonPitfalls = const [],
    super.explanation,
    super.tip,
  });

  factory GrammarRuleModel.fromJson(Map<String, dynamic> json) {
    final parsed = GrammarRule.fromJson(json);
    return GrammarRuleModel(
      id: parsed.id,
      topicId: parsed.topicId,
      title: parsed.title,
      summary: parsed.summary,
      detailedExplanation: parsed.detailedExplanation,
      examples: parsed.examples,
      commonPitfalls: parsed.commonPitfalls,
      explanation: parsed.explanation,
      tip: parsed.tip,
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
      explanation: entity.explanation,
      tip: entity.tip,
    );
  }

  GrammarRule toEntity() => this;
}
