import 'package:flutter/material.dart';
import '../../../../design_system/design_system.dart';
import '../../di/speaking_di.dart';
import '../providers/speaking_provider.dart';
import '../state/speaking_state.dart';
import '../widgets/ai_evaluation_card.dart';
import '../widgets/audio_recorder_controls.dart';
import '../widgets/part_switcher_tabs.dart';
import '../widgets/speaking_error_widget.dart';
import '../widgets/speaking_prompt_card.dart';
import '../widgets/transcript_card.dart';

class SpeakingScreen extends StatefulWidget {
  final SpeakingProvider? provider;

  const SpeakingScreen({super.key, this.provider});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  late final SpeakingProvider _provider;
  late final TextEditingController _transcriptController;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? SpeakingDI.provideSpeakingProvider();
    _transcriptController = TextEditingController();
    _provider.addListener(_onProviderChange);
    _provider.loadPrompts();
  }

  void _onProviderChange() {
    if (mounted) {
      final st = _provider.state;
      if (st.transcript != _transcriptController.text && !st.isTranscribing) {
        _transcriptController.text = st.transcript;
      }
      setState(() {});
    }
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderChange);
    _transcriptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final st = _provider.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('IELTS Speaking Practice'),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              children: [
                Icon(Icons.auto_awesome, size: 16, color: AppColors.primary),
                SizedBox(width: 6),
                Text('AI Examiner v2.0', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PartSwitcherTabs(
                selectedPart: st.selectedPart,
                onPartSelected: (part) => _provider.switchPart(part),
              ),
              const SizedBox(height: 16),
              if (st.isLoading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (st.errorMessage != null && st.prompts.isEmpty)
                SpeakingErrorWidget(
                  message: st.errorMessage!,
                  onRetry: () => _provider.loadPrompts(part: st.selectedPart),
                )
              else ...[
                if (st.currentPrompt != null) ...[
                  SpeakingPromptCard(prompt: st.currentPrompt!),
                  const SizedBox(height: 16),
                ],
                AudioRecorderControls(
                  state: st,
                  onStartPrep: () => _provider.startPreparation(),
                  onStartRecording: () => _provider.startRecording(),
                  onStopRecording: () => _provider.stopRecording(),
                  onReset: () => _provider.resetPractice(),
                  onEvaluate: () => _provider.evaluate(
                    overrideTranscript: _transcriptController.text,
                  ),
                ),
                const SizedBox(height: 16),
                if (_transcriptController.text.isNotEmpty ||
                    st.practiceState == PracticeState.recorded ||
                    st.isTranscribing)
                  TranscriptCard(
                    controller: _transcriptController,
                    isTranscribing: st.isTranscribing,
                    onChanged: (val) => _provider.updateTranscript(val),
                  ),
                if (st.isEvaluating)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text('AI Examiner Analyzing Speech...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                if (st.evaluationResult != null)
                  AIEvaluationCard(evaluation: st.evaluationResult!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
