import '../entities/flashcard_item.dart';
import '../repositories/word_bank_repository.dart';

class GetDueCards {
  final WordBankRepository _repository;

  GetDueCards(this._repository);

  Future<List<FlashcardItem>> call() async {
    return await _repository.getDueFlashcards();
  }
}

typedef GetDueFlashcardsUseCase = GetDueCards;
