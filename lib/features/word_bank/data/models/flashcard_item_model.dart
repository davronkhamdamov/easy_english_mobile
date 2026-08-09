import '../../domain/entities/flashcard_item.dart';

/// Data Transfer Object (DTO) for FlashcardItem entity with JSON serialization.
class FlashcardItemModel extends FlashcardItem {
  const FlashcardItemModel({
    required super.id,
    required super.word,
    required super.phonetic,
    required super.cefrLevel,
    required super.definition,
    required super.example,
    super.audioUrl,
    super.meaningIndex = 0,
    super.collocations = const [],
    super.synonyms = const [],
    super.antonyms = const [],
    super.grammaticalForms = const [],
    super.idioms = const [],
    super.phrasalVerbs = const [],
    super.repetitionCount = 0,
    super.easinessFactor = 2.5,
    super.intervalDays = 0,
    super.masteryLevel = 0,
    super.lastReviewedAt,
    super.nextReviewAt,
  });

  factory FlashcardItemModel.fromJson(Map<String, dynamic> json) {
    return FlashcardItemModel(
      id: json['id']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      phonetic: json['phonetic']?.toString() ?? '',
      cefrLevel:
          json['cefr_level']?.toString() ?? json['cefr']?.toString() ?? 'B2',
      definition: json['definition']?.toString() ?? '',
      example: json['example']?.toString() ?? '',
      audioUrl: json['audio_url']?.toString(),
      meaningIndex: (json['meaning_index'] as num?)?.toInt() ?? 0,
      collocations:
          (json['collocations'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      synonyms:
          (json['synonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      antonyms:
          (json['antonyms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      grammaticalForms:
          (json['grammatical_forms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      idioms:
          (json['idioms'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      phrasalVerbs:
          (json['phrasal_verbs'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      repetitionCount: (json['repetition_count'] as num?)?.toInt() ?? 0,
      easinessFactor: (json['easiness_factor'] as num?)?.toDouble() ?? 2.5,
      intervalDays: (json['interval_days'] as num?)?.toInt() ?? 0,
      masteryLevel:
          (json['mastery_level'] as num?)?.toInt() ??
          (json['mastery'] as num?)?.toInt() ??
          0,
      lastReviewedAt: json['last_reviewed_at'] != null
          ? DateTime.tryParse(json['last_reviewed_at'].toString())
          : null,
      nextReviewAt: json['next_review_at'] != null
          ? DateTime.tryParse(json['next_review_at'].toString())
          : null,
    );
  }

  factory FlashcardItemModel.fromEntity(FlashcardItem entity) {
    return FlashcardItemModel(
      id: entity.id,
      word: entity.word,
      phonetic: entity.phonetic,
      cefrLevel: entity.cefrLevel,
      definition: entity.definition,
      example: entity.example,
      audioUrl: entity.audioUrl,
      meaningIndex: entity.meaningIndex,
      collocations: entity.collocations,
      synonyms: entity.synonyms,
      antonyms: entity.antonyms,
      grammaticalForms: entity.grammaticalForms,
      idioms: entity.idioms,
      phrasalVerbs: entity.phrasalVerbs,
      repetitionCount: entity.repetitionCount,
      easinessFactor: entity.easinessFactor,
      intervalDays: entity.intervalDays,
      masteryLevel: entity.masteryLevel,
      lastReviewedAt: entity.lastReviewedAt,
      nextReviewAt: entity.nextReviewAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'phonetic': phonetic,
      'cefr_level': cefrLevel,
      'definition': definition,
      'example': example,
      'audio_url': audioUrl,
      'meaning_index': meaningIndex,
      'collocations': collocations,
      'synonyms': synonyms,
      'antonyms': antonyms,
      'grammatical_forms': grammaticalForms,
      'idioms': idioms,
      'phrasal_verbs': phrasalVerbs,
      'repetition_count': repetitionCount,
      'easiness_factor': easinessFactor,
      'interval_days': intervalDays,
      'mastery_level': masteryLevel,
      'last_reviewed_at': lastReviewedAt?.toIso8601String(),
      'next_review_at': nextReviewAt?.toIso8601String(),
    };
  }

  FlashcardItem toEntity() => this;
}
