import 'dart:convert';
import 'dart:math';

/// Exam mode type for IELTS (Academic vs General Training).
enum ExamType {
  academic,
  generalTraining;

  String get displayName {
    switch (this) {
      case ExamType.academic:
        return 'Academic';
      case ExamType.generalTraining:
        return 'General Training';
    }
  }

  static ExamType fromString(String val) {
    switch (val.toLowerCase()) {
      case 'generaltraining':
      case 'general_training':
      case 'gt':
        return ExamType.generalTraining;
      case 'academic':
      default:
        return ExamType.academic;
    }
  }
}

/// Skill section types in IELTS.
enum MockSkill {
  reading,
  listening,
  writing,
  speaking,
  fullMock;

  String get displayName {
    switch (this) {
      case MockSkill.reading:
        return 'Reading';
      case MockSkill.listening:
        return 'Listening';
      case MockSkill.writing:
        return 'Writing';
      case MockSkill.speaking:
        return 'Speaking';
      case MockSkill.fullMock:
        return 'Full Mock Exam';
    }
  }

  static MockSkill fromString(String val) {
    switch (val.toLowerCase()) {
      case 'reading':
        return MockSkill.reading;
      case 'listening':
        return MockSkill.listening;
      case 'writing':
        return MockSkill.writing;
      case 'speaking':
        return MockSkill.speaking;
      case 'fullmock':
      case 'full_mock':
      default:
        return MockSkill.fullMock;
    }
  }
}

/// Supported question types for mock reading & listening.
enum QuestionType {
  multipleChoice,
  trueFalseNotGiven,
  sentenceCompletion;

  String get displayName {
    switch (this) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.trueFalseNotGiven:
        return 'True / False / Not Given';
      case QuestionType.sentenceCompletion:
        return 'Sentence Completion';
    }
  }

  static QuestionType fromString(String val) {
    switch (val.toLowerCase().replaceAll(' ', '').replaceAll('/', '').replaceAll('_', '')) {
      case 'multiplechoice':
      case 'mcq':
        return QuestionType.multipleChoice;
      case 'truefalsenotgiven':
      case 'tfng':
        return QuestionType.trueFalseNotGiven;
      case 'sentencecompletion':
      case 'fillin':
        return QuestionType.sentenceCompletion;
      default:
        return QuestionType.multipleChoice;
    }
  }
}

/// Official IELTS Raw Score (0-40) to Band Score (1.0 - 9.0) Converter Utility.
class IeltsBandConverter {
  IeltsBandConverter._();

  /// Converts Academic Reading raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double academicReadingRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 39) return 9.0;
    if (score >= 37) return 8.5;
    if (score >= 35) return 8.0;
    if (score >= 33) return 7.5;
    if (score >= 30) return 7.0;
    if (score >= 27) return 6.5;
    if (score >= 23) return 6.0;
    if (score >= 19) return 5.5;
    if (score >= 15) return 5.0;
    if (score >= 13) return 4.5;
    if (score >= 10) return 4.0;
    if (score >= 8) return 3.5;
    if (score >= 6) return 3.0;
    if (score >= 4) return 2.5;
    if (score >= 2) return 2.0;
    return 1.0;
  }

  /// Converts General Training Reading raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double generalReadingRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 40) return 9.0;
    if (score >= 39) return 8.5;
    if (score >= 37) return 8.0;
    if (score >= 36) return 7.5;
    if (score >= 34) return 7.0;
    if (score >= 32) return 6.5;
    if (score >= 30) return 6.0;
    if (score >= 27) return 5.5;
    if (score >= 23) return 5.0;
    if (score >= 19) return 4.5;
    if (score >= 15) return 4.0;
    if (score >= 12) return 3.5;
    if (score >= 9) return 3.0;
    if (score >= 6) return 2.5;
    if (score >= 3) return 2.0;
    return 1.0;
  }

  /// Converts Listening raw score (0-40) to official IELTS Band score (1.0 - 9.0).
  static double listeningRawToBand(int rawScore) {
    final score = rawScore.clamp(0, 40);
    if (score >= 39) return 9.0;
    if (score >= 37) return 8.5;
    if (score >= 35) return 8.0;
    if (score >= 32) return 7.5;
    if (score >= 30) return 7.0;
    if (score >= 26) return 6.5;
    if (score >= 23) return 6.0;
    if (score >= 18) return 5.5;
    if (score >= 16) return 5.0;
    if (score >= 13) return 4.5;
    if (score >= 10) return 4.0;
    if (score >= 8) return 3.5;
    if (score >= 6) return 3.0;
    if (score >= 4) return 2.5;
    if (score >= 2) return 2.0;
    return 1.0;
  }

  /// Converts raw score to band based on section skill and exam type.
  static double calculateSectionBand({
    required MockSkill skill,
    required int rawScore,
    ExamType examType = ExamType.academic,
  }) {
    switch (skill) {
      case MockSkill.reading:
        return examType == ExamType.academic
            ? academicReadingRawToBand(rawScore)
            : generalReadingRawToBand(rawScore);
      case MockSkill.listening:
        return listeningRawToBand(rawScore);
      case MockSkill.writing:
      case MockSkill.speaking:
        // Raw score is treated directly as band if in range 1-9
        return (rawScore.toDouble() / 40.0 * 8.0 + 1.0).clamp(1.0, 9.0);
      case MockSkill.fullMock:
        return 6.5;
    }
  }

  /// Calculates overall band score according to official IELTS rounding rules.
  /// Average is rounded to nearest 0.5 (e.g., .25 -> .5, .75 -> next whole number).
  static double calculateOverallBand(List<double> scores) {
    if (scores.isEmpty) return 0.0;
    final avg = scores.reduce((a, b) => a + b) / scores.length;
    final floorVal = avg.floorToDouble();
    final remainder = avg - floorVal;

    if (remainder < 0.25) {
      return floorVal;
    } else if (remainder < 0.75) {
      return floorVal + 0.5;
    } else {
      return floorVal + 1.0;
    }
  }
}

