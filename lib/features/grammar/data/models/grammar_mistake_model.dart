import '../../domain/entities/grammar_mistake_record.dart';

class GrammarMistakeRecordModel extends GrammarMistakeRecord {
  GrammarMistakeRecordModel({
    required super.id,
    super.originalText = '',
    super.correctedText = '',
    super.ruleCategory = 'General',
    super.occurrenceCount = 1,
    required super.lastFailedAt,
    super.explanation = '',
    super.isResolved = false,
  });

  factory GrammarMistakeRecordModel.fromJson(Map<String, dynamic> json) {
    final parsed = GrammarMistakeRecord.fromJson(json);
    return GrammarMistakeRecordModel(
      id: parsed.id,
      originalText: parsed.originalText,
      correctedText: parsed.correctedText,
      ruleCategory: parsed.ruleCategory,
      occurrenceCount: parsed.occurrenceCount,
      lastFailedAt: parsed.lastFailedAt,
      explanation: parsed.explanation,
      isResolved: parsed.isResolved,
    );
  }

  factory GrammarMistakeRecordModel.fromEntity(GrammarMistakeRecord entity) {
    return GrammarMistakeRecordModel(
      id: entity.id,
      originalText: entity.originalText,
      correctedText: entity.correctedText,
      ruleCategory: entity.ruleCategory,
      occurrenceCount: entity.occurrenceCount,
      lastFailedAt: entity.lastFailedAt,
      explanation: entity.explanation,
      isResolved: entity.isResolved,
    );
  }

  GrammarMistakeRecord toEntity() => this;
}
