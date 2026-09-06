import 'dart:async';
import 'package:flutter/material.dart';
import '../../data/models/youtube_listening_models.dart';
import '../../data/repositories/youtube_listening_repository.dart';
import 'custom_youtube_player.dart';

class YoutubeQuizTab extends StatefulWidget {
  final YoutubeListeningRepository repository;

  const YoutubeQuizTab({
    super.key,
    required this.repository,
  });

  @override
  State<YoutubeQuizTab> createState() => _YoutubeQuizTabState();
}

class _YoutubeQuizTabState extends State<YoutubeQuizTab> {
  final TextEditingController _answerController = TextEditingController();
  final FocusNode _answerFocusNode = FocusNode();
  final CustomYoutubePlayerController _quizPlayerController =
      CustomYoutubePlayerController();

  Timer? _quizLoopTimer;

  QuizQuestion? _currentQuiz;
  bool _isLoading = false;
  int _score = 0;
  int _streak = 0;
  bool _isAnswerChecked = false;
  bool _isAnswerCorrect = false;
  bool _isRevealed = false;
  double _currentSpeed = 1.0;
  bool _hasInitialLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadNextQuestion();
  }

  @override
  void dispose() {
    _quizLoopTimer?.cancel();
    _answerController.dispose();
    _answerFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadNextQuestion() async {
    setState(() {
      _isLoading = true;
      _isAnswerChecked = false;
      _isAnswerCorrect = false;
      _isRevealed = false;
      _answerController.clear();
    });

    try {
      final quiz = await widget.repository.getRandomQuizQuestion();
      if (!mounted) return;

      setState(() {
        _currentQuiz = quiz;
        _isLoading = false;
      });

      _playQuizClip(quiz);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _playQuizClip(QuizQuestion quiz) {
    final leadInSec = (quiz.startSeconds - 0.5).clamp(0.0, 999999.0);

    if (_hasInitialLoaded) {
      _quizPlayerController.loadVideo(
        videoId: quiz.videoId,
        startSeconds: leadInSec,
      );
      _quizPlayerController.setPlaybackRate(_currentSpeed);
      _quizPlayerController.play();
    } else {
      _hasInitialLoaded = true;
    }

    _setupQuizLoop(quiz);
  }

  void _setupQuizLoop(QuizQuestion quiz) {
    _quizLoopTimer?.cancel();
    _quizLoopTimer =
        Timer.periodic(const Duration(milliseconds: 300), (timer) async {
      try {
        final currentSeconds = await _quizPlayerController.getCurrentTime();
        if (currentSeconds >= quiz.endSeconds + 0.5) {
          final leadInSec = (quiz.startSeconds - 0.5).clamp(0.0, 999999.0);
          _quizPlayerController.seekTo(leadInSec);
        }
      } catch (_) {}
    });
  }

  void _replayClip() {
    if (_currentQuiz == null) return;
    final leadInSec = (_currentQuiz!.startSeconds - 0.5).clamp(0.0, 999999.0);
    _quizPlayerController.seekTo(leadInSec);
    _quizPlayerController.play();
  }

  void _setSpeed(double speed) {
    setState(() {
      _currentSpeed = speed;
    });
    _quizPlayerController.setPlaybackRate(speed);
  }

  void _checkAnswer() {
    if (_currentQuiz == null) return;
    final input = _answerController.text.trim();
    if (input.isEmpty) return;

    final isCorrect =
        input.toLowerCase() == _currentQuiz!.targetWord.toLowerCase();

    setState(() {
      _isAnswerChecked = true;
      _isAnswerCorrect = isCorrect;
      if (isCorrect) {
        _score += 10;
        _streak += 1;
      } else {
        _streak = 0;
      }
    });
  }

  void _revealAnswer() {
    if (_currentQuiz == null) return;
    setState(() {
      _isRevealed = true;
      _streak = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isLoading && _currentQuiz == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 60),
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Card: Title, Score & Streak
          _buildQuizHeader(isDark),
          const SizedBox(height: 16),

          // 2. Video Snippet Frame
          if (_currentQuiz != null) _buildQuizVideoPlayer(isDark, _currentQuiz!),
          const SizedBox(height: 14),

          // 3. Audio / Playback Controls
          _buildPlaybackControls(isDark),
          const SizedBox(height: 16),

          // 4. Fill-in-the-Blank Interactive Question Box
          _buildQuestionCard(isDark),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildQuizHeader(bool isDark) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.2 : 0.15),
                        ),
                      ),
                      child: Text(
                        '🎯 Cloze Listening',
                        style: TextStyle(
                          color: theme.colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Fill-in-the-Blank Audio Quiz',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Listen to the audio clip & type the missing word.',
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Score: $_score',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Streak: $_streak',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizVideoPlayer(bool isDark, QuizQuestion quiz) {
    final leadInSec = (quiz.startSeconds - 0.5).clamp(0.0, 999999.0);

    return Container(
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: CustomYoutubePlayer(
        initialVideoId: quiz.videoId,
        initialStartSeconds: leadInSec,
        controller: _quizPlayerController,
        autoPlay: true,
      ),
    );
  }

  Widget _buildPlaybackControls(bool isDark) {
    final theme = Theme.of(context);
    return Row(
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.replay_rounded, size: 18),
          label: const Text('Replay Clip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          onPressed: _replayClip,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.onSurface,
            foregroundColor: theme.colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            elevation: 0,
          ),
        ),
        const Spacer(),
        _buildQuizSpeedBtn(0.75, 'Slow (0.75x)', isDark),
        const SizedBox(width: 8),
        _buildQuizSpeedBtn(1.0, 'Normal (1.0x)', isDark),
      ],
    );
  }

  Widget _buildQuizSpeedBtn(double speed, String label, bool isDark) {
    final theme = Theme.of(context);
    final isSelected = (_currentSpeed - speed).abs() < 0.01;
    return InkWell(
      onTap: () => _setSpeed(speed),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.surfaceContainerHighest
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? theme.colorScheme.onSurface : Colors.transparent,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionCard(bool isDark) {
    final theme = Theme.of(context);
    final quiz = _currentQuiz;
    if (quiz == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
              ),
            ),
            child: Text(
              quiz.maskedText,
              style: TextStyle(
                fontSize: 16,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.15 : 0.2),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  child: TextField(
                    controller: _answerController,
                    focusNode: _answerFocusNode,
                    enabled: !_isAnswerCorrect,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _checkAnswer(),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type missing word...',
                      hintStyle: TextStyle(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 14,
                        fontWeight: FontWeight.normal,
                      ),
                      filled: false,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _isAnswerCorrect ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
                  disabledForegroundColor: theme.colorScheme.onSurfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  elevation: 0,
                ),
                child: const Text('Check', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              ),
            ],
          ),
          if (_isAnswerChecked || _isRevealed) ...[
            const SizedBox(height: 14),
            _buildFeedbackBanner(isDark, quiz),
          ],
          const SizedBox(height: 20),
          Row(
            children: [
              OutlinedButton.icon(
                icon: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                label: const Text('Give Up / Reveal', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                onPressed: _revealAnswer,
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  side: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                ),
              ),
              const Spacer(),
              ElevatedButton.icon(
                icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                label: const Text('Next Clip', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                onPressed: _loadNextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.onSurface,
                  foregroundColor: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBanner(bool isDark, QuizQuestion quiz) {
    final theme = Theme.of(context);
    if (_isRevealed) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.lightbulb_rounded, color: theme.colorScheme.onSurface, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'The missing word was: "${quiz.targetWord}"',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_isAnswerCorrect) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: theme.colorScheme.onSurface, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                '🎉 Correct! The word was "${quiz.targetWord}". (+10 pts)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.cancel_rounded, color: theme.colorScheme.onSurface, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '❌ Not quite! Listen closely and try again.',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
