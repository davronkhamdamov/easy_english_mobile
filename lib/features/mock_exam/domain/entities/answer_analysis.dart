class AnswerAnalysis {
  final String questionId;
  final String userAnswer;
  final String correctAnswer;
  final bool isCorrect;
  final String explanation;

  const AnswerAnalysis({
    required this.questionId,
    required this.userAnswer,
    required this.correctAnswer,
    required this.isCorrect,
    required this.explanation,
  });

  factory AnswerAnalysis.fromJson(Map<String, dynamic> json) {
    return AnswerAnalysis(
      questionId: json['question_id'] as String? ?? json['questionId'] as String? ?? '',
      userAnswer: json['user_answer'] as String? ?? json['userAnswer'] as String? ?? '',
      correctAnswer: json['correct_answer'] as String? ?? json['correctAnswer'] as String? ?? '',
      isCorrect: json['is_correct'] as bool? ?? json['isCorrect'] as bool? ?? false,
      explanation: json['explanation'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'user_answer': userAnswer,
      'correct_answer': correctAnswer,
      'is_correct': isCorrect,
      'explanation': explanation,
    };
  }
}
