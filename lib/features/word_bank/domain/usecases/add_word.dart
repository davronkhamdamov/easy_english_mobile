import '../entities/flashcard_item.dart';
import '../repositories/word_bank_repository.dart';

class AddWord {
  final WordBankRepository _repository;

  AddWord(this._repository);

  Future<FlashcardItem> call(FlashcardItem item) async {
    return await _repository.addWord(item);
  }
}

typedef AddWordUseCase = AddWord;
