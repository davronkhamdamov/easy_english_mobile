import '../data/datasources/ai_coach_remote_datasource.dart';
import '../data/repositories/ai_coach_repository_impl.dart';
import '../domain/repositories/ai_coach_repository.dart';
import '../domain/usecases/fetch_ai_recommendations_usecase.dart';
import '../domain/usecases/fetch_five_tier_plan_usecase.dart';
import '../domain/usecases/get_ai_coach_recommendations.dart';
import '../domain/usecases/get_five_tier_recommendations.dart';
import '../presentation/providers/ai_coach_provider.dart';

class AiCoachDI {
  static AiCoachRemoteDatasource provideRemoteDatasource() {
    return AiCoachRemoteDatasource();
  }

  static AiCoachRepository provideRepository() {
    return AiCoachRepositoryImpl(
      remoteDatasource: provideRemoteDatasource(),
    );
  }

  static FetchAiRecommendationsUseCase provideFetchAiRecommendationsUseCase() {
    return FetchAiRecommendationsUseCase(provideRepository());
  }

  static FetchFiveTierPlanUseCase provideFetchFiveTierPlanUseCase() {
    return FetchFiveTierPlanUseCase(provideRepository());
  }

  static GetAiCoachRecommendations provideGetAiCoachRecommendations() {
    return GetAiCoachRecommendations(repository: provideRepository());
  }

  static GetFiveTierRecommendations provideGetFiveTierRecommendations() {
    return GetFiveTierRecommendations(repository: provideRepository());
  }

  static AiCoachProvider provideAiCoachProvider() {
    return AiCoachProvider(
      fetchAiRecommendationsUseCase: provideFetchAiRecommendationsUseCase(),
      fetchFiveTierPlanUseCase: provideFetchFiveTierPlanUseCase(),
      getAiCoachRecommendations: provideGetAiCoachRecommendations(),
      getFiveTierRecommendations: provideGetFiveTierRecommendations(),
    );
  }
}
