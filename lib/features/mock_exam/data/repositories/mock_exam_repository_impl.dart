import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_result.dart';
import '../../domain/repositories/mock_exam_repository.dart';
import '../datasources/mock_exam_local_datasource.dart';
import '../datasources/mock_exam_remote_datasource.dart';
import '../models/mock_exam_result_model.dart';

class MockExamRepositoryImpl implements MockExamRepository {
  final MockExamRemoteDatasource? remoteDatasource;
  final MockExamLocalDatasource localDatasource;

  MockExamRepositoryImpl({
    this.remoteDatasource,
    MockExamLocalDatasource? localDatasource,
  }) : localDatasource = localDatasource ?? MockExamLocalDatasourceImpl();

  @override
  Future<List<MockExamPaper>> getAvailableExams({ExamType? examType}) async {
    if (remoteDatasource != null) {
      try {
        final remoteModels = await remoteDatasource!.getAvailableExams(
          examType: examType,
        );
        return remoteModels.map((m) => m.toEntity()).toList();
      } catch (_) {
        // Fallback to local datasource if remote fails
      }
    }
    final localModels = await localDatasource.getAvailableExams(
      examType: examType,
    );
    return localModels.map((m) => m.toEntity()).toList();
  }

  @override
  Future<MockExamPaper> getExamPaperById(String paperId) async {
    if (remoteDatasource != null) {
      try {
        final remoteModel = await remoteDatasource!.getExamPaperById(paperId);
        return remoteModel.toEntity();
      } catch (_) {
        // Fallback to local datasource
      }
    }
    final localModel = await localDatasource.getExamPaperById(paperId);
    return localModel.toEntity();
  }

  @override
  Future<MockExamResult> submitExamResult(MockExamResult result) async {
    if (remoteDatasource != null) {
      try {
        final resultModel = MockExamResultModel.fromEntity(result);
        final submitted = await remoteDatasource!.submitExamResult(resultModel);
        return submitted.toEntity();
      } catch (_) {
        // Return original local result on network failure
      }
    }
    return result;
  }

  @override
  Future<List<MockExamResult>> getExamResultsHistory({String? userId}) async {
    if (remoteDatasource != null) {
      try {
        final remoteHistory = await remoteDatasource!.getExamResultsHistory(
          userId: userId,
        );
        return remoteHistory.map((m) => m.toEntity()).toList();
      } catch (_) {}
    }
    return [];
  }
}
