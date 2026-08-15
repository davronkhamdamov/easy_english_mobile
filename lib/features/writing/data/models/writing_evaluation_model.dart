import '../../domain/entities/writing_evaluation.dart';
import 'grammar_correction_model.dart';
import 'vocabulary_suggestion_model.dart';

class WritingEvaluationModel {
  final String id;
  final double overallBandScore;
  final double taskAchievementScore;
  final String taskAchievementFeedback;
  final double coherenceScore;
  final String coherenceFeedback;
  final double lexicalScore;
  final String lexicalFeedback;
  final double grammarScore;
  final String grammarFeedback;
  final int wordCount;
  final List<GrammarCorrectionModel> grammarCorrections;
  final List<VocabularySuggestionModel> vocabularySuggestions;
  final String sampleAnswer;

  WritingEvaluationModel({
    required this.id,
    required this.overallBandScore,
    required this.taskAchievementScore,
    required this.taskAchievementFeedback,
    required this.coherenceScore,
    required this.coherenceFeedback,
    required this.lexicalScore,
    required this.lexicalFeedback,
    required this.grammarScore,
    required this.grammarFeedback,
    required this.wordCount,
    required this.grammarCorrections,
    required this.vocabularySuggestions,
    required this.sampleAnswer,
  });

  factory WritingEvaluationModel.fromJson(Map<String, dynamic> json) {
    double parseScore(dynamic val, [double defaultVal = 7.0]) {
      if (val is num) return val.toDouble();
      return double.tryParse(val?.toString() ?? '') ?? defaultVal;
    }

    final criteria = json['criteria'] as Map<String, dynamic>? ?? {};

    Map<String, dynamic> getSubMap(String key) {
      final item = criteria[key];
      if (item is Map<String, dynamic>) return item;
      return {};
    }

    final taMap = getSubMap('task_achievement');
    final ccMap = getSubMap('coherence_cohesion');
    final lrMap = getSubMap('lexical_resource');
    final grMap = getSubMap('grammatical_range');

    final correctionsRaw = json['grammar_corrections'] ?? json['grammar_errors'];
    List<GrammarCorrectionModel> parsedCorrections = [];
    if (correctionsRaw is List) {
      parsedCorrections = correctionsRaw.map((e) {
        if (e is Map<String, dynamic>) {
          return GrammarCorrectionModel.fromJson(e);
        } else {
          return GrammarCorrectionModel(
            original: e.toString(),
            corrected: '',
            explanation: 'Grammar suggestion.',
          );
        }
      }).toList();
    }

    final vocabRaw = json['improved_vocabulary'] ?? json['vocabulary_suggestions'];
    List<VocabularySuggestionModel> parsedVocab = [];
    if (vocabRaw is List) {
      parsedVocab = vocabRaw.map((e) {
        if (e is Map<String, dynamic>) {
          return VocabularySuggestionModel.fromJson(e);
        } else {
          return VocabularySuggestionModel(
            usedWord: e.toString(),
            suggestedAlternatives: [],
          );
        }
      }).toList();
    }

    return WritingEvaluationModel(
      id: json['id']?.toString() ?? 'eval_${DateTime.now().millisecondsSinceEpoch}',
      overallBandScore: parseScore(json['overall_band_score'] ?? json['overall_band']),
      taskAchievementScore: parseScore(
        taMap['score'] ?? json['task_achievement_score'] ?? json['task_achievement_band'],
      ),
      taskAchievementFeedback:
          (taMap['feedback'] ?? json['task_achievement_feedback'] ?? '').toString(),
      coherenceScore: parseScore(
        ccMap['score'] ?? json['coherence_cohesion_score'] ?? json['coherence_cohesion_band'],
      ),
      coherenceFeedback:
          (ccMap['feedback'] ?? json['coherence_cohesion_feedback'] ?? '').toString(),
      lexicalScore: parseScore(
        lrMap['score'] ?? json['lexical_resource_score'] ?? json['lexical_resource_band'],
      ),
      lexicalFeedback:
          (lrMap['feedback'] ?? json['lexical_resource_feedback'] ?? '').toString(),
      grammarScore: parseScore(
        grMap['score'] ?? json['grammatical_range_score'] ?? json['grammar_accuracy_band'],
      ),
      grammarFeedback:
          (grMap['feedback'] ?? json['grammatical_range_feedback'] ?? '').toString(),
      wordCount: (json['word_count'] as num?)?.toInt() ?? 0,
      grammarCorrections: parsedCorrections,
      vocabularySuggestions: parsedVocab,
      sampleAnswer:
          (json['sample_band_9_answer'] ?? json['improved_sample'] ?? json['model_answer'] ?? '')
              .toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'overall_band_score': overallBandScore,
      'criteria': {
        'task_achievement': {'score': taskAchievementScore, 'feedback': taskAchievementFeedback},
        'coherence_cohesion': {'score': coherenceScore, 'feedback': coherenceFeedback},
        'lexical_resource': {'score': lexicalScore, 'feedback': lexicalFeedback},
        'grammatical_range': {'score': grammarScore, 'feedback': grammarFeedback},
      },
      'word_count': wordCount,
      'grammar_corrections': grammarCorrections.map((e) => e.toJson()).toList(),
      'improved_vocabulary': vocabularySuggestions.map((e) => e.toJson()).toList(),
      'sample_band_9_answer': sampleAnswer,
    };
  }

  WritingEvaluation toEntity() {
    return WritingEvaluation(
      id: id,
      overallBandScore: overallBandScore,
      taskAchievement: WritingCriterionScore(
        score: taskAchievementScore,
        feedback: taskAchievementFeedback,
      ),
      coherenceCohesion: WritingCriterionScore(
        score: coherenceScore,
        feedback: coherenceFeedback,
      ),
      lexicalResource: WritingCriterionScore(
        score: lexicalScore,
        feedback: lexicalFeedback,
      ),
      grammaticalRange: WritingCriterionScore(
        score: grammarScore,
        feedback: grammarFeedback,
      ),
      wordCount: wordCount,
      grammarCorrections: grammarCorrections.map((e) => e.toEntity()).toList(),
      vocabularySuggestions: vocabularySuggestions.map((e) => e.toEntity()).toList(),
      sampleAnswer: sampleAnswer,
    );
  }
}
