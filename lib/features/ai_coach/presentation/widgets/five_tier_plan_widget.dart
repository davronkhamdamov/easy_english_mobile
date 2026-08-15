import 'package:flutter/material.dart';
import '../../domain/entities/five_tier_recommendation.dart';

class FiveTierPlanWidget extends StatelessWidget {
  final FiveTierRecommendation plan;
  final int selectedIndex;
  final ValueChanged<int>? onTierSelected;

  const FiveTierPlanWidget({
    super.key,
    required this.plan,
    this.selectedIndex = 0,
    this.onTierSelected,
  });

  Color _getStatusColor(String status) {
    switch (status) {
      case 'completed':
        return const Color(0xFF10B981); // Green
      case 'in_progress':
        return const Color(0xFF3B82F6); // Blue
      case 'locked':
      default:
        return const Color(0xFF64748B); // Slate Grey
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'in_progress':
        return Icons.play_circle_fill_rounded;
      case 'locked':
      default:
        return Icons.lock_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tiers = plan.allTiers;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '5-Tier Learning Roadmap',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tiers.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final tier = tiers[index];
            final isSelected = index == selectedIndex;
            final color = _getStatusColor(tier.status);

            return GestureDetector(
              onTap: () => onTierSelected?.call(index),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF1E293B)
                      : const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? color : const Color(0xFF334155),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_getStatusIcon(tier.status), color: color, size: 22),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            tier.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            tier.status.replaceAll('_', ' ').toUpperCase(),
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (isSelected && tier.items.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Divider(color: Color(0xFF334155), height: 1),
                      const SizedBox(height: 12),
                      ...tier.items.map(
                        (item) => Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.circle,
                                size: 6,
                                color: color.withValues(alpha: 0.8),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    color: Color(0xFFE2E8F0),
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
