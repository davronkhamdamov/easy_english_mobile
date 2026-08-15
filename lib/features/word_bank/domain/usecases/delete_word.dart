import '../repositories/word_bank_repository.dart';

class DeleteWord {
  final WordBankRepository _repository;

  DeleteWord(this._repository);

  Future<bool> call(String id) async {
    return await _repository.removeWord(id);
  }
}

typedef DeleteWordUseCase = DeleteWord;
