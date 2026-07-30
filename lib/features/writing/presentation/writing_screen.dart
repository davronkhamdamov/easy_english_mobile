import 'package:flutter/material.dart';

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

    // Simulate AI GPT-4o Evaluation latency
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      _isEvaluating = false;
      _aiEvaluationResult = {
        'overall_band': 7.0,
        'task_achievement': 7.5,
        'coherence_cohesion': 6.5,
        'lexical_resource': 7.0,
        'grammar_accuracy': 7.0,
        'strengths': [
          'Well-developed body paragraphs with clear topic sentences.',
          'Effective use of academic connectors (e.g. Furthermore, Consequently).'
        ],
        'weaknesses': [
          'Minor repetition of vocabulary in the conclusion.',
          'Slight punctuation inaccuracy in paragraph 2.'
        ],
        'improved_sample':
            'While higher education represents a significant financial investment, providing universal tuition-free access fosters economic mobility and innovation...'
      };
    });
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
      body: SingleChildScrollView(
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
    );
  }

  Widget _buildAIEvaluationCard(ThemeData theme) {
    final eval = _aiEvaluationResult!;
    return Card(
      color: theme.colorScheme.surfaceVariant,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('AI Examiner Evaluation', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.amber,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Band ${eval['overall_band']}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Criteria Scores Grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _scoreBadge('Task Achievement', eval['task_achievement']),
                _scoreBadge('Coherence & Cohesion', eval['coherence_cohesion']),
                _scoreBadge('Lexical Resource', eval['lexical_resource']),
                _scoreBadge('Grammatical Accuracy', eval['grammar_accuracy']),
              ],
            ),
            const SizedBox(height: 16),

            // Strengths
            Text('Strengths:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.green)),
            ...((eval['strengths'] as List).map((s) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(children: [const Icon(Icons.check_circle, size: 16, color: Colors.green), const SizedBox(width: 6), Expanded(child: Text(s))]),
                ))),

            const SizedBox(height: 12),
            // Weaknesses
            Text('Areas for Improvement:', style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.orange)),
            ...((eval['weaknesses'] as List).map((w) => Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Row(children: [const Icon(Icons.warning, size: 16, color: Colors.orange), const SizedBox(width: 6), Expanded(child: Text(w))]),
                ))),
          ],
        ),
      ),
    );
  }

  Widget _scoreBadge(String label, double score) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text('$label: $score', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
    );
  }
}
