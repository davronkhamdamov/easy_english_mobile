import 'package:flutter/material.dart';
import '../providers/writing_provider.dart';
import '../widgets/writing_editor.dart';
import '../widgets/writing_evaluation_widget.dart';
import '../widgets/writing_prompt_card.dart';

/// Writing Task 1 & Task 2 Practice Screen with AI Evaluation Feedback Card.
class WritingScreen extends StatefulWidget {
  final WritingProvider? provider;

  const WritingScreen({super.key, this.provider});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late final WritingProvider _provider;
  final TextEditingController _essayController = TextEditingController();

  final String _task2Prompt =
      'Some people believe that university education should be free for everyone, while others think students should pay. Discuss both views and give your opinion.';

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? WritingProvider();
    _provider.addListener(_onProviderStateChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderStateChanged);
    _essayController.dispose();
    super.dispose();
  }

  void _onProviderStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _submitForAIEvaluation() async {
    if (_essayController.text.trim().isEmpty) return;

    try {
      await _provider.evaluateEssay(
        essayText: _essayController.text.trim(),
        prompt: _task2Prompt,
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Essay evaluation failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedTask = _provider.selectedTask;
    final isEvaluating = _provider.isEvaluating;
    final evaluationResult = _provider.evaluationResult;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Writing Practice'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Chip(
              label: Text(
                selectedTask == 1 ? 'Task 1 (150 words)' : 'Task 2 (250 words)',
              ),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Switcher Tabs
              Row(
                children: [
                  ChoiceChip(
                    label: const Text('Task 1 (Graph/Diagram)'),
                    selected: selectedTask == 1,
                    onSelected: (val) => _provider.selectTask(1),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Task 2 (Essay)'),
                    selected: selectedTask == 2,
                    onSelected: (val) => _provider.selectTask(2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prompt Card
              WritingPromptCard(prompt: _task2Prompt),
              const SizedBox(height: 16),

              // Essay Input Area
              WritingEditor(
                controller: _essayController,
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: isEvaluating ? null : _submitForAIEvaluation,
                  icon: isEvaluating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    isEvaluating
                        ? 'AI Examiner Evaluating...'
                        : 'Evaluate Essay with AI',
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // AI Band Score Card
              if (evaluationResult != null)
                WritingEvaluationWidget(evaluation: evaluationResult),
            ],
          ),
        ),
      ),
    );
  }
}
