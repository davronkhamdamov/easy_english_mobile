import 'package:flutter/material.dart';
import '../../domain/entities/exam_enums.dart';
import '../../domain/entities/mock_exam_paper.dart';
import '../providers/mock_exam_provider.dart';
import '../widgets/exam_category_chips.dart';
import '../widgets/exam_paper_item.dart';
import '../widgets/mock_exam_error_widget.dart';
import 'listening_practice_screen.dart';
import 'reading_practice_screen.dart';

class MockExamSelectionScreen extends StatefulWidget {
  final MockExamProvider? provider;

  const MockExamSelectionScreen({super.key, this.provider});

  @override
  State<MockExamSelectionScreen> createState() => _MockExamSelectionScreenState();
}

class _MockExamSelectionScreenState extends State<MockExamSelectionScreen> {
  late MockExamProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? MockExamProvider();
    _provider.addListener(_onProviderChange);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _provider.loadAvailableExams();
    });
  }

  void _onProviderChange() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    super.dispose();
  }

  void _openExamPaper(MockExamPaper paper) async {
    final detailPaper = await _provider.fetchPaper(paper.id) ?? paper;
    if (!mounted) return;

    if (detailPaper.type == 'listening' || paper.examType == ExamType.academic && paper.sections.any((s) => s.skill == MockSkill.listening)) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ListeningPracticeScreen(
            paper: detailPaper,
            provider: _provider,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ReadingPracticeScreen(
            paper: detailPaper,
            provider: _provider,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = _provider.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Mock Exam Center', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => _provider.loadAvailableExams(),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExamCategoryChips(
            selectedCategory: state.selectedCategory,
            onCategorySelected: (cat) => _provider.selectCategory(cat),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.errorMessage != null
                    ? MockExamErrorWidget(
                        errorMessage: state.errorMessage!,
                        onRetry: () => _provider.loadAvailableExams(),
                      )
                    : state.availablePapers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(Icons.folder_open_rounded, size: 48, color: theme.colorScheme.outline),
                                const SizedBox(height: 12),
                                Text('No mock exam papers available.', style: theme.textTheme.bodyLarge),
                                const SizedBox(height: 12),
                                ElevatedButton(
                                  onPressed: () => _provider.loadAvailableExams(),
                                  child: const Text('Refresh'),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(bottom: 24),
                            itemCount: state.availablePapers.length,
                            itemBuilder: (context, index) {
                              final paper = state.availablePapers[index];
                              return ExamPaperItem(
                                paper: paper,
                                onTap: () => _openExamPaper(paper),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}
