import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'camera_screen.dart';
import 'selfie_leaderboard_screen.dart';
import 'achievements_screen.dart';
import 'selfie_calendar_screen.dart';
import 'selfie_tips_screen.dart';
import 'models/selfie_streak_manager.dart';
import 'models/daily_challenges.dart';
import 'services/api_service.dart';

class DailySelfieScreen
    extends
        StatefulWidget {
  const DailySelfieScreen({
    super.key,
  });

  @override
  State<
    DailySelfieScreen
  >
  createState() => _DailySelfieScreenState();
}

class _DailySelfieScreenState
    extends
        State<
          DailySelfieScreen
        >
    with
        TickerProviderStateMixin {
  late AnimationController
  _fadeController;
  late AnimationController
  _scaleController;
  late Animation<
    double
  >
  _fadeAnimation;
  late Animation<
    double
  >
  _scaleAnimation;

  final SelfieStreakManager
  _streakManager = SelfieStreakManager();
  final DailyChallengeManager
  _challengeManager = DailyChallengeManager();

  int
  _currentStreak = 0;
  int
  _longestStreak = 0;
  bool
  _todayCompleted = false;
  String
  _todayTheme = '';
  String
  lastSelfieTime = "2 hours ago";
  bool
  _isLoading = true;

  int
  get currentStreak => _currentStreak;
  int
  get longestStreak => _longestStreak;
  bool
  get todayCompleted => _todayCompleted;

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

    _scaleController = AnimationController(
      duration: const Duration(
        milliseconds: 600,
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

    _scaleAnimation =
        Tween<
              double
            >(
              begin: 0.8,
              end: 1.0,
            )
            .animate(
              CurvedAnimation(
                parent: _scaleController,
                curve: Curves.elasticOut,
              ),
            );

    _fadeController.forward();
    _scaleController.forward();
    _loadSelfieData();
  }

  Future<
    void
  >
  _loadSelfieData() async {
    try {
      final streakResponse = await ApiService.getUserSelfieStreak();
      final challengeResponse = await ApiService.getTodayChallenge();

      if (streakResponse['success']) {
        setState(
          () {
            _currentStreak =
                streakResponse['data']['currentStreak'] ??
                0;
            _todayCompleted =
                streakResponse['data']['todayCompleted'] ??
                false;
            _todayTheme =
                streakResponse['data']['todayTheme'] ??
                '';
          },
        );
      }

      if (challengeResponse['success']) {
        setState(
          () {
            _todayTheme =
                challengeResponse['data']['theme'] ??
                _todayTheme;
          },
        );
      }

      setState(
        () {
          _isLoading = false;
        },
      );
    } catch (
      e
    ) {
      print(
        'Error loading selfie data: $e',
      );
      setState(
        () {
          _isLoading = false;
        },
      );
    }
  }

  @override
  void
  dispose() {
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget
  build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Header
              _buildHeader(),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 20,
                      ),

                      // Streak Card
                      _buildStreakCard(),

                      const SizedBox(
                        height: 30,
                      ),

                      // Today's Challenge
                      _buildTodayChallenge(),

                      const SizedBox(
                        height: 30,
                      ),

                      // Recent Selfies
                      _buildRecentSelfies(),

                      const SizedBox(
                        height: 100,
                      ), // Space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget
  _buildHeader() {
    return Container(
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(
            30,
          ),
          bottomRight: Radius.circular(
            30,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(
                        context,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.all(
                        8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(
                          12,
                        ),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  const Text(
                    'Daily Selfie\nChallenge',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const SelfieCalendarScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                      child: const Icon(
                        Icons.calendar_today,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const AchievementsScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const SelfieLeaderboardScreen(),
                        ),
                      );
                    },
                    child: Container(
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
                      child: const Icon(
                        Icons.leaderboard,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(
            height: 20,
          ),

          // Quick Stats
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<
                          Color
                        >(
                          Colors.white,
                        ),
                  ),
                )
              : Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        'Current Streak',
                        '$currentStreak days',
                        Icons.local_fire_department,
                      ),
                    ),
                    const SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: _buildStatCard(
                        'Best Streak',
                        '$longestStreak days',
                        Icons.emoji_events,
                      ),
                    ),
                  ],
                ),
        ],
      ),
    );
  }

  Widget
  _buildStatCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.15,
        ),
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: Colors.white.withValues(
            alpha: 0.3,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.8,
              ),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildStreakCard() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(
          24,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: todayCompleted
                ? [
                    const Color(
                      0xFF4CAF50,
                    ),
                    const Color(
                      0xFF45A049,
                    ),
                  ]
                : [
                    const Color(
                      0xFFFF6B6B,
                    ),
                    const Color(
                      0xFFFF5252,
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
            Icon(
              todayCompleted
                  ? Icons.check_circle
                  : Icons.camera_alt,
              color: Colors.white,
              size: 48,
            ),
            const SizedBox(
              height: 16,
            ),
            Text(
              todayCompleted
                  ? 'Today\'s Selfie Complete!'
                  : 'Take Today\'s Selfie',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Text(
              todayCompleted
                  ? 'Great job! Your streak continues 🔥'
                  : 'Don\'t break your $currentStreak day streak!',
              style: TextStyle(
                color: Colors.white.withValues(
                  alpha: 0.9,
                ),
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            if (todayCompleted) ...[
              const SizedBox(
                height: 12,
              ),
              Text(
                'Uploaded $lastSelfieTime',
                style: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.7,
                  ),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget
  _buildTodayChallenge() {
    final todaysChallenge = _challengeManager.getTodaysChallenge();

    // Use real theme if available, otherwise use challenge manager
    final displayTheme = _todayTheme.isNotEmpty
        ? _todayTheme
        : todaysChallenge.title;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        20,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(
          15,
        ),
        border: Border.all(
          color: Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(
                  8,
                ),
                decoration: BoxDecoration(
                  color:
                      const Color(
                        0xFF701CF5,
                      ).withValues(
                        alpha: 0.1,
                      ),
                  borderRadius: BorderRadius.circular(
                    10,
                  ),
                ),
                child: Text(
                  todaysChallenge.emoji,
                  style: const TextStyle(
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(
                width: 12,
              ),
              const Text(
                'Today\'s Challenge',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 16,
          ),
          Text(
            displayTheme,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            todaysChallenge.description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              height: 1.4,
            ),
          ),
          if (todaysChallenge.tips.isNotEmpty) ...[
            const SizedBox(
              height: 12,
            ),
            Container(
              padding: const EdgeInsets.all(
                12,
              ),
              decoration: BoxDecoration(
                color:
                    const Color(
                      0xFF701CF5,
                    ).withValues(
                      alpha: 0.05,
                    ),
                borderRadius: BorderRadius.circular(
                  8,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '💡 Tips:',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF701CF5,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 4,
                  ),
                  ...todaysChallenge.tips.map(
                    (
                      tip,
                    ) => Padding(
                      padding: const EdgeInsets.only(
                        bottom: 2,
                      ),
                      child: Text(
                        '• $tip',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(
            height: 20,
          ),

          // Take Selfie Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: todayCompleted
                  ? null
                  : () {
                      HapticFeedback.mediumImpact();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (
                                context,
                              ) => const CameraScreen(
                                selectedPath: 'selfie_challenge',
                              ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: todayCompleted
                    ? Colors.grey[300]
                    : const Color(
                        0xFF701CF5,
                      ),
                foregroundColor: todayCompleted
                    ? Colors.grey[600]
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    25,
                  ),
                ),
                elevation: todayCompleted
                    ? 0
                    : 3,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    todayCompleted
                        ? Icons.check
                        : Icons.camera_alt,
                    size: 20,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    todayCompleted
                        ? 'Completed'
                        : 'Take Selfie',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(
            height: 12,
          ),

          // Tips Button
          SizedBox(
            width: double.infinity,
            height: 44,
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (
                          context,
                        ) => const SelfieTipsScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(
                  color: Color(
                    0xFF701CF5,
                  ),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    22,
                  ),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.lightbulb_outline,
                    color: Color(
                      0xFF701CF5,
                    ),
                    size: 18,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text(
                    'Selfie Tips & Tricks',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(
                        0xFF701CF5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget
  _buildRecentSelfies() {
    final recentSelfies = _streakManager.getRecentActivity();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(
          height: 16,
        ),

        ...recentSelfies.map(
          (
            selfie,
          ) => Container(
            margin: const EdgeInsets.only(
              bottom: 12,
            ),
            padding: const EdgeInsets.all(
              16,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(
                12,
              ),
              border: Border.all(
                color:
                    selfie['completed']
                        as bool
                    ? const Color(
                        0xFF4CAF50,
                      ).withValues(
                        alpha: 0.3,
                      )
                    : Colors.grey[300]!,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.05,
                  ),
                  blurRadius: 5,
                  offset: const Offset(
                    0,
                    2,
                  ),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color:
                        selfie['completed']
                            as bool
                        ? const Color(
                            0xFF4CAF50,
                          )
                        : Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    selfie['completed']
                            as bool
                        ? Icons.check
                        : Icons.close,
                    color:
                        selfie['completed']
                            as bool
                        ? Colors.white
                        : Colors.grey[600],
                    size: 20,
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
                        selfie['day']
                            as String,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        selfie['completed']
                                as bool
                            ? 'Selfie uploaded ✨'
                            : 'Missed day',
                        style: TextStyle(
                          fontSize: 12,
                          color:
                              selfie['completed']
                                  as bool
                              ? const Color(
                                  0xFF4CAF50,
                                )
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (selfie['streak']
                    as bool)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color:
                          const Color(
                            0xFFFF6B35,
                          ).withValues(
                            alpha: 0.1,
                          ),
                      borderRadius: BorderRadius.circular(
                        8,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.local_fire_department,
                          color: Color(
                            0xFFFF6B35,
                          ),
                          size: 12,
                        ),
                        SizedBox(
                          width: 2,
                        ),
                        Text(
                          'Streak',
                          style: TextStyle(
                            color: Color(
                              0xFFFF6B35,
                            ),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
