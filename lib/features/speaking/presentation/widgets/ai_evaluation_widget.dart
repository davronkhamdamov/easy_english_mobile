import 'package:flutter/material.dart';
import '../../domain/entities/speaking_evaluation.dart';
import 'ai_evaluation_card.dart';

class AIEvaluationWidget extends StatelessWidget {
  final SpeakingAIEvaluation evaluation;

  const AIEvaluationWidget({super.key, required this.evaluation});

  @override
  Widget build(BuildContext context) {
    return AIEvaluationCard(evaluation: evaluation);
  }
}
