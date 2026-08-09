class WritingPrompt {
  final String id;
  final int taskType; // 1 for Task 1, 2 for Task 2
  final String title;
  final String promptText;
  final int suggestedWordCount;

  const WritingPrompt({
    required this.id,
    required this.taskType,
    required this.title,
    required this.promptText,
    required this.suggestedWordCount,
  });

  static const defaultTask1Prompt = WritingPrompt(
    id: 'wp_task1_default',
    taskType: 1,
    title: 'Task 1 (Graph/Diagram)',
    promptText:
        'The chart below shows the percentage of households in different countries with internet access from 2010 to 2020. Summarise the information by selecting and reporting the main features, and make comparisons where relevant.',
    suggestedWordCount: 150,
  );

  static const defaultTask2Prompt = WritingPrompt(
    id: 'wp_task2_default',
    taskType: 2,
    title: 'Task 2 (Essay)',
    promptText:
        'Some people believe that university education should be free for everyone, while others think students should pay. Discuss both views and give your opinion.',
    suggestedWordCount: 250,
  );

  WritingPrompt copyWith({
    String? id,
    int? taskType,
    String? title,
    String? promptText,
    int? suggestedWordCount,
  }) {
    return WritingPrompt(
      id: id ?? this.id,
      taskType: taskType ?? this.taskType,
      title: title ?? this.title,
      promptText: promptText ?? this.promptText,
      suggestedWordCount: suggestedWordCount ?? this.suggestedWordCount,
    );
  }
}
