import 'package:flutter/material.dart';
import '../../domain/entities/grammar_topic.dart';
import '../providers/grammar_provider.dart';
import '../widgets/evaluation_result_card.dart';
import '../widgets/grammar_error_widget.dart';

class GrammarExerciseScreen extends StatefulWidget {
  final GrammarTopic? topic;
  final String? initialSentence;
  final GrammarProvider? provider;

  const GrammarExerciseScreen({
    super.key,
    this.topic,
    this.initialSentence,
    this.provider,
  });

  @override
  State<GrammarExerciseScreen> createState() => _GrammarExerciseScreenState();
}

class _GrammarExerciseScreenState extends State<GrammarExerciseScreen> {
  late GrammarProvider _provider;
  final TextEditingController _sentenceController = TextEditingController();
  final TextEditingController _targetWordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? GrammarProvider();
    _provider.addListener(_onProviderChange);
    if (widget.initialSentence != null && widget.initialSentence!.isNotEmpty) {
      _sentenceController.text = widget.initialSentence!;
    }
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    _sentenceController.dispose();
    _targetWordController.dispose();
    super.dispose();
  }

  void _evaluateSentence() async {
    final text = _sentenceController.text.trim();
    if (text.isEmpty) return;
    await _provider.evaluateSentence(
      sentence: text,
      targetWord: _targetWordController.text.trim(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final evaluation = _provider.currentEvaluation;
    final isEvaluating = _provider.isEvaluating;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.topic?.title ?? 'Grammar Exercise Editor',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter Sentence to Evaluate',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _sentenceController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'e.g., She don\'t like playing tennis.',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _targetWordController,
              decoration: InputDecoration(
                hintText: 'Target word/phrase (optional, e.g., don\'t)',
                labelText: 'Target Word',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isEvaluating ? null : _evaluateSentence,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: isEvaluating
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Check Grammar with AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_provider.errorMessage != null)
              GrammarErrorWidget(
                errorMessage: _provider.errorMessage!,
                onRetry: _evaluateSentence,
              ),
            if (evaluation != null) EvaluationResultCard(evaluation: evaluation),
          ],
        ),
      ),
    );
  }
}
