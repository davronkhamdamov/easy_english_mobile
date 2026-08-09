class DayStreakInfo {
  final String day;
  final String date;
  final bool isActive;
  final bool isToday;
  final bool isFuture;
  final bool isFrozen;

  const DayStreakInfo({
    required this.day,
    required this.date,
    required this.isActive,
    required this.isToday,
    required this.isFuture,
    required this.isFrozen,
  });
}

class StreakInfo {
  final int streakCount;
  final bool isActiveToday;
  final String? lastActiveDate;
  final int streakFreezeCount;
  final bool streakFreezeAvailable;
  final String? lastFreezeUsedDate;
  final bool freezeProtectedYesterday;
  final List<DayStreakInfo> weeklyBreakdown;
  final int weeklyActiveDaysCount;

  const StreakInfo({
    required this.streakCount,
    required this.isActiveToday,
    this.lastActiveDate,
    required this.streakFreezeCount,
    required this.streakFreezeAvailable,
    this.lastFreezeUsedDate,
    required this.freezeProtectedYesterday,
    required this.weeklyBreakdown,
    required this.weeklyActiveDaysCount,
  });
}

class MilestoneBadge {
  final String id;
  final String title;
  final String description;
  final String badgeIcon;
  final String category;
  final bool isUnlocked;
  final String? unlockedAt;
  final double progressPercentage;
  final int currentValue;
  final int targetValue;

  const MilestoneBadge({
    required this.id,
    required this.title,
    required this.description,
    required this.badgeIcon,
    required this.category,
    required this.isUnlocked,
    this.unlockedAt,
    required this.progressPercentage,
    required this.currentValue,
    required this.targetValue,
  });
}

class MotivationalCard {
  final String id;
  final String title;
  final String message;
  final String cardType;
  final String iconName;
  final String accentColor;
  final String actionLabel;

  const MotivationalCard({
    required this.id,
    required this.title,
    required this.message,
    required this.cardType,
    required this.iconName,
    required this.accentColor,
    required this.actionLabel,
  });
}

class AchievementMotivationOverview {
  final StreakInfo streakInfo;
  final List<MilestoneBadge> unlockedBadges;
  final List<MilestoneBadge> lockedBadges;
  final List<MotivationalCard> motivationalCards;

  const AchievementMotivationOverview({
    required this.streakInfo,
    required this.unlockedBadges,
    required this.lockedBadges,
    required this.motivationalCards,
  });
}
