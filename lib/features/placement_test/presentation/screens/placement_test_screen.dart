import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../providers/placement_test_provider.dart';
import '../widgets/placement_error_widget.dart';
import '../widgets/placement_progress_indicator.dart';
import '../widgets/placement_question_card.dart';
import '../widgets/placement_question_palette_sheet.dart';
import '../widgets/placement_result_widget.dart';

class PlacementTestScreen extends StatefulWidget {
  final PlacementTestProvider? provider;

  const PlacementTestScreen({super.key, this.provider});

  @override
  State<PlacementTestScreen> createState() => _PlacementTestScreenState();
}

class _PlacementTestScreenState extends State<PlacementTestScreen> {
  late final PlacementTestProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? PlacementTestProvider();
    _provider.addListener(_onStateChanged);
  }

  @override
  void dispose() {
    _provider.removeListener(_onStateChanged);
    if (widget.provider == null) _provider.dispose();
    super.dispose();
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  void _showQuestionPalette() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => PlacementQuestionPaletteSheet(
        questions: _provider.questions,
        userAnswers: _provider.userAnswers,
        currentIndex: _provider.currentIndex,
        onSelectQuestion: (idx) => _provider.goToQuestion(idx),
      ),
    );
  }

  void _showSubmitConfirmationDialog() {
    final unanswered = _provider.questions.length - _provider.userAnswers.length;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Complete Diagnostic Test?'),
        content: Text(unanswered > 0 ? 'You still have $unanswered unanswered question(s). Submit test now?' : 'All questions answered! Submit diagnostic test?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Review Questions')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _provider.submitTest();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Submit Test'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('IELTS Diagnostic Placement Test'),
        elevation: 0,
        actions: [
          if (_provider.result == null && _provider.questions.isNotEmpty)
            IconButton(icon: const Icon(Icons.grid_view_rounded), onPressed: _showQuestionPalette),
        ],
      ),
      body: _buildBody(isDark),
    );
  }

  Widget _buildBody(bool isDark) {
    if (_provider.isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (_provider.errorMessage != null && _provider.questions.isEmpty) {
      return PlacementErrorWidget(errorMessage: _provider.errorMessage!, onRetry: () => _provider.loadQuestions());
    }
    if (_provider.result != null) {
      return PlacementResultWidget(
        result: _provider.result!,
        onStartLearning: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Starting course plan...'))),
      );
    }
    if (_provider.questions.isEmpty) {
      return PlacementErrorWidget(errorMessage: 'No questions available.', onRetry: () => _provider.loadQuestions());
    }

    final q = _provider.state.currentQuestion!;
    final selectedOpt = _provider.userAnswers[q.id];

    return Column(
      children: [
        PlacementProgressIndicator(session: _provider.session, onOpenPalette: _showQuestionPalette),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Question ${_provider.currentIndex + 1} of ${_provider.questions.length}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text('${_provider.userAnswers.length} answered', style: const TextStyle(fontSize: 13, color: AppColors.success, fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 12),
                PlacementQuestionCard(
                  question: q,
                  selectedOptionIndex: selectedOpt,
                  onSelectOption: (idx) => _provider.selectOption(idx),
                  isPlayingAudio: _provider.isPlayingAudio,
                  audioProgress: _provider.audioProgress,
                  onToggleAudioPlay: () => _provider.toggleAudioPlay(),
                ),
              ],
            ),
          ),
        ),
        _buildBottomNav(isDark),
      ],
    );
  }

  Widget _buildBottomNav(bool isDark) {
    final isLast = _provider.currentIndex == _provider.questions.length - 1;
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(top: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
      ),
      child: Row(
        children: [
          if (_provider.currentIndex > 0)
            OutlinedButton.icon(onPressed: () => _provider.previousQuestion(), icon: const Icon(Icons.arrow_back), label: const Text('Previous')),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: _provider.isSubmitting ? null : () => isLast ? _showSubmitConfirmationDialog() : _provider.nextQuestion(),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12)),
            icon: _provider.isSubmitting
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Icon(isLast ? Icons.check_circle_outline : Icons.arrow_forward),
            label: Text(isLast ? 'Submit Test' : 'Next Question'),
          ),
        ],
      ),
    );
  }
}
