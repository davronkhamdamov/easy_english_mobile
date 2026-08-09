import 'dart:convert';
import '../../../../core/network/api_client.dart';
import '../models/ai_coach_recommendation_dto.dart';
import '../models/five_tier_recommendation_dto.dart';

class AiCoachRemoteDatasource {
  final ApiClient _client;

  AiCoachRemoteDatasource({ApiClient? client})
    : _client = client ?? ApiClient();

  /// Fetches AI Content Recommendations (GET /api/v1/content-recommendations/)
  Future<AiCoachRecommendationDto?> fetchRecommendations() async {
    final response = await _client.get('/api/v1/content-recommendations/');
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return AiCoachRecommendationDto.fromJson(jsonMap);
    }
    return null;
  }

  /// Fetches 5-Tier Educational Recommendation Plan (GET /api/v1/content-recommendations/)
  Future<FiveTierRecommendationDto?> fetch5TierRecommendations() async {
    final response = await _client.get('/api/v1/content-recommendations/');
    if (response.statusCode == 200) {
      final jsonMap = jsonDecode(response.body) as Map<String, dynamic>;
      return FiveTierRecommendationDto.fromJson(jsonMap);
    }
    return null;
  }
}
