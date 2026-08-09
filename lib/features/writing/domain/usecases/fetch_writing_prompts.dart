import '../../data/repositories/writing_repository_impl.dart';
import '../entities/writing_prompt.dart';
import '../repositories/writing_repository.dart';

class FetchWritingPrompts {
  final WritingRepository _repository;

  FetchWritingPrompts({WritingRepository? repository})
    : _repository = repository ?? WritingRepositoryImpl();

  Future<List<WritingPrompt>> call() {
    return _repository.fetchWritingPrompts();
  }
}
