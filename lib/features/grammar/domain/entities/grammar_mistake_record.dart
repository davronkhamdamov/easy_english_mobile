/// Entity representing a logged grammar mistake.
class GrammarMistakeRecord {
  final String id;
  final String originalText;
  final String correctedText;
  final String ruleCategory;
  final int occurrenceCount;
  final DateTime lastFailedAt;
  final String explanation;
  final bool isResolved;

  const GrammarMistakeRecord({
    required this.id,
    required this.originalText,
    required this.correctedText,
    required this.ruleCategory,
    required this.occurrenceCount,
    required this.lastFailedAt,
    this.explanation = '',
    this.isResolved = false,
  });

  // Backwards compatibility getters
  String get topicCategory => ruleCategory;
  String get originalSentence => originalText;
  String get correctedSentence => correctedText;
  DateTime get firstSeenAt => lastFailedAt;
  DateTime get lastSeenAt => lastFailedAt;

  factory GrammarMistakeRecord.fromJson(Map<String, dynamic> json) {
    return GrammarMistakeRecord(
      id: json['id'] as String? ?? 'mistake_${DateTime.now().millisecondsSinceEpoch}',
      originalText: json['original_text'] as String? ?? json['originalText'] as String? ?? json['original_sentence'] as String? ?? '',
      correctedText: json['corrected_text'] as String? ?? json['correctedText'] as String? ?? json['corrected_sentence'] as String? ?? '',
      ruleCategory: json['rule_category'] as String? ?? json['ruleCategory'] as String? ?? json['topic_category'] as String? ?? 'General',
      occurrenceCount: (json['occurrence_count'] ?? json['occurrenceCount'] ?? 1) as int,
      lastFailedAt: json['last_failed_at'] != null
          ? DateTime.parse(json['last_failed_at'] as String)
          : (json['last_seen_at'] != null ? DateTime.parse(json['last_seen_at'] as String) : DateTime.now()),
      explanation: json['explanation'] as String? ?? '',
      isResolved: json['is_resolved'] as bool? ?? json['isResolved'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_text': originalText,
      'original_sentence': originalText,
      'corrected_text': correctedText,
      'corrected_sentence': correctedText,
      'rule_category': ruleCategory,
      'topic_category': ruleCategory,
      'occurrence_count': occurrenceCount,
      'last_failed_at': lastFailedAt.toIso8601String(),
      'last_seen_at': lastFailedAt.toIso8601String(),
      'explanation': explanation,
      'is_resolved': isResolved,
    };
  }

  GrammarMistakeRecord copyWith({
    String? id,
    String? originalText,
    String? correctedText,
    String? ruleCategory,
    int? occurrenceCount,
    DateTime? lastFailedAt,
    String? explanation,
    bool? isResolved,
    String? topicCategory,
    String? originalSentence,
    String? correctedSentence,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
  }) {
    return GrammarMistakeRecord(
      id: id ?? this.id,
      originalText: originalText ?? originalSentence ?? this.originalText,
      correctedText: correctedText ?? correctedSentence ?? this.correctedText,
      ruleCategory: ruleCategory ?? topicCategory ?? this.ruleCategory,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      lastFailedAt: lastFailedAt ?? lastSeenAt ?? firstSeenAt ?? this.lastFailedAt,
      explanation: explanation ?? this.explanation,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
