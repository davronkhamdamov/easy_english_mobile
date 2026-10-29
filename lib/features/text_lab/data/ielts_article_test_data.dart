import '../domain/entities/ielts_test_models.dart';

/// Pre-populated authentic IELTS Reading practice tests featuring rich article formatting
/// and every question format tested on the official IELTS exam.
class IeltsArticleTestPresets {
  static const List<IeltsArticleTestData> allTests = [
    urbanCanopyTest,
    cognitiveNeuroscienceTest,
    oceanEnergyTest,
  ];

  // =========================================================================
  // TEST 1: The Urban Canopy & Vertical Architecture
  // =========================================================================
  static const IeltsArticleTestData urbanCanopyTest = IeltsArticleTestData(
    id: 'ielts_reading_urban_canopy',
    title: 'The Urban Canopy: Vertical Forests and Biophilic Architecture',
    subtitle: 'Academic Reading Passage 2 • Environmental Engineering & Urban Planning',
    category: 'Architecture & Ecology',
    cefrLevel: 'C1 Academic',
    readTime: '14 min read',
    recommendedMinutes: 20,
    markdownContent: '''# 🌿 The Urban Canopy: Vertical Forests and Biophilic Architecture

As metropolitan conurbations swell towards unprecedented densities, municipal architects and environmental engineers confront an intractable dilemma: how to reconcile soaring housing demands with planetary boundary constraints. In response, a revolutionary paradigm dubbed **biophilic urbanism** has emerged, epitomized by vertical arboretums—multi-tiered high-rises clad in thousands of endemic shrubs, perennial flowers, and mature canopy trees.

---

### Paragraph A
The intellectual genesis of modern vertical forestry can be traced to the completion of Milan’s *Bosco Verticale* in 2014, conceived by architect Stefano Boeri. Rather than viewing flora as purely cosmetic embellishment, Boeri envisaged buildings functioning as living biological organisms. The twin residential towers host approximately 800 mature trees, 5,000 shrubs, and 15,000 perennial plants distributed across cantilevered balconies. This collective biomass equates to roughly 30,000 square meters of horizontal forest concentrated within an urban footprint of merely 3,000 square meters. The project catalyzed a worldwide proliferation of vegetative high-rises, from Singapore’s Supertrees to Sydney’s One Central Park.

### Paragraph B
Microclimatic regulation constitutes one of the most quantifiable dividends of vegetative cladding. In conventional metropolis settings, concrete, asphalt, and glazing absorb high-frequency solar radiation, triggering the notorious **Urban Heat Island (UHI)** effect, where central districts endure temperatures 3°C to 8°C above surrounding rural belts. By contrast, vertical canopies mitigate ambient thermal loading via ==evapotranspiration==—a physiological process whereby vegetation absorbs groundwater through roots and releases moisture vapor through stomata. Empirical sensors deployed along the facades of vegetated towers reveal that dense vegetative screening lowers summer exterior wall temperatures by up to 14°C, reducing mechanical HVAC refrigeration requirements by an estimated 28% annually.

### Paragraph C
Notwithstanding these thermal benefits, the structural and geotechnical engineering hurdles involved are formidable. Mature trees subjected to high-altitude aerodynamic forces experience severe wind shear. At elevations exceeding 80 meters, wind turbulence exerts rotational torque and horizontal deflection forces capable of compromising cantilevered parapets. Consequently, structural engineers mandate post-tensioned reinforced concrete slabs with heavy safety factors. Furthermore, soil selection requires specialized ultralight pumice-perlite substrates blended with organic humic matter, ensuring optimal moisture retention without exceeding structural dead-weight thresholds. Automated drip-irrigation networks, controlled by algorithmic soil tensiometers, recycle greywater from residential washing units to prevent both root desiccation and structural moisture penetration.

> [!NOTE] Engineering Specification: Substrate Density
> Standard topsoil possesses an air-dry bulk density of approximately 1,300 kg/m³, which escalates to 1,800 kg/m³ under saturation. Specialized engineered substrates reduce dry density to 620 kg/m³, preventing cataclysmic structural loading during torrential monsoon deluges.

### Paragraph D
Beyond thermodynamics and physics, the biophilic impact on human neurological equilibrium is profound. Environmental psychologist Dr. Elena Vance conducted longitudinal trials evaluating cortisol biomarkers in residents occupying units overlooking vegetated facades versus counterparts facing barren glass facades. Vance’s cohort exhibited a 34% drop in salivary cortisol levels and documented higher subjective attentional rejuvenation. This aligns closely with Edward O. Wilson’s seminal *Biophilia Hypothesis*, which posits that humanity harbors an innate biological affinity for organic life, an evolutionary legacy that modern sterile concrete landscapes systematically deprive.

### Paragraph E
Critics and conservative real-estate analysts, however, urge circumspection regarding scalability. Economist Dr. Ronald Evans cautions that capital expenditure premiums for vertical forests run between 15% and 25% higher than conventional curtain-wall skyscrapers. Ongoing horticultural maintenance—often executed by specialized arborists suspended from cradle hoists—imposes non-trivial recurring service levies on tenants. Skeptics argue that until municipal building codes offer subsidized density bonuses or carbon credits, vertical forests risk remaining utopian ecological enclaves for affluent property elites rather than democratized architectural norms.

---

### Quantitative Performance Matrix
| Dimension | Conventional Concrete Tower | Vegetated Biophilic High-Rise | Measured Differential |
| :--- | :--- | :--- | :--- |
| **Surface Temperature** | 46.5°C (Peak Summer) | 32.5°C (Shaded Facade) | **-14.0°C reduction** |
| **HVAC Energy Draw** | 185 kWh/m²/year | 133 kWh/m²/year | **-28.1% energy saving** |
| **Particulate Filtration (PM2.5)** | 1.2 kg/year | 25.4 kg/year | **+2,016% particulate capture** |
| **Structural Capital Cost** | \$2,400 / m² | \$2,880 / m² | **+20.0% capital premium** |

> [!TIP] IELTS Academic Reading Tip
> Notice the organizational progression: Paragraph A details origins and specifications; B explores thermodynamic mechanisms; C tackles engineering complications; D investigates psychological welfare; E evaluates commercial viability and limitations.
''',
    questions: [
      // 1. MATCHING HEADINGS (Questions 1 - 4)
      IeltsTestQuestion(
        id: 'q1_headings',
        questionNumber: '1 - 4',
        type: IeltsQuestionType.matchingHeadings,
        prompt: 'The reading passage has five paragraphs, A–E. Choose the correct heading for Paragraphs B, C, D, and E from the list of headings below.',
        questionText: 'Select the appropriate heading (i–vii) for each section.',
        correctAnswer: {
          'Paragraph B': 'ii',
          'Paragraph C': 'v',
          'Paragraph D': 'iii',
          'Paragraph E': 'i',
        },
        headingsCatalog: {
          'i': 'Financial reservations and maintenance practicalities',
          'ii': 'Thermodynamic advantages and ambient cooling',
          'iii': 'Psychological equilibrium and stress alleviation',
          'iv': 'Historical inspiration and initial architectural milestones',
          'v': 'Structural resilience, substrate weight, and irrigation controls',
          'vi': 'Governmental subsidies and global environmental treaties',
          'vii': 'Comparative analysis of tropical versus temperate fauna',
        },
        headingMatchItems: [
          HeadingMatchItem(
            paragraphId: 'Paragraph B',
            paragraphLabel: 'Paragraph B',
            correctHeadingId: 'ii',
          ),
          HeadingMatchItem(
            paragraphId: 'Paragraph C',
            paragraphLabel: 'Paragraph C',
            correctHeadingId: 'v',
          ),
          HeadingMatchItem(
            paragraphId: 'Paragraph D',
            paragraphLabel: 'Paragraph D',
            correctHeadingId: 'iii',
          ),
          HeadingMatchItem(
            paragraphId: 'Paragraph E',
            paragraphLabel: 'Paragraph E',
            correctHeadingId: 'i',
          ),
        ],
        paragraphReference: 'Paragraphs B–E',
        explanation: 'Paragraph B explains evapotranspiration and thermal cooling (Heading ii). Paragraph C discusses structural engineering, wind shear, and pumice-perlite substrate (Heading v). Paragraph D explores cortisol reduction and mental rejuvenation (Heading iii). Paragraph E examines high capital costs, arborist maintenance, and economic caution (Heading i).',
      ),

      // 2. TRUE / FALSE / NOT GIVEN (Questions 5, 6, 7)
      IeltsTestQuestion(
        id: 'q5_tfng',
        questionNumber: '5',
        type: IeltsQuestionType.trueFalseNotGiven,
        prompt: 'Do the following statements agree with the information given in the reading passage? Write TRUE, FALSE, or NOT GIVEN.',
        questionText: 'The total vegetated area hosted on Milan’s Bosco Verticale is approximately ten times larger than the physical footprint of the land it occupies.',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctAnswer: 'TRUE',
        paragraphReference: 'Paragraph A',
        explanation: 'Paragraph A states: "This collective biomass equates to roughly 30,000 square meters of horizontal forest concentrated within an urban footprint of merely 3,000 square meters." (30,000 / 3,000 = exactly 10 times). Thus the statement is TRUE.',
      ),
      IeltsTestQuestion(
        id: 'q6_tfng',
        questionNumber: '6',
        type: IeltsQuestionType.trueFalseNotGiven,
        prompt: 'Do the following statements agree with the information given in the reading passage? Write TRUE, FALSE, or NOT GIVEN.',
        questionText: 'Engineers found that natural topsoil retains moisture more effectively than engineered pumice-perlite substrates.',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctAnswer: 'NOT GIVEN',
        paragraphReference: 'Paragraph C',
        explanation: 'Paragraph C mentions that standard topsoil is much heavier (1,800 kg/m³ when saturated) and that engineered pumice-perlite substrates are ultralight with optimal moisture retention. However, no direct comparison asserting that natural topsoil "retains moisture more effectively" is made. The answer is NOT GIVEN.',
      ),
      IeltsTestQuestion(
        id: 'q7_tfng',
        questionNumber: '7',
        type: IeltsQuestionType.trueFalseNotGiven,
        prompt: 'Do the following statements agree with the information given in the reading passage? Write TRUE, FALSE, or NOT GIVEN.',
        questionText: 'Conventional residential skyscrapers consume less cooling energy in summer than towers equipped with living vegetative screening.',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctAnswer: 'FALSE',
        paragraphReference: 'Paragraph B & Matrix',
        explanation: 'Paragraph B and the performance matrix show that vegetated towers reduce mechanical HVAC refrigeration requirements by 28% (consuming 133 kWh/m² vs 185 kWh/m²). Therefore conventional towers consume more energy, directly contradicting the statement. The answer is FALSE.',
      ),

      // 3. MULTIPLE CHOICE - SINGLE ANSWER (Question 8)
      IeltsTestQuestion(
        id: 'q8_mcq',
        questionNumber: '8',
        type: IeltsQuestionType.multipleChoiceSingle,
        prompt: 'Choose the correct letter, A, B, C or D.',
        questionText: 'According to Paragraph B, what is the fundamental scientific mechanism by which vertical forests alleviate the Urban Heat Island effect?',
        options: [
          'A: Reflecting ultraviolet photons using waxy canopy foliage',
          'B: Evapotranspiration of absorbed groundwater through plant stomata',
          'C: Creating permanent shadow cones across surrounding pedestrian boulevards',
          'D: Converting carbon monoxide directly into dense cellular wood biomass',
        ],
        correctAnswer: 'B',
        paragraphReference: 'Paragraph B',
        explanation: 'Paragraph B explicitly notes: "vertical canopies mitigate ambient thermal loading via evapotranspiration—a physiological process whereby vegetation absorbs groundwater through roots and releases moisture vapor through stomata."',
      ),

      // 4. MULTIPLE CHOICE - MULTI-SELECT (Questions 9-10)
      IeltsTestQuestion(
        id: 'q9_10_multi',
        questionNumber: '9 - 10',
        type: IeltsQuestionType.multipleChoiceMulti,
        prompt: 'Choose TWO letters, A–E. Which TWO architectural and engineering challenges of high-rise vegetation are explicitly mentioned in Paragraph C?',
        questionText: 'Select TWO letters from A to E.',
        options: [
          'A: Aerodynamic wind shear and rotational torque at high altitudes',
          'B: Premature leaf decay caused by industrial acid precipitation',
          'C: Excessive dead-weight structural load when substrates absorb water',
          'D: Inability of automated soil sensors to function in sub-zero climates',
          'E: Competition between avian species nesting along residential balconies',
        ],
        correctAnswer: ['A', 'C'],
        paragraphReference: 'Paragraph C',
        explanation: 'Paragraph C identifies: (A) "At elevations exceeding 80 meters, wind turbulence exerts rotational torque and horizontal deflection forces" and (C) the danger of standard soil saturation leading to dead-weight structural thresholds, requiring ultralight engineered pumice substrates.',
      ),

      // 5. SENTENCE COMPLETION / FILL IN THE BLANK (Questions 11, 12)
      IeltsTestQuestion(
        id: 'q11_fill',
        questionNumber: '11',
        type: IeltsQuestionType.fillInTheBlank,
        prompt: 'Complete the sentences below. Choose NO MORE THAN TWO WORDS from the passage for each answer.',
        questionText: 'In order to prevent structural overloading, vertical forest planters utilize lightweight pumice-perlite mixed with ______ matter.',
        correctAnswer: 'organic humic',
        acceptableAnswers: ['organic humic', 'humic'],
        maxWords: 2,
        paragraphReference: 'Paragraph C',
        explanation: 'Paragraph C explicitly states: "soil selection requires specialized ultralight pumice-perlite substrates blended with organic humic matter".',
      ),
      IeltsTestQuestion(
        id: 'q12_fill',
        questionNumber: '12',
        type: IeltsQuestionType.fillInTheBlank,
        prompt: 'Complete the sentences below. Choose NO MORE THAN TWO WORDS from the passage for each answer.',
        questionText: 'Longitudinal medical evaluations conducted by Dr. Vance demonstrated a 34% reduction in ______ levels among occupants with views of greenery.',
        correctAnswer: 'salivary cortisol',
        acceptableAnswers: ['salivary cortisol', 'cortisol'],
        maxWords: 2,
        paragraphReference: 'Paragraph D',
        explanation: 'Paragraph D states: "Vance’s cohort exhibited a 34% drop in salivary cortisol levels and documented higher subjective attentional rejuvenation."',
      ),

      // 6. MATCHING FEATURES (Question 13)
      IeltsTestQuestion(
        id: 'q13_match_features',
        questionNumber: '13',
        type: IeltsQuestionType.matchingFeatures,
        prompt: 'Look at the following statements and the list of researchers and thinkers below. Match each statement with the correct person, A, B, or C.',
        questionText: 'Match each intellectual perspective to its originator.',
        correctAnswer: {
          'Posited that human beings possess an innate evolutionary affinity for living organisms': 'C',
          'Argued that vegetative towers require density bonuses and subsidies to be economically scalable': 'B',
          'Conceived high-rise towers designed to operate functionally as living biological organisms': 'A',
        },
        featuresCatalog: {
          'A': 'Stefano Boeri',
          'B': 'Dr. Ronald Evans',
          'C': 'Edward O. Wilson',
        },
        featureMatchItems: [
          FeatureMatchItem(
            statement: 'Posited that human beings possess an innate evolutionary affinity for living organisms',
            correctOptionKey: 'C',
          ),
          FeatureMatchItem(
            statement: 'Argued that vegetative towers require density bonuses and subsidies to be economically scalable',
            correctOptionKey: 'B',
          ),
          FeatureMatchItem(
            statement: 'Conceived high-rise towers designed to operate functionally as living biological organisms',
            correctOptionKey: 'A',
          ),
        ],
        paragraphReference: 'Paragraphs A, D, E',
        explanation: 'Stefano Boeri conceived buildings functioning as biological organisms (A). Dr. Ronald Evans highlighted the 15-25% cost premium and need for density subsidies (B). Edward O. Wilson authored the Biophilia Hypothesis regarding evolutionary affinity (C).',
      ),

      // 7. SHORT ANSWER QUESTION (Question 14)
      IeltsTestQuestion(
        id: 'q14_short_answer',
        questionNumber: '14',
        type: IeltsQuestionType.shortAnswer,
        prompt: 'Answer the question below. Choose NO MORE THAN THREE WORDS from the passage.',
        questionText: 'What automated system do engineered planters rely on to supply recycled greywater to root networks?',
        correctAnswer: 'drip-irrigation networks',
        acceptableAnswers: ['drip-irrigation networks', 'drip irrigation networks', 'drip-irrigation', 'drip irrigation'],
        maxWords: 3,
        paragraphReference: 'Paragraph C',
        explanation: 'Paragraph C states: "Automated drip-irrigation networks, controlled by algorithmic soil tensiometers, recycle greywater from residential washing units..."',
      ),
    ],
  );

