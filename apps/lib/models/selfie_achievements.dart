class SelfieAchievement {
  final String
  id;
  final String
  title;
  final String
  description;
  final String
  icon;
  final int
  requiredStreak;
  final bool
  isUnlocked;
  final DateTime?
  unlockedDate;

  const SelfieAchievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.requiredStreak,
    this.isUnlocked = false,
    this.unlockedDate,
  });
}

class SelfieAchievementManager {
  static final SelfieAchievementManager
  _instance = SelfieAchievementManager._internal();
  factory SelfieAchievementManager() => _instance;
  SelfieAchievementManager._internal();

  final List<
    SelfieAchievement
  >
  _achievements = [
    const SelfieAchievement(
      id: 'first_selfie',
      title: 'First Steps',
      description: 'Take your first daily selfie',
      icon: '📸',
      requiredStreak: 1,
    ),
    const SelfieAchievement(
      id: 'week_warrior',
      title: 'Week Warrior',
      description: 'Maintain a 7-day selfie streak',
      icon: '🔥',
      requiredStreak: 7,
    ),
    const SelfieAchievement(
      id: 'month_master',
      title: 'Month Master',
      description: 'Complete 30 consecutive days',
      icon: '👑',
      requiredStreak: 30,
    ),
    const SelfieAchievement(
      id: 'century_club',
      title: 'Century Club',
      description: 'Reach 100 days streak',
      icon: '💎',
      requiredStreak: 100,
    ),
    const SelfieAchievement(
      id: 'legend_status',
      title: 'Legend Status',
      description: 'Achieve 365 days streak',
      icon: '🏆',
      requiredStreak: 365,
    ),
  ];

  List<
    SelfieAchievement
  >
  get achievements => List.unmodifiable(
    _achievements,
  );

  List<
    SelfieAchievement
  >
  getUnlockedAchievements(
    int currentStreak,
  ) {
    return _achievements
        .where(
          (
            achievement,
          ) =>
              currentStreak >=
              achievement.requiredStreak,
        )
        .toList();
  }

  SelfieAchievement?
  getNextAchievement(
    int currentStreak,
  ) {
    return _achievements.firstWhere(
      (
        achievement,
      ) =>
          currentStreak <
          achievement.requiredStreak,
      orElse: () => _achievements.last,
    );
  }

  double
  getProgressToNextAchievement(
    int currentStreak,
  ) {
    final nextAchievement = getNextAchievement(
      currentStreak,
    );
    if (nextAchievement ==
        null) {
      return 1.0;
    }

    return currentStreak /
        nextAchievement.requiredStreak;
  }
}
