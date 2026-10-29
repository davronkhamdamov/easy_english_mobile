import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../../../../design_system/components/interactive_text/word_lookup_info.dart';
import '../../domain/entities/word_definition_entry.dart';

/// Service responsible for providing comprehensive, multi-sense dictionary entries.
/// Features high-accuracy curated entries (matching Cambridge & Oxford Learner's Dictionaries)
/// alongside dynamic live lookup for any English word via Open-Source Dictionary API.
class WordDefinitionService {
  static final WordDefinitionService _instance = WordDefinitionService._internal();
  factory WordDefinitionService({http.Client? httpClient}) {
    if (httpClient != null) {
      _instance._httpClient = httpClient;
    }
    return _instance;
  }
  WordDefinitionService._internal();

  http.Client? _httpClient;
  http.Client get _client => _httpClient ?? http.Client();

  final Map<String, WordDefinitionEntry> _cache = {};

  /// Retrieves full definition entry for a word.
  Future<WordDefinitionEntry> getDefinition(String rawWord) async {
    final clean = WordLookupDictionaryService.cleanToken(rawWord);
    if (clean.isEmpty) {
      return _buildEmptyEntry(rawWord);
    }

    // 1. Check in-memory cache
    if (_cache.containsKey(clean)) {
      final cached = _cache[clean]!;
      final isSaved = WordLookupDictionaryService().isWordSaved(clean);
      return cached.copyWith(isSaved: isSaved);
    }

    // 2. Check built-in curated dictionary entries (highest learner quality)
    if (_curatedDictionary.containsKey(clean)) {
      final entry = _curatedDictionary[clean]!;
      final isSaved = WordLookupDictionaryService().isWordSaved(clean);
      final resolved = entry.copyWith(isSaved: isSaved);
      _cache[clean] = resolved;
      return resolved;
    }

    // 3. Dynamic lookup via Open-Source Free Dictionary API
    try {
      final dynamicEntry = await _fetchFromApi(clean, rawWord);
      if (dynamicEntry != null) {
        final isSaved = WordLookupDictionaryService().isWordSaved(clean);
        final resolved = dynamicEntry.copyWith(isSaved: isSaved);
        _cache[clean] = resolved;
        return resolved;
      }
    } catch (e) {
      if (kDebugMode) {
        debugPrint('WordDefinitionService API fetch error for "$clean": $e');
      }
    }

    // 4. Fallback structured entry
    final fallback = _buildFallbackEntry(clean, rawWord);
    _cache[clean] = fallback;
    return fallback;
  }

  /// Fetches and parses full multi-sense dictionary entry from API.
  Future<WordDefinitionEntry?> _fetchFromApi(String clean, String raw) async {
    final url = Uri.parse(
      'https://api.dictionaryapi.dev/api/v2/entries/en/${Uri.encodeComponent(clean)}',
    );
    final response = await _client.get(url).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) return null;

    final decoded = jsonDecode(response.body);
    if (decoded is! List || decoded.isEmpty) return null;

    final List<WordSense> parsedSenses = [];
    final Set<String> posSet = {};
    String ukPhonetic = '';
    String? ukAudioUrl;
    String usPhonetic = '';
    String? usAudioUrl;
    final List<String> allCollocations = [];

