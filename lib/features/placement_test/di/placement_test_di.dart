import '../data/datasources/placement_remote_datasource.dart';
import '../data/repositories/placement_repository_impl.dart';
import '../domain/repositories/placement_repository.dart';
import '../domain/usecases/fetch_placement_questions.dart';
import '../domain/usecases/submit_placement_test.dart';
import '../presentation/providers/placement_test_provider.dart';

class PlacementTestDI {
  static PlacementRemoteDatasource provideRemoteDatasource() {
    return PlacementRemoteDatasource();
  }

  static PlacementRepository provideRepository() {
    return PlacementRepositoryImpl(
      remoteDatasource: provideRemoteDatasource(),
    );
  }

  static FetchPlacementQuestionsUseCase provideFetchPlacementQuestionsUseCase() {
    return FetchPlacementQuestionsUseCase(provideRepository());
  }

  static SubmitPlacementTestUseCase provideSubmitPlacementTestUseCase() {
    return SubmitPlacementTestUseCase(provideRepository());
  }

  static PlacementTestProvider providePlacementTestProvider() {
    return PlacementTestProvider(
      fetchQuestionsUseCase: provideFetchPlacementQuestionsUseCase(),
      submitTestUseCase: provideSubmitPlacementTestUseCase(),
    );
  }
}
