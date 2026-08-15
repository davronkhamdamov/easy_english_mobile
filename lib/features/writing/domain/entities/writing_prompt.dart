class WritingPrompt {
  final String id;
  final String taskType; // 'task1' or 'task2'
  final String topic;
  final String title;
  final String promptText;
  final int minWordCount;
  final String difficulty;

  const WritingPrompt({
    required this.id,
    required this.taskType,
    required this.topic,
    required this.title,
    required this.promptText,
    required this.minWordCount,
    required this.difficulty,
  });

  int get suggestedWordCount => minWordCount;
  int get taskTypeInt => taskType.toLowerCase().contains('1') ? 1 : 2;

  WritingPrompt copyWith({
    String? id,
    String? taskType,
    String? topic,
    String? title,
    String? promptText,
    int? minWordCount,
    String? difficulty,
  }) {
    return WritingPrompt(
      id: id ?? this.id,
      taskType: taskType ?? this.taskType,
      topic: topic ?? this.topic,
      title: title ?? this.title,
      promptText: promptText ?? this.promptText,
      minWordCount: minWordCount ?? this.minWordCount,
      difficulty: difficulty ?? this.difficulty,
    );
  }
}
