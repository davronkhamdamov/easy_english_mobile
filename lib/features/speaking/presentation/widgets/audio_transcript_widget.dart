import 'package:flutter/material.dart';
import 'transcript_card.dart';

class AudioTranscriptWidget extends StatelessWidget {
  final TextEditingController transcriptController;
  final bool isTranscribing;

  const AudioTranscriptWidget({
    super.key,
    required this.transcriptController,
    required this.isTranscribing,
  });

  @override
  Widget build(BuildContext context) {
    return TranscriptCard(
      controller: transcriptController,
      isTranscribing: isTranscribing,
    );
  }
}
