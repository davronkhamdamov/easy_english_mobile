import '../../../../core/network/api_client.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../datasources/mock_exam_remote_datasource.dart';

class MockExamRepositoryImpl implements MockExamRepository {
  final MockExamRemoteDatasource remoteDatasource;

  MockExamRepositoryImpl({
    MockExamRemoteDatasource? remoteDatasource,
  }) : remoteDatasource =
            remoteDatasource ?? MockExamRemoteDatasourceImpl(apiClient: ApiClient());

  @override
  Future<List<MockExamPaper>> getAvailableExams({ExamType? examType, String? type}) async {
    final remoteModels = await remoteDatasource.getAvailableExams(
      type: type,
      examType: examType,
    );
    return remoteModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MockExamPaper> getExamPaperById(String paperId) async {
    final remoteModel = await remoteDatasource.getExamPaperById(paperId);
    return remoteModel.toEntity();
  }

  @override
  Future<MockExamResult> submitExamResult(MockExamResult result) async {
    final submitted = await remoteDatasource.submitExamAnswers(
      paperId: result.examPaperId,
      userAnswers: result.userAnswers,
      timeSpentSeconds: result.timeTakenSeconds,
    );
    return submitted.toEntity();
  }

  @override
  Future<MockExamResult> submitExamAnswers({
    required String paperId,
    required Map<String, String> userAnswers,
    required int timeSpentSeconds,
  }) async {
    final submitted = await remoteDatasource.submitExamAnswers(
      paperId: paperId,
      userAnswers: userAnswers,
      timeSpentSeconds: timeSpentSeconds,
    );
    return submitted.toEntity();
  }

  @override
  Future<List<MockExamResult>> getExamResultsHistory({String? userId}) async {
    final remoteHistory = await remoteDatasource.getExamResultsHistory(
      userId: userId,
    );
    return remoteHistory.map((m) => m.toEntity()).toList();
  }
}