  // =========================================================================
  // TEST 2: Cognitive Neuroscience of Bilingualism
  // =========================================================================
  static const IeltsArticleTestData cognitiveNeuroscienceTest = IeltsArticleTestData(
    id: 'ielts_reading_cognitive_neuroscience',
    title: 'The Bilingual Brain: Neuroplasticity & Executive Control',
    subtitle: 'Academic Reading Passage 1 • Cognitive Psychology & Neuroscience',
    category: 'Cognitive Science',
    cefrLevel: 'C1 Academic',
    readTime: '12 min read',
    recommendedMinutes: 20,
    markdownContent: '''# 🧠 The Bilingual Brain: Neuroplasticity & Executive Control

Throughout much of the twentieth century, clinical consensus among Western pedagogues warned that exposing young infants to dual language inputs would induce cognitive confusion, syntactic interference, and delayed linguistic mastery. Modern neuroimaging modalities, however, have decisively debunked this archaic deficit hypothesis, revealing that bilingualism confers significant cognitive insulation and structural neuroplasticity.

---

### Paragraph A
When a bilingual individual converses in one tongue, both language lexical networks remain perpetually active in the cerebral cortex. Rather than turning off English when conversing in Spanish, the brain’s frontostriatal circuits actively suppress competing phonemes and lemmas through continuous **inhibitory control**. Dr. Ellen Bialystok, a distinguished research professor of psychology at York University, demonstrated that this lifelong mental acrobatics fortifies the brain’s **executive function system**—the supervisory command center governing attentional focus, task switching, and cognitive working memory.

### Paragraph B
Structural MRI investigations have pinpointed the tangible physiological manifestations of this mental workout. Bilingual cohorts exhibit noticeably thicker gray matter volume in the anterior cingulate cortex and left inferior parietal lobule. Furthermore, diffusion tensor imaging confirms greater white matter integrity along the corpus callosum and superior longitudinal fasciculus, ensuring faster inter-hemispheric neural signaling across frontal lobes.

### Paragraph C
Perhaps the most monumental discovery lies in cognitive reserve and dementia prophylaxis. Longitudinal epidemiological surveys across memory clinics in Edinburgh and Hyderabad revealed that lifelong bilinguals manifest clinical symptoms of neurodegenerative pathologies—such as Alzheimer’s disease—an average of 4.5 years later than monolingual peers presenting identical tau protein plaque deposits. While bilingualism does not forestall the underlying neuropathological decay, it equips patients with redundant neural routing to bypass compromised synapses.

> [!TIP] IELTS Core Concept
> Notice the distinction: Bilingualism does not prevent underlying anatomical degeneration; rather, it delays the *behavioral onset of symptoms* via neural redundancy.
''',
    questions: [
      IeltsTestQuestion(
        id: 'c_q1_tfng',
        questionNumber: '1',
        type: IeltsQuestionType.trueFalseNotGiven,
        prompt: 'Do the following statements agree with the information given in the reading passage? Write TRUE, FALSE, or NOT GIVEN.',
        questionText: 'Mid-twentieth-century educational experts generally believed that simultaneous multi-language acquisition disadvantaged young learners.',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctAnswer: 'TRUE',
        paragraphReference: 'Introduction',
        explanation: 'The passage explicitly states that early pedagogues warned that dual inputs would induce "cognitive confusion, syntactic interference, and delayed linguistic mastery."',
      ),
      IeltsTestQuestion(
        id: 'c_q2_mcq',
        questionNumber: '2',
        type: IeltsQuestionType.multipleChoiceSingle,
        prompt: 'Choose the correct letter, A, B, C or D.',
        questionText: 'According to Dr. Ellen Bialystok in Paragraph A, why is the executive control system enhanced in bilingual speakers?',
        options: [
          'A: They possess higher baseline genetic concentrations of dopamine',
          'B: Both languages remain active simultaneously, requiring continuous suppression of the inactive language',
          'C: They rarely experience emotional anxiety during verbal communication',
          'D: Their auditory cortices process phonetic vibrations at double speed',
        ],
        correctAnswer: 'B',
        paragraphReference: 'Paragraph A',
        explanation: 'Paragraph A clarifies that both language lexical networks remain active, requiring frontostriatal circuits to suppress competing phonemes through continuous inhibitory control.',
      ),
      IeltsTestQuestion(
        id: 'c_q3_fill',
        questionNumber: '3',
        type: IeltsQuestionType.fillInTheBlank,
        prompt: 'Complete the sentence below. Choose NO MORE THAN TWO WORDS AND/OR A NUMBER from the passage.',
        questionText: 'Clinical studies in memory clinics revealed that bilingual patients manifested dementia symptoms an average of ______ later than monolinguals.',
        correctAnswer: '4.5 years',
        acceptableAnswers: ['4.5 years', 'four and a half years'],
        maxWords: 2,
        paragraphReference: 'Paragraph C',
        explanation: 'Paragraph C states: "...lifelong bilinguals manifest clinical symptoms of neurodegenerative pathologies—such as Alzheimer’s disease—an average of 4.5 years later than monolingual peers".',
      ),
      IeltsTestQuestion(
        id: 'c_q4_short',
        questionNumber: '4',
        type: IeltsQuestionType.shortAnswer,
        prompt: 'Answer the question below. Choose NO MORE THAN TWO WORDS from the passage.',
        questionText: 'What term describes the supervisory brain system responsible for task switching and attentional control?',
        correctAnswer: 'executive function',
        acceptableAnswers: ['executive function', 'executive function system'],
        maxWords: 2,
        paragraphReference: 'Paragraph A',
        explanation: 'Paragraph A refers directly to: "the brain’s executive function system—the supervisory command center governing attentional focus, task switching...".',
      ),
    ],
  );

