class GrammarMistakeRecord {
  final String id;
  final String topicCategory;
  final String originalSentence;
  final String correctedSentence;
  final String explanation;
  final int occurrenceCount;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final bool isResolved;

  const GrammarMistakeRecord({
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

  GrammarMistakeRecord copyWith({
    String? id,
    String? topicCategory,
    String? originalSentence,
    String? correctedSentence,
    String? explanation,
    int? occurrenceCount,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    bool? isResolved,
  }) {
    return GrammarMistakeRecord(
      id: id ?? this.id,
      topicCategory: topicCategory ?? this.topicCategory,
      originalSentence: originalSentence ?? this.originalSentence,
      correctedSentence: correctedSentence ?? this.correctedSentence,
      explanation: explanation ?? this.explanation,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }
}
