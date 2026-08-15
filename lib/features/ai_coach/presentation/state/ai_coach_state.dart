import '../../domain/entities/ai_coach_recommendation.dart';
import '../../domain/entities/five_tier_recommendation.dart';

class AiCoachState {
  final bool isLoading;
  final AiCoachRecommendation? recommendations;
  final FiveTierRecommendation? fiveTierPlan;
  final int selectedTierIndex;
  final String? errorMessage;

  const AiCoachState({
    this.isLoading = false,
    this.recommendations,
    this.fiveTierPlan,
    this.selectedTierIndex = 0,
    this.errorMessage,
  });

  AiCoachState copyWith({
    bool? isLoading,
    AiCoachRecommendation? recommendations,
    FiveTierRecommendation? fiveTierPlan,
    int? selectedTierIndex,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AiCoachState(
      isLoading: isLoading ?? this.isLoading,
      recommendations: recommendations ?? this.recommendations,
      fiveTierPlan: fiveTierPlan ?? this.fiveTierPlan,
      selectedTierIndex: selectedTierIndex ?? this.selectedTierIndex,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}
