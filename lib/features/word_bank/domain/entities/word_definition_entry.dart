/// Domain entity for full, comprehensive multi-sense dictionary definitions.
/// Inspired by prestigious learner dictionaries (Cambridge, Oxford, Longman).
class WordDefinitionEntry {
  final String word;
  final String partOfSpeech;
  final List<String> allPartsOfSpeech;
  final String ukPhonetic;
  final String? ukAudioUrl;
  final String usPhonetic;
  final String? usAudioUrl;
  final List<WordSense> senses;
  final List<String> collocations;
  final List<String> idioms;
  final bool isSaved;

  const WordDefinitionEntry({
    required this.word,
    required this.partOfSpeech,
    this.allPartsOfSpeech = const [],
    this.ukPhonetic = '',
    this.ukAudioUrl,
    this.usPhonetic = '',
    this.usAudioUrl,
    required this.senses,
    this.collocations = const [],
    this.idioms = const [],
    this.isSaved = false,
  });

  WordDefinitionEntry copyWith({
    String? word,
    String? partOfSpeech,
    List<String>? allPartsOfSpeech,
    String? ukPhonetic,
    String? ukAudioUrl,
    String? usPhonetic,
    String? usAudioUrl,
    List<WordSense>? senses,
    List<String>? collocations,
    List<String>? idioms,
    bool? isSaved,
  }) {
    return WordDefinitionEntry(
      word: word ?? this.word,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      allPartsOfSpeech: allPartsOfSpeech ?? this.allPartsOfSpeech,
      ukPhonetic: ukPhonetic ?? this.ukPhonetic,
      ukAudioUrl: ukAudioUrl ?? this.ukAudioUrl,
      usPhonetic: usPhonetic ?? this.usPhonetic,
      usAudioUrl: usAudioUrl ?? this.usAudioUrl,
      senses: senses ?? this.senses,
      collocations: collocations ?? this.collocations,
      idioms: idioms ?? this.idioms,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// A specific meaning or sense of a headword within a part of speech.
/// Example: `work noun (ACTIVITY)`, `A1 [ U ]`
class WordSense {
  final String id;
  final String word;
  final String partOfSpeech;
  final String guideWord; // e.g. "ACTIVITY", "PLACE", "CREATION"
  final String cefrLevel; // e.g. "A1", "A2", "B1", "B2", "C1", "C2"
  final String grammaticalCode; // e.g. "[ U ]", "[ C ]", "[ T ]", "[ I ]"
  final String definition;
  final List<WordSenseExample> examples;
  final List<String> synonyms;
  final List<String> collocations;

  const WordSense({
    required this.id,
    required this.word,
    required this.partOfSpeech,
    required this.guideWord,
    this.cefrLevel = 'B1',
    this.grammaticalCode = '',
    required this.definition,
    this.examples = const [],
    this.synonyms = const [],
    this.collocations = const [],
  });

  /// Short grammatical abbreviation (e.g. "v", "n", "adj")
  String get shortPartOfSpeech => formatPartOfSpeechShort(partOfSpeech);

  /// Formatted headline: e.g. "work n (ACTIVITY)"
  String get displayTitle {
    final gw = guideWord.isNotEmpty ? ' ($guideWord)' : '';
    return '$word $shortPartOfSpeech$gw';
  }
}

/// Converts full part-of-speech names to standard learner dictionary abbreviations
/// (e.g. "verb" -> "v", "noun" -> "n", "adjective" -> "adj", "adverb" -> "adv").
String formatPartOfSpeechShort(String pos) {
  final clean = pos.trim().toLowerCase().replaceAll('.', '');
  switch (clean) {
    case 'verb':
      return 'v';
    case 'noun':
      return 'n';
    case 'adjective':
      return 'adj';
    case 'adverb':
      return 'adv';
    case 'preposition':
      return 'prep';
    case 'conjunction':
      return 'conj';
    case 'pronoun':
      return 'pron';
    case 'interjection':
      return 'interj';
    case 'phrasal verb':
      return 'phr v';
    case 'idiom':
      return 'idm';
    default:
      return clean.isNotEmpty ? clean : pos;
  }
}

/// An example sentence illustrating a sense, optionally highlighting
/// a collocation/pattern prefix (e.g. `do work`, `hard work`, `at work`).
class WordSenseExample {
  final String pattern;
  final String sentence;
  final String? audioUrl;

  const WordSenseExample({
    this.pattern = '',
    required this.sentence,
    this.audioUrl,
  });

  /// Full formatted text
  String get fullText => pattern.isNotEmpty ? '$pattern $sentence' : sentence;
}
