import 'package:flutter/material.dart';
import '../../../grammar/domain/usecases/evaluate_grammar.dart';
import '../providers/sentence_builder_provider.dart';
import '../widgets/evaluation_result_card.dart';
import '../widgets/sentence_input_field.dart';
import '../widgets/target_word_card.dart';

/// Interactive Sentence Builder Screen for Easy IELTS.
/// Students receive target vocabulary words and construct academic sentences.
class SentenceBuilderScreen extends StatefulWidget {
  final String? initialWord;
  final String? initialPrompt;
  final SentenceBuilderProvider? provider;
  final EvaluateGrammar? evaluateGrammar;

  const SentenceBuilderScreen({
    super.key,
    this.initialWord,
    this.initialPrompt,
    this.provider,
    this.evaluateGrammar,
  });

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  final TextEditingController _sentenceController = TextEditingController();
  late final SentenceBuilderProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider =
        widget.provider ??
        SentenceBuilderProvider(
          initialWord: widget.initialWord,
          initialPrompt: widget.initialPrompt,
          evaluateGrammar: widget.evaluateGrammar,
        );
    _provider.addListener(_onProviderChange);
  }

  void _onProviderChange() {
    if (!mounted) return;
    setState(() {});

    final error = _provider.errorMessage;
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Evaluation failed: $error'),
          backgroundColor: Colors.red,
        ),
      );
      _provider.clearError();
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    if (widget.provider == null) {
      _provider.dispose();
    }
    _sentenceController.dispose();
    super.dispose();
  }

  void _submitSentence() {
    _provider.submitSentence(_sentenceController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'Sentence Builder',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TargetWordCard(
                targetWord: _provider.targetWord,
                promptInstructions: _provider.promptInstructions,
              ),
              const SizedBox(height: 24),
              SentenceInputField(
                controller: _sentenceController,
                targetWord: _provider.targetWord,
                isEvaluating: _provider.isEvaluating,
                onSubmit: _submitSentence,
              ),
              if (_provider.evaluation != null) ...[
                const SizedBox(height: 28),
                EvaluationResultCard(evaluation: _provider.evaluation!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
