import '../data/datasources/speaking_remote_datasource.dart';
import '../data/repositories/speaking_repository_impl.dart';
import '../domain/repositories/speaking_repository.dart';
import '../domain/usecases/evaluate_speaking.dart';
import '../domain/usecases/fetch_speaking_prompts.dart';
import '../domain/usecases/transcribe_speaking_audio.dart';
import '../presentation/providers/speaking_provider.dart';

class SpeakingDI {
  static SpeakingRemoteDatasource provideRemoteDatasource() {
    return SpeakingRemoteDatasource();
  }

  static SpeakingRepository provideRepository() {
    return SpeakingRepositoryImpl(
      remoteDatasource: provideRemoteDatasource(),
    );
  }

  static FetchSpeakingPrompts provideFetchSpeakingPrompts() {
    return FetchSpeakingPrompts(provideRepository());
  }

  static TranscribeSpeakingAudio provideTranscribeSpeakingAudio() {
    return TranscribeSpeakingAudio(provideRepository());
  }

  static EvaluateSpeaking provideEvaluateSpeaking() {
    return EvaluateSpeaking(provideRepository());
  }

  static SpeakingProvider provideSpeakingProvider() {
    return SpeakingProvider(
      fetchSpeakingPrompts: provideFetchSpeakingPrompts(),
      transcribeSpeakingAudio: provideTranscribeSpeakingAudio(),
      evaluateSpeaking: provideEvaluateSpeaking(),
    );
  }
}
