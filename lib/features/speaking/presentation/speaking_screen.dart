import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../../design_system/design_system.dart';
import '../data/speaking_evaluation_service.dart';
import '../domain/speaking_model.dart';

/// IELTS Speaking Practice Screen featuring Part 1/2/3 Cue Cards,
/// Interactive Record/Stop, Animated Timer, Audio Transcript, and AI Band Score Evaluation.
class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

enum PracticeState { idle, preparing, recording, recorded, evaluating, evaluated }

class _SpeakingScreenState extends State<SpeakingScreen> with TickerProviderStateMixin {
  int _selectedPart = 1; // 1, 2, or 3
  late SpeakingPrompt _currentPrompt;
  PracticeState _state = PracticeState.idle;

  // Timers & Animations
  Timer? _timer;
  int _timerSeconds = 0;
  late AnimationController _micPulseController;
  late AnimationController _waveController;

  // Audio Recorder & Evaluation
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? _recordedAudioPath;

  bool _isTranscribing = false;
  SpeakingAIEvaluation? _aiEvaluation;
  late TextEditingController _transcriptController;
  double _waveformAmplitude = 0.5;

  @override
  void initState() {
    super.initState();
    _transcriptController = TextEditingController();
    _currentPrompt = SpeakingPrompt.samplePrompts[0];

    _micPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _transcriptController.dispose();
    _micPulseController.dispose();
    _waveController.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  void _switchPart(int part) {
    if (_state == PracticeState.recording || _state == PracticeState.preparing) {
      _stopTimer();
    }
    setState(() {
      _selectedPart = part;
      _currentPrompt = SpeakingPrompt.samplePrompts.firstWhere(
        (p) => p.part == part,
        orElse: () => SpeakingPrompt.samplePrompts[0],
      );
      _state = PracticeState.idle;
      _timerSeconds = 0;
      _aiEvaluation = null;
      _transcriptController.clear();
    });
  }

  void _startPreparation() {
    setState(() {
      _state = PracticeState.preparing;
      _timerSeconds = _currentPrompt.prepTimeSeconds > 0 ? _currentPrompt.prepTimeSeconds : 60;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds <= 1) {
        timer.cancel();
        _startRecording();
      } else {
        setState(() {
          _timerSeconds--;
        });
      }
    });
  }

