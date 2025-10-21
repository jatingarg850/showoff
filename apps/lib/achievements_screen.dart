import 'package:flutter/material.dart';
import 'models/selfie_achievements.dart';
import 'models/selfie_streak_manager.dart';

class AchievementsScreen
    extends
        StatefulWidget {
  const AchievementsScreen({
    super.key,
  });

  @override
  State<
    AchievementsScreen
  >
  createState() => _AchievementsScreenState();
}

class _AchievementsScreenState
    extends
        State<
          AchievementsScreen
        >
    with
        TickerProviderStateMixin {
  final SelfieAchievementManager
  _achievementManager = SelfieAchievementManager();
  final SelfieStreakManager
  _streakManager = SelfieStreakManager();

  late AnimationController
  _fadeController;
  late Animation<
    double
  >
  _fadeAnimation;

  @override
  void
  initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ),
      vsync: this,
    );
    _fadeAnimation =
        Tween<
              double
            >(
              begin: 0.0,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _fadeController,
                curve: Curves.easeInOut,
              ),
            );
    _fadeController.forward();
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    final currentStreak = _streakManager.currentStreak;
    final unlockedAchievements = _achievementManager.getUnlockedAchievements(
      currentStreak,
    );
    final nextAchievement = _achievementManager.getNextAchievement(
      currentStreak,
    );
    final progress = _achievementManager.getProgressToNextAchievement(
      currentStreak,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.black,
          ),
          onPressed: () => Navigator.pop(
            context,
          ),
        ),
        title: const Text(
          'Achievements',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Progress to next achievement
              if (nextAchievement !=
                  null)
                _buildNextAchievementCard(
                  nextAchievement,
                  progress,
                ),

              const SizedBox(
                height: 30,
              ),

              // Achievements grid
              const Text(
                'Your Achievements',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(
                height: 16,
              ),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.85,
                ),
                itemCount: _achievementManager.achievements.length,
                itemBuilder:
                    (
                      context,
                      index,
                    ) {
                      final achievement = _achievementManager.achievements[index];
                      final isUnlocked = unlockedAchievements.contains(
                        achievement,
                      );
                      return _buildAchievementCard(
                        achievement,
                        isUnlocked,
                      );
                    },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildNextAchievementCard(
    SelfieAchievement nextAchievement,
    double progress,
  ) {
    final currentStreak = _streakManager.currentStreak;
    final remaining =
        nextAchievement.requiredStreak -
        currentStreak;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(
              0xFF701CF5,
            ),
            Color(
              0xFF3E98E4,
            ),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(
          20,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(
              alpha: 0.1,
            ),
            blurRadius: 15,
            offset: const Offset(
              0,
              5,
            ),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  12,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(
                    alpha: 0.2,
                  ),
                  borderRadius: BorderRadius.circular(
                    15,
                  ),
                ),
                child: Text(
                  nextAchievement.icon,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Achievement',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.8,
                        ),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      nextAchievement.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '$remaining days to go!',
                      style: TextStyle(
                        color: Colors.white.withValues(
                          alpha: 0.9,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),

          // Progress bar
          Container(
            width: double.infinity,
            height: 8,
            decoration: BoxDecoration(
              color: Colors.white.withValues(
                alpha: 0.3,
              ),
              borderRadius: BorderRadius.circular(
                4,
              ),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress.clamp(
                0.0,
                1.0,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(
                    4,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            '${(progress * 100).toInt()}% Complete',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.9,
              ),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildAchievementCard(
    SelfieAchievement achievement,
    bool isUnlocked,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: isUnlocked
            ? Colors.white
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: isUnlocked
              ? const Color(
                  0xFF701CF5,
                ).withValues(
                  alpha: 0.3,
                )
              : Colors.grey[300]!,
          width: 2,
        ),
        boxShadow: isUnlocked
            ? [
                BoxShadow(
                  color:
                      const Color(
                        0xFF701CF5,
                      ).withValues(
                        alpha: 0.1,
                      ),
                  blurRadius: 10,
                  offset: const Offset(
                    0,
                    4,
                  ),
                ),
              ]
            : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(
                      0xFF701CF5,
                    ).withValues(
                      alpha: 0.1,
                    )
                  : Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: isUnlocked
                      ? null
                      : Colors.grey[400],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 12,
          ),
          Text(
            achievement.title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isUnlocked
                  ? Colors.black87
                  : Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 6,
          ),
          Text(
            achievement.description,
            style: TextStyle(
              fontSize: 12,
              color: isUnlocked
                  ? Colors.grey[600]
                  : Colors.grey[400],
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(
            height: 8,
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: isUnlocked
                  ? const Color(
                      0xFF4CAF50,
                    ).withValues(
                      alpha: 0.1,
                    )
                  : Colors.grey[200],
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Text(
              isUnlocked
                  ? 'Unlocked!'
                  : '${achievement.requiredStreak} days',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: isUnlocked
                    ? const Color(
                        0xFF4CAF50,
                      )
                    : Colors.grey[500],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
