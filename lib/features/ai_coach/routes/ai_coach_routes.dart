import 'package:flutter/material.dart';
import '../presentation/screens/ai_coach_screen.dart';

class AiCoachRoutes {
  static const String aiCoachPath = '/ai-coach';

  static Widget getAiCoachScreen() {
    return const AICoachScreen();
  }
}
