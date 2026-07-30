import 'dart:convert';

/// Status of a grammar topic in the roadmap progression.
enum GrammarTopicStatus {
  completed,
  current,
  locked,
}

extension GrammarTopicStatusExtension on GrammarTopicStatus {
  String get value {
    switch (this) {
      case GrammarTopicStatus.completed:
        return 'completed';
      case GrammarTopicStatus.current:
        return 'current';
      case GrammarTopicStatus.locked:
        return 'locked';
    }
  }

  static GrammarTopicStatus fromString(String val) {
    switch (val.toLowerCase()) {
      case 'completed':
        return GrammarTopicStatus.completed;
      case 'current':
      case 'in_progress':
        return GrammarTopicStatus.current;
      case 'locked':
      default:
        return GrammarTopicStatus.locked;
    }
  }
}

/// Type of grammar exercise question.
enum ExerciseType {
  multipleChoice,
  fillInTheBlank,
}

extension ExerciseTypeExtension on ExerciseType {
  String get value {
    switch (this) {
      case ExerciseType.multipleChoice:
        return 'multiple_choice';
      case ExerciseType.fillInTheBlank:
        return 'fill_in_the_blank';
    }
  }

  static ExerciseType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'fill_in_the_blank':
      case 'fill_blank':
        return ExerciseType.fillInTheBlank;
      case 'multiple_choice':
      default:
        return ExerciseType.multipleChoice;
    }
  }
}

/// Difficulty level of a grammar exercise.
enum ExerciseDifficulty {
  easy,
  medium,
  hard,
}

extension ExerciseDifficultyExtension on ExerciseDifficulty {
  String get value {
    switch (this) {
      case ExerciseDifficulty.easy:
        return 'easy';
      case ExerciseDifficulty.medium:
        return 'medium';
      case ExerciseDifficulty.hard:
        return 'hard';
    }
  }

  static ExerciseDifficulty fromString(String val) {
    switch (val.toLowerCase()) {
      case 'hard':
        return ExerciseDifficulty.hard;
      case 'medium':
        return ExerciseDifficulty.medium;
      case 'easy':
      default:
        return ExerciseDifficulty.easy;
    }
  }
}

/// Represents a single grammar rule with explanation, examples, and pitfalls.
class GrammarRule {
  final String id;
  final String topicId;
  final String title;
  final String summary;
  final String detailedExplanation;
  final List<String> examples;
  final List<String> commonPitfalls;

  const GrammarRule({
    required this.id,
    required this.topicId,
    required this.title,
    required this.summary,
    required this.detailedExplanation,
    required this.examples,
    required this.commonPitfalls,
  });

  GrammarRule copyWith({
    String? id,
    String? topicId,
    String? title,
    String? summary,
    String? detailedExplanation,
    List<String>? examples,
    List<String>? commonPitfalls,
  }) {
    return GrammarRule(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      title: title ?? this.title,
      summary: summary ?? this.summary,
      detailedExplanation: detailedExplanation ?? this.detailedExplanation,
      examples: examples ?? List.from(this.examples),
      commonPitfalls: commonPitfalls ?? List.from(this.commonPitfalls),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'title': title,
      'summary': summary,
      'detailed_explanation': detailedExplanation,
      'examples': examples,
      'common_pitfalls': commonPitfalls,
    };
  }

  factory GrammarRule.fromJson(Map<String, dynamic> json) {
    return GrammarRule(
      id: json['id'] as String? ?? '',
      topicId: json['topic_id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      detailedExplanation: json['detailed_explanation'] as String? ?? '',
      examples: List<String>.from(json['examples'] as List? ?? []),
      commonPitfalls: List<String>.from(json['common_pitfalls'] as List? ?? []),
    );
  }
}

/// Represents an interactive grammar exercise question.
class GrammarExercise {
  final String id;
  final String topicId;
  final String ruleId;
  final ExerciseType type;
  final String prompt;
  final String? sentenceWithBlank;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final ExerciseDifficulty difficulty;

  const GrammarExercise({
    required this.id,
    required this.topicId,
    required this.ruleId,
    required this.type,
    required this.prompt,
    this.sentenceWithBlank,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.difficulty = ExerciseDifficulty.medium,
  });