/// Single Question in a Mock Exam section or passage.
class MockQuestion {
  final String id;
  final int orderIndex;
  final QuestionType questionType;
  final String prompt;
  final List<String> options;
  final String correctAnswer;
  final String explanation;
  final String? passageId;
  final int sectionNumber;

  MockQuestion({
    required this.id,
    required this.orderIndex,
    required this.questionType,
    required this.prompt,
    required this.options,
    required this.correctAnswer,
    required this.explanation,
    this.passageId,
    this.sectionNumber = 1,
  });

  factory MockQuestion.fromJson(Map<String, dynamic> json) {
    return MockQuestion(
      id: json['id'] as String? ?? 'q_${json['order_index'] ?? 1}',
      orderIndex: (json['order_index'] ?? json['orderIndex'] ?? 1) as int,
      questionType: QuestionType.fromString(
        json['question_type'] as String? ?? json['questionType'] as String? ?? 'multipleChoice',
      ),
      prompt: json['prompt'] as String? ?? '',
      options: (json['options'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      correctAnswer: json['correct_answer'] as String? ?? json['correctAnswer'] as String? ?? '',
      explanation: json['explanation'] as String? ?? '',
      passageId: json['passage_id'] as String? ?? json['passageId'] as String?,
      sectionNumber: (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'order_index': orderIndex,
      'question_type': questionType.name,
      'prompt': prompt,
      'options': options,
      'correct_answer': correctAnswer,
      'explanation': explanation,
      'passage_id': passageId,
      'section_number': sectionNumber,
    };
  }
}

/// Reading passage containing text and associated questions.
class MockExamPassage {
  final String id;
  final String title;
  final String content;
  final int sectionNumber;
  final List<MockQuestion> questions;

  MockExamPassage({
    required this.id,
    required this.title,
    required this.content,
    required this.sectionNumber,
    required this.questions,
  });

  factory MockExamPassage.fromJson(Map<String, dynamic> json) {
    return MockExamPassage(
      id: json['id'] as String? ?? 'passage_1',
      title: json['title'] as String? ?? 'Passage Title',
      content: json['content'] as String? ?? '',
      sectionNumber: (json['section_number'] ?? json['sectionNumber'] ?? 1) as int,
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'section_number': sectionNumber,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }
}

/// Individual section inside a Mock Exam Paper (e.g. Reading, Listening).
class MockExamSection {
  final String id;
  final MockSkill skill;
  final String title;
  final int timeLimitMinutes;
  final List<MockExamPassage> passages;
  final List<MockQuestion> questions;
  final String? audioUrl;
  final String? transcript;

  MockExamSection({
    required this.id,
    required this.skill,
    required this.title,
    required this.timeLimitMinutes,
    this.passages = const [],
    this.questions = const [],
    this.audioUrl,
    this.transcript,
  });

  factory MockExamSection.fromJson(Map<String, dynamic> json) {
    return MockExamSection(
      id: json['id'] as String? ?? 'section_1',
      skill: MockSkill.fromString(json['skill'] as String? ?? 'reading'),
      title: json['title'] as String? ?? 'Section Title',
      timeLimitMinutes: (json['time_limit_minutes'] ?? json['timeLimitMinutes'] ?? 60) as int,
      passages: (json['passages'] as List<dynamic>?)
              ?.map((p) => MockExamPassage.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      questions: (json['questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      audioUrl: json['audio_url'] as String? ?? json['audioUrl'] as String?,
      transcript: json['transcript'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'skill': skill.name,
      'title': title,
      'time_limit_minutes': timeLimitMinutes,
      'passages': passages.map((p) => p.toJson()).toList(),
      'questions': questions.map((q) => q.toJson()).toList(),
      'audio_url': audioUrl,
      'transcript': transcript,
    };
  }

  /// Helper getter to aggregate all questions across passages or direct list.
  List<MockQuestion> get allQuestions {
    if (questions.isNotEmpty) return questions;
    final list = <MockQuestion>[];
    for (final p in passages) {
      list.addAll(p.questions);
    }
    return list;
  }
}

/// Complete Full IELTS Mock Exam Paper.
class MockExamPaper {
  final String id;
  final String title;
  final ExamType examType;
  final String description;
  final String difficulty;
  final List<MockExamSection> sections;

  MockExamPaper({
    required this.id,
    required this.title,
    required this.examType,
    required this.description,
    required this.difficulty,
    required this.sections,
  });

  factory MockExamPaper.fromJson(Map<String, dynamic> json) {
    return MockExamPaper(
      id: json['id'] as String? ?? 'paper_1',
      title: json['title'] as String? ?? 'Mock Exam Paper',
      examType: ExamType.fromString(json['exam_type'] as String? ?? json['examType'] as String? ?? 'academic'),
      description: json['description'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? 'Medium',
      sections: (json['sections'] as List<dynamic>?)
              ?.map((s) => MockExamSection.fromJson(s as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'exam_type': examType.name,
      'description': description,
      'difficulty': difficulty,
      'sections': sections.map((s) => s.toJson()).toList(),
    };
  }
}

/// Result domain model for completed section or full mock exam.
class MockExamResult {
  final String id;
  final String userId;
  final String examPaperId;
  final String examTitle;
  final ExamType examType;
  final double overallBand;
  final double readingBand;
  final double listeningBand;
  final double writingBand;
  final double speakingBand;
  final int readingRawScore;
  final int listeningRawScore;
  final int totalReadingQuestions;
  final int totalListeningQuestions;
  final int timeTakenSeconds;
  final Map<String, String> userAnswers;
  final List<MockQuestion> allQuestions;
  final Map<String, dynamic> detailedFeedback;
  final DateTime createdAt;

  MockExamResult({
    required this.id,
    required this.userId,
    required this.examPaperId,
    required this.examTitle,
    required this.examType,
    required this.overallBand,
    required this.readingBand,
    required this.listeningBand,
    required this.writingBand,
    required this.speakingBand,
    required this.readingRawScore,
    required this.listeningRawScore,
    required this.totalReadingQuestions,
    required this.totalListeningQuestions,
    required this.timeTakenSeconds,
    required this.userAnswers,
    required this.allQuestions,
    this.detailedFeedback = const {},
    required this.createdAt,
  });

  factory MockExamResult.fromJson(Map<String, dynamic> json) {
    return MockExamResult(
      id: json['id'] as String? ?? 'result_${DateTime.now().millisecondsSinceEpoch}',
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? 'user_default',
      examPaperId: json['exam_paper_id'] as String? ?? json['examPaperId'] as String? ?? 'paper_1',
      examTitle: json['exam_title'] as String? ?? json['examTitle'] as String? ?? 'Mock Exam',
      examType: ExamType.fromString(json['exam_type'] as String? ?? json['examType'] as String? ?? 'academic'),
      overallBand: (json['overall_band'] ?? json['overallBand'] ?? 6.5) as double,
      readingBand: (json['reading_band'] ?? json['readingBand'] ?? 6.5) as double,
      listeningBand: (json['listening_band'] ?? json['listeningBand'] ?? 6.5) as double,
      writingBand: (json['writing_band'] ?? json['writingBand'] ?? 6.5) as double,
      speakingBand: (json['speaking_band'] ?? json['speakingBand'] ?? 6.5) as double,
      readingRawScore: (json['reading_raw_score'] ?? json['readingRawScore'] ?? 0) as int,
      listeningRawScore: (json['listening_raw_score'] ?? json['listeningRawScore'] ?? 0) as int,
      totalReadingQuestions: (json['total_reading_questions'] ?? json['totalReadingQuestions'] ?? 40) as int,
      totalListeningQuestions: (json['total_listening_questions'] ?? json['totalListeningQuestions'] ?? 40) as int,
      timeTakenSeconds: (json['time_taken_seconds'] ?? json['timeTakenSeconds'] ?? 3600) as int,
      userAnswers: (json['user_answers'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v.toString()),
          ) ??
          {},
      allQuestions: (json['all_questions'] as List<dynamic>?)
              ?.map((q) => MockQuestion.fromJson(q as Map<String, dynamic>))
              .toList() ??
          [],
      detailedFeedback: (json['detailed_feedback'] as Map<String, dynamic>?) ?? {},
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'exam_paper_id': examPaperId,
      'exam_title': examTitle,
      'exam_type': examType.name,
      'overall_band': overallBand,
      'reading_band': readingBand,
      'listening_band': listeningBand,
      'writing_band': writingBand,
      'speaking_band': speakingBand,
      'reading_raw_score': readingRawScore,
      'listening_raw_score': listeningRawScore,
      'total_reading_questions': totalReadingQuestions,
      'total_listening_questions': totalListeningQuestions,
      'time_taken_seconds': timeTakenSeconds,
      'user_answers': userAnswers,
      'all_questions': allQuestions.map((q) => q.toJson()).toList(),
      'detailed_feedback': detailedFeedback,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Pre-populated Sample Data Provider for Mock Exams.
class SampleMockExamData {
  SampleMockExamData._();

  static MockExamPaper getSampleAcademicPaper() {
    return MockExamPaper(
      id: 'paper_academic_01',
      title: 'Cambridge Official Practice Test 1 (Academic)',
      examType: ExamType.academic,
      description: 'Full Academic IELTS Mock Test with updated 2026 format for Reading & Listening.',
      difficulty: 'Medium-Hard',
      sections: [
        MockExamSection(
          id: 'sec_reading_01',
          skill: MockSkill.reading,
          title: 'Academic Reading Test 1',
          timeLimitMinutes: 60,
          passages: [
            MockExamPassage(
              id: 'passage_01',
              title: 'Passage 1: The Architecture of Renewable Energy Cities',
              content: '''Modern urban centers consume over 70% of global primary energy and generate a proportionate share of greenhouse emissions. In response to mounting climate pressure, eco-architects are pioneering net-zero urban development models that integrate passive solar design, bio-climatic facades, and decentralized smart microgrids.

Historically, urban growth relied heavily on centralized fossil-fueled power stations situated far from residential areas. Modern renewable urban planning flips this paradigm by transforming buildings themselves into primary energy harvesting units. Photovoltaic solar tiles embedded in roofs, transparent solar glass windows, and vertical kinetic wind turbines on high-rise corners allow skyscrapers to function as localized energy producers.

Furthermore, thermal energy storage systems utilizing phase-change materials enable buildings to store excess heat absorbed during peak daylight hours and release it during cooler night periods. This minimizes dependence on mechanical HVAC units and significantly reduces urban heat island effects.

However, transitioning existing historic metropolises presents substantial logistical and socioeconomic challenges. Retrofitted historical structures must comply with strict aesthetic conservation guidelines while meeting rigorous contemporary energy performance benchmarks. Financial incentives, public-private partnerships, and regulatory building codes play a critical role in accelerating this transformation across global cities.''',
              sectionNumber: 1,
              questions: [
                MockQuestion(
                  id: 'q1',
                  orderIndex: 1,
                  questionType: QuestionType.multipleChoice,
                  prompt: 'What proportion of global primary energy is consumed by modern urban centers?',
                  options: ['A) Under 30%', 'B) Approximately 50%', 'C) Over 70%', 'D) Exactly 100%'],
                  correctAnswer: 'C) Over 70%',
                  explanation: 'The passage explicitly states: "Modern urban centers consume over 70% of global primary energy".',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q2',
                  orderIndex: 2,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt: 'Historical urban growth relied on power stations located within city centers.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation: 'The passage states historical urban growth relied on power stations "situated far from residential areas", making the statement False.',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q3',
                  orderIndex: 3,
                  questionType: QuestionType.sentenceCompletion,
                  prompt: 'Thermal energy storage systems utilize _____ materials to absorb and release heat.',
                  options: [],
                  correctAnswer: 'phase-change',
                  explanation: 'Paragraph 3 explicitly mentions "thermal energy storage systems utilizing phase-change materials".',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q4',
                  orderIndex: 4,
                  questionType: QuestionType.multipleChoice,
                  prompt: 'Which innovation allows skyscrapers to function as localized energy producers?',
                  options: [
                    'A) Diesel generators in basements',
                    'B) Photovoltaic solar tiles and transparent solar glass',
                    'C) Coal heating units',
                    'D) High-voltage overhead cables'
                  ],
                  correctAnswer: 'B) Photovoltaic solar tiles and transparent solar glass',
                  explanation: 'Paragraph 2 highlights photovoltaic solar tiles and transparent solar glass windows as key technologies.',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
              ],
            ),
            MockExamPassage(
              id: 'passage_02',
              title: 'Passage 2: Cognitive Neuroscience of Multilingual Lexical Processing',
              content: '''Neurolinguistic investigations over the past two decades have fundamentally altered our understanding of how multilingual individuals store and retrieve words across multiple languages. Previously, researchers postulated the existence of separate non-overlapping mental lexicons for each spoken language. Contemporary neuroimaging studies utilizing fMRI and event-related potentials (ERPs) overwhelmingly support the parallel activation hypothesis.

According to parallel activation theory, when a bilingual individual listens to or reads a word in one language, words in all known languages that share phonological or orthographic overlap are co-activated in parallel. For example, when a Spanish-English bilingual hears the word "pie" (foot in Spanish, dessert in English), neural representations for both semantic concepts are triggered simultaneously within milliseconds.

To resolve this conflict and select the target concept, the executive control network—primarily involving the dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)—is continuously engaged. This constant recruitment of domain-general executive function mechanism is widely believed to generate cognitive advantages in task switching and inhibitory control throughout the lifespan.''',
              sectionNumber: 2,
              questions: [
                MockQuestion(
                  id: 'q5',
                  orderIndex: 5,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt: 'Recent neuroimaging studies support the theory that multilinguals have separate mental lexicons.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation: 'Paragraph 1 notes that previous research postulated separate lexicons, but contemporary neuroimaging studies "overwhelmingly support the parallel activation hypothesis".',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q6',
                  orderIndex: 6,
                  questionType: QuestionType.sentenceCompletion,
                  prompt: 'The parallel activation hypothesis suggests that words in all known languages are co-activated in _____.',
                  options: [],
                  correctAnswer: 'parallel',
                  explanation: 'Paragraph 2 specifies that words sharing phonological or orthographic overlap are "co-activated in parallel".',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q7',
                  orderIndex: 7,
                  questionType: QuestionType.multipleChoice,
                  prompt: 'Which brain regions are primarily involved in executive control during multilingual word selection?',
                  options: [
                    'A) Primary auditory cortex and occipital lobe',
                    'B) Dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)',
                    'C) Cerebellum and brainstem',
                    'D) Hippocampus and amygdala'
                  ],
                  correctAnswer: 'B) Dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)',
                  explanation: 'Paragraph 3 directly identifies the DLPFC and ACC as the key areas engaged.',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q8',
                  orderIndex: 8,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt: 'Bilingual cognitive advantages are only present during early childhood.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation: 'Paragraph 3 notes cognitive advantages in task switching and control "throughout the lifespan", not just childhood.',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
              ],
            ),
          ],
        ),
        MockExamSection(
          id: 'sec_listening_01',
          skill: MockSkill.listening,
          title: 'Academic Listening Test 1',
          timeLimitMinutes: 30,
          audioUrl: 'https://example.com/audio/ielts_listening_mock1.mp3',
          transcript: '''SECTION 1: Conversation between a University Student & Housing Officer.
Housing Officer: Good morning, International Student Housing Office. How can I help you today?
Student: Hello, my name is Alex Chen. I'm arriving at Greenwood Campus next semester, and I need to book student accommodation.
Housing Officer: Welcome Alex! We have two main hall options available: Westgate College and Oakridge Hall. Westgate costs £150 per week including utilities, while Oakridge is £180 per week with en-suite bathrooms.
Student: I think Westgate fits my budget better. Does it include high-speed internet access?
Housing Officer: Yes, unlimited fiber Wi-Fi is included in all rooms. You just need to pay a £200 refundable deposit upon booking.

SECTION 2: Monologue on Campus Health & Sports Facilities.
Speaker: Welcome to the University Sports Center orientation tour. Our facility offers an Olympic-sized 50-meter swimming pool, a 3-floor fitness gym, and indoor squash courts. Membership for full-time students is discounted to £25 per month. The gym is open daily from 6:00 AM to 10:00 PM.''',
          questions: [
            MockQuestion(
              id: 'l1',
              orderIndex: 1,
              questionType: QuestionType.multipleChoice,
              prompt: 'How much is the weekly rent for Westgate College accommodation?',
              options: ['A) £120', 'B) £150', 'C) £180', 'D) £200'],
              correctAnswer: 'B) £150',
              explanation: 'The housing officer states: "Westgate costs £150 per week including utilities".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l2',
              orderIndex: 2,
              questionType: QuestionType.sentenceCompletion,
              prompt: 'Students are required to pay a refundable deposit of £_____ upon booking.',
              options: [],
              correctAnswer: '200',
              explanation: 'The housing officer mentions a "£200 refundable deposit upon booking".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l3',
              orderIndex: 3,
              questionType: QuestionType.trueFalseNotGiven,
              prompt: 'Oakridge Hall features private en-suite bathrooms.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'True',
              explanation: 'The officer specifies Oakridge is "£180 per week with en-suite bathrooms".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l4',
              orderIndex: 4,
              questionType: QuestionType.multipleChoice,
              prompt: 'What is the discounted monthly sports membership fee for full-time students?',
              options: ['A) £15', 'B) £20', 'C) £25', 'D) £30'],
              correctAnswer: 'C) £25',
              explanation: 'The speaker announces: "Membership for full-time students is discounted to £25 per month".',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l5',
              orderIndex: 5,
              questionType: QuestionType.sentenceCompletion,
              prompt: 'The campus fitness gym opens every morning at _____ AM.',
              options: [],
              correctAnswer: '6:00',
              explanation: 'The speaker states the gym is open daily from 6:00 AM to 10:00 PM.',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l6',
              orderIndex: 6,
              questionType: QuestionType.multipleChoice,
              prompt: 'What size is the campus swimming pool described in the orientation?',
              options: ['A) 25-meter', 'B) 50-meter', 'C) 100-meter', 'D) 10-meter'],
              correctAnswer: 'B) 50-meter',
              explanation: 'The speaker mentions an "Olympic-sized 50-meter swimming pool".',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l7',
              orderIndex: 7,
              questionType: QuestionType.trueFalseNotGiven,
              prompt: 'Non-students can also join the campus sports center for £25 per month.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'False',
              explanation: 'The £25 rate is specifically stated as a discounted rate for full-time students.',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l8',
              orderIndex: 8,
              questionType: QuestionType.sentenceCompletion,
              prompt: 'High-speed _____ Wi-Fi is included in Westgate accommodation rooms.',
              options: [],
              correctAnswer: 'fiber',
              explanation: 'The housing officer states: "unlimited fiber Wi-Fi is included".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l9',
              orderIndex: 9,
              questionType: QuestionType.multipleChoice,
              prompt: 'Which housing option has en-suite rooms for £180/week?',
              options: ['A) Westgate College', 'B) Oakridge Hall', 'C) Greenwood House', 'D) Parkside Villa'],
              correctAnswer: 'B) Oakridge Hall',
              explanation: 'The housing officer explicitly states Oakridge Hall is £180 per week with en-suite.',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l10',
              orderIndex: 10,
              questionType: QuestionType.trueFalseNotGiven,
              prompt: 'Alex Chen decided to book Oakridge Hall accommodation.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'False',
              explanation: 'Alex stated: "I think Westgate fits my budget better".',
              sectionNumber: 1,
            ),
          ],
        ),
      ],
    );
  }
}
