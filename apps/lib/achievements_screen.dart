import 'package:flutter/material.dart';
import 'services/api_service.dart';

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
  late AnimationController
  _fadeController;
  late Animation<
    double
  >
  _fadeAnimation;

  List<
    Map<
      String,
      dynamic
    >
  >
  _achievements = [];
  Map<
    String,
    dynamic
  >?
  _nextAchievement;
  int
  _currentStreak = 0;
  int
  _unlockedCount = 0;
  int
  _totalCount = 0;
  bool
  _isLoading = true;

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
    _loadAchievements();
  }

  Future<
    void
  >
  _loadAchievements() async {
    try {
      // Check for new achievements first
      await ApiService.checkAndUnlockAchievements();

      // Then load all achievements
      final response = await ApiService.getUserAchievements();

      if (response['success'] &&
          mounted) {
        setState(
          () {
            _achievements =
                List<
                  Map<
                    String,
                    dynamic
                  >
                >.from(
                  response['data']['achievements'] ??
                      [],
                );
            _nextAchievement = response['data']['nextAchievement'];
            _currentStreak =
                response['data']['currentStreak'] ??
                0;
            _unlockedCount =
                response['data']['unlockedCount'] ??
                0;
            _totalCount =
                response['data']['totalCount'] ??
                0;
            _isLoading = false;
          },
        );
      }
    } catch (
      e
    ) {
      print(
        'Error loading achievements: $e',
      );
      if (mounted) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
    }
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _refreshAchievements() async {
    await _loadAchievements();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<
                      Color
                    >(
                      Color(
                        0xFF701CF5,
                      ),
                    ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshAchievements,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress to next achievement
                      if (_nextAchievement !=
                          null)
                        _buildNextAchievementCard(
                          _nextAchievement!,
                        ),

                      const SizedBox(
                        height: 30,
                      ),

                      // Stats row
                      _buildStatsRow(),

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
                        itemCount: _achievements.length,
                        itemBuilder:
                            (
                              context,
                              index,
                            ) {
                              final achievement = _achievements[index];
                              return _buildAchievementCard(
                                achievement,
                              );
                            },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget
  _buildStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Streak',
            '$_currentStreak days',
            Icons.local_fire_department,
            Colors.orange,
          ),
        ),
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: _buildStatCard(
            'Unlocked',
            '$_unlockedCount/$_totalCount',
            Icons.emoji_events,
            Colors.green,
          ),
        ),
      ],
    );
  }

  Widget
  _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(
          0.1,
        ),
        borderRadius: BorderRadius.circular(
          12,
        ),
        border: Border.all(
          color: color.withOpacity(
            0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildNextAchievementCard(
    Map<
      String,
      dynamic
    >
    nextAchievement,
  ) {
    final remaining =
        nextAchievement['requiredStreak'] -
        _currentStreak;
    final progress =
        nextAchievement['progress'] ??
        0.0;

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
                  nextAchievement['icon'] ??
                      '🏆',
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
                      nextAchievement['title'] ??
                          '',
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
    Map<
      String,
      dynamic
    >
    achievement,
  ) {
    final isUnlocked =
        achievement['isUnlocked'] ??
        false;
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
                achievement['icon'] ??
                    '🏆',
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
            achievement['title'] ??
                '',
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
            achievement['description'] ??
                '',
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
                  : '${achievement['requiredStreak'] ?? 0} days',
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
