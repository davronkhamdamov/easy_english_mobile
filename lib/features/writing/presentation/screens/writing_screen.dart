import 'package:flutter/material.dart';
import '../providers/writing_provider.dart';
import '../widgets/writing_editor.dart';
import '../widgets/writing_error_widget.dart';
import '../widgets/writing_evaluation_widget.dart';
import '../widgets/writing_prompt_card.dart';
import '../widgets/writing_submit_button.dart';
import '../widgets/writing_task_selector.dart';

/// IELTS Writing Practice & AI Evaluation Screen.
class WritingScreen extends StatefulWidget {
  final WritingProvider? provider;

  const WritingScreen({super.key, this.provider});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  late final WritingProvider _provider;
  final TextEditingController _essayController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? WritingProvider();
    _provider.addListener(_onProviderStateChanged);
    _provider.loadPrompts();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderStateChanged);
    _essayController.dispose();
    super.dispose();
  }

  void _onProviderStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  void _submitForEvaluation() async {
    try {
      await _provider.evaluateEssay(essayText: _essayController.text);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Evaluation failed: ${e.toString().replaceAll('Exception: ', '')}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPrompt = _provider.selectedPrompt;
    final minWords = selectedPrompt?.minWordCount ?? (_provider.selectedTask == 1 ? 150 : 250);

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Writing Practice'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: Center(
              child: Chip(
                label: Text(
                  _provider.selectedTask == 1 ? 'Task 1' : 'Task 2',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: RefreshIndicator(
          onRefresh: _provider.loadPrompts,
          child: _buildBody(context, minWords),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, int minWords) {
    if (_provider.isLoadingPrompts) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Fetching IELTS Writing Prompts...'),
          ],
        ),
      );
    }

    if (_provider.errorMessage != null && _provider.selectedPrompt == null) {
      return WritingErrorWidget(
        message: _provider.errorMessage!,
        onRetry: _provider.loadPrompts,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Task Type Selector
          WritingTaskSelector(
            selectedTaskType: _provider.selectedTaskType,
            onTaskSelected: (type) => _provider.selectTaskType(type),
          ),
          const SizedBox(height: 16),

          // 2. Prompt Header Card
          if (_provider.selectedPrompt != null)
            WritingPromptCard(
              prompt: _provider.selectedPrompt,
              availablePrompts: _provider.filteredPrompts,
              onPromptSelected: (p) => _provider.selectPrompt(p),
            )
          else
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Text('No prompt available for selected task.'),
              ),
            ),
          const SizedBox(height: 16),

          // 3. Essay Editor Widget
          WritingEditor(
            controller: _essayController,
            minWordCount: minWords,
            validationError: _provider.validationError,
            onChanged: (val) => _provider.updateEssayText(val),
          ),
          const SizedBox(height: 20),

          // 4. AI Evaluation Action Button
          WritingSubmitButton(
            isEvaluating: _provider.isEvaluating,
            onPressed: _submitForEvaluation,
          ),
          const SizedBox(height: 24),

          // 5. AI Band Score Breakdown Card
          if (_provider.evaluationResult != null)
            WritingEvaluationWidget(evaluation: _provider.evaluationResult!),
        ],
      ),
    );
  }
}
