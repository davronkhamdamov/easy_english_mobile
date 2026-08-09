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

  static const List<Map<String, dynamic>> _seedItems = [
    {
      'id': 'wb_1',
      'word': 'Foster',
      'phonetic': '/ˈfɒstər/',
      'cefr_level': 'C1',
      'definition':
          'To encourage the development or growth of ideas, relationships, or skills.',
      'example':
          'The government policies aim to foster economic growth and innovative start-ups.',
      'collocations': [
        'foster growth',
        'foster creativity',
        'foster cooperation',
        'foster innovation',
      ],
      'idioms': ['nurture nature'],
      'phrasal_verbs': ['foster in', 'foster out'],
      'repetition_count': 1,
      'easiness_factor': 2.5,
      'interval_days': 3,
      'mastery_level': 3,
    },
    {
      'id': 'wb_2',
      'word': 'Paramount',
      'phonetic': '/ˈpærəmaʊnt/',
      'cefr_level': 'C1',
      'definition':
          'More important than anything else; supreme in power, rank, or importance.',
      'example':
          'Maintaining strict data security is of paramount importance in modern cloud architectures.',
      'collocations': [
        'paramount importance',
        'paramount duty',
        'paramount concern',
      ],
      'idioms': ['of the essence'],
      'phrasal_verbs': [],
      'repetition_count': 2,
      'easiness_factor': 2.6,
      'interval_days': 6,
      'mastery_level': 4,
    },
    {
      'id': 'wb_3',
      'word': 'Mitigate',
      'phonetic': '/ˈmɪtɪɡeɪt/',
      'cefr_level': 'B2',
      'definition':
          'Make something bad less severe, serious, painful, or damaging.',
      'example':
          'Proactive disaster response protocols help mitigate the financial impact of severe weather.',
      'collocations': [
        'mitigate risk',
        'mitigate climate change',
        'mitigate damage',
        'mitigate factors',
      ],
      'idioms': ['cushion the blow'],
      'phrasal_verbs': ['soften up'],
      'repetition_count': 0,
      'easiness_factor': 2.36,
      'interval_days': 1,
      'mastery_level': 2,
    },
    {
      'id': 'wb_4',
      'word': 'Ubiquitous',
      'phonetic': '/juːˈbɪkwɪtəs/',
      'cefr_level': 'C2',
      'definition': 'Present, appearing, or found everywhere at the same time.',
      'example':
          'Smartphones have become ubiquitous across all demographics in modern urban centers.',
      'collocations': [
        'ubiquitous presence',
        'ubiquitous technology',
        'become ubiquitous',
      ],
      'idioms': ['every nook and cranny'],
      'phrasal_verbs': ['crop up'],
      'repetition_count': 3,
      'easiness_factor': 2.7,
      'interval_days': 12,
      'mastery_level': 5,
    },
    {
      'id': 'wb_5',
      'word': 'Exacerbate',
      'phonetic': '/ɪɡˈzæsəbeɪt/',
      'cefr_level': 'C1',
      'definition':
          'Make a problem, bad situation, or negative feeling worse or more intense.',
      'example':
          'High traffic congestion exacerbates air pollution levels in densely populated cities.',
      'collocations': [
        'exacerbate problem',
        'exacerbate symptoms',
        'exacerbate tension',
      ],
      'idioms': ['add fuel to the fire'],
      'phrasal_verbs': ['stir up'],
      'repetition_count': 1,
      'easiness_factor': 2.4,
      'interval_days': 3,
      'mastery_level': 3,
    },
  ];

  @override
  Future<List<FlashcardItemModel>> fetchWordBankItems() async {
    try {
      final response = await _apiClient.get('/api/v1/word-bank');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FlashcardItemModel.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback to seed data when offline or backend unavailable
    }
    return _seedItems.map((j) => FlashcardItemModel.fromJson(j)).toList();
  }

  @override
  Future<List<FlashcardItemModel>> fetchDueFlashcards() async {
    try {
      final response = await _apiClient.get('/api/v1/word-bank/due');
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => FlashcardItemModel.fromJson(json)).toList();
      }
    } catch (_) {
      // Fallback to seed data
    }
    return _seedItems.map((j) => FlashcardItemModel.fromJson(j)).toList();
  }

  @override
  Future<FlashcardItemModel> submitReviewRating(
    String id,
    Map<String, dynamic> reviewData,
  ) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/word-bank/$id/review',
        reviewData,
      );
      if (response.statusCode == 200) {
        return FlashcardItemModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Fallback update logic
    }
    return FlashcardItemModel.fromJson({
      ..._seedItems.firstWhere(
        (element) => element['id'] == id,
        orElse: () => _seedItems.first,
      ),
      ...reviewData,
    });
  }

  @override
  Future<FlashcardItemModel> addWord(FlashcardItemModel model) async {
    try {
      final response = await _apiClient.post(
        '/api/v1/word-bank',
        model.toJson(),
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return FlashcardItemModel.fromJson(jsonDecode(response.body));
      }
    } catch (_) {
      // Fallback
    }
    return model;
  }

  @override
  Future<bool> deleteWord(String id) async {
    try {
      final response = await _apiClient.delete('/api/v1/word-bank/$id');
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (_) {
      return true;
    }
  }
}
