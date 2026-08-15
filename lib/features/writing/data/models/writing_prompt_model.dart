import '../../domain/entities/writing_prompt.dart';

class WritingPromptModel {
  final String id;
  final String taskType;
  final String topic;
  final String title;
  final String promptText;
  final int minWordCount;
  final String difficulty;

  WritingPromptModel({
    required this.id,
    required this.taskType,
    required this.topic,
    required this.title,
    required this.promptText,
    required this.minWordCount,
    required this.difficulty,
  });

  factory WritingPromptModel.fromJson(Map<String, dynamic> json) {
    final rawTaskType = json['task_type'] ?? json['taskType'] ?? 'task2';
    final normalizedTask = rawTaskType.toString().contains('1') ? 'task1' : 'task2';

    return WritingPromptModel(
      id: json['id']?.toString() ?? '',
      taskType: normalizedTask,
      topic: json['topic']?.toString() ?? 'General',
      title: json['title']?.toString() ?? 'Writing Prompt',
      promptText: (json['prompt_text'] ?? json['prompt'] ?? '').toString(),
      minWordCount:
          (json['min_word_count'] ?? json['suggested_word_count'] as num?)
              ?.toInt() ??
          (normalizedTask == 'task1' ? 150 : 250),
      difficulty: json['difficulty']?.toString() ?? 'Intermediate',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_type': taskType,
      'topic': topic,
      'title': title,
      'prompt_text': promptText,
      'min_word_count': minWordCount,
      'difficulty': difficulty,
    };
  }

  WritingPrompt toEntity() {
    return WritingPrompt(
      id: id,
      taskType: taskType,
      topic: topic,
      title: title,
      promptText: promptText,
      minWordCount: minWordCount,
      difficulty: difficulty,
    );
  }

  factory WritingPromptModel.fromEntity(WritingPrompt entity) {
    return WritingPromptModel(
      id: entity.id,
      taskType: entity.taskType,
      topic: entity.topic,
      title: entity.title,
      promptText: entity.promptText,
      minWordCount: entity.minWordCount,
      difficulty: entity.difficulty,
    );
  }
}
