/// Exam mode type for IELTS (Academic vs General Training).
enum ExamType {
  academic,
  generalTraining;

  String get displayName {
    switch (this) {
      case ExamType.academic:
        return 'Academic';
      case ExamType.generalTraining:
        return 'General Training';
    }
  }

  static ExamType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'generaltraining':
      case 'general_training':
      case 'gt':
        return ExamType.generalTraining;
      case 'academic':
      default:
        return ExamType.academic;
    }
  }
}

/// Skill section types in IELTS.
enum MockSkill {
  reading,
  listening,
  writing,
  speaking,
  fullMock;

  String get displayName {
    switch (this) {
      case MockSkill.reading:
        return 'Reading';
      case MockSkill.listening:
        return 'Listening';
      case MockSkill.writing:
        return 'Writing';
      case MockSkill.speaking:
        return 'Speaking';
      case MockSkill.fullMock:
        return 'Full Mock Exam';
    }
  }

  static MockSkill fromString(String val) {
    switch (val.toLowerCase()) {
      case 'reading':
        return MockSkill.reading;
      case 'listening':
        return MockSkill.listening;
      case 'writing':
        return MockSkill.writing;
      case 'speaking':
        return MockSkill.speaking;
      case 'fullmock':
      case 'full_mock':
      default:
        return MockSkill.fullMock;
    }
  }
}

/// Supported question types for mock reading & listening.
enum QuestionType {
  multipleChoice,
  trueFalseNotGiven,
  sentenceCompletion;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalseNotGiven:
        return 'True / False / Not Given';
      case QuestionType.sentenceCompletion:
        return 'Sentence Completion';
    }
  }

  static QuestionType fromString(String val) {
    switch (val
        .toLowerCase()
        .replaceAll(' ', '')
        .replaceAll('/', '')
        .replaceAll('_', '')) {
      case 'multiplechoice':
      case 'mcq':
        return QuestionType.multipleChoice;
      case 'truefalsenotgiven':
      case 'tfng':
        return QuestionType.trueFalseNotGiven;
      case 'sentencecompletion':
      case 'fillin':
        return QuestionType.sentenceCompletion;
      default:
        return QuestionType.multipleChoice;
    }
  }
}
