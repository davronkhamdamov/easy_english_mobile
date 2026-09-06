import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Representation of rich vocabulary data for a single word.
class WordLookupInfo {
  final String word;
  final String cleanWord;
  final String phonetic;
  final String partOfSpeech;
  final String cefrLevel;
  final String definition;
  final String? translation;
  final String? example;
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> collocations;
  final String? audioUrl;
  final bool isSaved;

  const WordLookupInfo({
    required this.word,
    required this.cleanWord,
    this.phonetic = '',
    this.partOfSpeech = '',
    this.cefrLevel = '',
    required this.definition,
    this.translation,
    this.example,
    this.synonyms = const [],
    this.antonyms = const [],
    this.collocations = const [],
    this.audioUrl,
    this.isSaved = false,
  });

  WordLookupInfo copyWith({
    String? word,
    String? cleanWord,
    String? phonetic,
    String? partOfSpeech,
    String? cefrLevel,
    String? definition,
    String? translation,
    String? example,
    List<String>? synonyms,
    List<String>? antonyms,
    List<String>? collocations,
    String? audioUrl,
    bool? isSaved,
  }) {
    return WordLookupInfo(
      word: word ?? this.word,
      cleanWord: cleanWord ?? this.cleanWord,
      phonetic: phonetic ?? this.phonetic,
      partOfSpeech: partOfSpeech ?? this.partOfSpeech,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      definition: definition ?? this.definition,
      translation: translation ?? this.translation,
      example: example ?? this.example,
      synonyms: synonyms ?? this.synonyms,
      antonyms: antonyms ?? this.antonyms,
      collocations: collocations ?? this.collocations,
      audioUrl: audioUrl ?? this.audioUrl,
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

/// Intelligent vocabulary dictionary engine combining Open-Source Free Dictionary API
/// with instant offline fallback & CEFR dataset.
class WordLookupDictionaryService {
  static final WordLookupDictionaryService _instance =
      WordLookupDictionaryService._internal();
  factory WordLookupDictionaryService({http.Client? httpClient}) {
    if (httpClient != null) {
      _instance._customClient = httpClient;
    }
    return _instance;
  }
  WordLookupDictionaryService._internal();

  http.Client? _customClient;
  http.Client get _httpClient => _customClient ?? http.Client();

  // Saved words state cache in memory
  final Set<String> _savedWords = <String>{};

  // Runtime memory cache for API lookups to avoid repeating network requests
  final Map<String, WordLookupInfo> _liveCache = {};

  bool isWordSaved(String word) {
    return _savedWords.contains(cleanToken(word));
  }

  void toggleSaved(String word) {
    final clean = cleanToken(word);
    if (_savedWords.contains(clean)) {
      _savedWords.remove(clean);
    } else {
      _savedWords.add(clean);
    }
  }

  static String cleanToken(String raw) {
    return raw.trim().toLowerCase().replaceAll(RegExp(r'[^a-zA-Z\-]'), '');
  }

  /// Looks up real word definitions via Open-Source Free Dictionary API.
  Future<WordLookupInfo> lookupWord(String rawWord) async {
    final clean = cleanToken(rawWord);
    if (clean.isEmpty) {
      return WordLookupInfo(
        word: rawWord,
        cleanWord: clean,
        definition: 'Punctuation or symbol.',
      );
    }

    // 1. Check runtime memory cache
    if (_liveCache.containsKey(clean)) {
      return _liveCache[clean]!.copyWith(
        word: rawWord.trim(),
        isSaved: _savedWords.contains(clean),
      );
    }

    // 2. Query Open-Source Free Dictionary API (https://dictionaryapi.dev/)
    try {
      final apiResult = await _fetchFromOpenSourceApi(clean, rawWord);
      if (apiResult != null) {
        _liveCache[clean] = apiResult;
        return apiResult.copyWith(
          word: rawWord.trim(),
          isSaved: _savedWords.contains(clean),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Open Source Dictionary API error for "$clean": $e');
      }
    }

    // 3. Fallback when term is not found in dictionary API
    final notFound = WordLookupInfo(
      word: rawWord.trim(),
      cleanWord: clean,
      phonetic: '/$clean/',
      definition: 'No dictionary definition found for "$rawWord".',
      audioUrl:
          'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=1',
      isSaved: _savedWords.contains(clean),
    );
    _liveCache[clean] = notFound;
    return notFound;
  }

  /// Fetches structured dictionary payload from the Open-Source Free Dictionary API.
  Future<WordLookupInfo?> _fetchFromOpenSourceApi(
    String cleanWord,
    String rawWord,
  ) async {
    final url = Uri.parse(
      'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(cleanWord)}',
    );

    final response = await _httpClient.get(url).timeout(
      const Duration(seconds: 25),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final list = jsonDecode(response.body);
    if (list is! List || list.isEmpty) return null;

    final entry = list[0] as Map<String, dynamic>;

    // Phonetics
    String phonetic = entry['phonetic']?.toString() ?? '';
    String? audioUrl;

    if (entry['phonetics'] is List) {
      final phoneticsList = entry['phonetics'] as List;
      for (final p in phoneticsList) {
        if (p is Map<String, dynamic>) {
          if (phonetic.isEmpty && p['text'] != null) {
            phonetic = p['text'].toString();
          }
          final audio = p['audio']?.toString() ?? '';
          if (audio.isNotEmpty && audioUrl == null) {
            audioUrl = audio.startsWith('http') ? audio : 'https:$audio';
          }
        }
      }
    }

    if (phonetic.isEmpty) {
      phonetic = '/$cleanWord/';
    }
    audioUrl ??=
        'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(cleanWord)}&type=1';

    // Meanings
    String partOfSpeech = '';
    String definition = '';
    String? example;
    final synonyms = <String>[];
    final antonyms = <String>[];

    if (entry['meanings'] is List && (entry['meanings'] as List).isNotEmpty) {
      for (final meaning in entry['meanings'] as List) {
        if (meaning is Map<String, dynamic>) {
          final pos = meaning['partOfSpeech']?.toString() ?? '';
          if (partOfSpeech.isEmpty && pos.isNotEmpty) {
            partOfSpeech = pos;
          }

          if (meaning['synonyms'] is List) {
            for (final s in meaning['synonyms'] as List) {
              final synStr = s.toString().trim();
              if (synStr.isNotEmpty &&
                  !synonyms.contains(synStr) &&
                  synStr.toLowerCase() != cleanWord) {
                synonyms.add(synStr);
              }
            }
          }

          if (meaning['antonyms'] is List) {
            for (final a in meaning['antonyms'] as List) {
              final antStr = a.toString().trim();
              if (antStr.isNotEmpty && !antonyms.contains(antStr)) {
                antonyms.add(antStr);
              }
            }
          }

          if (meaning['definitions'] is List &&
              (meaning['definitions'] as List).isNotEmpty) {
            for (final d in meaning['definitions'] as List) {
              if (d is Map<String, dynamic>) {
                if (definition.isEmpty && d['definition'] != null) {
                  definition = d['definition'].toString().trim();
                }
                if (example == null && d['example'] != null) {
                  final ex = d['example'].toString().trim();
                  if (ex.isNotEmpty) {
                    example = ex;
                  }
                }
                if (d['synonyms'] is List) {
                  for (final s in d['synonyms'] as List) {
                    final synStr = s.toString().trim();
                    if (synStr.isNotEmpty &&
                        !synonyms.contains(synStr) &&
                        synStr.toLowerCase() != cleanWord) {
                      synonyms.add(synStr);
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    if (definition.isEmpty) {
      return null;
    }

    return WordLookupInfo(
      word: rawWord,
      cleanWord: cleanWord,
      phonetic: phonetic,
      partOfSpeech: partOfSpeech,
      cefrLevel: '',
      definition: definition,
      example: example,
      synonyms: synonyms.take(5).toList(),
      antonyms: antonyms.take(3).toList(),
      collocations: const [],
      audioUrl: audioUrl,
      isSaved: _savedWords.contains(cleanWord),
    );
  }
}
