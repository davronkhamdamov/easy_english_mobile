import 'package:flutter/material.dart';
import '../domain/spaced_repetition.dart';
import 'flashcard_review_screen.dart';

/// Word Bank & Contextual Vocabulary Learning Screen.
class WordBankScreen extends StatefulWidget {
  const WordBankScreen({Key? key}) : super(key: key);

  @override
  State<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends State<WordBankScreen> {
  final List<Map<String, dynamic>> _wordBankItems = [
    {
      'word': 'Foster',
      'phonetic': '/ˈfɒstər/',
      'cefr': 'C1',
      'definition': 'To encourage the development or growth of ideas or relationships.',
      'collocations': ['foster growth', 'foster creativity', 'foster cooperation'],
      'idioms': ['nurture nature'],
      'example': 'The government policies aim to foster economic growth.',
      'mastery': 3, // Spaced repetition level
    },
    {
      'word': 'Paramount',
      'phonetic': '/ˈpærəmaʊnt/',
      'cefr': 'C1',
      'definition': 'More important than anything else; supreme.',
      'collocations': ['paramount importance', 'paramount duty'],
      'idioms': [],
      'example': 'Security is of paramount importance in financial systems.',
      'mastery': 4,
    },
    {
      'word': 'Mitigate',
      'phonetic': '/ˈmɪtɪɡeɪt/',
      'cefr': 'B2',
      'definition': 'Make something less severe, serious, or painful.',
      'collocations': ['mitigate risk', 'mitigate climate change'],
      'idioms': [],
      'example': 'Action must be taken to mitigate the impact of pollution.',
      'mastery': 2,
    },
  ];

  void _startFlashcardReview() {
    final flashcards = _wordBankItems.map((item) {
      return FlashcardItem(
        id: item['word'].toString().toLowerCase(),
        word: item['word'],
        phonetic: item['phonetic'],
        cefrLevel: item['cefr'],
        definition: item['definition'],
        example: item['example'],
        collocations: List<String>.from(item['collocations'] ?? []),
        idioms: List<String>.from(item['idioms'] ?? []),
        masteryLevel: item['mastery'] ?? 0,
      );
    }).toList();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardReviewScreen(initialItems: flashcards),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Word Bank'),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          IconButton(icon: const Icon(Icons.filter_list), onPressed: () {}),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _startFlashcardReview,
        icon: const Icon(Icons.style),
        label: const Text('Review Flashcards (SM-2)', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _wordBankItems.length,
        itemBuilder: (context, index) {
          final item = _wordBankItems[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(item['word'], style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(width: 8),
                          Text(item['phonetic'], style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey)),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCefrColor(item['cefr']),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          item['cefr'],
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(item['definition'], style: theme.textTheme.bodyMedium),
                  const Divider(height: 20),

                  // Collocations
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: (item['collocations'] as List<String>)
                        .map((col) => Chip(
                              label: Text(col, style: const TextStyle(fontSize: 11)),
                              backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.4),
                              padding: EdgeInsets.zero,
                              visualDensity: VisualDensity.compact,
                            ))
                        .toList(),
                  ),
                  const SizedBox(height: 8),

                  // Example Sentence
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.format_quote, size: 16, color: Colors.grey),
                        const SizedBox(width: 6),
                        Expanded(child: Text(item['example'], style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 13))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getCefrColor(String cefr) {
    switch (cefr) {
      case 'C2':
      case 'C1':
        return Colors.purple;
      case 'B2':
      case 'B1':
        return Colors.blue;
      default:
        return Colors.green;
    }
  }
}

