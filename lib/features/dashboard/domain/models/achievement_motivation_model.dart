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

  factory DayStreakInfo.fromJson(Map<String, dynamic> json) {
    return DayStreakInfo(
      day: json['day'] as String? ?? 'Mon',
      date: json['date'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      isToday: json['is_today'] as bool? ?? false,
      isFuture: json['is_future'] as bool? ?? false,
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }
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

  factory StreakInfo.fromJson(Map<String, dynamic> json) {
    final rawList = json['weekly_breakdown'] as List<dynamic>? ?? [];
    final breakdown = rawList.map((e) => DayStreakInfo.fromJson(e as Map<String, dynamic>)).toList();

    return StreakInfo(
      streakCount: (json['streak_count'] as num?)?.toInt() ?? 0,
      isActiveToday: json['is_active_today'] as bool? ?? false,
      lastActiveDate: json['last_active_date'] as String?,
      streakFreezeCount: (json['streak_freeze_count'] as num?)?.toInt() ?? 0,
      streakFreezeAvailable: json['streak_freeze_available'] as bool? ?? false,
      lastFreezeUsedDate: json['last_freeze_used_date'] as String?,
      freezeProtectedYesterday: json['freeze_protected_yesterday'] as bool? ?? false,
      weeklyBreakdown: breakdown,
      weeklyActiveDaysCount: (json['weekly_active_days_count'] as num?)?.toInt() ?? 0,
    );
  }
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

  factory MilestoneBadge.fromJson(Map<String, dynamic> json) {
    return MilestoneBadge(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      badgeIcon: json['badge_icon'] as String? ?? 'trophy',
      category: json['category'] as String? ?? 'general',
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] as String?,
      progressPercentage: (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
      targetValue: (json['target_value'] as num?)?.toInt() ?? 1,
    );
  }
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

  factory MotivationalCard.fromJson(Map<String, dynamic> json) {
    return MotivationalCard(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      cardType: json['card_type'] as String? ?? 'general',
      iconName: json['icon_name'] as String? ?? 'star',
      accentColor: json['accent_color'] as String? ?? 'blue',
      actionLabel: json['action_label'] as String? ?? 'View',
    );
  }
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

  factory AchievementMotivationOverview.fromJson(Map<String, dynamic> json) {
    final rawStreak = json['streak_info'] as Map<String, dynamic>? ?? {};
    final rawUnlocked = json['unlocked_badges'] as List<dynamic>? ?? [];
    final rawLocked = json['locked_badges'] as List<dynamic>? ?? [];
    final rawCards = json['motivational_cards'] as List<dynamic>? ?? [];

    return AchievementMotivationOverview(
      streakInfo: StreakInfo.fromJson(rawStreak),
      unlockedBadges: rawUnlocked.map((e) => MilestoneBadge.fromJson(e as Map<String, dynamic>)).toList(),
      lockedBadges: rawLocked.map((e) => MilestoneBadge.fromJson(e as Map<String, dynamic>)).toList(),
      motivationalCards: rawCards.map((e) => MotivationalCard.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
