import '../entities/flashcard_item.dart';
import '../repositories/word_bank_repository.dart';

class GetWordBank {
  final WordBankRepository _repository;

  GetWordBank(this._repository);

  Future<List<FlashcardItem>> call() async {
    return await _repository.getWordBankItems();
  }
}

typedef GetWordBankItemsUseCase = GetWordBank;
