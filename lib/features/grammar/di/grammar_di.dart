import '../../../../core/network/api_client.dart';
import '../data/datasources/grammar_remote_datasource.dart';
import '../data/repositories/grammar_repository_impl.dart';
import '../domain/repositories/grammar_repository.dart';
import '../domain/usecases/evaluate_grammar.dart';
import '../domain/usecases/get_grammar_mistakes.dart';
import '../domain/usecases/get_grammar_roadmap.dart';
import '../presentation/providers/grammar_provider.dart';

class GrammarDI {
  static GrammarRemoteDataSource provideRemoteDataSource({ApiClient? apiClient}) {
    return GrammarRemoteDataSourceImpl(client: apiClient ?? ApiClient());
  }

  static GrammarRepository provideRepository({GrammarRemoteDataSource? remoteDataSource}) {
    return GrammarRepositoryImpl(
      remoteDataSource: remoteDataSource ?? provideRemoteDataSource(),
    );
  }

  static FetchGrammarRoadmapUseCase provideGetGrammarRoadmap({GrammarRepository? repository}) {
    return GetGrammarRoadmap(repository: repository ?? provideRepository());
  }

  static FetchGrammarMistakesUseCase provideGetGrammarMistakes({GrammarRepository? repository}) {
    return GetGrammarMistakes(repository: repository ?? provideRepository());
  }

  static EvaluateGrammarSentenceUseCase provideEvaluateGrammar({GrammarRepository? repository}) {
    return EvaluateGrammar(repository: repository ?? provideRepository());
  }

  static GrammarProvider provideGrammarProvider({GrammarRepository? repository}) {
    final repo = repository ?? provideRepository();
    return GrammarProvider(
      repository: repo,
      getGrammarRoadmap: provideGetGrammarRoadmap(repository: repo),
      getGrammarMistakes: provideGetGrammarMistakes(repository: repo),
      evaluateGrammar: provideEvaluateGrammar(repository: repo),
    );
  }
}
