
/// Supported IELTS question types appearing in Academic and General Training tests.
enum IeltsQuestionType {
  multipleChoiceSingle,
  multipleChoiceMulti,
  trueFalseNotGiven,
  yesNoNotGiven,
  fillInTheBlank,
  matchingHeadings,
  matchingFeatures,
  shortAnswer;

  String get displayName {
    switch (this) {
      case IeltsQuestionType.multipleChoiceSingle:
        return 'Multiple Choice';
      case IeltsQuestionType.multipleChoiceMulti:
        return 'Multiple Choice (Pick 2)';
      case IeltsQuestionType.trueFalseNotGiven:
        return 'True / False / Not Given';
      case IeltsQuestionType.yesNoNotGiven:
        return 'Yes / No / Not Given';
      case IeltsQuestionType.fillInTheBlank:
        return 'Sentence Completion';
      case IeltsQuestionType.matchingHeadings:
        return 'Matching Headings';
      case IeltsQuestionType.matchingFeatures:
        return 'Matching Features';
      case IeltsQuestionType.shortAnswer:
        return 'Short Answer';
    }
  }

  String get shortCode {
    switch (this) {
      case IeltsQuestionType.multipleChoiceSingle:
        return 'MCQ';
      case IeltsQuestionType.multipleChoiceMulti:
        return 'MULTI';
      case IeltsQuestionType.trueFalseNotGiven:
        return 'TFNG';
      case IeltsQuestionType.yesNoNotGiven:
        return 'YNNG';
      case IeltsQuestionType.fillInTheBlank:
        return 'BLANK';
      case IeltsQuestionType.matchingHeadings:
        return 'HEADINGS';
      case IeltsQuestionType.matchingFeatures:
        return 'MATCH';
      case IeltsQuestionType.shortAnswer:
        return 'SHORT';
    }
  }
}

/// Item for matching headings questions.
class HeadingMatchItem {
  final String paragraphId; // e.g. "Paragraph A"
  final String paragraphLabel; // e.g. "Section A"
  final String correctHeadingId; // e.g. "iv"

  const HeadingMatchItem({
    required this.paragraphId,
    required this.paragraphLabel,
    required this.correctHeadingId,
  });
}

/// Item for matching features/statements questions.
class FeatureMatchItem {
  final String statement;
  final String correctOptionKey; // e.g. "B"

  const FeatureMatchItem({
    required this.statement,
    required this.correctOptionKey,
  });
}

/// Question model supporting all IELTS test formats.
class IeltsTestQuestion {
  final String id;
  final String questionNumber; // e.g. "1", "2-3", "4", "5-7"
  final IeltsQuestionType type;
  final String prompt; // e.g. "Choose the correct letter, A, B, C or D."
  final String questionText;
  final List<String> options;
  final dynamic correctAnswer; // String, List<String>, or Map<String, String>
  final List<String> acceptableAnswers;
  final int? maxWords; // e.g. 2 for "NO MORE THAN TWO WORDS"
  final String? paragraphReference; // e.g. "Paragraph B"
  final String explanation;
  
  // For Matching Headings
  final List<HeadingMatchItem>? headingMatchItems;
  final Map<String, String>? headingsCatalog; // e.g. {"i": "...", "ii": "..."}

  // For Matching Features
  final List<FeatureMatchItem>? featureMatchItems;
  final Map<String, String>? featuresCatalog; // e.g. {"A": "Dr. Ronald Evans", "B": "..."}

  const IeltsTestQuestion({
    required this.id,
    required this.questionNumber,
    required this.type,
    required this.prompt,
    required this.questionText,
    this.options = const [],
    required this.correctAnswer,
    this.acceptableAnswers = const [],
    this.maxWords,
    this.paragraphReference,
    required this.explanation,
    this.headingMatchItems,
    this.headingsCatalog,
    this.featureMatchItems,
    this.featuresCatalog,
  });
}

/// Full article reading test model rendered with article components & rich markdown.
class IeltsArticleTestData {
  final String id;
  final String title;
  final String subtitle;
  final String category;
  final String cefrLevel;
  final String readTime;
  final int recommendedMinutes;
  final String markdownContent;
  final List<IeltsTestQuestion> questions;

  const IeltsArticleTestData({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.category,
    required this.cefrLevel,
    required this.readTime,
    required this.recommendedMinutes,
    required this.markdownContent,
    required this.questions,
  });

  int get totalQuestionsCount {
    int count = 0;
    for (final q in questions) {
      if (q.type == IeltsQuestionType.matchingHeadings && q.headingMatchItems != null) {
        count += q.headingMatchItems!.length;
      } else if (q.type == IeltsQuestionType.matchingFeatures && q.featureMatchItems != null) {
        count += q.featureMatchItems!.length;
      } else if (q.type == IeltsQuestionType.multipleChoiceMulti) {
        count += (q.correctAnswer as List).length;
      } else {
        count += 1;
      }
    }
    return count;
  }
}
