import 'package:flutter/foundation.dart';
import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';
import '../../domain/usecases/fetch_ai_recommendations_usecase.dart';
import '../../domain/usecases/fetch_five_tier_plan_usecase.dart';
import '../../domain/usecases/get_ai_coach_recommendations.dart';
import '../../domain/usecases/get_five_tier_recommendations.dart';
import '../state/ai_coach_state.dart';

class AiCoachProvider extends ChangeNotifier {
  final FetchAiRecommendationsUseCase? _fetchAiRecommendationsUseCase;
  final FetchFiveTierPlanUseCase? _fetchFiveTierPlanUseCase;
  final GetAiCoachRecommendations? _getAiCoachRecommendations;
  final GetFiveTierRecommendations? _getFiveTierRecommendations;

  AiCoachState _state = const AiCoachState();

  AiCoachProvider({
    FetchAiRecommendationsUseCase? fetchAiRecommendationsUseCase,
    FetchFiveTierPlanUseCase? fetchFiveTierPlanUseCase,
    GetAiCoachRecommendations? getAiCoachRecommendations,
    GetFiveTierRecommendations? getFiveTierRecommendations,
  })  : _fetchAiRecommendationsUseCase = fetchAiRecommendationsUseCase,
        _fetchFiveTierPlanUseCase = fetchFiveTierPlanUseCase,
        _getAiCoachRecommendations = getAiCoachRecommendations,
        _getFiveTierRecommendations = getFiveTierRecommendations;

  AiCoachState get state => _state;
  bool get isLoading => _state.isLoading;
  AiCoachRecommendation? get recommendation => _state.recommendations;
  AiCoachRecommendation? get recommendations => _state.recommendations;
  FiveTierRecommendation? get fiveTierPlan => _state.fiveTierPlan;
  FiveTierRecommendation? get fiveTierRecommendation => _state.fiveTierPlan;
  int get selectedTierIndex => _state.selectedTierIndex;
  String? get errorMessage => _state.errorMessage;

  void selectTier(int index) {
    if (index >= 0 && index < 5) {
      _state = _state.copyWith(selectedTierIndex: index);
      notifyListeners();
    }
  }

  Future<void> fetchRecommendations() async {
    _state = _state.copyWith(isLoading: true, clearError: true);
    notifyListeners();

    try {
      final rec = _fetchAiRecommendationsUseCase != null
          ? await _fetchAiRecommendationsUseCase()
          : await _getAiCoachRecommendations!();

      FiveTierRecommendation? plan = rec.fiveTierPlan;
      if (_fetchFiveTierPlanUseCase != null) {
        try {
          plan = await _fetchFiveTierPlanUseCase();
        } catch (_) {}
      } else if (_getFiveTierRecommendations != null) {
        try {
          plan = await _getFiveTierRecommendations();
        } catch (_) {}
      }

      _state = _state.copyWith(
        isLoading: false,
        recommendations: rec,
        fiveTierPlan: plan,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      notifyListeners();
    }
  }

  Future<void> loadRecommendations() async {
    await fetchRecommendations();
  }

  Future<void> loadFiveTierRecommendations() async {
    if (_fetchFiveTierPlanUseCase != null || _getFiveTierRecommendations != null) {
      try {
        final plan = _fetchFiveTierPlanUseCase != null
            ? await _fetchFiveTierPlanUseCase()
            : await _getFiveTierRecommendations!();
        _state = _state.copyWith(fiveTierPlan: plan);
        notifyListeners();
      } catch (e) {
        _state = _state.copyWith(
          errorMessage: e.toString().replaceAll('Exception: ', ''),
        );
        notifyListeners();
      }
    }
  }

  Future<void> refresh() async {
    await fetchRecommendations();
  }
}
