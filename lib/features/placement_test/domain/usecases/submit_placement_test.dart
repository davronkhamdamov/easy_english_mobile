import '../entities/placement_result.dart';
import '../repositories/placement_repository.dart';

class SubmitPlacementTestUseCase {
  final PlacementRepository _repository;

  SubmitPlacementTestUseCase(this._repository);

  Future<PlacementResult> call({
    required Map<String, int> answers,
    required int totalTimeSeconds,
  }) {
    return _repository.submitPlacementTest(
      answers: answers,
      totalTimeSeconds: totalTimeSeconds,
    );
  }
}

/// Alias for backwards compatibility
class SubmitPlacementTest {
  final PlacementRepository _repository;

  SubmitPlacementTest([PlacementRepository? repository])
      : _repository = repository ?? _DefaultPlacementRepo();

  Future<PlacementResult> call(
    Map<String, dynamic> answers, {
    int totalTimeSeconds = 450,
  }) {
    final typedAnswers = answers.map((k, v) => MapEntry(k, (v as num).toInt()));
    return _repository.submitPlacementTest(
      answers: typedAnswers,
      totalTimeSeconds: totalTimeSeconds,
    );
  }
}

class _DefaultPlacementRepo implements PlacementRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
