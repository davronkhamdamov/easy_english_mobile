import '../../domain/entities/grammar_exercise.dart';
import '../../domain/entities/grammar_mistake_record.dart';
import '../../domain/entities/grammar_rule.dart';
import '../../domain/entities/grammar_topic.dart';

/// Test helper providing mock topics for unit testing.
class GrammarSeedData {
  GrammarSeedData._();

  static List<GrammarTopic> get sampleTopics => [
        GrammarTopic(
          id: 'topic_articles',
          title: 'Articles (A, An, The)',
          description: 'Master definite and indefinite articles in English grammar.',
          cefrLevel: 'B1',
          isCompleted: true,
          progressPercent: 100.0,
          status: GrammarTopicStatus.completed,
          masteryPercentage: 100.0,
          orderIndex: 1,
          prerequisiteIds: const [],
          iconName: 'article',
          rules: const [
            GrammarRule(
              id: 'rule_a_an',
              title: 'A vs An Rule',
              summary: 'Rule summary',
              detailedExplanation: 'Use A before consonant sounds, An before vowel sounds.',
              examples: ['a cat', 'an apple'],
              commonPitfalls: ['a apple'],
              tip: 'Focus on sound, not letter.',
            ),
          ],
          exercises: const [
            GrammarExercise(
              id: 'ex_1',
              topicId: 'topic_articles',
              prompt: 'She brought ___ apple.',
              type: ExerciseType.fillInTheBlank,
              options: ['a', 'an', 'the'],
              correctAnswer: 'an',
              explanation: 'Apple starts with a vowel sound.',
              difficultyScore: 1,
            ),
          ],
        ),
      ];

  static List<GrammarMistakeRecord> get sampleMistakes => [
        GrammarMistakeRecord(
          id: 'mistake_301',
          originalText: 'I am working here since 2020.',
          correctedText: 'I have been working here since 2020.',
          ruleCategory: 'Present Perfect Continuous',
          occurrenceCount: 3,
          lastFailedAt: DateTime.now(),
          explanation: 'Use present perfect continuous with since/for.',
        ),
      ];
}
