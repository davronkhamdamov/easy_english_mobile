import 'package:flutter/material.dart';
import '../../data/repositories/word_bank_repository_impl.dart';
import '../../domain/entities/flashcard_item.dart';
import '../../domain/repositories/word_bank_repository.dart';
import '../../domain/usecases/get_word_bank.dart';
import 'flashcard_review_screen.dart';

/// Word Bank & Contextual Vocabulary Learning Screen.
class WordBankScreen extends StatefulWidget {
  final WordBankRepository? repository;

  const WordBankScreen({super.key, this.repository});

  @override
  State<WordBankScreen> createState() => _WordBankScreenState();
}

class _WordBankScreenState extends State<WordBankScreen> {
  late final WordBankRepository _repository;
  late final GetWordBank _getWordBank;

  List<FlashcardItem> _wordBankItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? WordBankRepositoryImpl();
    _getWordBank = GetWordBank(_repository);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final items = await _getWordBank();
      if (mounted) {
        setState(() {
          _wordBankItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _startFlashcardReview() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FlashcardReviewScreen(initialItems: _wordBankItems),
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
        label: const Text(
          'Review Flashcards (SM-2)',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: _wordBankItems.length,
                itemBuilder: (context, index) {
                  final item = _wordBankItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
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
                                  Text(
                                    item.word,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    item.phonetic,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getCefrColor(item.cefrLevel),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  item.cefrLevel,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            item.definition,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const Divider(height: 20),

                          // Collocations
                          if (item.collocations.isNotEmpty) ...[
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: item.collocations
                                  .map(
                                    (col) => Chip(
                                      label: Text(
                                        col,
                                        style: const TextStyle(fontSize: 11),
                                      ),
                                      backgroundColor: theme
                                          .colorScheme
                                          .primaryContainer
                                          .withValues(alpha: 0.4),
                                      padding: EdgeInsets.zero,
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  )
                                  .toList(),
                            ),
                            const SizedBox(height: 8),
                          ],

                          // Example Sentence
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest
                                  .withValues(alpha: 0.5),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.format_quote,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    item.example,
                                    style: const TextStyle(
                                      fontStyle: FontStyle.italic,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }

  Color _getCefrColor(String cefr) {
    switch (cefr.toUpperCase()) {
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
