import 'package:flutter/material.dart';
import '../presentation/screens/speaking_screen.dart';

class SpeakingRoutes {
  static const String speakingPath = '/speaking';

  static Widget getSpeakingScreen() {
    return const SpeakingScreen();
  }
}
