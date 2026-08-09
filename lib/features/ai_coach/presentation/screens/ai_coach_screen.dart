import 'package:flutter/material.dart';
import '../providers/ai_coach_provider.dart';
import '../widgets/ai_coach_guidance_card.dart';
import '../widgets/ai_coach_header_card.dart';
import '../widgets/remediation_plan_section.dart';
import '../widgets/weakness_matrix_section.dart';

/// Interactive AI Coach & Personal Study Planner Screen.
class AICoachScreen extends StatefulWidget {
  final AiCoachProvider? provider;

  const AICoachScreen({super.key, this.provider});

  @override
  State<AICoachScreen> createState() => _AICoachScreenState();
}

class _AICoachScreenState extends State<AICoachScreen> {
  late final AiCoachProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = widget.provider ?? AiCoachProvider();
    _provider.addListener(_onProviderStateChanged);
    _provider.loadRecommendations();
  }

  @override
  void dispose() {
    _provider.removeListener(_onProviderStateChanged);
    if (widget.provider == null) {
      _provider.dispose();
    }
    super.dispose();
  }

  void _onProviderStateChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final recommendation = _provider.recommendation;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text(
          'AI Personal Coach',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        elevation: 0,
      ),
      body: _provider.isLoading || recommendation == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF6366F1)),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Card with Band Prediction
                  AiCoachHeaderCard(
                    predictedOverallBand: recommendation.predictedOverallBand,
                    targetBand: recommendation.targetBand,
                  ),
                  const SizedBox(height: 24),

                  // AI Coach Message Box
                  AiCoachGuidanceCard(notes: recommendation.aiCoachNotes),
                  const SizedBox(height: 24),

                  // Today's Remediation Plan
                  RemediationPlanSection(
                    tasks: recommendation.remediationTasks,
                  ),
                  const SizedBox(height: 24),

                  // Weakness Matrix
                  WeaknessMatrixSection(
                    weaknesses: recommendation.weaknessSummary,
                  ),
                ],
              ),
            ),
    );
  }
}
