import 'package:flutter/material.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';
import '../providers/mock_exam_provider.dart';
import '../widgets/audio_player_widget.dart';
import '../widgets/exam_timer_widget.dart';
import 'mock_result_screen.dart';

class ListeningPracticeScreen extends StatefulWidget {
  final MockExamPaper? paper;
  final MockExamSection? section;
  final ExamType examType;
  final String paperTitle;
  final MockExamProvider? provider;

  const ListeningPracticeScreen({
    super.key,
    this.paper,
    this.section,
    this.examType = ExamType.academic,
    this.paperTitle = 'Listening Section Practice',
    this.provider,
  });

  @override
  State<ListeningPracticeScreen> createState() => _ListeningPracticeScreenState();
}

class _ListeningPracticeScreenState extends State<ListeningPracticeScreen> {
  late MockExamProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? MockExamProvider();
    _provider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    super.dispose();
  }

  List<MockQuestion> get _questions {
    if (widget.paper != null && widget.paper!.questions.isNotEmpty) {
      return widget.paper!.questions;
    }
    if (widget.section != null && widget.section!.allQuestions.isNotEmpty) {
      return widget.section!.allQuestions;
    }
    return _provider.currentPaper?.questions ?? [];
  }

  String? get _audioUrl {
    if (widget.paper?.audioUrl != null && widget.paper!.audioUrl!.isNotEmpty) {
      return widget.paper!.audioUrl;
    }
    if (widget.section?.audioUrl != null && widget.section!.audioUrl!.isNotEmpty) {
      return widget.section!.audioUrl;
    }
    return _provider.currentPaper?.audioUrl;
  }

  void _submit() async {
    final paperId = widget.paper?.id ?? widget.section?.id ?? _provider.currentPaper?.id ?? 'exam_001';
    final result = await _provider.submitExam(paperId: paperId);
    if (!mounted) return;
    if (result != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => MockResultScreen(result: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final questions = _questions;
    final userAnswers = _provider.userAnswers;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.paper?.title ?? widget.paperTitle, style: const TextStyle(fontSize: 16)),
        actions: [
          ExamTimerWidget(remainingSeconds: _provider.state.remainingSeconds),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          AudioPlayerWidget(audioUrl: _audioUrl),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              itemCount: questions.length,
              itemBuilder: (context, idx) {
                final q = questions[idx];
                final selected = userAnswers[q.id];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: const EdgeInsets.all(14.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Q${q.questionNumber}. ${q.questionText}', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        if (q.options.isNotEmpty)
                          ...q.options.map((opt) => RadioListTile<String>(
                                title: Text(opt),
                                value: opt,
                                groupValue: selected,
                                onChanged: (val) {
                                  if (val != null) _provider.recordAnswer(q.id, val);
                                },
                              ))
                        else
                          TextField(
                            onChanged: (val) => _provider.recordAnswer(q.id, val),
                            decoration: const InputDecoration(
                              hintText: 'Type answer heard in audio...',
                              border: OutlineInputBorder(),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _provider.isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _provider.isSubmitting
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Submit Listening Answers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
