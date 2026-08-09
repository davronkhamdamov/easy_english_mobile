import 'package:flutter/material.dart';
import '../../domain/entities/achievement_motivation.dart';

class StreakCounterCard extends StatelessWidget {
  final StreakInfo streakInfo;
  final VoidCallback? onFreezePressed;

  const StreakCounterCard({
    super.key,
    required this.streakInfo,
    this.onFreezePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [
              Colors.orange.shade800.withValues(alpha: 0.85),
              Colors.deepOrange.shade900.withValues(alpha: 0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            // Header Row: Fire Streak + Freeze Protection Pill
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.local_fire_department,
                        color: Colors.amberAccent,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${streakInfo.streakCount} Day Streak',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.5,
                          ),
                        ),
                        Text(
                          streakInfo.isActiveToday
                              ? 'Active Today • Keep it up!'
                              : 'Practice today to keep your streak!',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Streak Freeze Badge / Button
                InkWell(
                  onTap: onFreezePressed,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: streakInfo.streakFreezeAvailable
                          ? Colors.cyan.shade600.withValues(alpha: 0.85)
                          : Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: streakInfo.streakFreezeAvailable
                            ? Colors.cyanAccent
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.ac_unit,
                          color: Colors.cyanAccent,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${streakInfo.streakFreezeCount} Shield',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // Weekly Breakdown Tracker Pills (Mon-Sun)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: streakInfo.weeklyBreakdown.map((dayInfo) {
                return _buildDayPill(dayInfo);
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDayPill(DayStreakInfo info) {
    Color bg;
    Border? border;
    Widget iconChild;

    if (info.isFrozen) {
      bg = Colors.cyan.shade400;
      iconChild = const Icon(Icons.ac_unit, color: Colors.white, size: 14);
    } else if (info.isActive) {
      bg = Colors.amberAccent;
      iconChild = const Icon(Icons.check, color: Colors.deepOrange, size: 14);
    } else if (info.isFuture) {
      bg = Colors.white.withValues(alpha: 0.1);
      iconChild = Text(
        info.day[0],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.5),
          fontSize: 11,
        ),
      );
    } else {
      bg = Colors.black.withValues(alpha: 0.2);
      iconChild = Text(
        info.day[0],
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.7),
          fontSize: 11,
        ),
      );
    }

    if (info.isToday) {
      border = Border.all(color: Colors.white, width: 2);
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: bg,
            shape: BoxShape.circle,
            border: border,
          ),
          child: Center(child: iconChild),
        ),
        const SizedBox(height: 4),
        Text(
          info.day,
          style: TextStyle(
            color: info.isToday ? Colors.white : Colors.white70,
            fontSize: 11,
            fontWeight: info.isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
