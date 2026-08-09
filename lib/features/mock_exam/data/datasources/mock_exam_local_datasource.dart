import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../../domain/entities/mock_exam_passage.dart';
import '../../domain/entities/mock_exam_section.dart';
import '../../domain/entities/mock_question.dart';
import '../models/mock_exam_paper_model.dart';

/// Seed data provider and local data source for Mock Exam papers.
class SampleMockExamData {
  SampleMockExamData._();

  static MockExamPaper getSampleAcademicPaper() {
    return MockExamPaper(
      id: 'paper_academic_01',
      title: 'Cambridge Official Practice Test 1 (Academic)',
      examType: ExamType.academic,
      description:
          'Full Academic IELTS Mock Test with updated 2026 format for Reading & Listening.',
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
              content:
                  '''Modern urban centers consume over 70% of global primary energy and generate a proportionate share of greenhouse emissions. In response to mounting climate pressure, eco-architects are pioneering net-zero urban development models that integrate passive solar design, bio-climatic facades, and decentralized smart microgrids.

Historically, urban growth relied heavily on centralized fossil-fueled power stations situated far from residential areas. Modern renewable urban planning flips this paradigm by transforming buildings themselves into primary energy harvesting units. Photovoltaic solar tiles embedded in roofs, transparent solar glass windows, and vertical kinetic wind turbines on high-rise corners allow skyscrapers to function as localized energy producers.

Furthermore, thermal energy storage systems utilizing phase-change materials enable buildings to store excess heat absorbed during peak daylight hours and release it during cooler night periods. This minimizes dependence on mechanical HVAC units and significantly reduces urban heat island effects.

However, transitioning existing historic metropolises presents substantial logistical and socioeconomic challenges. Retrofitted historical structures must comply with strict aesthetic conservation guidelines while meeting rigorous contemporary energy performance benchmarks. Financial incentives, public-private partnerships, and regulatory building codes play a critical role in accelerating this transformation across global cities.''',
              sectionNumber: 1,
              questions: [
                MockQuestion(
                  id: 'q1',
                  orderIndex: 1,
                  questionType: QuestionType.multipleChoice,
                  prompt:
                      'What proportion of global primary energy is consumed by modern urban centers?',
                  options: [
                    'A) Under 30%',
                    'B) Approximately 50%',
                    'C) Over 70%',
                    'D) Exactly 100%',
                  ],
                  correctAnswer: 'C) Over 70%',
                  explanation:
                      'The passage explicitly states: "Modern urban centers consume over 70% of global primary energy".',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q2',
                  orderIndex: 2,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt:
                      'Historical urban growth relied on power stations located within city centers.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation:
                      'The passage states historical urban growth relied on power stations "situated far from residential areas", making the statement False.',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q3',
                  orderIndex: 3,
                  questionType: QuestionType.sentenceCompletion,
                  prompt:
                      'Thermal energy storage systems utilize _____ materials to absorb and release heat.',
                  options: [],
                  correctAnswer: 'phase-change',
                  explanation:
                      'Paragraph 3 explicitly mentions "thermal energy storage systems utilizing phase-change materials".',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
                MockQuestion(
                  id: 'q4',
                  orderIndex: 4,
                  questionType: QuestionType.multipleChoice,
                  prompt:
                      'Which innovation allows skyscrapers to function as localized energy producers?',
                  options: [
                    'A) Diesel generators in basements',
                    'B) Photovoltaic solar tiles and transparent solar glass',
                    'C) Coal heating units',
                    'D) High-voltage overhead cables',
                  ],
                  correctAnswer:
                      'B) Photovoltaic solar tiles and transparent solar glass',
                  explanation:
                      'Paragraph 2 highlights photovoltaic solar tiles and transparent solar glass windows as key technologies.',
                  passageId: 'passage_01',
                  sectionNumber: 1,
                ),
              ],
            ),
            MockExamPassage(
              id: 'passage_02',
              title:
                  'Passage 2: Cognitive Neuroscience of Multilingual Lexical Processing',
              content:
                  '''Neurolinguistic investigations over the past two decades have fundamentally altered our understanding of how multilingual individuals store and retrieve words across multiple languages. Previously, researchers postulated the existence of separate non-overlapping mental lexicons for each spoken language. Contemporary neuroimaging studies utilizing fMRI and event-related potentials (ERPs) overwhelmingly support the parallel activation hypothesis.

According to parallel activation theory, when a bilingual individual listens to or reads a word in one language, words in all known languages that share phonological or orthographic overlap are co-activated in parallel. For example, when a Spanish-English bilingual hears the word "pie" (foot in Spanish, dessert in English), neural representations for both semantic concepts are triggered simultaneously within milliseconds.

To resolve this conflict and select the target concept, the executive control network—primarily involving the dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)—is continuously engaged. This constant recruitment of domain-general executive function mechanism is widely believed to generate cognitive advantages in task switching and inhibitory control throughout the lifespan.''',
              sectionNumber: 2,
              questions: [
                MockQuestion(
                  id: 'q5',
                  orderIndex: 5,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt:
                      'Recent neuroimaging studies support the theory that multilinguals have separate mental lexicons.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation:
                      'Paragraph 1 notes that previous research postulated separate lexicons, but contemporary neuroimaging studies "overwhelmingly support the parallel activation hypothesis".',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q6',
                  orderIndex: 6,
                  questionType: QuestionType.sentenceCompletion,
                  prompt:
                      'The parallel activation hypothesis suggests that words in all known languages are co-activated in _____.',
                  options: [],
                  correctAnswer: 'parallel',
                  explanation:
                      'Paragraph 2 specifies that words sharing phonological or orthographic overlap are "co-activated in parallel".',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q7',
                  orderIndex: 7,
                  questionType: QuestionType.multipleChoice,
                  prompt:
                      'Which brain regions are primarily involved in executive control during multilingual word selection?',
                  options: [
                    'A) Primary auditory cortex and occipital lobe',
                    'B) Dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)',
                    'C) Cerebellum and brainstem',
                    'D) Hippocampus and amygdala',
                  ],
                  correctAnswer:
                      'B) Dorsolateral prefrontal cortex (DLPFC) and anterior cingulate cortex (ACC)',
                  explanation:
                      'Paragraph 3 directly identifies the DLPFC and ACC as the key areas engaged.',
                  passageId: 'passage_02',
                  sectionNumber: 2,
                ),
                MockQuestion(
                  id: 'q8',
                  orderIndex: 8,
                  questionType: QuestionType.trueFalseNotGiven,
                  prompt:
                      'Bilingual cognitive advantages are only present during early childhood.',
                  options: ['True', 'False', 'Not Given'],
                  correctAnswer: 'False',
                  explanation:
                      'Paragraph 3 notes cognitive advantages in task switching and control "throughout the lifespan", not just childhood.',
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
          transcript:
              '''SECTION 1: Conversation between a University Student & Housing Officer.
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
              prompt:
                  'How much is the weekly rent for Westgate College accommodation?',
              options: ['A) £120', 'B) £150', 'C) £180', 'D) £200'],
              correctAnswer: 'B) £150',
              explanation:
                  'The housing officer states: "Westgate costs £150 per week including utilities".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l2',
              orderIndex: 2,
              questionType: QuestionType.sentenceCompletion,
              prompt:
                  'Students are required to pay a refundable deposit of £_____ upon booking.',
              options: [],
              correctAnswer: '200',
              explanation:
                  'The housing officer mentions a "£200 refundable deposit upon booking".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l3',
              orderIndex: 3,
              questionType: QuestionType.trueFalseNotGiven,
              prompt: 'Oakridge Hall features private en-suite bathrooms.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'True',
              explanation:
                  'The officer specifies Oakridge is "£180 per week with en-suite bathrooms".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l4',
              orderIndex: 4,
              questionType: QuestionType.multipleChoice,
              prompt:
                  'What is the discounted monthly sports membership fee for full-time students?',
              options: ['A) £15', 'B) £20', 'C) £25', 'D) £30'],
              correctAnswer: 'C) £25',
              explanation:
                  'The speaker announces: "Membership for full-time students is discounted to £25 per month".',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l5',
              orderIndex: 5,
              questionType: QuestionType.sentenceCompletion,
              prompt: 'The campus fitness gym opens every morning at _____ AM.',
              options: [],
              correctAnswer: '6:00',
              explanation:
                  'The speaker states the gym is open daily from 6:00 AM to 10:00 PM.',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l6',
              orderIndex: 6,
              questionType: QuestionType.multipleChoice,
              prompt:
                  'What size is the campus swimming pool described in the orientation?',
              options: [
                'A) 25-meter',
                'B) 50-meter',
                'C) 100-meter',
                'D) 10-meter',
              ],
              correctAnswer: 'B) 50-meter',
              explanation:
                  'The speaker mentions an "Olympic-sized 50-meter swimming pool".',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l7',
              orderIndex: 7,
              questionType: QuestionType.trueFalseNotGiven,
              prompt:
                  'Non-students can also join the campus sports center for £25 per month.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'False',
              explanation:
                  'The £25 rate is specifically stated as a discounted rate for full-time students.',
              sectionNumber: 2,
            ),
            MockQuestion(
              id: 'l8',
              orderIndex: 8,
              questionType: QuestionType.sentenceCompletion,
              prompt:
                  'High-speed _____ Wi-Fi is included in Westgate accommodation rooms.',
              options: [],
              correctAnswer: 'fiber',
              explanation:
                  'The housing officer states: "unlimited fiber Wi-Fi is included".',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l9',
              orderIndex: 9,
              questionType: QuestionType.multipleChoice,
              prompt: 'Which housing option has en-suite rooms for £180/week?',
              options: [
                'A) Westgate College',
                'B) Oakridge Hall',
                'C) Greenwood House',
                'D) Parkside Villa',
              ],
              correctAnswer: 'B) Oakridge Hall',
              explanation:
                  'The housing officer explicitly states Oakridge Hall is £180 per week with en-suite.',
              sectionNumber: 1,
            ),
            MockQuestion(
              id: 'l10',
              orderIndex: 10,
              questionType: QuestionType.trueFalseNotGiven,
              prompt: 'Alex Chen decided to book Oakridge Hall accommodation.',
              options: ['True', 'False', 'Not Given'],
              correctAnswer: 'False',
              explanation:
                  'Alex stated: "I think Westgate fits my budget better".',
              sectionNumber: 1,
            ),
          ],
        ),
      ],
    );
  }
}

abstract class MockExamLocalDatasource {
  Future<List<MockExamPaperModel>> getAvailableExams({ExamType? examType});
  Future<MockExamPaperModel> getExamPaperById(String paperId);
}

class MockExamLocalDatasourceImpl implements MockExamLocalDatasource {
  @override
  Future<List<MockExamPaperModel>> getAvailableExams({
    ExamType? examType,
  }) async {
    final samplePaper = SampleMockExamData.getSampleAcademicPaper();
    final paper1 = MockExamPaperModel.fromEntity(samplePaper);

    final paper2 = MockExamPaperModel.fromEntity(
      MockExamPaper(
        id: 'paper_academic_02',
        title: 'Cambridge Official Practice Test 2',
        examType: examType ?? ExamType.academic,
        description:
            'Advanced passage difficulty featuring high-frequency C1 collocations.',
        difficulty: 'Hard',
        sections: samplePaper.sections,
      ),
    );

    final all = [paper1, paper2];
    if (examType != null) {
      return all.where((p) => p.examType == examType).toList();
    }
    return all;
  }

  @override
  Future<MockExamPaperModel> getExamPaperById(String paperId) async {
    final exams = await getAvailableExams();
    return exams.firstWhere((p) => p.id == paperId, orElse: () => exams.first);
  }
}
