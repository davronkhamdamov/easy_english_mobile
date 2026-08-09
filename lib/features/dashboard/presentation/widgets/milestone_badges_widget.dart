import 'package:flutter/material.dart';
import '../../domain/entities/achievement_motivation.dart';

class MilestoneBadgesWidget extends StatelessWidget {
  final List<MilestoneBadge> unlockedBadges;
  final List<MilestoneBadge> lockedBadges;

  const MilestoneBadgesWidget({
    super.key,
    required this.unlockedBadges,
    required this.lockedBadges,
  });

  IconData _parseBadgeIcon(String iconName) {
    switch (iconName.toLowerCase()) {
      case 'local_fire_department':
      case 'flame':
        return Icons.local_fire_department;
      case 'bolt':
      case 'lightning':
        return Icons.bolt;
      case 'explore':
      case 'compass':
        return Icons.explore;
      case 'stars':
      case 'target':
        return Icons.stars;
      case 'security':
      case 'shield':
        return Icons.shield;
      case 'emoji_events':
      case 'trophy':
      default:
        return Icons.emoji_events;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final allBadges = [...unlockedBadges, ...lockedBadges];

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.workspace_premium,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Milestone Badges',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
                Text(
                  '${unlockedBadges.length}/${allBadges.length} Unlocked',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: allBadges.length,
                separatorBuilder: (ctx, i) => const SizedBox(width: 12),
                itemBuilder: (ctx, index) {
                  final b = allBadges[index];
                  final iconData = _parseBadgeIcon(b.badgeIcon);

                  return Container(
                    width: 95,
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: b.isUnlocked
                          ? Colors.amber.shade50
                          : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: b.isUnlocked
                            ? Colors.amber.shade400
                            : Colors.grey.shade300,
                        width: b.isUnlocked ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: b.isUnlocked
                                  ? Colors.amber
                                  : Colors.grey.shade400,
                              child: Icon(
                                iconData,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            if (!b.isUnlocked)
                              Positioned(
                                right: -2,
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: const BoxDecoration(
                                    color: Colors.grey,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.lock,
                                    color: Colors.white,
                                    size: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          b.title,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: b.isUnlocked
                                ? Colors.black87
                                : Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          b.isUnlocked
                              ? 'Unlocked'
                              : '${b.progressPercentage.toInt()}%',
                          style: TextStyle(
                            fontSize: 10,
                            color: b.isUnlocked
                                ? Colors.amber.shade900
                                : Colors.grey,
                            fontWeight: b.isUnlocked
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
