import '../../domain/entities/achievement_motivation.dart';

class DayStreakInfoModel extends DayStreakInfo {
  const DayStreakInfoModel({
    required super.day,
    required super.date,
    required super.isActive,
    required super.isToday,
    required super.isFuture,
    required super.isFrozen,
  });

  factory DayStreakInfoModel.fromJson(Map<String, dynamic> json) {
    return DayStreakInfoModel(
      day: json['day'] as String? ?? 'Mon',
      date: json['date'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? false,
      isToday: json['is_today'] as bool? ?? false,
      isFuture: json['is_future'] as bool? ?? false,
      isFrozen: json['is_frozen'] as bool? ?? false,
    );
  }

  DayStreakInfo toEntity() {
    return DayStreakInfo(
      day: day,
      date: date,
      isActive: isActive,
      isToday: isToday,
      isFuture: isFuture,
      isFrozen: isFrozen,
    );
  }
}

class StreakInfoModel extends StreakInfo {
  const StreakInfoModel({
    required super.streakCount,
    required super.isActiveToday,
    super.lastActiveDate,
    required super.streakFreezeCount,
    required super.streakFreezeAvailable,
    super.lastFreezeUsedDate,
    required super.freezeProtectedYesterday,
    required super.weeklyBreakdown,
    required super.weeklyActiveDaysCount,
  });

  factory StreakInfoModel.fromJson(Map<String, dynamic> json) {
    final rawList = json['weekly_breakdown'] as List<dynamic>? ?? [];
    final breakdown = rawList
        .map((e) => DayStreakInfoModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return StreakInfoModel(
      streakCount: (json['streak_count'] as num?)?.toInt() ?? 0,
      isActiveToday: json['is_active_today'] as bool? ?? false,
      lastActiveDate: json['last_active_date'] as String?,
      streakFreezeCount: (json['streak_freeze_count'] as num?)?.toInt() ?? 0,
      streakFreezeAvailable: json['streak_freeze_available'] as bool? ?? false,
      lastFreezeUsedDate: json['last_freeze_used_date'] as String?,
      freezeProtectedYesterday:
          json['freeze_protected_yesterday'] as bool? ?? false,
      weeklyBreakdown: breakdown,
      weeklyActiveDaysCount:
          (json['weekly_active_days_count'] as num?)?.toInt() ?? 0,
    );
  }

  StreakInfo toEntity() {
    return StreakInfo(
      streakCount: streakCount,
      isActiveToday: isActiveToday,
      lastActiveDate: lastActiveDate,
      streakFreezeCount: streakFreezeCount,
      streakFreezeAvailable: streakFreezeAvailable,
      lastFreezeUsedDate: lastFreezeUsedDate,
      freezeProtectedYesterday: freezeProtectedYesterday,
      weeklyBreakdown: weeklyBreakdown,
      weeklyActiveDaysCount: weeklyActiveDaysCount,
    );
  }
}

class MilestoneBadgeModel extends MilestoneBadge {
  const MilestoneBadgeModel({
    required super.id,
    required super.title,
    required super.description,
    required super.badgeIcon,
    required super.category,
    required super.isUnlocked,
    super.unlockedAt,
    required super.progressPercentage,
    required super.currentValue,
    required super.targetValue,
  });

  factory MilestoneBadgeModel.fromJson(Map<String, dynamic> json) {
    return MilestoneBadgeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      badgeIcon: json['badge_icon'] as String? ?? 'trophy',
      category: json['category'] as String? ?? 'general',
      isUnlocked: json['is_unlocked'] as bool? ?? false,
      unlockedAt: json['unlocked_at'] as String?,
      progressPercentage:
          (json['progress_percentage'] as num?)?.toDouble() ?? 0.0,
      currentValue: (json['current_value'] as num?)?.toInt() ?? 0,
      targetValue: (json['target_value'] as num?)?.toInt() ?? 1,
    );
  }

  MilestoneBadge toEntity() {
    return MilestoneBadge(
      id: id,
      title: title,
      description: description,
      badgeIcon: badgeIcon,
      category: category,
      isUnlocked: isUnlocked,
      unlockedAt: unlockedAt,
      progressPercentage: progressPercentage,
      currentValue: currentValue,
      targetValue: targetValue,
    );
  }
}

class MotivationalCardModel extends MotivationalCard {
  const MotivationalCardModel({
    required super.id,
    required super.title,
    required super.message,
    required super.cardType,
    required super.iconName,
    required super.accentColor,
    required super.actionLabel,
  });

  factory MotivationalCardModel.fromJson(Map<String, dynamic> json) {
    return MotivationalCardModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      message: json['message'] as String? ?? '',
      cardType: json['card_type'] as String? ?? 'general',
      iconName: json['icon_name'] as String? ?? 'star',
      accentColor: json['accent_color'] as String? ?? 'blue',
      actionLabel: json['action_label'] as String? ?? 'View',
    );
  }

  MotivationalCard toEntity() {
    return MotivationalCard(
      id: id,
      title: title,
      message: message,
      cardType: cardType,
      iconName: iconName,
      accentColor: accentColor,
      actionLabel: actionLabel,
    );
  }
}

class AchievementMotivationOverviewModel extends AchievementMotivationOverview {
  const AchievementMotivationOverviewModel({
    required super.streakInfo,
    required super.unlockedBadges,
    required super.lockedBadges,
    required super.motivationalCards,
  });

  factory AchievementMotivationOverviewModel.fromJson(
    Map<String, dynamic> json,
  ) {
    final rawStreak = json['streak_info'] as Map<String, dynamic>? ?? {};
    final rawUnlocked = json['unlocked_badges'] as List<dynamic>? ?? [];
    final rawLocked = json['locked_badges'] as List<dynamic>? ?? [];
    final rawCards = json['motivational_cards'] as List<dynamic>? ?? [];

    return AchievementMotivationOverviewModel(
      streakInfo: StreakInfoModel.fromJson(rawStreak),
      unlockedBadges: rawUnlocked
          .map((e) => MilestoneBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      lockedBadges: rawLocked
          .map((e) => MilestoneBadgeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      motivationalCards: rawCards
          .map((e) => MotivationalCardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  AchievementMotivationOverview toEntity() {
    return AchievementMotivationOverview(
      streakInfo: streakInfo,
      unlockedBadges: unlockedBadges,
      lockedBadges: lockedBadges,
      motivationalCards: motivationalCards,
    );
  }
}
