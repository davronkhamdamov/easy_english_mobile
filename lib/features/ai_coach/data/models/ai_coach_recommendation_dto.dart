import '../../domain/entities/ai_coach_recommendation.dart';

class AiCoachRecommendationDto {
  final double? predictedOverallBand;
  final double? targetBand;
  final List<String>? weaknessSummary;
  final List<String>? remediationTasks;
  final String? aiCoachNotes;

  AiCoachRecommendationDto({
    this.predictedOverallBand,
    this.targetBand,
    this.weaknessSummary,
    this.remediationTasks,
    this.aiCoachNotes,
  });

  factory AiCoachRecommendationDto.fromJson(Map<String, dynamic> json) {
    return AiCoachRecommendationDto(
      predictedOverallBand: (json['predicted_overall_band'] as num?)
          ?.toDouble(),
      targetBand: (json['target_band'] as num?)?.toDouble(),
      weaknessSummary: (json['weakness_summary'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      remediationTasks: (json['remediation_tasks'] as List?)
          ?.map((e) => e.toString())
          .toList(),
      aiCoachNotes: json['ai_coach_notes']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'predicted_overall_band': predictedOverallBand,
      'target_band': targetBand,
      'weakness_summary': weaknessSummary,
      'remediation_tasks': remediationTasks,
      'ai_coach_notes': aiCoachNotes,
    };
  }

  AiCoachRecommendation toDomain() {
    return AiCoachRecommendation(
      predictedOverallBand: predictedOverallBand ?? 7.0,
      targetBand: targetBand ?? 7.5,
      weaknessSummary:
          weaknessSummary ??
          const [
            'Task 2 Grammatical Range & Coherence',
            'Listening Section 3 Multiple Choice',
            'Academic C1 Synonyms',
          ],
      remediationTasks:
          remediationTasks ??
          const [
            'Complete 1 Sentence Builder exercise on "Conditionals"',
            'Review 5 C1 Academic Flashcards',
            'Listen to 1 Short Academic Segment',
          ],
      aiCoachNotes:
          aiCoachNotes ??
          'Your Speaking Part 1 fluency score rose to Band 7.5! Focus on Task 2 writing structure next.',
    );
  }
}
