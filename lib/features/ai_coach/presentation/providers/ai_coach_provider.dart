import 'package:flutter/foundation.dart';
import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';
import '../../domain/usecases/get_ai_coach_recommendations.dart';
import '../../domain/usecases/get_five_tier_recommendations.dart';

class AiCoachProvider extends ChangeNotifier {
  final GetAiCoachRecommendations _getAiCoachRecommendations;
  final GetFiveTierRecommendations _getFiveTierRecommendations;

  AiCoachRecommendation? _recommendation;
  FiveTierRecommendation? _fiveTierRecommendation;
  bool _isLoading = false;
  String? _errorMessage;

  AiCoachProvider({
    GetAiCoachRecommendations? getAiCoachRecommendations,
    GetFiveTierRecommendations? getFiveTierRecommendations,
  }) : _getAiCoachRecommendations =
           getAiCoachRecommendations ?? GetAiCoachRecommendations(),
       _getFiveTierRecommendations =
           getFiveTierRecommendations ?? GetFiveTierRecommendations();

  AiCoachRecommendation? get recommendation => _recommendation;
  FiveTierRecommendation? get fiveTierRecommendation => _fiveTierRecommendation;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _recommendation = await _getAiCoachRecommendations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFiveTierRecommendations() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _fiveTierRecommendation = await _getFiveTierRecommendations();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
