import 'package:flutter/material.dart';
import '../domain/entities/grammar_topic.dart';
import '../presentation/screens/grammar_article_screen.dart';
import '../presentation/screens/grammar_exercise_screen.dart';
import '../presentation/screens/grammar_mistakes_screen.dart';
import '../presentation/screens/grammar_roadmap_screen.dart';

class GrammarRoutes {
  static const String roadmap = '/grammar';
  static const String exercise = '/grammar/exercise';
  static const String mistakes = '/grammar/mistakes';
  static const String article = '/grammar/article';

  static Map<String, WidgetBuilder> getRoutes() {
    return {
      roadmap: (context) => const GrammarRoadmapScreen(),
      exercise: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is GrammarTopic) return GrammarExerciseScreen(topic: args);
        if (args is String) return GrammarExerciseScreen(initialSentence: args);
        return const GrammarExerciseScreen();
      },
      mistakes: (context) => const GrammarMistakesScreen(),
      article: (context) {
        final args = ModalRoute.of(context)?.settings.arguments;
        if (args is GrammarTopic) return GrammarArticleScreen(topic: args);
        if (args is String) return GrammarArticleScreen(initialArticleId: args);
        return const GrammarArticleScreen();
      },
    };
  }
}
