import 'diagnostic_session.dart';
import 'diagnostic_skill.dart';

/// Domain entity representing calculated IELTS Estimated Band Score result.
class EstimatedBandScore {
  final double overallBand;
  final double grammarBand;
  final double vocabularyBand;
  final double readingBand;
  final double listeningBand;
  final String cefrEquivalent;
  final Map<String, double> skillBreakdown;
  final List<String> strengths;
  final List<String> weaknesses;

  const EstimatedBandScore({
    required this.overallBand,
    required this.grammarBand,
    required this.vocabularyBand,
    required this.readingBand,
    required this.listeningBand,
    required this.cefrEquivalent,
    required this.skillBreakdown,
    required this.strengths,
    required this.weaknesses,
  });

  /// Calculates band score based on correctness per skill category.
  factory EstimatedBandScore.fromSession(DiagnosticSession session) {
    final Map<DiagnosticSkill, int> correctCounts = {
      DiagnosticSkill.grammar: 0,
      DiagnosticSkill.vocabulary: 0,
      DiagnosticSkill.reading: 0,
      DiagnosticSkill.listening: 0,
    };

    final Map<DiagnosticSkill, int> totalCounts = {
      DiagnosticSkill.grammar: 0,
      DiagnosticSkill.vocabulary: 0,
      DiagnosticSkill.reading: 0,
      DiagnosticSkill.listening: 0,
    };

    for (final q in session.questions) {
      totalCounts[q.skill] = (totalCounts[q.skill] ?? 0) + 1;
      if (session.userAnswers[q.id] == q.correctOptionIndex) {
        correctCounts[q.skill] = (correctCounts[q.skill] ?? 0) + 1;
      }
    }

    double calcBand(DiagnosticSkill skill) {
      final total = totalCounts[skill] ?? 0;
      if (total == 0) return 5.5;
      final ratio = (correctCounts[skill] ?? 0) / total;
      // Convert ratio to IELTS Band (range 4.0 - 9.0)
      final rawBand = 4.0 + (ratio * 5.0);
      // Round to nearest 0.5
      return (rawBand * 2).round() / 2.0;
    }

    final grammarBand = calcBand(DiagnosticSkill.grammar);
    final vocabBand = calcBand(DiagnosticSkill.vocabulary);
    final readingBand = calcBand(DiagnosticSkill.reading);
    final listeningBand = calcBand(DiagnosticSkill.listening);

    final rawOverall =
        (grammarBand + vocabBand + readingBand + listeningBand) / 4.0;
    final overallBand = (rawOverall * 2).round() / 2.0;

    String cefr;
    if (overallBand >= 8.0) {
      cefr = 'C2 Expert';
    } else if (overallBand >= 7.0) {
      cefr = 'C1 Advanced';
    } else if (overallBand >= 6.0) {
      cefr = 'B2 Upper Intermediate';
    } else if (overallBand >= 5.0) {
      cefr = 'B1 Intermediate';
    } else {
      cefr = 'A2 Elementary';
    }

    final List<String> strengths = [];
    final List<String> weaknesses = [];

    if (grammarBand >= 7.0) {
      strengths.add('Strong grammatical accuracy and sentence structure.');
    } else {
      weaknesses.add('Complex sentence structure and article usage.');
    }

    if (vocabBand >= 7.0) {
      strengths.add('Broad academic vocabulary and precise collocations.');
    } else {
      weaknesses.add('CEFR B2/C1 academic vocabulary range.');
    }

    if (readingBand >= 7.0) {
      strengths.add('Excellent passage scanning and inference speed.');
    } else {
      weaknesses.add('True/False/Not Given statement differentiation.');
    }

    if (listeningBand >= 7.0) {
      strengths.add('High comprehension of connected speech and accents.');
    } else {
      weaknesses.add('Distractor identification in fast-paced dialogues.');
    }

    return EstimatedBandScore(
      overallBand: overallBand,
      grammarBand: grammarBand,
      vocabularyBand: vocabBand,
      readingBand: readingBand,
      listeningBand: listeningBand,
      cefrEquivalent: cefr,
      skillBreakdown: {
        'Grammar': grammarBand,
        'Vocabulary': vocabBand,
        'Reading': readingBand,
        'Listening': listeningBand,
      },
      strengths: strengths.isEmpty
          ? ['Consistent effort across basic questions.']
          : strengths,
      weaknesses: weaknesses.isEmpty
          ? ['Targeted vocabulary expansion for Band 8+']
          : weaknesses,
    );
  }
}
