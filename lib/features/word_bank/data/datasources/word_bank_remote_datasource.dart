import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../../../../core/network/api_client.dart';
import '../models/flashcard_item_model.dart';

abstract class WordBankRemoteDataSource {
  Future<List<FlashcardItemModel>> fetchWordBankItems();
  Future<List<FlashcardItemModel>> fetchDueFlashcards();
  Future<FlashcardItemModel> submitReviewRating(
    String id,
    Map<String, dynamic> reviewData,
  );
  Future<FlashcardItemModel> addWord(FlashcardItemModel model);
  Future<bool> deleteWord(String id);
}

class WordBankRemoteDataSourceImpl implements WordBankRemoteDataSource {
  final ApiClient _apiClient;

  WordBankRemoteDataSourceImpl({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient();

  @override
  Future<List<FlashcardItemModel>> fetchWordBankItems() async {
    try {
      final response = await _apiClient.get('/api/v1/wordbank/');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> jsonList = _extractList(
          decoded,
          const ['results', 'data', 'items', 'wordbank', 'flashcards', 'words'],
        );
        if (jsonList.isNotEmpty) {
          return jsonList
              .whereType<Map>()
              .map((json) => FlashcardItemModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }
    } catch (_) {
      // Remote API call failed, fallback below
    }

    final bundled = await _loadBundledVocabulary();
    if (bundled.isNotEmpty) {
      return bundled;
    }
    throw Exception('Failed to fetch word bank items');
  }

  @override
  Future<List<FlashcardItemModel>> fetchDueFlashcards() async {
    try {
      final response = await _apiClient.get('/api/v1/wordbank/due/');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List<dynamic> jsonList = _extractList(
          decoded,
          const ['due_cards', 'results', 'data', 'items', 'flashcards', 'words'],
        );
        if (jsonList.isNotEmpty) {
          return jsonList
              .whereType<Map>()
              .map((json) => FlashcardItemModel.fromJson(Map<String, dynamic>.from(json)))
              .toList();
        }
      }
    } catch (_) {
      // Remote API call failed, fallback below
    }

    final all = await fetchWordBankItems();
    return all.take(5).toList();
  }

  Future<List<FlashcardItemModel>> _loadBundledVocabulary() async {
    try {
      final raw = await rootBundle.loadString('assets/data/vocabulary_bank.json');
      final decoded = jsonDecode(raw);
      if (decoded is Map && decoded['words'] is List) {
        return (decoded['words'] as List)
            .whereType<Map>()
            .map((json) => FlashcardItemModel.fromJson(Map<String, dynamic>.from(json)))
            .toList();
      }
    } catch (_) {}
    return const [];
  }

  @override
  Future<FlashcardItemModel> submitReviewRating(
    String id,
    Map<String, dynamic> reviewData,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/wordbank/$id/review/',
      reviewData,
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = jsonDecode(response.body);
      final map = _extractMap(decoded, const ['data', 'result', 'item', 'flashcard']);
      return FlashcardItemModel.fromJson(map);
    }
    throw Exception(
      'Failed to submit review rating (Status: ${response.statusCode})',
    );
  }

  @override
  Future<FlashcardItemModel> addWord(FlashcardItemModel model) async {
    final response = await _apiClient.post(
      '/api/v1/wordbank/',
      model.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      final decoded = jsonDecode(response.body);
      final map = _extractMap(decoded, const ['data', 'result', 'item', 'flashcard']);
      return FlashcardItemModel.fromJson(map);
    }
    throw Exception('Failed to add word (Status: ${response.statusCode})');
  }

  @override
  Future<bool> deleteWord(String id) async {
    final response = await _apiClient.delete('/api/v1/wordbank/$id/');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    throw Exception('Failed to delete word (Status: ${response.statusCode})');
  }

  List<dynamic> _extractList(dynamic decoded, List<String> preferredKeys) {
    if (decoded is List) {
      return decoded;
    }
    if (decoded is Map) {
      for (final key in preferredKeys) {
        if (decoded[key] is List) {
          return decoded[key] as List<dynamic>;
        }
      }
      for (final value in decoded.values) {
        if (value is List) {
          return value;
        }
      }
    }
    return const [];
  }

  Map<String, dynamic> _extractMap(dynamic decoded, List<String> preferredKeys) {
    if (decoded is Map) {
      for (final key in preferredKeys) {
        if (decoded[key] is Map) {
          return Map<String, dynamic>.from(decoded[key] as Map);
        }
      }
      return Map<String, dynamic>.from(decoded);
    }
    return const {};
  }
}
