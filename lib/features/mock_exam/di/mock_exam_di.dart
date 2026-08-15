import '../../../../core/network/api_client.dart';
import '../data/datasources/mock_exam_remote_datasource.dart';
import '../data/repositories/mock_exam_repository_impl.dart';
import '../domain/repositories/mock_exam_repository.dart';
import '../domain/usecases/get_available_mock_exams.dart';
import '../domain/usecases/get_exam_history.dart';
import '../domain/usecases/get_mock_exam_paper.dart';
import '../domain/usecases/submit_mock_exam.dart';
import '../presentation/providers/mock_exam_provider.dart';

class MockExamDI {
  static MockExamRemoteDatasource provideRemoteDatasource({ApiClient? apiClient}) {
    return MockExamRemoteDatasourceImpl(apiClient: apiClient ?? ApiClient());
  }

  static MockExamRepository provideRepository({MockExamRemoteDatasource? remoteDatasource}) {
    return MockExamRepositoryImpl(
      remoteDatasource: remoteDatasource ?? provideRemoteDatasource(),
    );
  }

  static GetAvailableMockExams provideGetAvailableExams({MockExamRepository? repository}) {
    return GetAvailableMockExams(repository ?? provideRepository());
  }

  static GetMockExamPaper provideGetMockExamPaper({MockExamRepository? repository}) {
    return GetMockExamPaper(repository ?? provideRepository());
  }

  static SubmitMockExam provideSubmitMockExam({MockExamRepository? repository}) {
    return SubmitMockExam(repository ?? provideRepository());
  }

  static GetExamHistoryUseCase provideGetExamHistory({MockExamRepository? repository}) {
    return GetExamHistoryUseCase(repository ?? provideRepository());
  }

  static MockExamProvider provideMockExamProvider({MockExamRepository? repository}) {
    final repo = repository ?? provideRepository();
    return MockExamProvider(
      repository: repo,
      getAvailableMockExams: provideGetAvailableExams(repository: repo),
      getMockExamPaper: provideGetMockExamPaper(repository: repo),
      submitMockExam: provideSubmitMockExam(repository: repo),
      getExamHistory: provideGetExamHistory(repository: repo),
    );
  }
}
