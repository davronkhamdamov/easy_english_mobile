import '../../data/repositories/placement_repository_impl.dart';
import '../entities/placement_question.dart';
import '../repositories/placement_repository.dart';

class FetchPlacementQuestions {
  final PlacementRepository _repository;

  FetchPlacementQuestions({PlacementRepository? repository})
    : _repository = repository ?? PlacementRepositoryImpl();

  Future<List<PlacementQuestion>> call() {
    return _repository.fetchPlacementQuestions();
  }
}
