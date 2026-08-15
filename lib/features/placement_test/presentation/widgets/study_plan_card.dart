import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/study_plan_recommendation.dart';

class StudyPlanCard extends StatelessWidget {
  final StudyPlanRecommendation plan;
  final VoidCallback onSavePlan;
  final VoidCallback onRetakeTest;

  const StudyPlanCard({
    super.key,
    required this.plan,
    required this.onSavePlan,
    required this.onRetakeTest,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Personalized IELTS Study Plan',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Chip(
                      label: Text('Target Band ${plan.targetBand}'),
                      backgroundColor: AppColors.primaryLight,
                      labelStyle: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricTile('Daily Target', '${plan.recommendedDailyMinutes} mins/day'),
                    _buildMetricTile('Estimated Time', '${plan.estimatedWeeksToTarget} weeks'),
                    _buildMetricTile('Weekly Goals', '${plan.weeklySchedule.length} modules'),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Recommended Daily Schedule:',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                ...plan.weeklySchedule.map(
                  (item) => Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          item.day,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 12),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '${item.focusSkill}: ${item.action}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                        Text('${item.durationMinutes}m', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            onPressed: onSavePlan,
            icon: const Icon(Icons.bookmark_added),
            label: const Text('Save Study Plan to Dashboard'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          height: 46,
          child: OutlinedButton.icon(
            onPressed: onRetakeTest,
            icon: const Icon(Icons.refresh),
            label: const Text('Retake Diagnostic Test'),
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMetricTile(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey)),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
        ),
      ],
    );
  }
}