  // =========================================================================
  // TEST 3: Marine Kinetic Energy & Tidal Microgrids
  // =========================================================================
  static const IeltsArticleTestData oceanEnergyTest = IeltsArticleTestData(
    id: 'ielts_reading_ocean_energy',
    title: 'Harnessing the Deep: Marine Kinetic Energy & Tidal Microgrids',
    subtitle: 'Academic Reading Passage 3 • Renewable Engineering & Marine Hydrology',
    category: 'Marine Hydrology',
    cefrLevel: 'C1 Academic',
    readTime: '13 min read',
    recommendedMinutes: 20,
    markdownContent: '''# 🌊 Harnessing the Deep: Marine Kinetic Energy & Tidal Microgrids

While terrestrial wind and photovoltaic solar farms now generate record gigawatts of clean electricity, their notorious intermittency continues to strain municipal power distribution grids. Unlike atmospheric airflow and sunshine, the lunar and gravitational tide is **100% predictable centuries in advance**.

---

### Paragraph A
Ocean energy exploitation primarily bifurcates into wave oscillation energy and subsea tidal stream kinetics. Tidal stream turbines function akin to underwater windmills, extracting kinetic power from rapid water displacements channeled through narrow sea straits and estuaries. Because seawater possesses an ambient density roughly 832 times greater than sea-level air, an eight-knot marine current exerts hydrodynamic forces equivalent to an atmospheric gale exceeding 350 km/h, allowing surprisingly compact hydro-rotors to yield tremendous continuous torque.

### Paragraph B
Hostile marine environments present profound survivability challenges. Subsea components face electrochemical corrosion, extreme hydrodynamic cavitation pressures, and biocorrosion from colonizing barnacles. To counter galvanic corrosion, engineers fabricate turbine rotors using carbon-fiber-reinforced epoxy polymers and equip nacelles with sacrificial zinc anodes and biocidal antifouling paints.
''',
    questions: [
      IeltsTestQuestion(
        id: 'o_q1_tfng',
        questionNumber: '1',
        type: IeltsQuestionType.trueFalseNotGiven,
        prompt: 'Do the following statements agree with the information given in the reading passage? Write TRUE, FALSE, or NOT GIVEN.',
        questionText: 'Tidal gravitational energy output fluctuates with weather patterns in the same manner as wind energy.',
        options: ['TRUE', 'FALSE', 'NOT GIVEN'],
        correctAnswer: 'FALSE',
        paragraphReference: 'Introduction',
        explanation: 'The passage explicitly contrasts tidal power with wind/solar intermittency, stating: "Unlike atmospheric airflow and sunshine, the lunar and gravitational tide is 100% predictable centuries in advance."',
      ),
      IeltsTestQuestion(
        id: 'o_q2_fill',
        questionNumber: '2',
        type: IeltsQuestionType.fillInTheBlank,
        prompt: 'Complete the sentence below. Choose NO MORE THAN TWO WORDS AND/OR A NUMBER from the passage.',
        questionText: 'Seawater has an ambient physical density approximately ______ times higher than atmospheric air.',
        correctAnswer: '832',
        acceptableAnswers: ['832', '832 times'],
        maxWords: 2,
        paragraphReference: 'Paragraph A',
        explanation: 'Paragraph A notes: "Because seawater possesses an ambient density roughly 832 times greater than sea-level air...".',
      ),
      IeltsTestQuestion(
        id: 'o_q3_mcq',
        questionNumber: '3',
        type: IeltsQuestionType.multipleChoiceSingle,
        prompt: 'Choose the correct letter, A, B, C or D.',
        questionText: 'Which material do marine engineers utilize to fabricate turbine rotors resistant to electrochemical degradation?',
        options: [
          'A: Galvanized marine copper alloy',
          'B: Carbon-fiber-reinforced epoxy polymers',
          'C: Cast iron encased in asphalt bitumen',
          'D: Tempered borosilicate glass fiber',
        ],
        correctAnswer: 'B',
        paragraphReference: 'Paragraph B',
        explanation: 'Paragraph B states: "engineers fabricate turbine rotors using carbon-fiber-reinforced epoxy polymers and equip nacelles with sacrificial zinc anodes".',
      ),
    ],
  );
}
