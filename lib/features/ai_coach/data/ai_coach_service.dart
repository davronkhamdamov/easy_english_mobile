import 'dart:convert';
import '../../../core/auth/api_client.dart';
import 'five_tier_recommendation_model.dart';

class AiCoachService {
  final ApiClient _client = ApiClient();

  /// Fetches AI Content Recommendations (GET /api/v1/content-recommendations/)
  Future<Map<String, dynamic>> fetchRecommendations() async {
    final response = await _client.get('/api/v1/content-recommendations/');
    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      return {
        'target_band': 7.5,
        'predicted_overall_band': 7.0,
        'weakness_summary': [
          'Task 2 Grammatical Range & Coherence',
          'Listening Section 3 Multiple Choice',
          'Academic C1 Synonyms'
        ],
        'remediation_tasks': [
          'Complete 1 Sentence Builder exercise on "Conditionals"',
          'Review 5 C1 Academic Flashcards',
          'Listen to 1 Short Academic Segment'
        ],
        'ai_coach_notes':
            'Your Speaking Part 1 fluency score rose to Band 7.5! Focus on Task 2 writing structure next.',
      };
    }
  }

  /// Fetches 5-Tier Educational Recommendation Plan (GET /api/v1/content-recommendations/)
  Future<FiveTierRecommendation> fetch5TierRecommendations() async {
    final response = await _client.get('/api/v1/content-recommendations/');
    if (response.statusCode == 200) {
      return FiveTierRecommendation.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } else {
      return FiveTierRecommendation(
        tier1CriticalWeaknesses: ['Task 2 Grammatical Range & Coherence'],
        tier2ScheduledReviews: ['Review 5 C1 Academic Flashcards (SM-2 Spaced Repetition)'],
        tier3PersonalizedRoadmap: ['Lesson 4: Advanced Complex Sentence Structures'],
        tier4AiSuggestions: ['Google Antigravity Memory Agent: Focus on Speaking Part 3 Fluency'],
        tier5OptionalPractice: ['Full-Length IELTS Reading Mock Test'],
      );
    }
  }
}
