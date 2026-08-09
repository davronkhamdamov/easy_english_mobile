import '../../data/repositories/placement_repository_impl.dart';
import '../entities/placement_result.dart';
import '../repositories/placement_repository.dart';

class SubmitPlacementTest {
  final PlacementRepository _repository;

  SubmitPlacementTest({PlacementRepository? repository})
    : _repository = repository ?? PlacementRepositoryImpl();

  Future<PlacementResult> call(Map<String, dynamic> answers) {
    return _repository.submitPlacementTest(answers);
  }
}
