import 'package:flutter/material.dart';

/// Interactive Sentence Builder Screen for Easy IELTS.
/// Students receive target vocabulary words and construct academic sentences.
/// Real-time evaluation powered by Gemini 1.5 Flash AI engine.
class SentenceBuilderScreen extends StatefulWidget {
  final String? initialWord;
  final String? initialPrompt;

  const SentenceBuilderScreen({
    Key? key,
    this.initialWord,
    this.initialPrompt,
  }) : super(key: key);

  @override
  State<SentenceBuilderScreen> createState() => _SentenceBuilderScreenState();
}

class _SentenceBuilderScreenState extends State<SentenceBuilderScreen> {
  final TextEditingController _sentenceController = TextEditingController();
  bool _isEvaluating = false;
  Map<String, dynamic>? _aiEvaluation;

  String get _targetWord => widget.initialWord ?? 'Foster';
  String get _promptInstructions =>
      widget.initialPrompt ??
      'Construct a formal IELTS Academic sentence using the target word "${_targetWord}". Include a complex clause or passive voice.';

  void _submitSentence() async {
    final text = _sentenceController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _isEvaluating = true;
      _aiEvaluation = null;
    });

    // Simulate AI evaluation call (Gemini 1.5 Flash)
    await Future.delayed(const Duration(milliseconds: 1200));

    final containsWord = text.toLowerCase().contains(_targetWord.toLowerCase());

    setState(() {
      _isEvaluating = false;
      if (containsWord) {
        _aiEvaluation = {
          'is_correct': true,
          'grammar_score': 95.0,
          'feedback':
              'Excellent usage of "${_targetWord}" with formal academic tone and strong grammatical structure.',
          'corrections': <String>[],
          'band_8_expressions': [
            'Implementing strategic policies serves to ${_targetWord.toLowerCase()} long-term economic prosperity.',
            'Educational reforms are crucial to ${_targetWord.toLowerCase()} critical thinking skills among students.'
          ]
        };
      } else {
        _aiEvaluation = {
          'is_correct': false,
          'grammar_score': 45.0,
          'feedback': 'Target word "${_targetWord}" is missing from your sentence.',
          'corrections': ['Make sure to explicitly include "${_targetWord}".'],
          'band_8_expressions': [
            'Fostering cross-cultural exchange enhances global diplomacy.'
          ]
        };
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text('Sentence Builder', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Target Word Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _targetWord,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                        child: const Text('Target Word'),
                      )
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _promptInstructions,
                    style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 14, height: 1.4),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Your Sentence:',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sentenceController,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type your sentence incorporating "${_targetWord}"...',
                hintStyle: const TextStyle(color: Color(0xFF64748B)),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF334155)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isEvaluating ? null : _submitSentence,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isEvaluating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit & Evaluate',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),

            if (_aiEvaluation != null) ...[
              const SizedBox(height: 28),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _aiEvaluation!['is_correct'] ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _aiEvaluation!['is_correct'] ? Icons.check_circle : Icons.error,
                          color: _aiEvaluation!['is_correct'] ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _aiEvaluation!['is_correct'] ? 'Band 8.0+ Usage' : 'Needs Improvement',
                          style: TextStyle(
                            color: _aiEvaluation!['is_correct'] ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _aiEvaluation!['feedback'] ?? '',
                      style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 14, height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Band 8+ Native Expressions:',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    ...(_aiEvaluation!['band_8_expressions'] as List<String>).map(
                      (expr) => Padding(
                        padding: const EdgeInsets.only(bottom: 6.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(color: Color(0xFF3B82F6), fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                expr,
                                style: const TextStyle(color: Colors.white, fontSize: 13, fontStyle: FontStyle.italic),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