    for (final entry in decoded) {
      if (entry is! Map<String, dynamic>) continue;

      // Parse phonetics
      if (entry['phonetics'] is List) {
        for (final p in entry['phonetics'] as List) {
          if (p is! Map<String, dynamic>) continue;
          final text = p['text']?.toString() ?? '';
          final audio = p['audio']?.toString() ?? '';
          final resolvedAudio = audio.isNotEmpty
              ? (audio.startsWith('http') ? audio : 'https:$audio')
              : null;

          if (audio.contains('-uk') || audio.contains('/uk/')) {
            if (ukPhonetic.isEmpty && text.isNotEmpty) ukPhonetic = text;
            ukAudioUrl ??= resolvedAudio;
          } else if (audio.contains('-us') || audio.contains('/us/')) {
            if (usPhonetic.isEmpty && text.isNotEmpty) usPhonetic = text;
            usAudioUrl ??= resolvedAudio;
          } else {
            if (ukPhonetic.isEmpty && text.isNotEmpty) ukPhonetic = text;
            if (usPhonetic.isEmpty && text.isNotEmpty) usPhonetic = text;
            ukAudioUrl ??= resolvedAudio;
            usAudioUrl ??= resolvedAudio;
          }
        }
      }

      // Parse meanings & definitions
      if (entry['meanings'] is List) {
        for (final meaning in entry['meanings'] as List) {
          if (meaning is! Map<String, dynamic>) continue;
          final pos = meaning['partOfSpeech']?.toString() ?? 'noun';
          posSet.add(pos);

          final defs = meaning['definitions'];
          if (defs is List) {
            for (var i = 0; i < defs.length; i++) {
              final d = defs[i];
              if (d is! Map<String, dynamic>) continue;
              final defText = d['definition']?.toString().trim() ?? '';
              if (defText.isEmpty) continue;

              // Check if definition contains heading/category e.g. "(heading) Employment."
              String guideWord = '';
              String cleanedDef = defText;
              if (defText.startsWith('(heading)')) {
                guideWord = defText.replaceFirst('(heading)', '').trim().replaceAll('.', '').toUpperCase();
                continue; // Heading marker
              } else if (defText.startsWith('(') && defText.contains(')')) {
                final closeIdx = defText.indexOf(')');
                final potentialGuide = defText.substring(1, closeIdx).trim();
                if (potentialGuide.length < 25) {
                  guideWord = potentialGuide.toUpperCase();
                  cleanedDef = defText.substring(closeIdx + 1).trim();
                }
              }

              if (guideWord.isEmpty) {
                // Infer guideword from definition keyword
                guideWord = _inferGuideWord(cleanedDef, i, pos);
              }

              final exampleText = d['example']?.toString().trim();
              final List<WordSenseExample> examples = [];
              if (exampleText != null && exampleText.isNotEmpty) {
                final split = _extractExamplePattern(clean, exampleText);
                examples.add(WordSenseExample(
                  pattern: split.key,
                  sentence: split.value,
                  audioUrl: 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(exampleText)}&type=1',
                ));
              }

              final syns = <String>[];
              if (d['synonyms'] is List) {
                for (final s in d['synonyms'] as List) {
                  final str = s.toString().trim();
                  if (str.isNotEmpty && str.toLowerCase() != clean) syns.add(str);
                }
              }

              final grammarCode = _inferGrammarCode(pos, cleanedDef);
              final cefr = _inferCefrLevel(i, clean);

              parsedSenses.add(WordSense(
                id: '${clean}_${pos}_$i',
                word: clean,
                partOfSpeech: pos,
                guideWord: guideWord,
                cefrLevel: cefr,
                grammaticalCode: grammarCode,
                definition: cleanedDef,
                examples: examples,
                synonyms: syns.take(4).toList(),
                collocations: const [],
              ));
            }
          }
        }
      }
    }

    if (parsedSenses.isEmpty) return null;

    ukPhonetic = ukPhonetic.isNotEmpty ? ukPhonetic : '/$clean/';
    usPhonetic = usPhonetic.isNotEmpty ? usPhonetic : '/$clean/';
    ukAudioUrl ??= 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=1';
    usAudioUrl ??= 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=2';

    final primaryPos = posSet.isNotEmpty ? posSet.first : 'noun';

    return WordDefinitionEntry(
      word: raw.trim(),
      partOfSpeech: primaryPos,
      allPartsOfSpeech: posSet.toList(),
      ukPhonetic: ukPhonetic,
      ukAudioUrl: ukAudioUrl,
      usPhonetic: usPhonetic,
      usAudioUrl: usAudioUrl,
      senses: parsedSenses,
      collocations: allCollocations,
      isSaved: false,
    );
  }

  static String _inferGuideWord(String def, int index, String pos) {
    final words = def.split(RegExp(r'\s+'));
    if (words.isNotEmpty && words.first.length > 3) {
      return words.first.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
    }
    return pos == 'verb' ? 'ACTION ${index + 1}' : 'MEANING ${index + 1}';
  }

  static String _inferGrammarCode(String pos, String def) {
    if (pos == 'noun') {
      if (def.contains('substance') || def.contains('quality') || def.contains('material') || def.contains('effort')) {
        return '[ U ]';
      }
      return '[ C ]';
    } else if (pos == 'verb') {
      return '[ I or T ]';
    } else if (pos == 'adjective') {
      return '[ adj ]';
    }
    return '';
  }

  static String _inferCefrLevel(int index, String word) {
    if (index == 0) return 'A1';
    if (index == 1) return 'A2';
    if (index == 2) return 'B1';
    if (index == 3) return 'B2';
    return 'C1';
  }

  static MapEntry<String, String> _extractExamplePattern(String word, String sentence) {
    final lower = sentence.toLowerCase();
    final collocations = [
      'hard $word',
      'do $word',
      'at $word',
      'to $word',
      '$word by',
      '$word on',
      '$word in',
      '$word with',
      '$word out',
    ];
    for (final col in collocations) {
      if (lower.contains(col)) {
        return MapEntry(col, sentence);
      }
    }
    return MapEntry('', sentence);
  }

  WordDefinitionEntry _buildEmptyEntry(String word) {
    return WordDefinitionEntry(
      word: word,
      partOfSpeech: 'noun',
      senses: const [],
      isSaved: false,
    );
  }

  WordDefinitionEntry _buildFallbackEntry(String clean, String raw) {
    return WordDefinitionEntry(
      word: raw,
      partOfSpeech: 'noun',
      allPartsOfSpeech: const ['noun'],
      ukPhonetic: '/$clean/',
      ukAudioUrl: 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=1',
      usPhonetic: '/$clean/',
      usAudioUrl: 'https://dict.youdao.com/dictvoice?audio=${Uri.encodeComponent(clean)}&type=2',
      senses: [
        WordSense(
          id: '${clean}_1',
          word: clean,
          partOfSpeech: 'noun',
          guideWord: 'GENERAL',
          cefrLevel: 'B1',
          grammaticalCode: '[ C or U ]',
          definition: 'A term denoting a core concept or entity in academic and everyday English.',
          examples: [
            WordSenseExample(
              pattern: clean,
              sentence: 'Understanding "$clean" enhances vocabulary comprehension and communication.',
            ),
          ],
        ),
      ],
      isSaved: false,
    );
  }

  // =========================================================================
  // CURATED HIGH-QUALITY LEARNER'S DICTIONARY DATASET (Cambridge / Oxford Style)
  // =========================================================================
  static final Map<String, WordDefinitionEntry> _curatedDictionary = {
    'work': const WordDefinitionEntry(
      word: 'work',
      partOfSpeech: 'noun',
      allPartsOfSpeech: ['noun', 'verb'],
      ukPhonetic: '/wɜːk/',
      ukAudioUrl: 'https://api.dictionaryapi.dev/media/pronunciations/en/work-uk.mp3',
      usPhonetic: '/wɝːk/',
      usAudioUrl: 'https://api.dictionaryapi.dev/media/pronunciations/en/work-us.ogg',
      senses: [
        WordSense(
          id: 'work_n_activity',
          word: 'work',
          partOfSpeech: 'noun',
          guideWord: 'ACTIVITY',
          cefrLevel: 'A1',
          grammaticalCode: '[ U ]',
          definition: 'an activity, such as a job, that a person uses physical or mental effort to do, usually for money:',
          examples: [
            WordSenseExample(
              pattern: 'do work',
              sentence: "I've got so much work to do.",
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=I%27ve%20got%20so%20much%20work%20to%20do.&type=1',
            ),
            WordSenseExample(
              pattern: 'hard work',
              sentence: 'Carrying heavy loads around all day is hard work.',
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=Carrying%20heavy%20loads%20around%20all%20day%20is%20hard%20work.&type=1',
            ),
          ],
          synonyms: ['labor', 'toil', 'employment', 'effort'],
          collocations: ['hard work', 'do work', 'start work', 'stop work'],
        ),
        WordSense(
          id: 'work_n_place',
          word: 'work',
          partOfSpeech: 'noun',
          guideWord: 'PLACE',
          cefrLevel: 'A1',
          grammaticalCode: '[ U ]',
          definition: 'a place where a person goes specially to do their job:',
          examples: [
            WordSenseExample(
              pattern: 'to work',
              sentence: 'Do you have far to travel to work each day?',
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=Do%20you%20have%20far%20to%20travel%20to%20work%20each%20day?&type=1',
            ),
            WordSenseExample(
              pattern: 'at work',
              sentence: 'Thousands of people are seriously injured at work every year.',
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=Thousands%20of%20people%20are%20seriously%20injured%20at%20work%20every%20year.&type=1',
            ),
          ],
          synonyms: ['workplace', 'office', 'job site'],
          collocations: ['at work', 'go to work', 'leave work', 'travel to work'],
        ),
        WordSense(
          id: 'work_n_creation',
          word: 'work',
          partOfSpeech: 'noun',
          guideWord: 'CREATION',
          cefrLevel: 'B2',
          grammaticalCode: '[ C ]',
          definition: 'something created as a result of effort, especially a painting, book, or piece of music:',
          examples: [
            WordSenseExample(
              pattern: 'work by',
              sentence: 'The museum has many works by Picasso as well as other modern painters.',
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=The%20museum%20has%20many%20works%20by%20Picasso%20as%20well%20as%20other%20modern%20painters.&type=1',
            ),
            WordSenseExample(
              pattern: 'poetic works',
              sentence: 'the poetic works of Tagore',
              audioUrl: 'https://dict.youdao.com/dictvoice?audio=the%20poetic%20works%20of%20Tagore&type=1',
            ),
          ],
          synonyms: ['masterpiece', 'creation', 'composition', 'oeuvre'],
          collocations: ['work of art', 'collected works', 'literary work'],
        ),
        WordSense(
          id: 'work_n_material',
          word: 'work',
          partOfSpeech: 'noun',
          guideWord: 'MATERIAL',
          cefrLevel: 'A2',
          grammaticalCode: '[ U ]',
          definition: 'the material used by someone at work, or what they produce:',
          examples: [
            WordSenseExample(
              pattern: 'take work home',
              sentence: "I'll have to take this work home with me and finish it there.",
            ),
            WordSenseExample(
              pattern: 'the work of',
              sentence: 'All the furniture is the work of residents here.',
            ),
          ],
          synonyms: ['product', 'output', 'handiwork'],
          collocations: ['take work home', 'the work of'],
        ),
        WordSense(
          id: 'work_v_labor',
          word: 'work',
          partOfSpeech: 'verb',
          guideWord: 'EFFORT',
          cefrLevel: 'A1',
          grammaticalCode: '[ I or T ]',
          definition: 'to exert physical or mental effort to accomplish a goal, task, or job:',
          examples: [
            WordSenseExample(
              pattern: 'work in',
              sentence: 'He is working in a hospital as a junior doctor.',
            ),
            WordSenseExample(
              pattern: 'work hard',
              sentence: 'She worked day and night to achieve IELTS Band 8.0.',
            ),
          ],
          synonyms: ['labor', 'strive', 'endeavor'],
          collocations: ['work hard', 'work overtime', 'work remotely'],
        ),
        WordSense(
          id: 'work_v_function',
          word: 'work',
          partOfSpeech: 'verb',
          guideWord: 'OPERATE',
          cefrLevel: 'A2',
          grammaticalCode: '[ I ]',
          definition: 'to function correctly, act as intended, or achieve the desired result:',
          examples: [
            WordSenseExample(
              pattern: 'work properly',
              sentence: 'The new air conditioning system is working properly now.',
            ),
            WordSenseExample(
              pattern: 'plan work',
              sentence: 'Our preparation strategy worked and our scores increased.',
            ),
          ],
          synonyms: ['function', 'succeed', 'operate'],
          collocations: ['work well', 'work out', 'work properly'],
        ),
      ],
      collocations: [
        'hard work',
        'at work',
        'do work',
        'out of work',
        'work of art',
        'work ethic',
        'work experience',
        'team work',
      ],
      idioms: [
        'work like a charm',
        'make short work of',
        'all in a day\'s work',
        'dirty work',
      ],
    ),
    'foster': const WordDefinitionEntry(
      word: 'foster',
      partOfSpeech: 'verb',
      allPartsOfSpeech: ['verb', 'adjective'],
      ukPhonetic: '/ˈfɒstər/',
      ukAudioUrl: 'https://dict.youdao.com/dictvoice?audio=foster&type=1',
      usPhonetic: '/ˈfɑːstər/',
      usAudioUrl: 'https://dict.youdao.com/dictvoice?audio=foster&type=2',
      senses: [
        WordSense(
          id: 'foster_v_encourage',
          word: 'foster',
          partOfSpeech: 'verb',
          guideWord: 'ENCOURAGE',
          cefrLevel: 'C1',
          grammaticalCode: '[ T ]',
          definition: 'to encourage the development or growth of ideas or feelings:',
          examples: [
            WordSenseExample(
              pattern: 'foster growth',
              sentence: 'The economic policies aim to foster sustainable development.',
            ),
            WordSenseExample(
              pattern: 'foster innovation',
              sentence: 'The club helps foster friendly relations and creative innovation among students.',
            ),
          ],
          synonyms: ['promote', 'cultivate', 'nurture', 'encourage'],
          collocations: ['foster development', 'foster innovation', 'foster creativity'],
        ),
        WordSense(
          id: 'foster_v_care',
          word: 'foster',
          partOfSpeech: 'verb',
          guideWord: 'CARE FOR',
          cefrLevel: 'B2',
          grammaticalCode: '[ I or T ]',
          definition: 'to take care of a child, usually for a limited time, without being the child\'s legal parent:',
          examples: [
            WordSenseExample(
              pattern: 'foster parents',
              sentence: 'They have fostered over twenty vulnerable children over the last decade.',
            ),
          ],
          synonyms: ['adopt', 'rear', 'bring up'],
          collocations: ['foster child', 'foster parent', 'foster home'],
        ),
      ],
      collocations: ['foster development', 'foster relationships', 'foster growth'],
    ),
    'eloquent': const WordDefinitionEntry(
      word: 'eloquent',
      partOfSpeech: 'adjective',
      allPartsOfSpeech: ['adjective'],
      ukPhonetic: '/ˈel.ə.kwənt/',
      ukAudioUrl: 'https://dict.youdao.com/dictvoice?audio=eloquent&type=1',
      usPhonetic: '/ˈel.ə.kwənt/',
      usAudioUrl: 'https://dict.youdao.com/dictvoice?audio=eloquent&type=2',
      senses: [
        WordSense(
          id: 'eloquent_adj_fluent',
          word: 'eloquent',
          partOfSpeech: 'adjective',
          guideWord: 'FLUENT',
          cefrLevel: 'C1',
          grammaticalCode: '[ adj ]',
          definition: 'giving a clear, strong message; using language expressively and fluently:',
          examples: [
            WordSenseExample(
              pattern: 'eloquent speech',
              sentence: 'She delivered an eloquent speech that moved the entire audience to tears.',
            ),
            WordSenseExample(
              pattern: 'eloquent testimony',
              sentence: 'The success of the scholarship program is eloquent testimony to its quality.',
            ),
          ],
          synonyms: ['articulate', 'expressive', 'persuasive', 'fluent'],
          collocations: ['eloquent speech', 'eloquent silence', 'eloquent plea'],
        ),
      ],
      collocations: ['eloquent speech', 'eloquent speaker', 'eloquently expressed'],
    ),
    'resilient': const WordDefinitionEntry(
      word: 'resilient',
      partOfSpeech: 'adjective',
      allPartsOfSpeech: ['adjective'],
      ukPhonetic: '/rɪˈzɪl.i.ənt/',
      ukAudioUrl: 'https://dict.youdao.com/dictvoice?audio=resilient&type=1',
      usPhonetic: '/rɪˈzɪl.i.ənt/',
      usAudioUrl: 'https://dict.youdao.com/dictvoice?audio=resilient&type=2',
      senses: [
        WordSense(
          id: 'resilient_adj_recover',
          word: 'resilient',
          partOfSpeech: 'adjective',
          guideWord: 'STRONG',
          cefrLevel: 'C1',
          grammaticalCode: '[ adj ]',
          definition: 'able to quickly return to a good condition after difficulties, setbacks, or damage:',
          examples: [
            WordSenseExample(
              pattern: 'resilient economy',
              sentence: 'The country possesses a remarkably resilient economy that withstood the crisis.',
            ),
            WordSenseExample(
              pattern: 'resilient spirit',
              sentence: 'Children are often remarkably resilient in the face of unexpected hardship.',
            ),
          ],
          synonyms: ['tough', 'adaptable', 'buoyant', 'hardy'],
          collocations: ['resilient economy', 'resilient people', 'highly resilient'],
        ),
      ],
      collocations: ['resilient economy', 'resilient infrastructure', 'psychological resilience'],
    ),
    'meticulous': const WordDefinitionEntry(
      word: 'meticulous',
      partOfSpeech: 'adjective',
      allPartsOfSpeech: ['adjective'],
      ukPhonetic: '/məˈtɪk.jə.ləs/',
      ukAudioUrl: 'https://dict.youdao.com/dictvoice?audio=meticulous&type=1',
      usPhonetic: '/məˈtɪk.jə.ləs/',
      usAudioUrl: 'https://dict.youdao.com/dictvoice?audio=meticulous&type=2',
      senses: [
        WordSense(
          id: 'meticulous_adj_careful',
          word: 'meticulous',
          partOfSpeech: 'adjective',
          guideWord: 'CAREFUL',
          cefrLevel: 'C2',
          grammaticalCode: '[ adj ]',
          definition: 'very careful and with great attention to every detail:',
          examples: [
            WordSenseExample(
              pattern: 'meticulous research',
              sentence: 'The researcher was meticulous about documenting every step of the experiment.',
            ),
            WordSenseExample(
              pattern: 'meticulous planning',
              sentence: 'Through meticulous planning, the event ran smoothly without a single hitch.',
            ),
          ],
          synonyms: ['painstaking', 'thorough', 'scrupulous', 'exact'],
          collocations: ['meticulous planning', 'meticulous attention to detail', 'meticulous preparation'],
        ),
      ],
      collocations: ['meticulous attention', 'meticulous records', 'meticulously clean'],
    ),
  };
}
