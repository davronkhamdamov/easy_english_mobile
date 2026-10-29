import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Represents a single word entry in search history.
class WordSearchHistoryItem {
  final String word;
  final String? partOfSpeech;
  final String? definition;
  final DateTime timestamp;

  const WordSearchHistoryItem({
    required this.word,
    this.partOfSpeech,
    this.definition,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
    'word': word,
    if (partOfSpeech != null) 'partOfSpeech': partOfSpeech,
    if (definition != null) 'definition': definition,
    'timestamp': timestamp.toIso8601String(),
  };

  factory WordSearchHistoryItem.fromJson(Map<String, dynamic> json) =>
      WordSearchHistoryItem(
        word: json['word'] as String? ?? '',
        partOfSpeech: json['partOfSpeech'] as String?,
        definition: json['definition'] as String?,
        timestamp: json['timestamp'] != null
            ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
            : DateTime.now(),
      );
}

/// Service managing persistent vocabulary search history.
class WordSearchHistoryService {
  static final WordSearchHistoryService _instance =
      WordSearchHistoryService._internal();

  factory WordSearchHistoryService({
    FlutterSecureStorage? storage,
    bool enablePersistence = true,
  }) {
    if (storage != null) {
      _instance._storage = storage;
    }
    _instance.enablePersistence = enablePersistence;
    return _instance;
  }

  WordSearchHistoryService._internal();

  bool enablePersistence = true;
  FlutterSecureStorage? _storage;
  FlutterSecureStorage get storage => _storage ?? const FlutterSecureStorage();

  static const String _storageKey = 'easy_english_vocab_search_history';
  final List<WordSearchHistoryItem> _memoryCache = [];

  List<WordSearchHistoryItem> get currentHistory =>
      List.unmodifiable(_memoryCache);

  /// Loads search history from storage into memory cache.
  Future<List<WordSearchHistoryItem>> loadHistory() async {
    if (!enablePersistence) return List.unmodifiable(_memoryCache);
    try {
      final jsonStr = await storage.read(key: _storageKey);
      if (jsonStr != null && jsonStr.isNotEmpty) {
        final decoded = jsonDecode(jsonStr);
        if (decoded is List) {
          _memoryCache.clear();
          for (final item in decoded) {
            if (item is Map<String, dynamic>) {
              _memoryCache.add(WordSearchHistoryItem.fromJson(item));
            }
          }
        }
      }
    } catch (_) {
      // Ignored in test environments without native storage channel
    }
    return List.unmodifiable(_memoryCache);
  }

  /// Adds a successfully searched word to history (moves to top if already present).
  Future<void> addSuccessfulSearch({
    required String word,
    String? partOfSpeech,
    String? definition,
  }) async {
    final clean = word.trim();
    if (clean.isEmpty) return;

    // Remove existing match to place at the top
    _memoryCache.removeWhere(
      (item) => item.word.toLowerCase() == clean.toLowerCase(),
    );

    _memoryCache.insert(
      0,
      WordSearchHistoryItem(
        word: clean,
        partOfSpeech: partOfSpeech,
        definition: definition,
        timestamp: DateTime.now(),
      ),
    );

    // Keep up to 30 recent items
    if (_memoryCache.length > 30) {
      _memoryCache.removeRange(30, _memoryCache.length);
    }

    await _persist();
  }

  /// Removes an individual word from history.
  Future<void> removeItem(String word) async {
    _memoryCache.removeWhere(
      (item) => item.word.toLowerCase() == word.trim().toLowerCase(),
    );
    await _persist();
  }

  /// Clears all search history.
  Future<void> clearHistory() async {
    _memoryCache.clear();
    await _persist();
  }

  Future<void> _persist() async {
    if (!enablePersistence) return;
    try {
      final jsonStr = jsonEncode(
        _memoryCache.map((e) => e.toJson()).toList(),
      );
      await storage.write(key: _storageKey, value: jsonStr);
    } catch (_) {
      // Ignored in test environments without native storage channel
    }
  }
}
