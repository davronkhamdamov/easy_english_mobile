import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// Model for a dictionary search suggestion.
class WordSuggestion {
  final String word;
  final String? partOfSpeech;
  final String? meaningHint;
  final String? cefrLevel;

  const WordSuggestion({
    required this.word,
    this.partOfSpeech,
    this.meaningHint,
    this.cefrLevel,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordSuggestion &&
          runtimeType == other.runtimeType &&
          word.toLowerCase() == other.word.toLowerCase();

  @override
  int get hashCode => word.toLowerCase().hashCode;
}

/// Service providing live word autocomplete and suggestions 100% via online APIs
/// (Datamuse Lexical Engine & Wiktionary OpenSearch) without relying on local lists.
class WordSuggestionService {
  static final WordSuggestionService _instance =
      WordSuggestionService._internal();

  factory WordSuggestionService({http.Client? httpClient}) {
    if (httpClient != null) {
      _instance._httpClient = httpClient;
    }
    return _instance;
  }

  WordSuggestionService._internal();

  http.Client? _httpClient;
  http.Client get _client => _httpClient ?? http.Client();

  /// In-memory cache for recent API queries to avoid redundant network roundtrips.
  final Map<String, List<WordSuggestion>> _cache = {};

  /// Clears in-memory query cache (useful in tests or when refreshing).
  void clearCache() {
    _cache.clear();
  }

  /// Fetches autocomplete suggestions 100% online from public dictionary & lexical APIs.
  /// Queries Datamuse words API with wildcard & rich metadata (definitions + part of speech),
  /// with fallbacks to Datamuse sug and Wiktionary OpenSearch.
  Future<List<WordSuggestion>> getSuggestions(String query) async {
    final clean = query.trim().toLowerCase();
    if (clean.isEmpty) return const [];

    // Return cached results if already fetched
    if (_cache.containsKey(clean)) {
      return _cache[clean]!;
    }

    // 1. Primary: Datamuse words API with prefix wildcard & metadata (pos, defs)
    try {
      final url = Uri.parse(
        'https://api.datamuse.com/words?sp=${Uri.encodeComponent(clean)}*&md=d,p&max=10',
      );
      final response = await _client.get(url).timeout(const Duration(seconds: 3));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final List<WordSuggestion> results = [];
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final parsed = _parseDatamuseWord(item);
              if (parsed != null && !results.contains(parsed)) {
                results.add(parsed);
              }
            }
            if (results.length >= 8) break;
          }
          if (results.isNotEmpty) {
            _cache[clean] = results;
            return results;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Datamuse words query skipped/failed: $e');
      }
    }

    // 2. Secondary: Datamuse fast autocomplete endpoint (sug?s=...)
    try {
      final sugUrl = Uri.parse(
        'https://api.datamuse.com/sug?s=${Uri.encodeComponent(clean)}',
      );
      final response = await _client.get(sugUrl).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.isNotEmpty) {
          final List<WordSuggestion> results = [];
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              final w = item['word']?.toString().trim();
              if (w != null && w.isNotEmpty) {
                final suggestion = WordSuggestion(word: w);
                if (!results.contains(suggestion)) {
                  results.add(suggestion);
                }
              }
            }
            if (results.length >= 8) break;
          }
          if (results.isNotEmpty) {
            _cache[clean] = results;
            return results;
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Datamuse sug query skipped/failed: $e');
      }
    }

    // 3. Tertiary: Wiktionary OpenSearch API fallback
    try {
      final wikiUrl = Uri.parse(
        'https://en.wiktionary.org/w/api.php?action=opensearch&search=${Uri.encodeComponent(clean)}&limit=8&format=json',
      );
      final response = await _client.get(wikiUrl).timeout(const Duration(seconds: 2));

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded is List && decoded.length >= 2) {
          final wordsList = decoded[1];
          if (wordsList is List && wordsList.isNotEmpty) {
            final List<WordSuggestion> results = [];
            for (final item in wordsList) {
              final w = item.toString().trim();
              if (w.isNotEmpty) {
                final suggestion = WordSuggestion(word: w);
                if (!results.contains(suggestion)) {
                  results.add(suggestion);
                }
              }
              if (results.length >= 8) break;
            }
            if (results.isNotEmpty) {
              _cache[clean] = results;
              return results;
            }
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Wiktionary OpenSearch query skipped/failed: $e');
      }
    }

    return const [];
  }

  /// Parses Datamuse JSON item into a WordSuggestion with part of speech and definition preview.
  WordSuggestion? _parseDatamuseWord(Map<String, dynamic> item) {
    final word = item['word']?.toString().trim();
    if (word == null || word.isEmpty) return null;

    String? partOfSpeech;
    String? meaningHint;

    // Check tags for parts of speech: 'n', 'v', 'adj', 'adv'
    final tags = item['tags'];
    if (tags is List) {
      for (final tag in tags) {
        final t = tag.toString().toLowerCase();
        if (t == 'n' || t == 'noun') {
          partOfSpeech = 'n';
          break;
        } else if (t == 'v' || t == 'verb') {
          partOfSpeech = 'v';
          break;
        } else if (t == 'adj' || t == 'adjective') {
          partOfSpeech = 'adj';
          break;
        } else if (t == 'adv' || t == 'adverb') {
          partOfSpeech = 'adv';
          break;
        }
      }
    }

    // Extract first definition from defs if available
    final defs = item['defs'];
    if (defs is List && defs.isNotEmpty) {
      final firstDef = defs.first.toString();
      final tabIndex = firstDef.indexOf('\t');
      if (tabIndex != -1) {
        final posPrefix = firstDef.substring(0, tabIndex).trim();
        final rawMeaning = firstDef.substring(tabIndex + 1).trim();
        if (partOfSpeech == null) {
          if (posPrefix == 'n') {
            partOfSpeech = 'n';
          } else if (posPrefix == 'v') {
            partOfSpeech = 'v';
          } else if (posPrefix == 'adj') {
            partOfSpeech = 'adj';
          } else if (posPrefix == 'adv') {
            partOfSpeech = 'adv';
          }
        }
        meaningHint = _cleanDefinition(rawMeaning);
      } else {
        meaningHint = _cleanDefinition(firstDef);
      }
    }

    return WordSuggestion(
      word: word,
      partOfSpeech: partOfSpeech,
      meaningHint: meaningHint,
    );
  }

  String _cleanDefinition(String def) {
    var cleaned = def.trim();
    // Remove leading grammatical qualifiers like (transitive), (uncountable)
    cleaned = cleaned.replaceAll(RegExp(r'^\([a-zA-Z\s,;]+\)\s*'), '');
    if (cleaned.length > 80) {
      cleaned = '${cleaned.substring(0, 77)}...';
    }
    return cleaned;
  }
}
