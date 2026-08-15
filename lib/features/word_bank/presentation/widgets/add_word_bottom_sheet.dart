import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_item.dart';

class AddWordBottomSheet extends StatefulWidget {
  final Future<bool> Function(FlashcardItem item) onAddWord;

  const AddWordBottomSheet({super.key, required this.onAddWord});

  @override
  State<AddWordBottomSheet> createState() => _AddWordBottomSheetState();
}

class _AddWordBottomSheetState extends State<AddWordBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _wordController = TextEditingController();
  final _phoneticController = TextEditingController();
  final _definitionController = TextEditingController();
  final _exampleController = TextEditingController();
  final _collocationsController = TextEditingController();

  String _cefrLevel = 'B2';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _wordController.dispose();
    _phoneticController.dispose();
    _definitionController.dispose();
    _exampleController.dispose();
    _collocationsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    final collocations = _collocationsController.text
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    final newItem = FlashcardItem(
      id: 'wb_${DateTime.now().millisecondsSinceEpoch}',
      word: _wordController.text.trim(),
      phonetic: _phoneticController.text.trim().isNotEmpty
          ? _phoneticController.text.trim()
          : '/${_wordController.text.trim().toLowerCase()}/',
      cefrLevel: _cefrLevel,
      definition: _definitionController.text.trim(),
      example: _exampleController.text.trim(),
      collocations: collocations,
    );

    final success = await widget.onAddWord(newItem);
    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add New Vocabulary Word',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _wordController,
                decoration: const InputDecoration(
                  labelText: 'Word',
                  hintText: 'e.g. Foster',
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? 'Word is required' : null,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _phoneticController,
                      decoration: const InputDecoration(
                        labelText: 'Phonetic',
                        hintText: '/ˈfɒstər/',
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<String>(
                    value: _cefrLevel,
                    items: ['B1', 'B2', 'C1', 'C2']
                        .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _cefrLevel = val);
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _definitionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Definition',
                  hintText: 'Meaning of the word...',
                ),
                validator: (val) => val == null || val.trim().isEmpty
                    ? 'Definition is required'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _exampleController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Example Sentence',
                  hintText: 'Sentence demonstrating context usage...',
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _collocationsController,
                decoration: const InputDecoration(
                  labelText: 'Collocations (comma-separated)',
                  hintText: 'foster growth, foster innovation',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Add to Word Bank'),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
