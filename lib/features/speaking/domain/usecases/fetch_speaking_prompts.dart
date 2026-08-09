import '../../data/repositories/speaking_repository_impl.dart';
import '../entities/speaking_prompt.dart';
import '../repositories/speaking_repository.dart';

class FetchSpeakingPrompts {
  final SpeakingRepository _repository;

  FetchSpeakingPrompts({SpeakingRepository? repository})
    : _repository = repository ?? SpeakingRepositoryImpl();

  Future<List<SpeakingPrompt>> call() {
    return _repository.fetchSpeakingPrompts();
  }
}
