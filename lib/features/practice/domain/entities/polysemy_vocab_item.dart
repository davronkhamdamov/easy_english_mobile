import 'package:flutter/material.dart';

/// Represents a distinct sense/meaning of a polysemous word.
class VocabSense {
  final String definition;
  final String partOfSpeech;
  final String exampleSentence;
  final String cefrLevel;
  final bool isPrimary;

  const VocabSense({
    required this.definition,
    required this.partOfSpeech,
    required this.exampleSentence,
    this.cefrLevel = 'C1',
    this.isPrimary = false,
  });
}

/// Represents an interactive multiple-choice question testing the contextual meaning of a word.
class VocabContextQuestion {
  final String id;
  final String targetWord;
  final String contextSentence;
  final String highlightedWord;
  final List<String> options;
  final int correctOptionIndex;
  final int targetSenseIndex;
  final String explanation;
  final String? sourceContextType; // e.g., 'IELTS Reading Passage', 'Task 2 Essay', 'Academic Lecture'

  const VocabContextQuestion({
    required this.id,
    required this.targetWord,
    required this.contextSentence,
    required this.highlightedWord,
    required this.options,
    required this.correctOptionIndex,
    required this.targetSenseIndex,
    required this.explanation,
    this.sourceContextType = 'IELTS Academic Context',
  });
}

/// Represents a vocabulary entry that has multiple distinct academic meanings.
class PolysemyVocabItem {
  final String id;
  final String word;
  final String phonetic;
  final String generalPartOfSpeech;
  final String cefrLevel;
  final List<VocabSense> senses;
  final List<VocabContextQuestion> questions;
  final List<String> tags;

  const PolysemyVocabItem({
    required this.id,
    required this.word,
    required this.phonetic,
    required this.generalPartOfSpeech,
    this.cefrLevel = 'C1',
    required this.senses,
    required this.questions,
    this.tags = const [],
  });
}

/// A structured practice pack (e.g. "Pack 1: Words 1-10").
class PolysemyPracticeSet {
  final String id;
  final String title;
  final String description;
  final List<PolysemyVocabItem> items;

  const PolysemyPracticeSet({
    required this.id,
    required this.title,
    required this.description,
    required this.items,
  });

  int get totalQuestions =>
      items.fold(0, (sum, item) => sum + item.questions.length);
}

/// Represents a top-level category on the practice page, like Top 100 or Top 200.
class PolysemyCategory {
  final String id;
  final String title;
  final String subtitle;
  final String badge;
  final IconData icon;
  final Color accentColor;
  final List<PolysemyPracticeSet> sets;

  const PolysemyCategory({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.icon,
    required this.accentColor,
    required this.sets,
  });

  int get totalWords =>
      sets.fold(0, (sum, set) => sum + set.items.length);

  int get totalQuestions =>
      sets.fold(0, (sum, set) => sum + set.totalQuestions);
}
