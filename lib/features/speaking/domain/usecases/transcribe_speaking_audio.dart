import '../../data/repositories/speaking_repository_impl.dart';
import '../repositories/speaking_repository.dart';

class TranscribeSpeakingAudio {
  final SpeakingRepository _repository;

  TranscribeSpeakingAudio({SpeakingRepository? repository})
    : _repository = repository ?? SpeakingRepositoryImpl();

  Future<String> call(String audioFilePath) {
    return _repository.transcribeSpeakingAudio(audioFilePath);
  }
}
