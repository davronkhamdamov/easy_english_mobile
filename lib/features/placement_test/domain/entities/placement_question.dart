import 'diagnostic_skill.dart';

/// Domain entity representing a single placement test diagnostic question.
class PlacementQuestion {
  final String id;
  final DiagnosticSkill skill;
  final String prompt;
  final String? passage;
  final String? audioUrl;
  final List<String> options;
  final int correctOptionIndex;
  final String explanation;
  final String cefrLevel; // e.g. "A2", "B1", "B2", "C1", "C2"

  const PlacementQuestion({
    required this.id,
    required this.skill,
    required this.prompt,
    this.passage,
    this.audioUrl,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
    required this.cefrLevel,
  });

  PlacementQuestion copyWith({
    String? id,
    DiagnosticSkill? skill,
    String? prompt,
    String? passage,
    String? audioUrl,
    List<String>? options,
    int? correctOptionIndex,
    String? explanation,
    String? cefrLevel,
  }) {
    return PlacementQuestion(
      id: id ?? this.id,
      skill: skill ?? this.skill,
      prompt: prompt ?? this.prompt,
      passage: passage ?? this.passage,
      audioUrl: audioUrl ?? this.audioUrl,
      options: options ?? this.options,
      correctOptionIndex: correctOptionIndex ?? this.correctOptionIndex,
      explanation: explanation ?? this.explanation,
      cefrLevel: cefrLevel ?? this.cefrLevel,
    );
  }

  static const List<PlacementQuestion> sampleQuestions = [
    PlacementQuestion(
      id: 'q1_grammar',
      skill: DiagnosticSkill.grammar,
      prompt:
          'Choose the sentence with correct grammatical structure for Task 2 academic writing:',
      options: [
        'Neither the researchers nor the professor were able to prove the hypothesis.',
        'Neither the researchers nor the professor was able to prove the hypothesis.',
        'Neither the researchers or the professor were able to prove the hypothesis.',
        'Neither of the researchers nor professor are able to prove the hypothesis.',
      ],
      correctOptionIndex: 1,
      explanation:
          'When using "neither... nor", the verb agrees with the subject closer to it ("the professor" -> singular "was").',
      cefrLevel: 'B2',
    ),
    PlacementQuestion(
      id: 'q2_grammar',
      skill: DiagnosticSkill.grammar,
      prompt:
          'Complete the sentence: "Had the government implemented strict regulations earlier, carbon emissions _______ reduced significantly."',
      options: ['would be', 'will have been', 'would have been', 'had been'],
      correctOptionIndex: 2,
      explanation:
          'Inverted third conditional requires "would have been" in the main clause.',
      cefrLevel: 'C1',
    ),
    PlacementQuestion(
      id: 'q3_vocab',
      skill: DiagnosticSkill.vocabulary,
      prompt:
          'Which word is the most appropriate academic synonym for "gradually increase over time"?',
      options: ['Escalate', 'Accumulate', 'Proliferate', 'Fluctuate'],
      correctOptionIndex: 1,
      explanation:
          '"Accumulate" specifically means to gather or increase gradually over time.',
      cefrLevel: 'B2',
    ),
    PlacementQuestion(
      id: 'q4_vocab',
      skill: DiagnosticSkill.vocabulary,
      prompt:
          'Select the correct collocation: "The new renewable energy policy aims to _______ a pivotal role in urban sustainability."',
      options: ['make', 'play', 'give', 'take'],
      correctOptionIndex: 1,
      explanation:
          'The standard academic collocation is "play a pivotal role".',
      cefrLevel: 'B2',
    ),
    PlacementQuestion(
      id: 'q5_reading',
      skill: DiagnosticSkill.reading,
      passage:
          'Urbanization in the 21st century has shifted demographic patterns worldwide. Cities now host over 55% of the global population, a figure projected to reach 68% by 2050. While urban areas generate 80% of global GDP, they are also responsible for over 70% of greenhouse gas emissions. Managing infrastructure resilience while mitigating environmental degradation represents the primary challenge for municipal planning committees.',
      prompt:
          'According to the passage, which of the following statements is TRUE?',
      options: [
        'More than two-thirds of the world population currently lives in cities.',
        'Cities produce less than half of global greenhouse gas emissions.',
        'Urban centers generate the vast majority of global economic output.',
        'Municipal planning committees have successfully solved urban emissions.',
      ],
      correctOptionIndex: 2,
      explanation:
          'The text states cities generate 80% of global GDP, which represents the vast majority of economic output.',
      cefrLevel: 'B2',
    ),
    PlacementQuestion(
      id: 'q6_reading',
      skill: DiagnosticSkill.reading,
      passage:
          'Cognitive neuroscientists studying bilingualism have observed enhanced executive function in individuals who regularly navigate two languages. This "bilingual advantage" manifests primarily in task-switching, conflict resolution, and working memory retention. Critics argue that pubic publication bias inflates these findings, yet recent neuroimaging confirms structural increases in grey matter density in left inferior parietal cortex.',
      prompt: 'What is the main purpose of mentioning critics in the passage?',
      options: [
        'To disprove the existence of any bilingual brain advantages.',
        'To introduce a counter-perspective regarding published study reliability.',
        'To argue that neuroimaging data is fundamentally flawed.',
        'To recommend publishing fewer bilingual studies in scientific journals.',
      ],
      correctOptionIndex: 1,
      explanation:
          'The mention of critics introduces a counter-argument regarding publication bias.',
      cefrLevel: 'C1',
    ),
    PlacementQuestion(
      id: 'q7_listening',
      skill: DiagnosticSkill.listening,
      audioUrl: 'https://cdn.easyenglish.app/audio/diagnostic_sec1.mp3',
      prompt:
          'Audio Transcript: [Lecturer: "The deadline for submitting the environmental impact assessment has been extended from Thursday the 12th to Monday the 16th at noon."]\n\nWhen is the final deadline for the environmental impact assessment?',
      options: [
        'Thursday 12th at midnight',
        'Friday 13th at noon',
        'Monday 16th at noon',
        'Monday 16th at midnight',
      ],
      correctOptionIndex: 2,
      explanation:
          'The speaker explicitly states the new extended deadline is Monday the 16th at noon.',
      cefrLevel: 'B1',
    ),
    PlacementQuestion(
      id: 'q8_listening',
      skill: DiagnosticSkill.listening,
      audioUrl: 'https://cdn.easyenglish.app/audio/diagnostic_sec2.mp3',
      prompt:
          'Audio Transcript: [Student: "I was planning to focus my case study on solar microgrids, but Professor Vance suggested offshore wind farms might offer richer data."]\n\nWhat topic did Professor Vance recommend for the case study?',
      options: [
        'Solar microgrids',
        'Offshore wind farms',
        'Hydroelectric dams',
        'Geothermal energy',
      ],
      correctOptionIndex: 1,
      explanation:
          'The professor recommended offshore wind farms because they offer richer data.',
      cefrLevel: 'B2',
    ),
  ];
}
