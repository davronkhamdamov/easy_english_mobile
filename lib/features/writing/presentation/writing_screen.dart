import 'package:flutter/material.dart';
import '../data/writing_evaluation_service.dart';

/// Writing Task 1 & Task 2 Practice Screen with AI Evaluation Feedback Card.
class WritingScreen extends StatefulWidget {
  const WritingScreen({Key? key}) : super(key: key);

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  int _selectedTask = 2; // Task 1 or Task 2
  final TextEditingController _essayController = TextEditingController();
  bool _isEvaluating = false;
  Map<String, dynamic>? _aiEvaluationResult;

  final String _task2Prompt =
      'Some people believe that university education should be free for everyone, while others think students should pay. Discuss both views and give your opinion.';

  void _submitForAIEvaluation() async {
    if (_essayController.text.trim().isEmpty) return;

    setState(() {
      _isEvaluating = true;
    });

    try {
      final eval = await WritingEvaluationService().evaluateEssay(
        essayText: _essayController.text.trim(),
        prompt: _task2Prompt,
        taskType: 'task$_selectedTask',
      );

      if (mounted) {
        setState(() {
          _isEvaluating = false;
          _aiEvaluationResult = {
            'overall_band': eval.overallBandScore,
            'task_achievement': eval.taskAchievementScore,
            'coherence_cohesion': eval.coherenceCohesionScore,
            'lexical_resource': eval.lexicalResourceScore,
            'grammar_accuracy': eval.grammaticalRangeScore,
            'strengths': eval.strengths,
            'weaknesses': eval.weaknesses,
            'grammar_corrections': eval.grammarCorrections,
            'improved_sample': eval.improvedSample,
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isEvaluating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Essay evaluation failed: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Writing Practice'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Chip(
              label: Text(_selectedTask == 1 ? 'Task 1 (150 words)' : 'Task 2 (250 words)'),
              backgroundColor: theme.colorScheme.primaryContainer,
            ),
          )
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
                    selected: _selectedTask == 1,
                    onSelected: (val) => setState(() => _selectedTask = 1),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('Task 2 (Essay)'),
                    selected: _selectedTask == 2,
                    onSelected: (val) => setState(() => _selectedTask = 2),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Prompt Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Essay Prompt', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(_task2Prompt, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Essay Input Area
              TextField(
                controller: _essayController,
                maxLines: 10,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Type your essay response here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  counterText: '${_essayController.text.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).length} words',
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _isEvaluating ? null : _submitForAIEvaluation,
                  icon: _isEvaluating
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.auto_awesome),
                  label: Text(_isEvaluating ? 'AI Examiner Evaluating...' : 'Evaluate Essay with AI'),
                ),
              ),
              const SizedBox(height: 24),

              // AI Band Score Card
              if (_aiEvaluationResult != null) _buildAIEvaluationCard(theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAIEvaluationCard(ThemeData theme) {
    final eval = _aiEvaluationResult!;
    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('AI Evaluation Feedback', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const Divider(height: 24),

            // Strengths
            if ((eval['strengths'] as List).isNotEmpty) ...[
              Text('Strengths:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
              ...((eval['strengths'] as List).map((s) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(children: [const Icon(Icons.check_circle, size: 16, color: Colors.green), const SizedBox(width: 6), Expanded(child: Text(s.toString()))]),
                  ))),
              const SizedBox(height: 12),
            ],

            // Weaknesses
            if ((eval['weaknesses'] as List).isNotEmpty) ...[
              Text('Areas for Improvement:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
              ...((eval['weaknesses'] as List).map((w) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(children: [const Icon(Icons.warning, size: 16, color: Colors.orange), const SizedBox(width: 6), Expanded(child: Text(w.toString()))]),
                  ))),
              const SizedBox(height: 12),
            ],

            // Grammar Corrections
            if ((eval['grammar_corrections'] as List?)?.isNotEmpty ?? false) ...[
              Text('Grammar Corrections:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.redAccent)),
              ...(((eval['grammar_corrections'] as List)).map((g) => Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Row(children: [const Icon(Icons.build_circle, size: 16, color: Colors.redAccent), const SizedBox(width: 6), Expanded(child: Text(g.toString()))]),
                  ))),
              const SizedBox(height: 12),
            ],

            // Improved Sample Answer
            if ((eval['improved_sample'] as String?)?.isNotEmpty ?? false) ...[
              Text('Improved Model Sample:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  eval['improved_sample'].toString(),
                  style: theme.textTheme.bodyMedium?.copyWith(height: 1.4, fontStyle: FontStyle.italic),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
