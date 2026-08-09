/// Enum representing the IELTS skills evaluated in the Placement Test.
enum DiagnosticSkill {
  grammar,
  vocabulary,
  reading,
  listening;

  String get displayName {
    switch (this) {
      case DiagnosticSkill.grammar:
        return 'Grammar';
      case DiagnosticSkill.vocabulary:
        return 'Vocabulary';
      case DiagnosticSkill.reading:
        return 'Reading';
      case DiagnosticSkill.listening:
        return 'Listening';
    }
  }

  static DiagnosticSkill fromString(String val) {
    switch (val.toLowerCase()) {
      case 'grammar':
        return DiagnosticSkill.grammar;
      case 'vocabulary':
        return DiagnosticSkill.vocabulary;
      case 'reading':
        return DiagnosticSkill.reading;
      case 'listening':
        return DiagnosticSkill.listening;
      default:
        return DiagnosticSkill.grammar;
    }
  }
}
