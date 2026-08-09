class WritingSubmission {
  final String essayText;
  final String prompt;
  final String taskType;

  const WritingSubmission({
    required this.essayText,
    required this.prompt,
    this.taskType = 'task2',
  });
}
