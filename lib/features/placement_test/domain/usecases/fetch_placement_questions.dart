import '../../data/repositories/placement_repository_impl.dart';
import '../entities/placement_question.dart';
import '../repositories/placement_repository.dart';

class FetchPlacementQuestionsUseCase {
  final PlacementRepository _repository;

  FetchPlacementQuestionsUseCase([PlacementRepository? repository])
      : _repository = repository ?? PlacementRepositoryImpl();

  Future<List<PlacementQuestion>> call() {
    return _repository.fetchPlacementQuestions();
  }
}

/// Alias for backwards compatibility
typedef FetchPlacementQuestions = FetchPlacementQuestionsUseCase;
