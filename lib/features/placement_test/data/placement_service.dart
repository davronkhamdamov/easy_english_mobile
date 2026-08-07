import 'dart:convert';
import '../../../core/auth/api_client.dart';

class PlacementResult {
  final double initialBandScore;
  final double targetBandScore;
  final List<String> weakAreas;
  final String studyPlanSummary;

  PlacementResult({
    required this.initialBandScore,
    required this.targetBandScore,
    required this.weakAreas,
    required this.studyPlanSummary,
  });

  factory PlacementResult.fromJson(Map<String, dynamic> json) {
    return PlacementResult(
      initialBandScore: (json['initial_band_score'] as num?)?.toDouble() ?? 6.0,
      targetBandScore: (json['target_band_score'] as num?)?.toDouble() ?? 7.5,
      weakAreas: (json['weak_areas'] as List?)?.map((e) => e.toString()).toList() ?? [],
      studyPlanSummary: json['study_plan_summary']?.toString() ?? 'Initial study plan generated.',
    );
  }
}

class PlacementService {
  final ApiClient _client = ApiClient();

  /// Submits diagnostic placement test responses (POST /api/v1/placement/submit/)
  Future<PlacementResult> submitPlacementTest(Map<String, dynamic> answers) async {
    final response = await _client.post('/api/v1/placement/submit/', answers);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return PlacementResult.fromJson(json);
    } else {
      throw Exception('Failed to submit placement test (${response.statusCode}): ${response.body}');
    }
  }
}
