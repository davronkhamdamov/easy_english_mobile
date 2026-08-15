import 'package:flutter/material.dart';
import '../../domain/entities/speaking_prompt.dart';
import 'speaking_prompt_card.dart';

class CueCardPromptWidget extends StatelessWidget {
  final SpeakingPrompt currentPrompt;
  final String Function(int)? formatDuration;

  const CueCardPromptWidget({
    super.key,
    required this.currentPrompt,
    this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    return SpeakingPromptCard(prompt: currentPrompt);
  }
}
