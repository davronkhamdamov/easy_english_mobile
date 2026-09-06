import 'package:flutter/material.dart';
import '../../domain/entities/grammar_topic.dart';
import '../providers/grammar_provider.dart';
import '../widgets/grammar_error_widget.dart';
import '../widgets/grammar_topic_card.dart';
import 'grammar_article_screen.dart';

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

  void _openTopicArticle(GrammarTopic topic) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GrammarArticleScreen(
          topic: topic,
          allTopics: _provider.topics,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _provider.state;
    final topics = _provider.topics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grammar Roadmap', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? GrammarErrorWidget(
                  errorMessage: state.errorMessage!,
                  onRetry: () => _provider.loadRoadmap(),
                )
              : topics.isEmpty
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
                      padding: const EdgeInsets.only(top: 8, bottom: 24),
                      itemCount: topics.length,
                      itemBuilder: (context, index) {
                        final topic = topics[index];
                        return GrammarTopicCard(
                          topic: topic,
                          onTap: () => _openTopicArticle(topic),
                        );
                      },
                    ),
    );
  }
}
