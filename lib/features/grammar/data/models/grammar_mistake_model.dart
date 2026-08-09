import '../../domain/entities/grammar_mistake_record.dart';

class GrammarMistakeRecordModel {
  final String id;
  final String topicCategory;
  final String originalSentence;
  final String correctedSentence;
  final String explanation;
  final int occurrenceCount;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final bool isResolved;

  const GrammarMistakeRecordModel({
    required this.id,
    required this.topicCategory,
    required this.originalSentence,
    required this.correctedSentence,
    required this.explanation,
    required this.occurrenceCount,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.isResolved = false,
  });

  factory GrammarMistakeRecordModel.fromJson(Map<String, dynamic> json) {
    return GrammarMistakeRecordModel(
      id: json['id'] as String? ?? '',
      topicCategory: json['topic_category'] as String? ?? 'General',
      originalSentence: json['original_sentence'] as String? ?? '',
      correctedSentence: json['corrected_sentence'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      occurrenceCount: json['occurrence_count'] as int? ?? 1,
      firstSeenAt: json['first_seen_at'] != null
          ? DateTime.parse(json['first_seen_at'] as String)
          : DateTime.now(),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : DateTime.now(),
      isResolved: json['is_resolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_category': topicCategory,
      'original_sentence': originalSentence,
      'corrected_sentence': correctedSentence,
      'explanation': explanation,
      'occurrence_count': occurrenceCount,
      'first_seen_at': firstSeenAt.toIso8601String(),
      'last_seen_at': lastSeenAt.toIso8601String(),
      'is_resolved': isResolved,
    };
  }

  GrammarMistakeRecord toEntity() {
    return GrammarMistakeRecord(
      id: id,
      topicCategory: topicCategory,
      originalSentence: originalSentence,
      correctedSentence: correctedSentence,
      explanation: explanation,
      occurrenceCount: occurrenceCount,
      firstSeenAt: firstSeenAt,
      lastSeenAt: lastSeenAt,
      isResolved: isResolved,
    );
  }

  factory GrammarMistakeRecordModel.fromEntity(GrammarMistakeRecord entity) {
    return GrammarMistakeRecordModel(
      id: entity.id,
      topicCategory: entity.topicCategory,
      originalSentence: entity.originalSentence,
      correctedSentence: entity.correctedSentence,
      explanation: entity.explanation,
      occurrenceCount: entity.occurrenceCount,
      firstSeenAt: entity.firstSeenAt,
      lastSeenAt: entity.lastSeenAt,
      isResolved: entity.isResolved,
    );
  }
}
