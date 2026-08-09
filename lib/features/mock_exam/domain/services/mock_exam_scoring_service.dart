import '../entities/exam_enums.dart';

/// Official IELTS Raw Score (0-40) to Band Score (1.0 - 9.0) Converter Utility.
class IeltsBandConverter {
  IeltsBandConverter._();

  /// Converts Academic Reading raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double academicReadingRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 39) return 9.0;
    if (score >= 37) return 8.5;
    if (score >= 35) return 8.0;
    if (score >= 33) return 7.5;
    if (score >= 30) return 7.0;
    if (score >= 27) return 6.5;
    if (score >= 23) return 6.0;
    if (score >= 19) return 5.5;
    if (score >= 15) return 5.0;
    if (score >= 13) return 4.5;
    if (score >= 10) return 4.0;
    if (score >= 8) return 3.5;
    if (score >= 6) return 3.0;
    if (score >= 4) return 2.5;
    if (score >= 2) return 2.0;
    return 1.0;
  }

  /// Converts General Training Reading raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double generalReadingRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 40) return 9.0;
    if (score >= 39) return 8.5;
    if (score >= 37) return 8.0;
    if (score >= 36) return 7.5;
    if (score >= 34) return 7.0;
    if (score >= 32) return 6.5;
    if (score >= 30) return 6.0;
    if (score >= 27) return 5.5;
    if (score >= 23) return 5.0;
    if (score >= 19) return 4.5;
    if (score >= 15) return 4.0;
    if (score >= 12) return 3.5;
    if (score >= 9) return 3.0;
    if (score >= 6) return 2.5;
    if (score >= 3) return 2.0;
    return 1.0;
  }

  /// Converts Listening raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double listeningRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 39) return 9.0;
    if (score >= 37) return 8.5;
    if (score >= 35) return 8.0;
    if (score >= 32) return 7.5;
    if (score >= 30) return 7.0;
    if (score >= 26) return 6.5;
    if (score >= 23) return 6.0;
    if (score >= 18) return 5.5;
    if (score >= 16) return 5.0;
    if (score >= 13) return 4.5;
    if (score >= 10) return 4.0;
    if (score >= 8) return 3.5;
    if (score >= 6) return 3.0;
    if (score >= 4) return 2.5;
    if (score >= 2) return 2.0;
    return 1.0;
  }

  /// Converts raw score to band based on section skill and exam type.
  static double calculateSectionBand({
    required MockSkill skill,
    required int rawScore,
    ExamType examType = ExamType.academic,
  }) {
    switch (skill) {
      case MockSkill.reading:
        return examType == ExamType.academic
            ? academicReadingRawToBand(rawScore)
            : generalReadingRawToBand(rawScore);
      case MockSkill.listening:
        return listeningRawToBand(rawScore);
      case MockSkill.writing:
      case MockSkill.speaking:
        // Raw score is treated directly as band if in range 1-9
        return (rawScore.toDouble() / 40.0 * 8.0 + 1.0).clamp(1.0, 9.0);
      case MockSkill.fullMock:
        return 6.5;
    }
  }

  /// Calculates overall band score according to official IELTS rounding rules.
  /// Average is rounded to nearest 0.5 (e.g., .25 -> .5, .75 -> next whole number).
  static double calculateOverallBand(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    final floorVal = avg.floorToDouble();
    final remainder = avg - floorVal;

    if (remainder < 0.25) {
      return floorVal;
    } else if (remainder < 0.75) {
      return floorVal + 0.5;
    } else {
      return floorVal + 1.0;
    }
  }
}
