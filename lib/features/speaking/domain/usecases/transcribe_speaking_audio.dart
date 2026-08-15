import '../repositories/speaking_repository.dart';

class TranscribeSpeakingAudio {
  final SpeakingRepository _repository;

  TranscribeSpeakingAudio(this._repository);

  Future<String> call(String audioFilePath) {
    return _repository.transcribeSpeakingAudio(audioFilePath);
  }
}
