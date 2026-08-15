import 'package:flutter/material.dart';
import '../../domain/entities/grammar_topic.dart';
import '../providers/grammar_provider.dart';
import '../widgets/cefr_level_chips.dart';
import '../widgets/grammar_error_widget.dart';
import '../widgets/grammar_topic_card.dart';
import 'grammar_exercise_screen.dart';
import 'grammar_mistakes_screen.dart';

class GrammarRoadmapScreen extends StatefulWidget {
  final GrammarProvider? provider;

  const GrammarRoadmapScreen({super.key, this.provider});

  @override
  State<GrammarRoadmapScreen> createState() => _GrammarRoadmapScreenState();
}

class _GrammarRoadmapScreenState extends State<GrammarRoadmapScreen> {
  late GrammarProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? GrammarProvider();
    _provider.addListener(_onProviderChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadRoadmap();
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

  void _openExercise(GrammarTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarExerciseScreen(topic: topic, provider: _provider),
      ),
    );
  }

  void _openMistakes() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarMistakesScreen(provider: _provider),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _provider.state;
    final filtered = _provider.filteredTopics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Mistake Log',
            onPressed: _openMistakes,
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _provider.loadRoadmap(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CefrLevelChips(
            selectedLevel: state.selectedCefrLevel,
            onLevelSelected: (lvl) => _provider.selectCefrLevel(lvl),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? GrammarErrorWidget(
                        errorMessage: state.errorMessage!,
                        onRetry: () => _provider.loadRoadmap(),
                      )
                    : filtered.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.auto_stories_rounded, size: 48, color: theme.colorScheme.outline),
                                const SizedBox(height: 12),
                                Text('No grammar topics available.', style: theme.textTheme.bodyLarge),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _provider.loadRoadmap(),
                                  child: const Text('Refresh Topics'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final topic = filtered[index];
                              return GrammarTopicCard(
                                topic: topic,
                                onTap: () => _openExercise(topic),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
