import '../../domain/entities/writing_prompt.dart';

class WritingPromptModel {
  final String id;
  final int taskType;
  final String title;
  final String promptText;
  final int suggestedWordCount;

  WritingPromptModel({
    required this.id,
    required this.taskType,
    required this.title,
    required this.promptText,
    required this.suggestedWordCount,
  });

  factory WritingPromptModel.fromJson(Map<String, dynamic> json) {
    return WritingPromptModel(
      id: json['id']?.toString() ?? '',
      taskType: (json['task_type'] ?? json['taskType'] as num?)?.toInt() ?? 2,
      title: json['title']?.toString() ?? 'Writing Prompt',
      promptText: json['prompt_text'] ?? json['prompt'] ?? '',
      suggestedWordCount:
          (json['suggested_word_count'] ?? json['suggestedWordCount'] as num?)
              ?.toInt() ??
          250,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'task_type': taskType,
      'title': title,
      'prompt_text': promptText,
      'suggested_word_count': suggestedWordCount,
    };
  }

  WritingPrompt toEntity() {
    return WritingPrompt(
      id: id,
      taskType: taskType,
      title: title,
      promptText: promptText,
      suggestedWordCount: suggestedWordCount,
    );
  }

  factory WritingPromptModel.fromEntity(WritingPrompt entity) {
    return WritingPromptModel(
      id: entity.id,
      taskType: entity.taskType,
      title: entity.title,
      promptText: entity.promptText,
      suggestedWordCount: entity.suggestedWordCount,
    );
  }
}
