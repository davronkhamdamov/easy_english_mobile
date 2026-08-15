import 'dart:convert';
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
    final response = await _apiClient.get('/api/v1/word-bank');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => FlashcardItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      'Failed to fetch word bank items (Status: ${response.statusCode})',
    );
  }

  @override
  Future<List<FlashcardItemModel>> fetchDueFlashcards() async {
    final response = await _apiClient.get('/api/v1/word-bank/due');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data
          .map((json) => FlashcardItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    }
    throw Exception(
      'Failed to fetch due flashcards (Status: ${response.statusCode})',
    );
  }

  @override
  Future<FlashcardItemModel> submitReviewRating(
    String id,
    Map<String, dynamic> reviewData,
  ) async {
    final response = await _apiClient.post(
      '/api/v1/word-bank/$id/review',
      reviewData,
    );
    if (response.statusCode == 200) {
      return FlashcardItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception(
      'Failed to submit review rating (Status: ${response.statusCode})',
    );
  }

  @override
  Future<FlashcardItemModel> addWord(FlashcardItemModel model) async {
    final response = await _apiClient.post(
      '/api/v1/word-bank',
      model.toJson(),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return FlashcardItemModel.fromJson(
        jsonDecode(response.body) as Map<String, dynamic>,
      );
    }
    throw Exception('Failed to add word (Status: ${response.statusCode})');
  }

  @override
  Future<bool> deleteWord(String id) async {
    final response = await _apiClient.delete('/api/v1/word-bank/$id');
    if (response.statusCode == 200 || response.statusCode == 204) {
      return true;
    }
    throw Exception('Failed to delete word (Status: ${response.statusCode})');
  }
}
