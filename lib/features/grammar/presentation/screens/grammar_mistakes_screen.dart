import 'package:flutter/material.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../providers/grammar_provider.dart';
import '../widgets/grammar_error_widget.dart';
import '../widgets/mistake_record_card.dart';
import 'grammar_exercise_screen.dart';

class GrammarMistakesScreen extends StatefulWidget {
  final GrammarProvider? provider;

  const GrammarMistakesScreen({super.key, this.provider});

  @override
  State<GrammarMistakesScreen> createState() => _GrammarMistakesScreenState();
}

class _GrammarMistakesScreenState extends State<GrammarMistakesScreen> {
  late GrammarProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? GrammarProvider();
    _provider.addListener(_onProviderChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadMistakes();
    });
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _retryMistake(GrammarMistakeRecord mistake) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarExerciseScreen(
          initialSentence: mistake.originalText,
          provider: _provider,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mistakes = _provider.mistakes;
    final isLoading = _provider.isLoading;
    final errorMessage = _provider.errorMessage;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Mistake Log', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _provider.loadMistakes(),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? GrammarErrorWidget(
                  errorMessage: errorMessage,
                  onRetry: () => _provider.loadMistakes(),
                )
              : mistakes.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded, size: 48, color: theme.colorScheme.outline),
                          const SizedBox(height: 12),
                          Text('No grammar mistakes logged!', style: theme.textTheme.bodyLarge),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _provider.loadMistakes(),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.only(bottom: 24, top: 8),
                      itemCount: mistakes.length,
                      itemBuilder: (context, index) {
                        final item = mistakes[index];
                        return MistakeRecordCard(
                          mistake: item,
                          onRetry: () => _retryMistake(item),
                        );
                      },
                    ),
    );
  }
}
