import 'package:flutter/material.dart';
import '../../domain/entities/polysemy_vocab_item.dart';

/// Curated data source of the most essential IELTS words with multiple meanings.
class PolysemyVocabData {
  PolysemyVocabData._();

  // =========================================================================
  // SET 1: Foundation Academic Polysemes (Words 1 - 10)
  // =========================================================================
  static const PolysemyPracticeSet set1 = PolysemyPracticeSet(
    id: 'set_1',
    title: 'Pack 1: Core Academic Essentials',
    description: 'High-frequency words essential for Reading & Task 2 Essays',
    items: [
      PolysemyVocabItem(
        id: 'w_address',
        word: 'Address',
        phonetic: '/əˈdres/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To think about and begin to deal with a problem or issue.',
            partOfSpeech: 'verb',
            exampleSentence: 'The government must urgently address the shortage of affordable housing in urban areas.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To speak directly to a person or an assembly.',
            partOfSpeech: 'verb',
            exampleSentence: 'The professor addressed the symposium on climate mitigation.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'The particulars of the place where someone lives or an organization is situated.',
            partOfSpeech: 'noun',
            exampleSentence: 'Please provide your permanent residential address.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_address_1',
            targetWord: 'Address',
            contextSentence:
                'Unless policymakers enact stringent emissions caps to address runaway greenhouse gas emissions, coastal cities will face irreversible inundation.',
            highlightedWord: 'address',
            options: [
              'A) To speak formally to a public delegation',
              'B) To record the physical location of an entity',
              'C) To confront and begin dealing with a difficult issue',
              'D) To send correspondence through the postal service',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 0,
            explanation:
                'In academic and policy texts, "address" most often means to confront, tackle, or deal with a serious problem rather than speaking or writing a mailing address.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_compromise',
        word: 'Compromise',
        phonetic: '/ˈkɒmprəmaɪz/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To weaken, undermine, or expose to danger or suspicion.',
            partOfSpeech: 'verb',
            exampleSentence: 'Poor cyber hygiene can compromise an institution’s confidential data.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'An agreement reached by each side making mutual concessions.',
            partOfSpeech: 'noun',
            exampleSentence: 'Both negotiators eventually reached an amicable compromise.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'To settle a dispute by mutual concession.',
            partOfSpeech: 'verb',
            exampleSentence: 'Neither party was willing to compromise on salary terms.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_compromise_1',
            targetWord: 'Compromise',
            contextSentence:
                'Substandard building materials compromised the structural stability of the high-rise tower, leading to catastrophic seismic failure.',
            highlightedWord: 'compromised',
            options: [
              'A) Settled a dispute through mutual negotiation',
              'B) Undermined, weakened, or put at grave risk',
              'C) Guaranteed absolute safety under rigorous testing',
              'D) Officially ratified an international treaty',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In scientific and engineering IELTS passages, "compromise" regularly means to weaken or damage the integrity/safety of a structure or system.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_novel',
        word: 'Novel',
        phonetic: '/ˈnɒvəl/',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'Strikingly new, unusual, or original in style or conception.',
            partOfSpeech: 'adjective',
            exampleSentence: 'The biochemical lab devised a novel mechanism to synthesize organic polymers.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A fictitious prose narrative of book length.',
            partOfSpeech: 'noun',
            exampleSentence: 'He published his first historical novel in 1998.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_novel_1',
            targetWord: 'Novel',
            contextSentence:
                'The bioengineering team pioneered a novel approach to water desalination, utilizing solar-activated graphene membranes.',
            highlightedWord: 'novel',
            options: [
              'A) A long narrative fictional book',
              'B) Exceptionally outdated and traditional',
              'C) Strikingly new, innovative, and unprecedented',
              'D) Purely theoretical and untested in practice',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 0,
            explanation:
                'In academic texts, "novel" is almost always an adjective meaning original, innovative, or new, rather than a literary novel.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_sound',
        word: 'Sound',
        phonetic: '/saʊnd/',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'Based on valid reasoning, evidence, or judgment; reliable and robust.',
            partOfSpeech: 'adjective',
            exampleSentence: 'The committee rejected the hypothesis because it lacked sound methodology.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Vibrations travelling through the air or another medium heard by ears.',
            partOfSpeech: 'noun',
            exampleSentence: 'The sudden sound startled everyone in the quiet room.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'In good condition; physically healthy or undamaged.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Despite the storm, the timber foundation remained completely sound.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_sound_1',
            targetWord: 'Sound',
            contextSentence:
                'Macroeconomic decisions must be anchored in sound statistical modeling rather than speculative political rhetoric.',
            highlightedWord: 'sound',
            options: [
              'A) Audible acoustic vibrations detectable by the ear',
              'B) Logically robust, reliable, and grounded in truth',
              'C) Extremely loud and overwhelming in volume',
              'D) Temporary and fleeting in duration',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'Academic IELTS reading passages use "sound" as an adjective denoting rigor, reliability, and logical validity (e.g. "sound advice", "sound conclusion").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_discipline',
        word: 'Discipline',
        phonetic: '/ˈdɪs.ə.plɪn/',
        generalPartOfSpeech: 'noun / verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'A specific branch of knowledge, learning, or academic study.',
            partOfSpeech: 'noun',
            exampleSentence: 'Biotechnology is a cross-cutting discipline requiring expertise in genetics and informatics.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'The practice of training people to obey rules, using punishment to correct disobedience.',
            partOfSpeech: 'noun',
            exampleSentence: 'The school had strict standards of student discipline.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_discipline_1',
            targetWord: 'Discipline',
            contextSentence:
                'Quantum computing intersects multiple scientific disciplines, uniting theoretical physics, materials science, and cryptography.',
            highlightedWord: 'disciplines',
            options: [
              'A) Harsh punitive measures administered to offenders',
              'B) Distinct branches of academic learning and research',
              'C) Daily fitness and endurance training routines',
              'D) Strict behavioral regulations within an army',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In academic contexts, "discipline" refers to a scholarly subject or field of study, not behavioral punishment or self-control.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_subject',
        word: 'Subject',
        phonetic: '/ˈsʌbdʒɪkt/ (n) /səbˈdʒekt/ (v)',
        generalPartOfSpeech: 'noun / adjective / verb',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'Likely or prone to be affected by something undesirable; dependent upon.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Airline ticket fares are subject to substantial seasonal fluctuations.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A person or animal being tested or studied in a scientific experiment.',
            partOfSpeech: 'noun',
            exampleSentence: 'Cognitive responses of fifty human subjects were recorded.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A branch of knowledge studied in a school or college.',
            partOfSpeech: 'noun',
            exampleSentence: 'Mathematics was her favorite subject at school.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_subject_1',
            targetWord: 'Subject',
            contextSentence:
                'Any proposed expansion of the protected wetlands remains subject to formal environmental impact assessments.',
            highlightedWord: 'subject to',
            options: [
              'A) Dependent upon or conditioned by official requirements',
              'B) The central topic of a school textbook',
              'C) A laboratory participant undergoing a clinical trial',
              'D) Forced to endure cruel physical punishment',
            ],
            correctOptionIndex: 0,
            targetSenseIndex: 0,
            explanation:
                '"Subject to" is an essential academic phrase meaning conditional upon or vulnerable to something.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_scale',
        word: 'Scale',
        phonetic: '/skeɪl/',
        generalPartOfSpeech: 'noun / verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'The relative size, extent, or proportion of something compared to standard dimensions.',
            partOfSpeech: 'noun',
            exampleSentence: 'The unprecedented scale of deforestation stunned environmental observers.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To climb up or over something high and steep.',
            partOfSpeech: 'verb',
            exampleSentence: 'Mountaineers successfully scaled the vertical cliff face.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'An instrument used for weighing objects or people.',
            partOfSpeech: 'noun',
            exampleSentence: 'She weighed the chemical powder on the digital scale.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_scale_1',
            targetWord: 'Scale',
            contextSentence:
                'Economies of scale enable colossal multinational conglomerates to dramatically slash manufacturing overheads.',
            highlightedWord: 'scale',
            options: [
              'A) Flakes of keratin covering the skin of reptiles and fish',
              'B) A laboratory instrument used for measuring mass',
              'C) The size, scope, or volume of production operations',
              'D) The act of ascending a steep mountain slope',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 0,
            explanation:
                '"Economies of scale" is a foundational IELTS economics collocation referring to cost advantages resulting from large production size/scope.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_yield',
        word: 'Yield',
        phonetic: '/jiːld/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To produce, generate, or supply a desirable result, crop, or profit.',
            partOfSpeech: 'verb / noun',
            exampleSentence: 'Genetic hybridization yielded crops that withstood acute drought conditions.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To surrender, concede, or submit under sustained pressure.',
            partOfSpeech: 'verb',
            exampleSentence: 'The defensive military garrison eventually yielded to intense bombardment.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'To give way to oncoming traffic at a junction.',
            partOfSpeech: 'verb',
            exampleSentence: 'Drivers must yield to vehicles approaching from the left.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_yield_1',
            targetWord: 'Yield',
            contextSentence:
                'Extensive archaeological excavations along the river basin yielded invaluable relics from the Bronze Age.',
            highlightedWord: 'yielded',
            options: [
              'A) Surrendered unconditionally to rival forces',
              'B) Produced, unveiled, or brought forth valuable findings',
              'C) Slowed down vehicle speed at a road intersection',
              'D) Collapsed structurally beneath heavy tectonic strain',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In research, science, and archaeology, "yield" means to generate, produce, or bring forth results.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_state',
        word: 'State',
        phonetic: '/steɪt/',
        generalPartOfSpeech: 'noun / verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'The particular physical or mental condition that someone or something is in.',
            partOfSpeech: 'noun',
            exampleSentence: 'The bridge had fallen into a derelict state of decay.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'To express something clearly and formally in speech or writing.',
            partOfSpeech: 'verb',
            exampleSentence: 'The author explicitly stated the research limitations.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A nation or territory considered as an organized political community under one government.',
            partOfSpeech: 'noun',
            exampleSentence: 'Healthcare subsidies should be guaranteed by the state.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_state_1',
            targetWord: 'State',
            contextSentence:
                'Respondents were requested to state their primary motivation for adopting telecommuting arrangements.',
            highlightedWord: 'state',
            options: [
              'A) A federal territory under sovereign national jurisdiction',
              'B) A temporary physical condition of matter such as solid or gas',
              'C) Express or articulate formally in words',
              'D) Overturn or invalidate a previously declared law',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 1,
            explanation:
                'In academic surveys and IELTS test prompts, "state" as a verb means to express, formulate, or declare clearly.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_harbour',
        word: 'Harbour',
        phonetic: '/ˈhɑː.bər/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To secretly hold or maintain a belief, suspicion, or grudge; or to shelter bacteria/pathogens.',
            partOfSpeech: 'verb',
            exampleSentence: 'Stagnant reservoirs harbour disease-transmitting mosquito larvae.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A sheltered port along a coast where ships seek safety.',
            partOfSpeech: 'noun',
            exampleSentence: 'Dozens of fishing vessels anchored safely in the deep-water harbour.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_harbour_1',
            targetWord: 'Harbour',
            contextSentence:
                'Damp and poorly ventilated living spaces frequently harbour airborne fungal spores that trigger acute respiratory distress.',
            highlightedWord: 'harbour',
            options: [
              'A) Provide a coastal berth for seafaring merchant ships',
              'B) Shelter, house, or provide a haven for microorganisms',
              'C) Construct an engineered artificial sea defense',
              'D) Officially deport undocumented foreign visitors',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In IELTS biology and medical passages, "harbour" is used as a verb meaning to carry, sustain, or shelter pathogens or parasites.',
          ),
        ],
      ),
    ],
  );

  // =========================================================================
  // SET 2: Research & Analysis Polysemes (Words 11 - 20)
  // =========================================================================
  static const PolysemyPracticeSet set2 = PolysemyPracticeSet(
    id: 'set_2',
    title: 'Pack 2: Research & Analysis Polysemes',
    description: 'Words frequently appearing in scientific passages and data commentary',
    items: [
      PolysemyVocabItem(
        id: 'w_observe',
        word: 'Observe',
        phonetic: '/əbˈzɜːv/',
        generalPartOfSpeech: 'verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To obey or comply with a law, rule, religious ritual, or tradition.',
            partOfSpeech: 'verb',
            exampleSentence: 'Citizens are expected to strictly observe civil aviation security guidelines.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To notice, perceive, or monitor scientifically over time.',
            partOfSpeech: 'verb',
            exampleSentence: 'Astronomers observed minute changes in celestial luminosity.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'To comment or remark on an occurrence.',
            partOfSpeech: 'verb',
            exampleSentence: '"It has become unseasonably humid," the guide observed.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_observe_1',
            targetWord: 'Observe',
            contextSentence:
                'Unless all affiliated laboratories observe standardized calibration protocols, cross-institutional comparisons are meaningless.',
            highlightedWord: 'observe',
            options: [
              'A) Visually inspect through an optical microscope',
              'B) Adhere strictly to, comply with, or follow rules',
              'C) Remark informally during a social conversation',
              'D) Dismiss as antiquated or non-functional',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In legal, organizational, and protocol contexts, "observe" means to adhere strictly to rules or customs.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_sustain',
        word: 'Sustain',
        phonetic: '/səˈsteɪn/',
        generalPartOfSpeech: 'verb',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To undergo, experience, or suffer damage, injury, or loss.',
            partOfSpeech: 'verb',
            exampleSentence: 'The offshore wind turbine sustained severe structural erosion during the gale.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To strengthen or support physically or mentally; to keep alive.',
            partOfSpeech: 'verb',
            exampleSentence: 'Adequate nourishment is vital to sustain human life in polar climates.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'To maintain or cause to continue over an extended period.',
            partOfSpeech: 'verb',
            exampleSentence: 'Developing economies struggled to sustain rapid GDP growth.',
            cefrLevel: 'B2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_sustain_1',
            targetWord: 'Sustain',
            contextSentence:
                'The historic cathedral sustained profound architectural impairment during the nighttime artillery blitz.',
            highlightedWord: 'sustained',
            options: [
              'A) Preserved in pristine, unspoiled condition',
              'B) Endured, suffered, or experienced severe harm',
              'C) Financed through generous governmental subsidies',
              'D) Demolished deliberately by urban planners',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'When paired with damage, injury, losses, or casualties, "sustain" means to suffer or experience that harm.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_temper',
        word: 'Temper',
        phonetic: '/ˈtem.pər/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1 / C2',
        senses: [
          VocabSense(
            definition: 'To moderate, soften, tone down, or balance the harshness of something.',
            partOfSpeech: 'verb',
            exampleSentence: 'Economists urged the central bank to temper its aggressive interest rate hikes.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To heat and then cool metals or glass to increase toughness and reduce brittleness.',
            partOfSpeech: 'verb',
            exampleSentence: 'Tempered steel resists fracture under sudden mechanical impact.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A person’s state of mind seen in terms of their being angry or calm.',
            partOfSpeech: 'noun',
            exampleSentence: 'He struggled to control his explosive temper during the heated meeting.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_temper_1',
            targetWord: 'Temper',
            contextSentence:
                'Technological optimism regarding artificial intelligence must be tempered by realistic evaluations of ethical perils.',
            highlightedWord: 'tempered',
            options: [
              'A) Enraged through constant provocative agitation',
              'B) Softened, moderated, or balanced by prudence',
              'C) Heated rapidly inside an industrial smelting furnace',
              'D) Magnified exponentially beyond reasonable limits',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In Band 8–9 academic discourse, "to temper X with Y" means to moderate or counterbalance enthusiasm or harshness with sober judgment.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_appreciate',
        word: 'Appreciate',
        phonetic: '/əˈpriː.ʃi.eɪt/',
        generalPartOfSpeech: 'verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To increase in monetary or investment value over a period of time.',
            partOfSpeech: 'verb',
            exampleSentence: 'Commercial properties in the financial district appreciated by 15% annually.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To fully understand the gravity, difficulty, or full implications of a situation.',
            partOfSpeech: 'verb',
            exampleSentence: 'Novice researchers seldom appreciate the logistical hurdles of polar expeditions.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To recognize the full worth of; to be grateful for.',
            partOfSpeech: 'verb',
            exampleSentence: 'I truly appreciate your thoughtful assistance with my dissertation.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_appreciate_1',
            targetWord: 'Appreciate',
            contextSentence:
                'Due to finite availability and mounting institutional demand, prime agricultural acreage has appreciated considerably.',
            highlightedWord: 'appreciated',
            options: [
              'A) Formally expressed gratitude to foreign investors',
              'B) Gained financial worth and monetary value over time',
              'C) Understood the artistic subtleties of modern design',
              'D) Deteriorated in quality and arable fertility',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In economics and business IELTS passages, "appreciate" refers to asset growth in monetary value (the direct antonym of "depreciate").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_check',
        word: 'Check',
        phonetic: '/tʃek/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To halt, curb, restrain, or suppress an undesirable growth, movement, or power.',
            partOfSpeech: 'verb',
            exampleSentence: 'Stringent environmental regulations are designed to check toxic industrial emissions.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To examine something in order to determine its accuracy, quality, or condition.',
            partOfSpeech: 'verb',
            exampleSentence: 'Engineers checked the electrical circuits before turning on the power.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'A pattern of small squares of alternating colors.',
            partOfSpeech: 'noun',
            exampleSentence: 'She bought a woolen scarf in a red and black check.',
            cefrLevel: 'A2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_check_1',
            targetWord: 'Check',
            contextSentence:
                'The supreme court serves as a constitutional bulwark to check executive overreach and uphold the rule of law.',
            highlightedWord: 'check',
            options: [
              'A) Put a tick mark beside an entry on an inventory sheet',
              'B) Restrain, curb, or limit excessive authority',
              'C) Write a bank payment voucher to transfer funds',
              'D) Inspect visually for minor manufacturing defects',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                '"Checks and balances" is a standard political and academic concept meaning systems that curb or restrain unchecked power.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_register',
        word: 'Register',
        phonetic: '/ˈredʒ.ɪ.stər/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'A variety of a language or style used in specific social or academic contexts (e.g., formal vs. colloquial).',
            partOfSpeech: 'noun',
            exampleSentence: 'Academic essays necessitate a formal linguistic register devoid of slang.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To perceive, notice, or make a mental impression of something.',
            partOfSpeech: 'verb',
            exampleSentence: 'He was so absorbed in study that he did not register the sounding fire alarm.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'An official list or record of names, items, or events.',
            partOfSpeech: 'noun',
            exampleSentence: 'The registrar checked the names entered into the student register.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_register_1',
            targetWord: 'Register',
            contextSentence:
                'Linguists observed that bilingual speakers fluidly shift their linguistic register depending on the professional status of their interlocutor.',
            highlightedWord: 'register',
            options: [
              'A) A hardcopy book used to log daily attendance',
              'B) The tone, vocabulary, and formality level of language',
              'C) A mechanical device calculating cash transactions',
              'D) An official government document certifying marriage',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In IELTS language and sociolinguistic readings, "register" refers to the degree of formality and lexical choice adapted to a setting.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_compound',
        word: 'Compound',
        phonetic: '/ˈkɒm.paʊnd/ (n) /kəmˈpaʊnd/ (v)',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To make an existing problem, misery, or error worse or more intense.',
            partOfSpeech: 'verb',
            exampleSentence: 'Prolonged droughts were compounded by a total breakdown of irrigation networks.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A chemical substance formed from two or more elements chemically united in fixed proportions.',
            partOfSpeech: 'noun',
            exampleSentence: 'Water is a chemical compound composed of hydrogen and oxygen.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'A secure, fenced or walled enclosure containing residential buildings.',
            partOfSpeech: 'noun',
            exampleSentence: 'Diplomats resided within a heavily guarded embassy compound.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_compound_1',
            targetWord: 'Compound',
            contextSentence:
                'Severe fiscal mismanagement was compounded by sudden global supply chain bottlenecks, triggering runaway inflation.',
            highlightedWord: 'compounded',
            options: [
              'A) Resolved amicably through bilateral mediation',
              'B) Aggravated, worsened, or intensified',
              'C) Chemically bonded inside a laboratory beaker',
              'D) Encircling a military perimeter with barricades',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In IELTS essays and Reading tests, "compounded by" means magnified or exacerbated by additional complications.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_channel',
        word: 'Channel',
        phonetic: '/ˈtʃæn.əl/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To direct, focus, or allocate money, energy, or resources toward a designated objective.',
            partOfSpeech: 'verb',
            exampleSentence: 'Developing countries must channel more capital into renewable energy infrastructure.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A length of water joining two larger areas of water; or a television frequency band.',
            partOfSpeech: 'noun',
            exampleSentence: 'Merchant freighters navigated through the English Channel.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_channel_1',
            targetWord: 'Channel',
            contextSentence:
                'Philanthropic foundations channeled multimillion-dollar grants toward eradicating neglected tropical diseases.',
            highlightedWord: 'channeled',
            options: [
              'A) Streamed continuous digital video programming online',
              'B) Directed, funneled, or allocated funds purposefully',
              'C) Dredged a deep waterway for maritime navigation',
              'D) Emitted high-frequency electromagnetic audio signals',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In academic and policy writing, "to channel funds/effort into" means to direct or funnel them toward a specific purpose.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_court',
        word: 'Court',
        phonetic: '/kɔːt/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To provoke, invite, or risk disaster, controversy, or severe consequences through reckless actions.',
            partOfSpeech: 'verb',
            exampleSentence: 'Ignoring climate warnings is courting unprecedented humanitarian catastrophes.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To pay romantic attention to someone with an intention towards marriage.',
            partOfSpeech: 'verb',
            exampleSentence: 'The young gentleman courted the aristocrat’s daughter for two years.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'A tribunal presided over by a judge; or an area marked out for playing ball games.',
            partOfSpeech: 'noun',
            exampleSentence: 'The accused stood before the supreme court of justice.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_court_1',
            targetWord: 'Court',
            contextSentence:
                'By dismantling established antitrust safeguards, regulators court catastrophic systemic monopolization across tech markets.',
            highlightedWord: 'court',
            options: [
              'A) Convene a legal tribunal with judges and juries',
              'B) Seek romantic engagement through dating rituals',
              'C) Risk inviting, provoking, or precipitating danger',
              'D) Compete on a marked sports arena like tennis',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 0,
            explanation:
                'The academic collocation "to court disaster/controversy/peril" means to invite or recklessly risk catastrophic consequences.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_minute',
        word: 'Minute',
        phonetic: '/maɪˈnjuːt/ (adj) /ˈmɪn.ɪt/ (n)',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Extremely small in size, volume, or degree; characterized by precise, microscopic attention to detail.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Forensic investigators detected minute quantities of metallic residue on the suspect’s garment.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A period of time equal to sixty seconds.',
            partOfSpeech: 'noun',
            exampleSentence: 'The presentation lasted forty-five minutes.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'An official written record of the proceedings at a formal meeting.',
            partOfSpeech: 'noun',
            exampleSentence: 'The board secretary distributed the draft meeting minutes for approval.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_minute_1',
            targetWord: 'Minute',
            contextSentence:
                'High-resolution electron microscopy permits scientists to observe minute structural defects within silicon microprocessors.',
            highlightedWord: 'minute',
            options: [
              'A) Lasting for precisely sixty seconds in duration',
              'B) Written documentation of a formal board gathering',
              'C) Infinitesimally small, microscopic, or subtle',
              'D) Punctual and adhering strictly to a timetable',
            ],
            correctOptionIndex: 2,
            targetSenseIndex: 0,
            explanation:
                'Pronounced /maɪˈnjuːt/, this adjective is a staple in IELTS science readings to describe microscopic, tiny, or subtle phenomena.',
          ),
        ],
      ),
    ],
  );

  // =========================================================================
  // SET 3: Reading Traps & Band 8/9 Contexts (Words 21 - 30)
  // =========================================================================
  static const PolysemyPracticeSet set3 = PolysemyPracticeSet(
    id: 'set_3',
    title: 'Pack 3: IELTS Reading Traps & Deceptive Meanings',
    description: 'Words with secondary meanings that test-takers routinely confuse',
    items: [
      PolysemyVocabItem(
        id: 'w_current',
        word: 'Current',
        phonetic: '/ˈkʌr.ənt/',
        generalPartOfSpeech: 'noun / adjective',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'A general trend, prevailing sentiment, or ideological movement among a population.',
            partOfSpeech: 'noun',
            exampleSentence: 'An underlying current of popular discontent threatened political stability.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A continuous, directed body of water or air moving in a definite direction; or flow of electricity.',
            partOfSpeech: 'noun',
            exampleSentence: 'Oceanic thermal currents regulate planetary atmospheric temperatures.',
            cefrLevel: 'B1',
          ),
          VocabSense(
            definition: 'Belonging to the present time; happening or being used now.',
            partOfSpeech: 'adjective',
            exampleSentence: 'What is your current employment status?',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_current_1',
            targetWord: 'Current',
            contextSentence:
                'An ominous current of intellectual cynicism permeated post-war European philosophical treatises.',
            highlightedWord: 'current',
            options: [
              'A) A stream of charged electrical electrons in a conductor',
              'B) An underlying tendency, mood, or intellectual trend',
              'C) A fast-flowing hydrodynamic maritime water channel',
              'D) Existing contemporarily at the exact present moment',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In historical and sociological IELTS passages, "current" often denotes an ideological undercurrent or prevailing cultural movement.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_gravity',
        word: 'Gravity',
        phonetic: '/ˈɡræv.ə.ti/',
        generalPartOfSpeech: 'noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Extreme seriousness, solemnity, or profound importance of a situation or crisis.',
            partOfSpeech: 'noun',
            exampleSentence: 'Ministers failed to grasp the full gravity of the brewing financial contagion.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'The force that attracts a body toward the centre of the earth or another physical body.',
            partOfSpeech: 'noun',
            exampleSentence: 'Newton formulated universal mathematical laws governing terrestrial gravity.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_gravity_1',
            targetWord: 'Gravity',
            contextSentence:
                'The sovereign state refused to acknowledge the gravity of its environmental catastrophe, downplaying radiation fallout.',
            highlightedWord: 'gravity',
            options: [
              'A) Natural physical attraction between massive celestial bodies',
              'B) Profound seriousness, critical weight, or dire severity',
              'C) Rapid descent of an aircraft under turbulent drag',
              'D) A state of weightlessness experienced in orbital vacuum',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In formal academic and political commentary, "gravity" refers to the profound seriousness, urgency, or magnitude of a problem.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_pronounced',
        word: 'Pronounced',
        phonetic: '/prəˈnaʊnst/',
        generalPartOfSpeech: 'adjective / verb',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'Very noticeable, prominent, conspicuous, or strongly marked.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Sociologists observed a pronounced demographic shift toward suburban fringe settlements.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Uttered or articulated vocally using speech sounds.',
            partOfSpeech: 'verb',
            exampleSentence: 'The foreign surname is pronounced differently in American English.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'Declared or judged officially by an authority.',
            partOfSpeech: 'verb',
            exampleSentence: 'The coroner officially pronounced the explorer deceased.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_pronounced_1',
            targetWord: 'Pronounced',
            contextSentence:
                'Elderly demographics exhibited a pronounced preference for face-to-face banking interactions over algorithmic smartphone apps.',
            highlightedWord: 'pronounced',
            options: [
              'A) Articulated audibly through vocal cords and tongue',
              'B) Highly noticeable, conspicuous, and distinct',
              'C) Legally proclaimed by an authorized public notary',
              'D) Denounced as unlawful and hazardous by critics',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'As an adjective in IELTS Writing Task 1 and Reading, "pronounced" means conspicuous, distinct, or markedly noticeable (e.g. "a pronounced decline").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_qualify',
        word: 'Qualify',
        phonetic: '/ˈkwɒl.ɪ.faɪ/',
        generalPartOfSpeech: 'verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To limit, restrict, moderate, or add reservations to a statement or claim.',
            partOfSpeech: 'verb',
            exampleSentence: 'The scientist qualified her ambitious claims, emphasizing that initial sample sizes were limited.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To be entitled to a particular benefit or privilege by meeting necessary conditions.',
            partOfSpeech: 'verb',
            exampleSentence: 'Applicants must qualify for governmental tuition assistance.',
            cefrLevel: 'B1',
          ),
          VocabSense(
            definition: 'To complete training or pass an examination that enables one to practice a profession.',
            partOfSpeech: 'verb',
            exampleSentence: 'She qualified as a commercial patent attorney last autumn.',
            cefrLevel: 'B2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_qualify_1',
            targetWord: 'Qualify',
            contextSentence:
                'Before disseminating the statistical conclusions, the lead statistician insisted on qualifying the findings to avert media sensationalism.',
            highlightedWord: 'qualifying',
            options: [
              'A) Granting a vocational certificate of professional competence',
              'B) Adding necessary limitations, nuances, or reservations to a statement',
              'C) Earning eligibility to participate in an international tournament',
              'D) Discarding fraudulent data points from empirical logs',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In academic argument analysis (common in IELTS Reading Section 3), "to qualify a statement" means to make it less absolute by stating conditions or exceptions.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_render',
        word: 'Render',
        phonetic: '/ˈren.dər/',
        generalPartOfSpeech: 'verb',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To cause someone or something to become or be in a specified condition.',
            partOfSpeech: 'verb',
            exampleSentence: 'Sudden subzero temperatures rendered the mechanical pumps completely inoperable.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To provide or give assistance, aid, or service.',
            partOfSpeech: 'verb',
            exampleSentence: 'Emergency paramedics rendered immediate first aid to injured passengers.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To represent or depict artistically in paint, music, or computational 3D graphics.',
            partOfSpeech: 'verb',
            exampleSentence: 'The software rendered a photorealistic 3D architectural mockup.',
            cefrLevel: 'B2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_render_1',
            targetWord: 'Render',
            contextSentence:
                'Extensive subterranean soil salinization has rendered once-fertile agrarian floodplains entirely barren.',
            highlightedWord: 'rendered',
            options: [
              'A) Replaced ancient topsoil with organic synthetic fertilizers',
              'B) Transformed or caused to become a specific state',
              'C) Generated digital computer graphic visual textures',
              'D) Officially submitted written tax filings to treasurers',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                '"Render + [adjective/state]" is an advanced C1 structure meaning to cause something to become that state (e.g., "rendered obsolete", "rendered helpless").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_currency',
        word: 'Currency',
        phonetic: '/ˈkʌr.ən.si/',
        generalPartOfSpeech: 'noun',
        cefrLevel: 'B1 / C1',
        senses: [
          VocabSense(
            definition: 'The state or condition of being commonly accepted, widely believed, or in current use.',
            partOfSpeech: 'noun',
            exampleSentence: 'The outdated theory gained surprising currency among pop psychologists.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A system of money in general use in a particular country.',
            partOfSpeech: 'noun',
            exampleSentence: 'The euro was adopted as the official national currency in 2002.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_currency_1',
            targetWord: 'Currency',
            contextSentence:
                'The conviction that early childhood multilingualism fosters superior cognitive flexibility has gained immense currency among educators.',
            highlightedWord: 'currency',
            options: [
              'A) Banknotes and minted coinage used for trade',
              'B) Widespread acceptance, popularity, or prevalence of an idea',
              'C) Sudden fluctuations in overseas foreign exchange rates',
              'D) Sovereign borrowing bonds issued by central banks',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'The academic idiom "to gain currency" means to achieve widespread belief, acceptance, or vogue within a discipline.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_champion',
        word: 'Champion',
        phonetic: '/ˈtʃæm.pi.ən/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To actively defend, advocate, or fight vigorously for a cause or policy.',
            partOfSpeech: 'verb',
            exampleSentence: 'Eminent climatologists continue to champion renewable solar subsidies.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A person who has defeated all rivals in a competition.',
            partOfSpeech: 'noun',
            exampleSentence: 'The reigning Olympic heavyweight champion defended his gold title.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_champion_1',
            targetWord: 'Champion',
            contextSentence:
                'Grassroots civic associations championed legislation capping maximum working hours for young medical residents.',
            highlightedWord: 'championed',
            options: [
              'A) Won trophies at a national sports championship',
              'B) Vigorously advocated, promoted, and defended a cause',
              'C) Defeated corporate opponents in open litigation',
              'D) Enforced strict punitive penalties on offenders',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In IELTS Writing and Reading, "champion" as a verb means to actively support, advocate, and spearhead a positive cause.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_plastic',
        word: 'Plastic',
        phonetic: '/ˈplæs.tɪk/',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Capable of being easily molded, shaped, adapted, or transformed (flexible neurobiology).',
            partOfSpeech: 'adjective',
            exampleSentence: 'Neuroscientists demonstrated that synaptic connections in the cerebral cortex remain highly plastic throughout adulthood.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Synthetic material made from organic polymers.',
            partOfSpeech: 'noun',
            exampleSentence: 'Single-use plastic bottles contribute substantially to marine pollution.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'Artificial, false, or superficial.',
            partOfSpeech: 'adjective',
            exampleSentence: 'She flashed a stiff, plastic smile at the photographers.',
            cefrLevel: 'B2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_plastic_1',
            targetWord: 'Plastic',
            contextSentence:
                'Because mammalian neural architecture is fundamentally plastic, rehabilitation therapies can rewire neurological motor functions following ischemic stroke.',
            highlightedWord: 'plastic',
            options: [
              'A) Manufactured from non-biodegradable synthetic polymers',
              'B) Highly malleable, adaptive, and capable of remodeling',
              'C) Rigid, brittle, and vulnerable to sudden fracture',
              'D) Fake, inauthentic, or emotionally disingenuous',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In biology/neuroscience (e.g. "neuroplasticity"), "plastic" refers to the capacity to adapt, mold, and physically reconfigure.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_table',
        word: 'Table',
        phonetic: '/ˈteɪ.bəl/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To present formally for discussion or consideration at a meeting (UK/Commonwealth usage).',
            partOfSpeech: 'verb',
            exampleSentence: 'Opposition MPs intend to table an emergency parliamentary motion tomorrow morning.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To postpone consideration of a topic or bill indefinitely (US usage).',
            partOfSpeech: 'verb',
            exampleSentence: 'The senate committee voted to table the budget bill until next spring.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A piece of furniture with a flat top and one or more legs.',
            partOfSpeech: 'noun',
            exampleSentence: 'They gathered around the kitchen table for dinner.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'A set of facts or figures systematically displayed, especially in columns.',
            partOfSpeech: 'noun',
            exampleSentence: 'Table 2 outlines demographic trends over the past decade.',
            cefrLevel: 'A2',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_table_1',
            targetWord: 'Table',
            contextSentence:
                'During the annual summit, the delegation tabled a landmark proposal to establish a multinational carbon offset exchange.',
            highlightedWord: 'tabled',
            options: [
              'A) Placed physically upon a wooden conference table',
              'B) Formally submitted and presented for diplomatic debate',
              'C) Formatted quantitative numbers into rows and columns',
              'D) Annulled and expunged entirely from treaty archives',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In British English and IELTS international diplomacy texts, "to table a proposal" means to formally submit or present it for discussion.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_weather',
        word: 'Weather',
        phonetic: '/ˈweð.ər/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To successfully endure, survive, or overcome a difficult ordeal or economic crisis.',
            partOfSpeech: 'verb',
            exampleSentence: 'The commercial aviation industry weathered the unprecedented pandemic downturn.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To undergo change in appearance, texture, or composition through long exposure to the atmosphere.',
            partOfSpeech: 'verb',
            exampleSentence: 'Centuries of rain and wind had weathered the limestone statuary.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'The state of the atmosphere at a particular place and time as regards heat, cloudiness, dryness, etc.',
            partOfSpeech: 'noun',
            exampleSentence: 'The meteorological bureau forecast inclement weather for the weekend.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_weather_1',
            targetWord: 'Weather',
            contextSentence:
                'Armed with resilient financial reserves, domestic cooperative credit unions weathered the severe liquidity contraction.',
            highlightedWord: 'weathered',
            options: [
              'A) Suffered acute atmospheric deterioration from heavy precipitation',
              'B) Successfully withstood, endured, and survived adversity',
              'C) Anticipated sunshine and dry winds using barometer gauges',
              'D) Dissolved into liquidation due to insolvency',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In economic and corporate IELTS passages, "to weather a storm/crisis" means to withstand adversity and come through intact.',
          ),
        ],
      ),
    ],
  );

  // =========================================================================
  // SET 4: Advanced Academic Discourses (Words 31 - 40)
  // =========================================================================
  static const PolysemyPracticeSet set4 = PolysemyPracticeSet(
    id: 'set_4',
    title: 'Pack 4: Advanced Academic Polysemes',
    description: 'High-level C1/C2 vocabulary tested in complex Reading Section 3 texts',
    items: [
      PolysemyVocabItem(
        id: 'w_spare',
        word: 'Spare',
        phonetic: '/speər/',
        generalPartOfSpeech: 'adjective / verb',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Severely minimal, restrained, elegant, or devoid of unnecessary decoration or surplus words.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Critics lauded the novelist’s spare, stripped-down prose style.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Additional to what is required for ordinary use; extra.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Do you carry a spare tire in the trunk?',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'To refrain from harming, killing, or punishing someone.',
            partOfSpeech: 'verb',
            exampleSentence: 'The king chose to spare the captive rebels.',
            cefrLevel: 'B1',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_spare_1',
            targetWord: 'Spare',
            contextSentence:
                'The architectural pavilion featured a spare, austere interior that celebrated raw concrete and natural daylight.',
            highlightedWord: 'spare',
            options: [
              'A) Unused or held as a surplus backup replacement',
              'B) Minimalist, austere, and devoid of ornate excess',
              'C) Forgiving and merciful toward captured enemies',
              'D) Overly crowded with historical decorative clutter',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In art, design, and literary criticism, "spare" denotes an austere, restrained, and minimalist aesthetic.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_husband',
        word: 'Husband',
        phonetic: '/ˈhʌz.bənd/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C2',
        senses: [
          VocabSense(
            definition: 'To manage, conserve, or use resources prudently and economically.',
            partOfSpeech: 'verb',
            exampleSentence: 'Desert agriculturalists must husband dwindling groundwater reservoirs with extreme diligence.',
            cefrLevel: 'C2',
          ),
          VocabSense(
            definition: 'A married man considered in relation to his spouse.',
            partOfSpeech: 'noun',
            exampleSentence: 'She and her husband relocated to Edinburgh last spring.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_husband_1',
            targetWord: 'Husband',
            contextSentence:
                'Stranded explorers were forced to husband their meager food rations until rescue teams penetrated the blizzard.',
            highlightedWord: 'husband',
            options: [
              'A) Wed through a formal church marriage ceremony',
              'B) Carefully conserve and economize scarce supplies',
              'C) Discard as rotten and hazardous to human health',
              'D) Barter with indigenous tradesmen for weapons',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In formal academic and environmental English, "to husband" is a sophisticated verb meaning to conserve or manage resources carefully (the root of "husbandry").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_warrant',
        word: 'Warrant',
        phonetic: '/ˈwɒr.ənt/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1',
        senses: [
          VocabSense(
            definition: 'To justify, necessitate, or make a particular course of action reasonable.',
            partOfSpeech: 'verb',
            exampleSentence: 'The gravity of the security breach certainly warrants an independent inquiry.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A document issued by a legal or government official authorizing the police to make an arrest or search premises.',
            partOfSpeech: 'noun',
            exampleSentence: 'Detectives procured a judicial search warrant from the magistrate.',
            cefrLevel: 'B2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_warrant_1',
            targetWord: 'Warrant',
            contextSentence:
                'Preliminary blood testing revealed negligible anomalies that did not warrant invasive surgical intervention.',
            highlightedWord: 'warrant',
            options: [
              'A) Serve a formal police arrest summons',
              'B) Justify, legitimize, or necessitate an action',
              'C) Guarantee product repair under manufacturer warranty',
              'D) Overturn an existing legal precedent in court',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In academic reasoning, "to warrant" means that evidence or circumstances justify or call for a specific response.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_discount',
        word: 'Discount',
        phonetic: '/ˈdɪs.kaʊnt/ (n) /dɪsˈkaʊnt/ (v)',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To regard a possibility or fact as being unworthy of consideration or untrue; to dismiss.',
            partOfSpeech: 'verb',
            exampleSentence: 'Anthropologists caution against discounting folklore as mere superstitious fable.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A deduction from the usual cost of something.',
            partOfSpeech: 'noun',
            exampleSentence: 'Students are eligible for a 10% discount on textbooks.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_discount_1',
            targetWord: 'Discount',
            contextSentence:
                'While early historians discounted oral traditions, archaeological digs substantiated the accuracy of tribal chronicles.',
            highlightedWord: 'discounted',
            options: [
              'A) Reduced retail sales prices for holiday shoppers',
              'B) Dismissed as inaccurate or unworthy of serious credence',
              'C) Subsidized via educational government endowment funds',
              'D) Translated ancient dialects into classical Latin prose',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In IELTS Reading and analytical essays, "to discount an explanation/theory" means to dismiss or ignore it as improbable.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_tender',
        word: 'Tender',
        phonetic: '/ˈten.dər/',
        generalPartOfSpeech: 'verb / adjective',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To formally offer or present something (e.g. a resignation, bid, or payment) for acceptance.',
            partOfSpeech: 'verb',
            exampleSentence: 'Following the regulatory scandal, the chief executive tendered his immediate resignation.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Showing gentleness, kindness, and affection.',
            partOfSpeech: 'adjective',
            exampleSentence: 'He cared for the orphaned infant with tender devotion.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'Easy to cut or chew; not tough (of food/meat).',
            partOfSpeech: 'adjective',
            exampleSentence: 'Slow-cooking braised the beef until it was supremely tender.',
            cefrLevel: 'B1',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_tender_1',
            targetWord: 'Tender',
            contextSentence:
                'Engineering consortia submitted formal bids to tender construction proposals for the trans-isthmus rail corridor.',
            highlightedWord: 'tender',
            options: [
              'A) Display emotional affection and loving tenderness',
              'B) Formally offer, bid, or present a commercial proposal',
              'C) Soften edible meat fibers through prolonged stewing',
              'D) Require urgent medical treatment for fragile tissue',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In commerce, law, and formal English, "to tender a bid/resignation/currency" means to formally offer or submit it.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_wax',
        word: 'Wax',
        phonetic: '/wæks/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'C1 / C2',
        senses: [
          VocabSense(
            definition: 'To increase in size, strength, number, or volume; or to become progressively more of something.',
            partOfSpeech: 'verb',
            exampleSentence: 'The lecturer waxed lyrical about the virtues of classical renaissance architecture.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To undergo a cyclical increase in the illuminated surface area of the moon.',
            partOfSpeech: 'verb',
            exampleSentence: 'As the moon waxes toward full, gravitational tidal forces intensify.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A sticky substance produced by bees or synthesized from petroleum, used for candles.',
            partOfSpeech: 'noun',
            exampleSentence: 'Scented wax dripped down the candlestick holder.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_wax_1',
            targetWord: 'Wax',
            contextSentence:
                'Over centuries of imperial rule, sovereign political influence waxed and waned according to military fortunes.',
            highlightedWord: 'waxed and waned',
            options: [
              'A) Melted down like beeswax candles under intense flame',
              'B) Increased and subsequently decreased in strength over time',
              'C) Coated with protective waterproof paraffin grease',
              'D) Remained strictly stagnant and unvarying throughout history',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'The classical idiom "to wax and wane" means to undergo cyclical expansion followed by decline (e.g. power, enthusiasm, or the moon).',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_flag',
        word: 'Flag',
        phonetic: '/flæɡ/',
        generalPartOfSpeech: 'verb / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'To become tired, weaker, or less enthusiastic or effective; to decline.',
            partOfSpeech: 'verb',
            exampleSentence: 'Toward the final marathon stretch, the athlete’s stamina began to flag.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'To mark something for attention or identify an issue.',
            partOfSpeech: 'verb',
            exampleSentence: 'Auditors flagged multiple discrepancies in the accounting ledger.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'A piece of cloth with a distinctive design used as an emblem of a country.',
            partOfSpeech: 'noun',
            exampleSentence: 'The national flag fluttered proudly atop the embassy flagpole.',
            cefrLevel: 'A1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_flag_1',
            targetWord: 'Flag',
            contextSentence:
                'Despite promising initial momentum, consumer enthusiasm for electric vehicles began to flag amid steep charging costs.',
            highlightedWord: 'flag',
            options: [
              'A) Hoist an embroidered national banner on a post',
              'B) Weaken, diminish, droop, or lose vital energy',
              'C) Alert border police to suspicious contraband cargo',
              'D) Celebrate an official patriotic public holiday',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In academic prose, "to flag" means to weaken, wane, or decline in stamina or vigor.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_pedestrian',
        word: 'Pedestrian',
        phonetic: '/pəˈdes.tri.ən/',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Dull, lacking inspiration or excitement; unremarkable, ordinary.',
            partOfSpeech: 'adjective',
            exampleSentence: 'The critic dismissed the cinematic adaptation as pedestrian and clichéd.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'A person walking rather than traveling in a vehicle.',
            partOfSpeech: 'noun',
            exampleSentence: 'The municipality established pedestrian crossings along the avenue.',
            cefrLevel: 'A2',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_pedestrian_1',
            targetWord: 'Pedestrian',
            contextSentence:
                'Compared to the pioneering brilliance of earlier symphonies, the composer’s later repertoire sounded remarkably pedestrian.',
            highlightedWord: 'pedestrian',
            options: [
              'A) Designed specifically for people traveling on foot',
              'B) Monotonous, uninspired, conventional, and dull',
              'C) Featuring swift tempo accelerations and vibrant brass',
              'D) Outlawed on urban municipal expressways and bridges',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In arts and literary IELTS reviews, "pedestrian" as an adjective describes something mundane, unoriginal, and lacking creative sparkle.',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_faculty',
        word: 'Faculty',
        phonetic: '/ˈfæk.əl.ti/',
        generalPartOfSpeech: 'noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'An inherent mental or physical power, capability, or aptitude.',
            partOfSpeech: 'noun',
            exampleSentence: 'Sensory faculties such as audition and eyesight deteriorate naturally with advanced age.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'The teaching and administrative staff in an educational institution.',
            partOfSpeech: 'noun',
            exampleSentence: 'The law school faculty held its annual curriculum review.',
            cefrLevel: 'B2',
            isPrimary: true,
          ),
          VocabSense(
            definition: 'A group of university departments concerned with a major division of knowledge.',
            partOfSpeech: 'noun',
            exampleSentence: 'She enrolled in the Faculty of Medicine.',
            cefrLevel: 'B1',
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_faculty_1',
            targetWord: 'Faculty',
            contextSentence:
                'Prolonged sleep deprivation severely degrades the human brain’s executive cognitive faculties and memory consolidation.',
            highlightedWord: 'faculties',
            options: [
              'A) University professors and academic teaching staff',
              'B) Inherent biological or mental capacities and powers',
              'C) Administrative campus buildings housing lecture theaters',
              'D) Accredited diploma certificates awarded upon graduation',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In biology and psychology IELTS texts, "faculties" refers to innate mental/sensory capabilities (e.g. "critical faculties", "faculty of speech").',
          ),
        ],
      ),
      PolysemyVocabItem(
        id: 'w_fluid',
        word: 'Fluid',
        phonetic: '/ˈfluː.ɪd/',
        generalPartOfSpeech: 'adjective / noun',
        cefrLevel: 'B2 / C1',
        senses: [
          VocabSense(
            definition: 'Not settled, stable, or fixed; constantly changing and adaptable.',
            partOfSpeech: 'adjective',
            exampleSentence: 'Geopolitical alliances remained fluid during the protracted regional conflict.',
            cefrLevel: 'C1',
          ),
          VocabSense(
            definition: 'Smooth, graceful, and elegant in movement or sound.',
            partOfSpeech: 'adjective',
            exampleSentence: 'The ballerina moved across the stage with fluid grace.',
            cefrLevel: 'B2',
          ),
          VocabSense(
            definition: 'A substance that has no fixed shape and yields easily to external pressure; a gas or liquid.',
            partOfSpeech: 'noun',
            exampleSentence: 'Mechanics checked the hydraulic transmission fluid.',
            cefrLevel: 'B1',
            isPrimary: true,
          ),
        ],
        questions: [
          VocabContextQuestion(
            id: 'q_fluid_1',
            targetWord: 'Fluid',
            contextSentence:
                'Corporate hierarchies are becoming increasingly fluid, as cross-functional teams replace rigid departmental silos.',
            highlightedWord: 'fluid',
            options: [
              'A) Composed of flowing liquid water or chemical oil',
              'B) Dynamic, flexible, adaptable, and constantly evolving',
              'C) Insolvent and incapable of honoring creditor debts',
              'D) Strictly regimented by authoritarian military codes',
            ],
            correctOptionIndex: 1,
            targetSenseIndex: 0,
            explanation:
                'In sociological and organizational discourse, "fluid" means flexible, non-rigid, and open to continuous adaptation.',
          ),
        ],
      ),
    ],
  );

  // =========================================================================
  // CATEGORIES DEFINITION
  // =========================================================================

  /// The Top 100 IELTS Multi-Meaning Words Category
  static const PolysemyCategory top100Category = PolysemyCategory(
    id: 'ielts_100',
    title: 'Top 100 Multi-Meaning Words',
    subtitle: 'Essential IELTS polysemes tested in Reading & Task 2',
    badge: 'IELTS 100',
    icon: Icons.auto_stories_rounded,
    accentColor: Color(0xFF6366F1), // Indigo
    sets: [set1, set2, set3, set4],
  );

  /// The Top 200 Academic Context Words Category
  static const PolysemyCategory top200Category = PolysemyCategory(
    id: 'ielts_200',
    title: 'Top 200 Academic Multi-Meaning Words',
    subtitle: 'Advanced Band 7.5–9.0 contextual vocabulary & tricky nuances',
    badge: 'IELTS 200',
    icon: Icons.psychology_rounded,
    accentColor: Color(0xFF0EA5E9), // Sky Blue
    sets: [set1, set2, set3, set4],
  );

  static List<PolysemyCategory> get allCategories => [
        top100Category,
        top200Category,
      ];

  static PolysemyCategory? getCategoryById(String id) {
    if (id == 'ielts_100') return top100Category;
    if (id == 'ielts_200') return top200Category;
    return null;
  }
}