  GrammarExercise copyWith({
    String? id,
    String? topicId,
    String? ruleId,
    ExerciseType? type,
    String? prompt,
    String? sentenceWithBlank,
    List<String>? options,
    String? correctAnswer,
    String? explanation,
    ExerciseDifficulty? difficulty,
  }) {
    return GrammarExercise(
      id: id ?? this.id,
      topicId: topicId ?? this.topicId,
      ruleId: ruleId ?? this.ruleId,
      type: type ?? this.type,
      prompt: prompt ?? this.prompt,
      sentenceWithBlank: sentenceWithBlank ?? this.sentenceWithBlank,
      options: options ?? List.from(this.options),
      correctAnswer: correctAnswer ?? this.correctAnswer,
      explanation: explanation ?? this.explanation,
      difficulty: difficulty ?? this.difficulty,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_id': topicId,
      'rule_id': ruleId,
      'type': type.value,
      'prompt': prompt,
      'sentence_with_blank': sentenceWithBlank,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'difficulty': difficulty.value,
    };
  }

  factory GrammarExercise.fromJson(Map<String, dynamic> json) {
    return GrammarExercise(
      id: json['id'] as String? ?? '',
      topicId: json['topic_id'] as String? ?? '',
      ruleId: json['rule_id'] as String? ?? '',
      type: ExerciseTypeExtension.fromString(json['type'] as String? ?? 'multiple_choice'),
      prompt: json['prompt'] as String? ?? '',
      sentenceWithBlank: json['sentence_with_blank'] as String?,
      options: List<String>.from(json['options'] as List? ?? []),
      correctAnswer: json['correct_answer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      difficulty: ExerciseDifficultyExtension.fromString(json['difficulty'] as String? ?? 'medium'),
    );
  }
}

/// Represents a grammar topic in the adaptive roadmap graph.
class GrammarTopic {
  final String id;
  final String title;
  final String description;
  final String cefrLevel;
  final GrammarTopicStatus status;
  final double masteryPercentage;
  final int orderIndex;
  final List<String> prerequisiteIds;
  final String iconName;
  final List<GrammarRule> rules;
  final List<GrammarExercise> exercises;

  const GrammarTopic({
    required this.id,
    required this.title,
    required this.description,
    required this.cefrLevel,
    required this.status,
    required this.masteryPercentage,
    required this.orderIndex,
    required this.prerequisiteIds,
    required this.iconName,
    required this.rules,
    required this.exercises,
  });

  GrammarTopic copyWith({
    String? id,
    String? title,
    String? description,
    String? cefrLevel,
    GrammarTopicStatus? status,
    double? masteryPercentage,
    int? orderIndex,
    List<String>? prerequisiteIds,
    String? iconName,
    List<GrammarRule>? rules,
    List<GrammarExercise>? exercises,
  }) {
    return GrammarTopic(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      cefrLevel: cefrLevel ?? this.cefrLevel,
      status: status ?? this.status,
      masteryPercentage: masteryPercentage ?? this.masteryPercentage,
      orderIndex: orderIndex ?? this.orderIndex,
      prerequisiteIds: prerequisiteIds ?? List.from(this.prerequisiteIds),
      iconName: iconName ?? this.iconName,
      rules: rules ?? List.from(this.rules),
      exercises: exercises ?? List.from(this.exercises),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'cefr_level': cefrLevel,
      'status': status.value,
      'mastery_percentage': masteryPercentage,
      'order_index': orderIndex,
      'prerequisite_ids': prerequisiteIds,
      'icon_name': iconName,
      'rules': rules.map((r) => r.toJson()).toList(),
      'exercises': exercises.map((e) => e.toJson()).toList(),
    };
  }

