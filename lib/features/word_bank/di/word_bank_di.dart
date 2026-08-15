import '../data/datasources/word_bank_remote_datasource.dart';
import '../data/repositories/word_bank_repository_impl.dart';
import '../domain/repositories/word_bank_repository.dart';
import '../domain/usecases/add_word.dart';
import '../domain/usecases/delete_word.dart';
import '../domain/usecases/get_due_cards.dart';
import '../domain/usecases/get_word_bank.dart';
import '../domain/usecases/review_flashcard.dart';

class WordBankDI {
  WordBankDI._();

  static WordBankRemoteDataSource createRemoteDataSource() {
    return WordBankRemoteDataSourceImpl();
  }

  static WordBankRepository createRepository({
    WordBankRemoteDataSource? remoteDataSource,
  }) {
    return WordBankRepositoryImpl(
      remoteDataSource: remoteDataSource ?? createRemoteDataSource(),
    );
  }

  static GetWordBank createGetWordBank(WordBankRepository repo) =>
      GetWordBank(repo);

  static GetDueCards createGetDueCards(WordBankRepository repo) =>
      GetDueCards(repo);

  static ReviewFlashcard createReviewFlashcard(WordBankRepository repo) =>
      ReviewFlashcard(repo);

  static AddWord createAddWord(WordBankRepository repo) => AddWord(repo);

  static DeleteWord createDeleteWord(WordBankRepository repo) =>
      DeleteWord(repo);
}
