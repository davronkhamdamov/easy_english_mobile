import '../../domain/entities/achievement_motivation.dart';
import '../../domain/entities/learning_path.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;

  DashboardRepositoryImpl({DashboardRemoteDataSource? remoteDataSource})
    : _remoteDataSource = remoteDataSource ?? DashboardRemoteDataSourceImpl();

  @override
  Future<LearningPathResponse> getLearningPathToday() async {
    final model = await _remoteDataSource.fetchLearningPathToday();
    return model.toEntity();
  }

  @override
  Future<AchievementMotivationOverview> getMotivationOverview() async {
    final model = await _remoteDataSource.fetchMotivationOverview();
    return model.toEntity();
  }

  @override
  Future<bool> activateStreakFreeze() {
    return _remoteDataSource.activateStreakFreeze();
  }
}
