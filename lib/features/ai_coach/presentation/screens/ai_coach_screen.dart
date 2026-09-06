import 'package:flutter/material.dart';
import '../../di/ai_coach_di.dart';
import '../providers/ai_coach_provider.dart';
import '../widgets/ai_coach_error_widget.dart';
import '../widgets/ai_coach_guidance_card.dart';
import '../widgets/ai_coach_header_card.dart';
import '../widgets/five_tier_plan_widget.dart';
import '../widgets/recommended_topics_list.dart';
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
    _provider = widget.provider ?? AiCoachDI.provideAiCoachProvider();
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
    final theme = Theme.of(context);
    final recommendation = _provider.recommendation;
    final plan = _provider.fiveTierPlan;
    final errorMessage = _provider.errorMessage;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'AI Personal Coach',
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.onSurface),
      ),
      body: RefreshIndicator(
        onRefresh: () => _provider.refresh(),
        color: theme.colorScheme.onSurface,
        backgroundColor: theme.colorScheme.surface,
        child: _buildBody(recommendation, plan, errorMessage, theme),
      ),
    );
  }

  Widget _buildBody(
    dynamic recommendation,
    dynamic plan,
    String? errorMessage,
    ThemeData theme,
  ) {
    if (_provider.isLoading && recommendation == null) {
      return Center(
        child: CircularProgressIndicator(color: theme.colorScheme.onSurface),
      );
    }

    if (errorMessage != null && recommendation == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: AiCoachErrorWidget(
            errorMessage: errorMessage,
            onRetry: () => _provider.fetchRecommendations(),
          ),
        ),
      );
    }

    if (recommendation == null) {
      return SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
          child: AiCoachErrorWidget(
            errorMessage: 'No recommendations data available.',
            onRetry: () => _provider.fetchRecommendations(),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          AiCoachHeaderCard(
            predictedOverallBand: recommendation.predictedOverallBand,
            targetBand: recommendation.targetBand,
            coachMessage: recommendation.aiCoachMessage,
            primaryWeakness: recommendation.primaryWeakness,
          ),
          const SizedBox(height: 20),

          // Recommended Topics Horizontal Scroll List
          if (recommendation.recommendedTopics.isNotEmpty) ...[
            RecommendedTopicsList(
              topics: recommendation.recommendedTopics,
            ),
            const SizedBox(height: 24),
          ],

          // 5-Tier Interactive Roadmap
          if (plan != null) ...[
            FiveTierPlanWidget(
              plan: plan,
              selectedIndex: _provider.selectedTierIndex,
              onTierSelected: (idx) => _provider.selectTier(idx),
            ),
            const SizedBox(height: 24),
          ],

          // Coach Guidance Card
          AiCoachGuidanceCard(notes: recommendation.aiCoachNotes),
          const SizedBox(height: 24),

          // Remediation Plan Section
          RemediationPlanSection(
            tasks: recommendation.remediationTasks,
          ),
          const SizedBox(height: 24),

          // Weakness Matrix Section
          WeaknessMatrixSection(
            weaknesses: recommendation.weaknessSummary,
          ),
        ],
      ),
    );
  }
}