  factory GrammarTopic.fromJson(Map<String, dynamic> json) {
    return GrammarTopic(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      cefrLevel: json['cefr_level'] as String? ?? 'B1',
      status: GrammarTopicStatusExtension.fromString(json['status'] as String? ?? 'locked'),
      masteryPercentage: (json['mastery_percentage'] as num? ?? 0.0).toDouble(),
      orderIndex: json['order_index'] as int? ?? 0,
      prerequisiteIds: List<String>.from(json['prerequisite_ids'] as List? ?? []),
      iconName: json['icon_name'] as String? ?? 'book',
      rules: (json['rules'] as List? ?? [])
          .map((r) => GrammarRule.fromJson(r as Map<String, dynamic>))
          .toList(),
      exercises: (json['exercises'] as List? ?? [])
          .map((e) => GrammarExercise.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Represents a long-term grammar mistake record tracked over time across exercises, writing, and speaking.
class GrammarMistakeRecord {
  final String id;
  final String topicCategory;
  final String originalSentence;
  final String correctedSentence;
  final String explanation;
  final int occurrenceCount;
  final DateTime firstSeenAt;
  final DateTime lastSeenAt;
  final bool isResolved;

  const GrammarMistakeRecord({
    required this.id,
    required this.topicCategory,
    required this.originalSentence,
    required this.correctedSentence,
    required this.explanation,
    required this.occurrenceCount,
    required this.firstSeenAt,
    required this.lastSeenAt,
    this.isResolved = false,
  });

  GrammarMistakeRecord copyWith({
    String? id,
    String? topicCategory,
    String? originalSentence,
    String? correctedSentence,
    String? explanation,
    int? occurrenceCount,
    DateTime? firstSeenAt,
    DateTime? lastSeenAt,
    bool? isResolved,
  }) {
    return GrammarMistakeRecord(
      id: id ?? this.id,
      topicCategory: topicCategory ?? this.topicCategory,
      originalSentence: originalSentence ?? this.originalSentence,
      correctedSentence: correctedSentence ?? this.correctedSentence,
      explanation: explanation ?? this.explanation,
      occurrenceCount: occurrenceCount ?? this.occurrenceCount,
      firstSeenAt: firstSeenAt ?? this.firstSeenAt,
      lastSeenAt: lastSeenAt ?? this.lastSeenAt,
      isResolved: isResolved ?? this.isResolved,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'topic_category': topicCategory,
      'original_sentence': originalSentence,
      'corrected_sentence': correctedSentence,
      'explanation': explanation,
      'occurrence_count': occurrenceCount,
      'first_seen_at': firstSeenAt.toIso8601String(),
      'last_seen_at': lastSeenAt.toIso8601String(),
      'is_resolved': isResolved,
    };
  }

  factory GrammarMistakeRecord.fromJson(Map<String, dynamic> json) {
    return GrammarMistakeRecord(
      id: json['id'] as String? ?? '',
      topicCategory: json['topic_category'] as String? ?? 'General',
      originalSentence: json['original_sentence'] as String? ?? '',
      correctedSentence: json['corrected_sentence'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      occurrenceCount: json['occurrence_count'] as int? ?? 1,
      firstSeenAt: json['first_seen_at'] != null
          ? DateTime.parse(json['first_seen_at'] as String)
          : DateTime.now(),
      lastSeenAt: json['last_seen_at'] != null
          ? DateTime.parse(json['last_seen_at'] as String)
          : DateTime.now(),
      isResolved: json['is_resolved'] as bool? ?? false,
    );
  }
}

/// Provides seed datasets for grammar topics and mistake history.
class GrammarSeedData {
  GrammarSeedData._();

  static List<GrammarTopic> get sampleTopics => [
        GrammarTopic(
          id: 'topic_articles',
          title: 'Articles (A/An/The & Zero Article)',
          description: 'Master definite, indefinite, and zero articles in IELTS Academic Writing & Speaking.',
          cefrLevel: 'B1',
          status: GrammarTopicStatus.completed,
          masteryPercentage: 100.0,
          orderIndex: 1,
          prerequisiteIds: [],
          iconName: 'articles',
          rules: [
            const GrammarRule(
              id: 'rule_articles_1',
              topicId: 'topic_articles',
              title: 'Definite vs Indefinite Articles',
              summary: 'Use "a/an" for singular countable nouns mentioned for the first time; use "the" for specific or unique entities.',
              detailedExplanation: 'In IELTS Writing Task 2, using articles correctly shows control of grammatical accuracy. Use "a" before consonant sounds and "an" before vowel sounds. Use "the" when referring to something previously mentioned or uniquely defined in context.',
              examples: [
                'A recent study shows that environmental degradation is increasing.',
                'The study conducted by Cambridge University highlights key factors.',
                'The sun plays a vital role in solar energy production.',
              ],
              commonPitfalls: [
                'Do not use "a/an" with uncountable nouns (e.g. "an advice" -> "a piece of advice").',
                'Do not omit "the" before specific singular/plural nouns modified by relative clauses.',
              ],
            ),
          ],
          exercises: [
            const GrammarExercise(
              id: 'ex_articles_1',
              topicId: 'topic_articles',
              ruleId: 'rule_articles_1',
              type: ExerciseType.multipleChoice,
              prompt: 'Choose the correct article to complete the IELTS essay sentence:',
              sentenceWithBlank: '_____ rapid growth of urban centers has led to severe traffic congestion.',
              options: ['A', 'An', 'The', 'Zero article (no article)'],
              correctAnswer: 'The',
              explanation: '"The" is required because "rapid growth of urban centers" is a specific noun phrase defined by the prepositional phrase.',
              difficulty: ExerciseDifficulty.easy,
            ),
            const GrammarExercise(
              id: 'ex_articles_2',
              topicId: 'topic_articles',
              ruleId: 'rule_articles_1',
              type: ExerciseType.fillInTheBlank,
              prompt: 'Fill in the blank with the correct article (a, an, the, or zero):',
              sentenceWithBlank: 'Governments should invest in _____ renewable energy to combat climate change.',
              options: ['zero', 'the', 'a', 'an'],
              correctAnswer: 'zero',
              explanation: '"Renewable energy" is an uncountable noun phrase used in a general sense, so no article (zero article) is needed.',
              difficulty: ExerciseDifficulty.medium,
            ),
          ],
        ),
        GrammarTopic(
          id: 'topic_sva',
          title: 'Subject-Verb Agreement',
          description: 'Ensure correct agreement with complex subjects, collective nouns, and inverted clauses.',
          cefrLevel: 'B2',
          status: GrammarTopicStatus.current,
          masteryPercentage: 65.0,
          orderIndex: 2,
          prerequisiteIds: ['topic_articles'],
          iconName: 'sva',
          rules: [
            const GrammarRule(
              id: 'rule_sva_1',
              topicId: 'topic_sva',
              title: 'Agreement with Intervening Clauses & Complex Noun Phrases',
              summary: 'The verb must agree with the head noun of the subject, not with words inside prepositional phrases or relative clauses.',
              detailedExplanation: 'A common mistake in Band 6 writing is confusing the verb agreement when long modifiers intervene between the subject and the verb. Always locate the true head noun.',
              examples: [
                'The number of international students attending universities HAS increased significantly.',
                'A variety of measures WERE proposed by the committee.',
              ],
              commonPitfalls: [
                'Writing "The quality of these products are poor" instead of "is poor".',
                'Confusing "a number of" (+ plural verb) with "the number of" (+ singular verb).',
              ],
            ),
          ],
          exercises: [
            const GrammarExercise(
              id: 'ex_sva_1',
              topicId: 'topic_sva',
              ruleId: 'rule_sva_1',
              type: ExerciseType.multipleChoice,
              prompt: 'Select the correct verb form for the complex subject:',
              sentenceWithBlank: 'The implementation of new environmental policies _____ expected to reduce emissions.',
              options: ['is', 'are', 'were', 'have been'],
              correctAnswer: 'is',
              explanation: 'The head noun is "implementation" (singular), so the singular verb "is" must be used despite the plural noun "policies" following it.',
              difficulty: ExerciseDifficulty.medium,
            ),
            const GrammarExercise(
              id: 'ex_sva_2',
              topicId: 'topic_sva',
              ruleId: 'rule_sva_1',
              type: ExerciseType.fillInTheBlank,
              prompt: 'Complete the sentence with the correct form of "have":',
              sentenceWithBlank: 'A significant number of research studies _____ demonstrated the benefits of bilingual education.',
              options: ['have', 'has', 'having', 'had been'],
              correctAnswer: 'have',
              explanation: '"A number of" takes a plural verb ("have demonstrated"), whereas "the number of" takes a singular verb.',
              difficulty: ExerciseDifficulty.medium,
            ),
          ],
        ),
        GrammarTopic(
          id: 'topic_conditionals',
          title: 'Conditionals (2nd, 3rd & Mixed)',
          description: 'Construct complex hypothetical scenarios and counterfactual arguments for Band 7+ essays.',
          cefrLevel: 'B2',
          status: GrammarTopicStatus.current,
          masteryPercentage: 30.0,
          orderIndex: 3,
          prerequisiteIds: ['topic_sva'],
          iconName: 'conditionals',
          rules: [
            const GrammarRule(
              id: 'rule_cond_1',
              topicId: 'topic_conditionals',
              title: 'Third & Mixed Conditionals for Past Hypotheses',
              summary: 'Use Third Conditional (If + had + pp, would have + pp) for past unfulfilled situations and Mixed Conditionals to link past causes with present results.',
              detailedExplanation: 'Examiners award high GRA (Grammatical Range and Accuracy) scores for accurate third and mixed conditional structures in Task 2 arguments.',
              examples: [
                'If governments had taken early action, the economic crisis would have been prevented.',
                'If I had studied medicine, I would be working in a hospital today.',
              ],
              commonPitfalls: [
                'Using "would have" in the if-clause (e.g., "If governments would have taken action...").',
                'Confusing past perfect with simple past in third conditionals.',
              ],
            ),
          ],
          exercises: [
            const GrammarExercise(
              id: 'ex_cond_1',
              topicId: 'topic_conditionals',
              ruleId: 'rule_cond_1',
              type: ExerciseType.multipleChoice,
              prompt: 'Select the grammatically correct Third Conditional sentence:',
              sentenceWithBlank: 'If stricter regulations _____ introduced earlier, pollution levels _____ lower today.',
              options: [
                'had been / would be',
                'were / would have been',
                'have been / will be',
                'would be / had been'
              ],
              correctAnswer: 'had been / would be',
              explanation: 'This is a mixed conditional: past action ("had been introduced") resulting in a present state ("would be lower today").',
              difficulty: ExerciseDifficulty.hard,
            ),
          ],
        ),
        GrammarTopic(
          id: 'topic_relative_clauses',
          title: 'Relative Clauses (Defining & Non-Defining)',
          description: 'Use relative pronouns (which, who, whose, where) to create complex academic sentences.',
          cefrLevel: 'C1',
          status: GrammarTopicStatus.locked,
          masteryPercentage: 0.0,
          orderIndex: 4,
          prerequisiteIds: ['topic_conditionals'],
          iconName: 'relative_clauses',
          rules: [
            const GrammarRule(
              id: 'rule_rel_1',
              topicId: 'topic_relative_clauses',
              title: 'Non-Defining Relative Clauses with "Which"',
              summary: 'Use non-defining relative clauses offset by commas to comment on entire previous clauses.',
              detailedExplanation: 'Clauses like ", which in turn leads to..." demonstrate high syntactic sophistication in IELTS Task 2.',
              examples: [
                'Urban sprawl causes deforestation, which in turn leads to habitat destruction.',
                'The university introduced online courses, which allowed thousands of students to learn remotely.',
              ],
              commonPitfalls: [
                'Using "that" instead of "which" in non-defining clauses (after commas).',
                'Omitting necessary commas in non-defining relative clauses.',
              ],
            ),
          ],
          exercises: [
            const GrammarExercise(
              id: 'ex_rel_1',
              topicId: 'topic_relative_clauses',
              ruleId: 'rule_rel_1',
              type: ExerciseType.multipleChoice,
              prompt: 'Choose the correct relative pronoun and punctuation:',
              sentenceWithBlank: 'Automated manufacturing reduces production costs _____ allows companies to lower prices.',
              options: [
                ', which',
                ', that',
                ' which',
                ' who'
              ],
              correctAnswer: ', which',
              explanation: 'A non-defining clause starting with ", which" is required to add non-essential commenting information about the previous main clause.',
              difficulty: ExerciseDifficulty.hard,
            ),
          ],
        ),
        GrammarTopic(
          id: 'topic_inversion',
          title: 'Inversion & Fronting for Emphasis',
          description: 'Master advanced Band 8+ structural inversion (Not only..., Hardly had..., Seldom do...).',
          cefrLevel: 'C2',
          status: GrammarTopicStatus.locked,
          masteryPercentage: 0.0,
          orderIndex: 5,
          prerequisiteIds: ['topic_relative_clauses'],
          iconName: 'inversion',
          rules: [
            const GrammarRule(
              id: 'rule_inv_1',
              topicId: 'topic_inversion',
              title: 'Negative & Limiting Adverb Inversion',
              summary: 'When starting a sentence with negative adverbs (Not only, Rarely, Seldom, Under no circumstances), invert the auxiliary verb and subject.',
              detailedExplanation: 'Structure: Negative Adverb + Auxiliary Verb + Subject + Main Verb. Used for emphatic academic statements.',
              examples: [
                'Not only does public transport reduce pollution, but it also alleviates urban congestion.',
                'Rarely have researchers observed such dramatic climatic shifts in a short period.',
              ],
              commonPitfalls: [
                'Forgetting auxiliary verb inversion (e.g., "Not only public transport reduces..." is INCORRECT).',
                'Using wrong auxiliary tense in inverted clause.',
              ],
            ),
          ],
          exercises: [
            const GrammarExercise(
              id: 'ex_inv_1',
              topicId: 'topic_inversion',
              ruleId: 'rule_inv_1',
              type: ExerciseType.multipleChoice,
              prompt: 'Select the correctly inverted Band 8+ sentence:',
              sentenceWithBlank: '_____ the economic impact of global tourism, but it also fosters cultural exchange.',
              options: [
                'Not only does higher education boost',
                'Not only higher education boosts',
                'Higher education not only boost',
                'Does not only higher education boost'
              ],
              correctAnswer: 'Not only does higher education boost',
              explanation: 'Emphatic negative inversion requires "Not only" followed by the auxiliary verb "does", then the subject "higher education", and the base verb "boost".',
              difficulty: ExerciseDifficulty.hard,
            ),
          ],
        ),
      ];

  static List<GrammarMistakeRecord> get sampleMistakes => [
        GrammarMistakeRecord(
          id: 'mistake_1',
          topicCategory: 'Subject-Verb Agreement',
          originalSentence: 'The number of students who attends online lectures have increased.',
          correctedSentence: 'The number of students who attend online lectures HAS increased.',
          explanation: '1. "students who attend" (plural relative clause verb).\n2. "The number of..." takes the singular main verb "has increased", not "have".',
          occurrenceCount: 4,
          firstSeenAt: DateTime.now().subtract(const Duration(days: 10)),
          lastSeenAt: DateTime.now().subtract(const Duration(hours: 4)),
          isResolved: false,
        ),
        GrammarMistakeRecord(
          id: 'mistake_2',
          topicCategory: 'Articles',
          originalSentence: 'Governments must provide an advice for young job seekers.',
          correctedSentence: 'Governments must provide ADVICE (or a piece of advice) for young job seekers.',
          explanation: '"Advice" is an uncountable noun. Never place "an" directly before uncountable nouns.',
          occurrenceCount: 3,
          firstSeenAt: DateTime.now().subtract(const Duration(days: 7)),
          lastSeenAt: DateTime.now().subtract(const Duration(days: 1)),
          isResolved: false,
        ),
        GrammarMistakeRecord(
          id: 'mistake_3',
          topicCategory: 'Conditionals',
          originalSentence: 'If governments would have invested earlier, pollution levels were lower.',
          correctedSentence: 'If governments HAD INVESTED earlier, pollution levels WOULD BE lower.',
          explanation: 'Never use "would have" in the conditional IF-clause. Use Past Perfect ("had invested") in the IF-clause and "would be" in the main result clause.',
          occurrenceCount: 2,
          firstSeenAt: DateTime.now().subtract(const Duration(days: 5)),
          lastSeenAt: DateTime.now().subtract(const Duration(days: 2)),
          isResolved: false,
        ),
        GrammarMistakeRecord(
          id: 'mistake_4',
          topicCategory: 'Inversion',
          originalSentence: 'Not only public transport reduces pollution, but it also saves money.',
          correctedSentence: 'Not only DOES public transport reduce pollution, but it also saves money.',
          explanation: 'Sentences beginning with "Not only" must invert the auxiliary verb ("does") before the subject ("public transport").',
          occurrenceCount: 1,
          firstSeenAt: DateTime.now().subtract(const Duration(days: 2)),
          lastSeenAt: DateTime.now().subtract(const Duration(days: 2)),
          isResolved: false,
        ),
      ];
}
