import '../../domain/entities/flashcard_item.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../../domain/services/spaced_repetition.dart';
import '../datasources/word_bank_remote_datasource.dart';
import '../models/flashcard_item_model.dart';

class WordBankRepositoryImpl implements WordBankRepository {
  final WordBankRemoteDataSource _remoteDataSource;

  WordBankRepositoryImpl({WordBankRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? WordBankRemoteDataSourceImpl();

  @override
  Future<List<FlashcardItem>> getWordBankItems() async {
    final models = await _remoteDataSource.fetchWordBankItems();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<FlashcardItem>> getDueFlashcards() async {
    final models = await _remoteDataSource.fetchDueFlashcards();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FlashcardItem> submitReview({
    required String id,
    required ReviewRating rating,
  }) async {
    final items = await getWordBankItems();
    final item = items.firstWhere(
      (card) => card.id == id,
      orElse: () => items.first,
    );

    final calcResult = SM2Algorithm.calculate(
      currentEF: item.easinessFactor,
      currentRepetition: item.repetitionCount,
      currentInterval: item.intervalDays,
      rating: rating,
    );

    final updatedModel = await _remoteDataSource.submitReviewRating(
      id,
      calcResult.toJson(),
    );

    return updatedModel.toEntity();
  }

  @override
  Future<FlashcardItem> addWord(FlashcardItem item) async {
    final model = FlashcardItemModel.fromEntity(item);
    final savedModel = await _remoteDataSource.addWord(model);
    return savedModel.toEntity();
  }

  @override
  Future<bool> removeWord(String id) async {
    return await _remoteDataSource.deleteWord(id);
  }
}
