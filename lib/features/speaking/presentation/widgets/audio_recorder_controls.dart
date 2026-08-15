import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../state/speaking_state.dart';
import 'speaking_timer_readout.dart';
import 'waveform_visualizer.dart';

class AudioRecorderControls extends StatefulWidget {
  final SpeakingState state;
  final VoidCallback onStartPrep;
  final VoidCallback onStartRecording;
  final VoidCallback onStopRecording;
  final VoidCallback onReset;
  final VoidCallback onEvaluate;

  const AudioRecorderControls({
    super.key,
    required this.state,
    required this.onStartPrep,
    required this.onStartRecording,
    required this.onStopRecording,
    required this.onReset,
    required this.onEvaluate,
  });

  @override
  State<AudioRecorderControls> createState() => _AudioRecorderControlsState();
}

class _AudioRecorderControlsState extends State<AudioRecorderControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final st = widget.state;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: st.practiceState == PracticeState.recording
              ? AppColors.danger.withValues(alpha: 0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
        ),
      ),
      child: Column(
        children: [
          SpeakingTimerReadout(state: st),
          const SizedBox(height: 14),
          if (st.practiceState == PracticeState.recording) ...[
            const WaveformVisualizer(),
            const SizedBox(height: 14),
          ],
          _buildActionButton(st),
          const SizedBox(height: 12),
          _buildSecondaryActions(st),
        ],
      ),
    );
  }

  Widget _buildActionButton(SpeakingState st) {
    if (st.practiceState == PracticeState.recording) {
      return AnimatedBuilder(
        animation: _pulseController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.danger.withValues(
                    alpha: 0.4 * _pulseController.value,
                  ),
                  blurRadius: 20 * _pulseController.value,
                  spreadRadius: 6 * _pulseController.value,
                ),
              ],
            ),
            child: FloatingActionButton.large(
              heroTag: 'stop_btn',
              onPressed: widget.onStopRecording,
              backgroundColor: AppColors.danger,
              child: const Icon(Icons.stop_rounded, size: 40, color: Colors.white),
            ),
          );
        },
      );
    }

    if (st.practiceState == PracticeState.preparing) {
      return FloatingActionButton.large(
        heroTag: 'prep_btn',
        onPressed: widget.onStartRecording,
        backgroundColor: AppColors.warning,
        child: const Icon(Icons.play_arrow_rounded, size: 44, color: Colors.black),
      );
    }

    return FloatingActionButton.large(
      heroTag: 'record_btn',
      onPressed: widget.onStartRecording,
      backgroundColor: AppColors.primary,
      child: const Icon(Icons.mic_rounded, size: 38, color: Colors.white),
    );
  }

  Widget _buildSecondaryActions(SpeakingState st) {
    if (st.practiceState == PracticeState.idle && st.selectedPart == 2) {
      return TextButton.icon(
        onPressed: widget.onStartPrep,
        icon: const Icon(Icons.hourglass_bottom_rounded, size: 18),
        label: const Text('Start 60s Prep Timer'),
      );
    }
    if (st.practiceState == PracticeState.preparing) {
      return TextButton.icon(
        onPressed: widget.onStartRecording,
        icon: const Icon(Icons.play_arrow_rounded, size: 20),
        label: const Text('Skip Prep & Record'),
      );
    }
    if (st.practiceState == PracticeState.recorded) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          OutlinedButton.icon(
            onPressed: widget.onReset,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Re-record'),
          ),
          const SizedBox(width: 12),
          ElevatedButton.icon(
            onPressed: widget.onEvaluate,
            icon: const Icon(Icons.auto_awesome, size: 18),
            label: const Text('Evaluate with AI'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }
}
