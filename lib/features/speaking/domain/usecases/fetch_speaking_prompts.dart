import '../entities/speaking_prompt.dart';
import '../repositories/speaking_repository.dart';

class FetchSpeakingPrompts {
  final SpeakingRepository _repository;

  FetchSpeakingPrompts(this._repository);

  Future<List<SpeakingPrompt>> call({int? part}) {
    return _repository.fetchSpeakingPrompts(part: part);
  }
}
