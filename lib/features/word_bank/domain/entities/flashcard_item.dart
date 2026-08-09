/// Pure domain entity representing a Word Bank item / Flashcard.
class FlashcardItem {
  final String id;
  final String word;
  final String phonetic;
  final String cefrLevel;
  final String definition;
  final String example;
  final String? audioUrl;
  final int meaningIndex;
  final List<String> collocations;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> grammaticalForms;
  final List<String> idioms;
  final List<String> phrasalVerbs;

  // SM-2 Spaced Repetition Parameters
  final int repetitionCount;
  final double easinessFactor;
  final int intervalDays;
  final int masteryLevel;
  final DateTime? lastReviewedAt;
  final DateTime? nextReviewAt;

  const FlashcardItem({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.cefrLevel,
    required this.definition,
    required this.example,
    this.audioUrl,
    this.meaningIndex = 0,
    this.collocations = const [],
    this.synonyms = const [],
    this.antonyms = const [],
    this.grammaticalForms = const [],
    this.idioms = const [],
    this.phrasalVerbs = const [],
    this.repetitionCount = 0,
    this.easinessFactor = 2.5,
    this.intervalDays = 0,
    this.masteryLevel = 0,
    this.lastReviewedAt,
    this.nextReviewAt,
  });

  FlashcardItem copyWith({
    String? id,
    String? word,
    String? phonetic,
    String? cefrLevel,
    String? definition,
    String? example,
    String? audioUrl,
    int? meaningIndex,
    List<String>? collocations,
    List<String>? synonyms,
    List<String>? antonyms,
    List<String>? grammaticalForms,
    List<String>? idioms,
    List<String>? phrasalVerbs,
    int? repetitionCount,
    double? easinessFactor,
    int? intervalDays,
    int? masteryLevel,
    DateTime? lastReviewedAt,
    DateTime? nextReviewAt,
  }) {
    return FlashcardItem(
      id: id ?? this.id,
      word: word ?? this.word,
      phonetic: phonetic ?? this.phonetic,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      definition: definition ?? this.definition,
      example: example ?? this.example,
      audioUrl: audioUrl ?? this.audioUrl,
      meaningIndex: meaningIndex ?? this.meaningIndex,
      collocations: collocations ?? this.collocations,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      grammaticalForms: grammaticalForms ?? this.grammaticalForms,
      idioms: idioms ?? this.idioms,
      phrasalVerbs: phrasalVerbs ?? this.phrasalVerbs,
      repetitionCount: repetitionCount ?? this.repetitionCount,
      easinessFactor: easinessFactor ?? this.easinessFactor,
      intervalDays: intervalDays ?? this.intervalDays,
      masteryLevel: masteryLevel ?? this.masteryLevel,
      lastReviewedAt: lastReviewedAt ?? this.lastReviewedAt,
      nextReviewAt: nextReviewAt ?? this.nextReviewAt,
    );
  }
}
