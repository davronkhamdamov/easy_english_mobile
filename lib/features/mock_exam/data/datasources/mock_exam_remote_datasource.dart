import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/exam_enums.dart';
import '../models/mock_exam_paper_model.dart';
import '../models/mock_exam_result_model.dart';

abstract class MockExamRemoteDatasource {
  Future<List<MockExamPaperModel>> getAvailableExams({ExamType? examType});
  Future<MockExamPaperModel> getExamPaperById(String paperId);
  Future<MockExamResultModel> submitExamResult(MockExamResultModel resultModel);
  Future<List<MockExamResultModel>> getExamResultsHistory({String? userId});
}

class MockExamRemoteDatasourceImpl implements MockExamRemoteDatasource {
  final ApiClient apiClient;

  MockExamRemoteDatasourceImpl({required this.apiClient});

  @override
  Future<List<MockExamPaperModel>> getAvailableExams({
    ExamType? examType,
  }) async {
    final path = examType != null
        ? '/api/v1/mock-exams?type=${examType.name}'
        : '/api/v1/mock-exams';
    final response = await apiClient.get(path);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map(
            (json) => MockExamPaperModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch mock exams: ${response.statusCode}');
    }
  }

  @override
  Future<MockExamPaperModel> getExamPaperById(String paperId) async {
    final response = await apiClient.get('/api/v1/mock-exams/$paperId');

    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return MockExamPaperModel.fromJson(jsonMap);
    } else {
      throw Exception(
        'Failed to fetch mock exam paper: ${response.statusCode}',
      );
    }
  }

  @override
  Future<MockExamResultModel> submitExamResult(
    MockExamResultModel resultModel,
  ) async {
    final response = await apiClient.post(
      '/api/v1/mock-exams/submit',
      resultModel.toJson(),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return MockExamResultModel.fromJson(jsonMap);
    } else {
      throw Exception('Failed to submit exam result: ${response.statusCode}');
    }
  }

  @override
  Future<List<MockExamResultModel>> getExamResultsHistory({
    String? userId,
  }) async {
    final path = userId != null
        ? '/api/v1/mock-exams/results?user_id=$userId'
        : '/api/v1/mock-exams/results';
    final response = await apiClient.get(path);

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body) as List<dynamic>;
      return jsonList
          .map(
            (json) =>
                MockExamResultModel.fromJson(json as Map<String, dynamic>),
          )
          .toList();
    } else {
      throw Exception('Failed to fetch exam history: ${response.statusCode}');
    }
  }
}
