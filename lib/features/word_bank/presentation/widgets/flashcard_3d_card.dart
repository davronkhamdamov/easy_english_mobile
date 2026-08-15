import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../domain/entities/flashcard_item.dart';
import 'flashcard_card_back.dart';
import 'flashcard_card_front.dart';

class Flashcard3DCard extends StatelessWidget {
  final FlashcardItem card;
  final bool isFlipped;
  final Animation<double> flipAnimation;
  final VoidCallback onPlayWordAudio;
  final VoidCallback onPlaySentenceAudio;

  const Flashcard3DCard({
    super.key,
    required this.card,
    required this.isFlipped,
    required this.flipAnimation,
    required this.onPlayWordAudio,
    required this.onPlaySentenceAudio,
  });

  @override
  Widget build(BuildContext context) {
    final angle = flipAnimation.value * math.pi;

    return Transform(
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateY(angle),
      alignment: Alignment.center,
      child: angle < math.pi / 2
          ? FlashcardCardFront(
              card: card,
              onPlayWordAudio: onPlayWordAudio,
              onPlaySentenceAudio: onPlaySentenceAudio,
            )
          : Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(math.pi),
              child: FlashcardCardBack(card: card),
            ),
    );
  }
}
