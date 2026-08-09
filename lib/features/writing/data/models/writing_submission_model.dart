import '../../domain/entities/writing_submission.dart';

class WritingSubmissionModel {
  final String essayText;
  final String prompt;
  final String taskType;

  WritingSubmissionModel({
    required this.essayText,
    required this.prompt,
    required this.taskType,
  });

  factory WritingSubmissionModel.fromJson(Map<String, dynamic> json) {
    return WritingSubmissionModel(
      essayText: json['essay_text'] ?? json['essayText'] ?? '',
      prompt: json['prompt'] ?? '',
      taskType: json['task_type'] ?? json['taskType'] ?? 'task2',
    );
  }

  Map<String, dynamic> toJson() {
    return {'essay_text': essayText, 'prompt': prompt, 'task_type': taskType};
  }

  WritingSubmission toEntity() {
    return WritingSubmission(
      essayText: essayText,
      prompt: prompt,
      taskType: taskType,
    );
  }

  factory WritingSubmissionModel.fromEntity(WritingSubmission entity) {
    return WritingSubmissionModel(
      essayText: entity.essayText,
      prompt: entity.prompt,
      taskType: entity.taskType,
    );
  }
}
