import 'package:flutter/material.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';
import '../providers/mock_exam_provider.dart';
import '../widgets/exam_timer_widget.dart';
import 'mock_result_screen.dart';

class ReadingPracticeScreen extends StatefulWidget {
  final MockExamPaper? paper;
  final MockExamSection? section;
  final ExamType examType;
  final String paperTitle;
  final MockExamProvider? provider;

  const ReadingPracticeScreen({
    super.key,
    this.paper,
    this.section,
    this.examType = ExamType.academic,
    this.paperTitle = 'Academic Reading Practice',
    this.provider,
  });

  @override
  State<ReadingPracticeScreen> createState() => _ReadingPracticeScreenState();
}

class _ReadingPracticeScreenState extends State<ReadingPracticeScreen> {
  late MockExamProvider _provider;
  int _activeTab = 0;

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

  String get _passageText {
    if (widget.paper?.passageText != null && widget.paper!.passageText!.isNotEmpty) {
      return widget.paper!.passageText!;
    }
    if (widget.section?.passages.isNotEmpty ?? false) {
      return widget.section!.passages.map((p) => '${p.title}\n\n${p.content}').join('\n\n---\n\n');
    }
    return _provider.currentPaper?.passageText ?? 'Passage text not available.';
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _activeTab = 0),
                  icon: Icon(Icons.menu_book, color: _activeTab == 0 ? theme.colorScheme.primary : theme.colorScheme.outline),
                  label: Text('Passage Text', style: TextStyle(fontWeight: _activeTab == 0 ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => setState(() => _activeTab = 1),
                  icon: Icon(Icons.help_outline, color: _activeTab == 1 ? theme.colorScheme.primary : theme.colorScheme.outline),
                  label: Text('Questions (${userAnswers.length}/${questions.length})', style: TextStyle(fontWeight: _activeTab == 1 ? FontWeight.bold : FontWeight.normal)),
                ),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _activeTab == 0
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: SelectableText(
                      _passageText,
                      style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
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
                              ...q.options.map((opt) => RadioListTile<String>(
                                    title: Text(opt),
                                    value: opt,
                                    groupValue: selected,
                                    onChanged: (val) {
                                      if (val != null) _provider.recordAnswer(q.id, val);
                                    },
                                  )),
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
                  : const Text('Submit Reading Test', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