  void _startRecording() async {
    _timer?.cancel();
    HapticFeedback.heavyImpact();
    _transcriptController.clear();
    _recordedAudioPath = null;

    setState(() {
      _state = PracticeState.recording;
      _timerSeconds = 0;
    });

    final hasPerm = await _audioRecorder.hasPermission();
    if (hasPerm) {
      try {
        final tempDir = await getTemporaryDirectory();
        final filePath = '${tempDir.path}/speaking_${DateTime.now().millisecondsSinceEpoch}.m4a';
        _recordedAudioPath = filePath;

        try {
          await _audioRecorder.start(
            const RecordConfig(
              encoder: AudioEncoder.aacLc,
              sampleRate: 44100,
              bitRate: 128000,
              numChannels: 1, // Mono voice recording for maximum gain & clarity
            ),
            path: filePath,
          );
        } catch (encoderErr) {
          debugPrint('Mono AAC LC encoder failed, trying default RecordConfig: $encoderErr');
          await _audioRecorder.start(
            const RecordConfig(numChannels: 1),
            path: filePath,
          );
        }
        debugPrint('Audio recording started successfully at: $filePath');
      } catch (e) {
        debugPrint('AudioRecorder start exception: $e');
      }
    } else {
      debugPrint('Microphone permission denied for AudioRecorder');
      if (mounted) {
        DSSnackbar.show(
          context,
          message: 'Microphone permission is required to record audio.',
          variant: DSSnackbarVariant.danger,
        );
      }
    }

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _timerSeconds++;
        _waveformAmplitude = 0.3 + (0.6 * ((timer.tick % 4) / 3.0));
      });

      // Auto-stop when reaching max speaking time
      if (_timerSeconds >= _currentPrompt.speakingTimeSeconds) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() async {
    _timer?.cancel();

    String? audioPath = _recordedAudioPath;
    try {
      if (await _audioRecorder.isRecording()) {
        final stoppedPath = await _audioRecorder.stop();
        if (stoppedPath != null && stoppedPath.isNotEmpty) {
          audioPath = stoppedPath;
          _recordedAudioPath = stoppedPath;
        }
      }
    } catch (e) {
      debugPrint('AudioRecorder stop exception: $e');
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _state = PracticeState.recorded;
      _isTranscribing = true;
    });

    if (audioPath != null && audioPath.isNotEmpty && File(audioPath).existsSync()) {
      try {
        debugPrint('Sending audio file to Whisper API ($audioPath)...');
        final whisperTranscript = await SpeakingEvaluationService().transcribeSpeakingAudio(audioPath);
        if (mounted && whisperTranscript.isNotEmpty) {
          setState(() {
            _transcriptController.text = whisperTranscript;
            _isTranscribing = false;
          });
          return;
        }
      } catch (e) {
        debugPrint('Whisper API transcription exception: $e');
        if (mounted) {
          DSSnackbar.show(
            context,
            message: 'Whisper API error: ${e.toString()}',
            variant: DSSnackbarVariant.danger,
          );
        }
      }
    } else {
      debugPrint('No audio file found at $audioPath to send to Whisper API');
      if (mounted) {
        DSSnackbar.show(
          context,
          message: 'No audio file recorded ($audioPath). Please check microphone permissions.',
          variant: DSSnackbarVariant.warning,
        );
      }
    }

    if (mounted) {
      setState(() {
        _isTranscribing = false;
      });
    }
  }

  void _resetPractice() async {
    _timer?.cancel();
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (_) {}

    setState(() {
      _state = PracticeState.idle;
      _timerSeconds = 0;
      _recordedAudioPath = null;
      _aiEvaluation = null;
      _transcriptController.clear();
    });
  }

  void _stopTimer() async {
    _timer?.cancel();
    try {
      if (await _audioRecorder.isRecording()) {
        await _audioRecorder.stop();
      }
    } catch (_) {}
    _state = PracticeState.idle;
  }

  Future<void> _evaluateSpeakingWithAI() async {
    final currentText = _transcriptController.text.trim();
    if (currentText.isEmpty) {
      DSSnackbar.show(
        context,
        message: 'Please speak into your microphone or type your response first.',
        variant: DSSnackbarVariant.danger,
      );
      return;
    }

    setState(() {
      _state = PracticeState.evaluating;
    });

    try {
      final res = await SpeakingEvaluationService().evaluateSpeaking(
        audioFilePath: _recordedAudioPath,
        part: _selectedPart,
        prompt: _currentPrompt.title,
        transcript: currentText,
      );

      if (mounted) {
        setState(() {
          _state = PracticeState.evaluated;
          _aiEvaluation = SpeakingAIEvaluation(
            id: 'eval_${DateTime.now().millisecondsSinceEpoch}',
            submissionId: 'sub_${DateTime.now().millisecondsSinceEpoch}',
            overallBand: res.overallBandScore,
            fluencyCoherenceBand: res.fluencyScore,
            lexicalResourceBand: res.lexicalResourceScore,
            grammarRangeBand: res.grammarScore,
            pronunciationBand: res.pronunciationScore,
            transcript: res.transcription.isNotEmpty ? res.transcription : currentText,
            grammarErrors: res.grammarErrors,
            vocabularyTips: res.vocabularyTips,
            strengths: res.strengths,
            areasForImprovement: res.areasForImprovement,
            evaluatedAt: DateTime.now(),
          );
        });
      }
    } catch (e) {
      debugPrint('AI Evaluation Error: $e');
      if (mounted) {
        setState(() {
          _state = PracticeState.recorded;
        });
        DSSnackbar.show(
          context,
          message: 'Evaluation failed: ${e.toString().replaceAll('Exception: ', '')}',
          variant: DSSnackbarVariant.danger,
        );
      }
    }
  }

  String _formatDuration(int totalSeconds) {
    final minutes = totalSeconds ~/ 60;
    final seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Speaking Practice'),
        centerTitle: false,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                const SizedBox(width: 6),
                Text(
                  'AI Examiner v2.0',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.opaque,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Part Switcher Tabs (Part 1 / Part 2 / Part 3)
              _buildPartSelector(theme, isDark),
              const SizedBox(height: 16),

              // Cue Card Prompt Widget
              _buildPromptCard(theme, isDark),
              const SizedBox(height: 20),

              // Animated Timer & Waveform Controls Card
              _buildRecordingControllerCard(theme, isDark),
              const SizedBox(height: 20),

              // Audio Transcript Display Card
              if (_transcriptController.text.isNotEmpty || _state == PracticeState.recorded || _isTranscribing)
                _buildTranscriptCard(theme, isDark),

              // AI Band Score Evaluation Card
              if (_state == PracticeState.evaluating) _buildLoadingEvaluationCard(theme),
              if (_state == PracticeState.evaluated && _aiEvaluation != null)
                _buildAIEvaluationCard(theme, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPartSelector(ThemeData theme, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [1, 2, 3].map((part) {
          final isSelected = _selectedPart == part;
          return Expanded(
            child: GestureDetector(
              onTap: () => _switchPart(part),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? (isDark ? AppColors.primary : AppColors.primary)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    part == 2 ? 'Part 2 (Cue Card)' : 'Part $part',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: isSelected
                          ? Colors.white
                          : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPromptCard(ThemeData theme, bool isDark) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _currentPrompt.topic,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.secondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      'Max ${_formatDuration(_currentPrompt.speakingTimeSeconds)}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              _currentPrompt.promptText,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                height: 1.3,
              ),
            ),
            if (_currentPrompt.bulletPoints.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkBackground.withOpacity(0.5)
                      : AppColors.lightBackground,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'You should say:',
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ..._currentPrompt.bulletPoints.map(
                      (bullet) => Padding(
                        padding: const EdgeInsets.only(bottom: 4.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(
                                bullet,
                                style: theme.textTheme.bodyMedium?.copyWith(height: 1.25),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingControllerCard(ThemeData theme, bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
        border: Border.all(
          color: _state == PracticeState.recording
              ? AppColors.danger.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        children: [
          // Animated Timer Display
          _buildTimerDisplay(theme, isDark),
          const SizedBox(height: 16),

          // Sound Waveform Visualizer (during recording)
          if (_state == PracticeState.recording) _buildWaveformVisualizer(),
          if (_state == PracticeState.recording) const SizedBox(height: 16),

          // Recording / Stop Button
          _buildActionButton(theme),

          const SizedBox(height: 12),

          // Secondary Action Hints
          if (_state == PracticeState.idle && _selectedPart == 2)
            TextButton.icon(
              onPressed: _startPreparation,
              icon: const Icon(Icons.hourglass_bottom_rounded, size: 18),
              label: const Text('Start 60s Preparation Timer'),
            ),
          if (_state == PracticeState.preparing)
            TextButton.icon(
              onPressed: _startRecording,
              icon: const Icon(Icons.play_arrow_rounded, size: 20),
              label: const Text('Skip Prep & Begin Speaking'),
            ),
          if (_state == PracticeState.recorded)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _resetPractice,
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Re-record'),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _evaluateSpeakingWithAI,
                  icon: const Icon(Icons.auto_awesome, size: 18),
                  label: const Text('Evaluate with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildTimerDisplay(ThemeData theme, bool isDark) {
    String label = 'Ready to Speak';
    Color timerColor = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

    if (_state == PracticeState.preparing) {
      label = 'Preparation Time Remaining';
      timerColor = AppColors.warning;
    } else if (_state == PracticeState.recording) {
      label = 'Recording Audio...';
      timerColor = AppColors.danger;
    } else if (_state == PracticeState.recorded) {
      label = 'Audio Captured';
      timerColor = AppColors.success;
    } else if (_state == PracticeState.evaluating) {
      label = 'AI Examiner Analyzing Speech...';
      timerColor = AppColors.primary;
    }

    return Column(
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            _formatDuration(_timerSeconds),
            key: ValueKey(_timerSeconds),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: timerColor,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaveformVisualizer() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(12, (index) {
            final heightMultiplier = (index % 3 == 0)
                ? (1.0 - _waveController.value * 0.5) * _waveformAmplitude
                : (0.3 + _waveController.value * 0.7) * _waveformAmplitude;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: 5,
              height: 28 * heightMultiplier,
              decoration: BoxDecoration(
                color: AppColors.danger,
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildActionButton(ThemeData theme) {
    if (_state == PracticeState.recording) {
      return AnimatedBuilder(
        animation: _micPulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withOpacity(0.4 * _micPulseController.value),
                  blurRadius: 20 * _micPulseController.value,
                  spreadRadius: 8 * _micPulseController.value,
                )
              ],
            ),
            child: FloatingActionButton.large(
              heroTag: 'stop_btn',
              onPressed: _stopRecording,
              backgroundColor: AppColors.danger,
              elevation: 4,
              child: const Icon(Icons.stop_rounded, size: 40, color: Colors.white),
            ),
          );
        },
      );
    }

    if (_state == PracticeState.preparing) {
      return FloatingActionButton.large(
        heroTag: 'prep_btn',
        onPressed: _startRecording,
        backgroundColor: AppColors.warning,
        elevation: 4,
        child: const Icon(Icons.play_arrow_rounded, size: 44, color: Colors.black),
      );
    }

    return FloatingActionButton.large(
      heroTag: 'record_btn',
      onPressed: _startRecording,
      backgroundColor: AppColors.primary,
      elevation: 4,
      child: const Icon(Icons.mic_rounded, size: 38, color: Colors.white),
    );
  }

  Widget _buildTranscriptCard(ThemeData theme, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 20),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark ? AppColors.darkSurface : Colors.white,
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
                    const Icon(Icons.subtitles_rounded, size: 18, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Text(
                      'Audio Transcript',
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                if (_isTranscribing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    tooltip: 'Copy Transcript',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _transcriptController.text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Transcript copied to clipboard')),
                      );
                    },
                  ),
              ],
            ),
            const Divider(height: 16),
            if (_isTranscribing) ...[
              const LinearProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 12),
              Center(
                child: Text(
                  'Transcribing audio via OpenAI Whisper API...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ] else
              TextField(
                controller: _transcriptController,
                maxLines: 4,
                onTapOutside: (_) => FocusScope.of(context).unfocus(),
                decoration: InputDecoration(
                  hintText: 'Edit or type spoken response here...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  isDense: true,
                ),
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingEvaluationCard(ThemeData theme) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: const Padding(
        padding: EdgeInsets.all(32.0),
        child: Column(
          children: [
            CircularProgressIndicator(strokeWidth: 3, color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Analyzing Fluency, Vocabulary, Grammar, & Pronunciation...',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAIEvaluationCard(ThemeData theme, bool isDark) {
    final eval = _aiEvaluation!;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? AppColors.darkSurface : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Band Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Band Score Evaluation',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Assessed via Official IELTS Scoring Rubric',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: isDark ? AppColors.darkTextMuted : AppColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(height: 24),

            // Strengths
            if (eval.strengths.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Key Strengths',
                eval.strengths,
                Icons.check_circle_rounded,
                AppColors.success,
                isDark,
              ),
              const SizedBox(height: 16),
            ],

            // Grammar Errors & Feedback
            if (eval.grammarErrors.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Grammar Corrections',
                eval.grammarErrors,
                Icons.build_circle_rounded,
                AppColors.danger,
                isDark,
              ),
              const SizedBox(height: 16),
            ],

            // Vocabulary Enhancement Tips
            if (eval.vocabularyTips.isNotEmpty) ...[
              _buildFeedbackSection(
                theme,
                'Lexical & Vocabulary Tips',
                eval.vocabularyTips,
                Icons.lightbulb_rounded,
                AppColors.warning,
                isDark,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackSection(
    ThemeData theme,
    String title,
    List<String> items,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkBackground.withOpacity(0.5)
            : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                  Expanded(
                    child: Text(
                      item,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
