class SelfieStreakManager {
  static final SelfieStreakManager
  _instance = SelfieStreakManager._internal();
  factory SelfieStreakManager() => _instance;
  SelfieStreakManager._internal();

  // Mock data - in a real app, this would be stored in a database
  int
  _currentStreak = 7;
  int
  _longestStreak = 15;
  bool
  _todayCompleted = false;
  DateTime?
  _lastSelfieDate;
  final List<
    DateTime
  >
  _completedDates = [];

  // Getters
  int
  get currentStreak => _currentStreak;
  int
  get longestStreak => _longestStreak;
  bool
  get todayCompleted => _todayCompleted;
  DateTime?
  get lastSelfieDate => _lastSelfieDate;
  List<
    DateTime
  >
  get completedDates => List.unmodifiable(
    _completedDates,
  );

  // Check if user has completed today's selfie
  bool
  isTodayCompleted() {
    if (_lastSelfieDate ==
        null) {
      return false;
    }
    final today = DateTime.now();
    return _lastSelfieDate!.year ==
            today.year &&
        _lastSelfieDate!.month ==
            today.month &&
        _lastSelfieDate!.day ==
            today.day;
  }

  // Complete today's selfie
  void
  completeTodaysSelfie() {
    final today = DateTime.now();

    if (!isTodayCompleted()) {
      _lastSelfieDate = today;
      _completedDates.add(
        today,
      );
      _todayCompleted = true;

      // Check if streak continues
      if (_isConsecutiveDay()) {
        _currentStreak++;
      } else {
        _currentStreak = 1; // Reset streak
      }

      // Update longest streak
      if (_currentStreak >
          _longestStreak) {
        _longestStreak = _currentStreak;
      }
    }
  }

  // Check if today is consecutive to the last selfie
  bool
  _isConsecutiveDay() {
    if (_completedDates.length <
        2) {
      return true;
    }

    final today = DateTime.now();
    final yesterday = today.subtract(
      const Duration(
        days: 1,
      ),
    );

    // Check if yesterday was completed
    return _completedDates.any(
      (
        date,
      ) =>
          date.year ==
              yesterday.year &&
          date.month ==
              yesterday.month &&
          date.day ==
              yesterday.day,
    );
  }

  // Get streak status for a specific date
  bool
  isDateCompleted(
    DateTime date,
  ) {
    return _completedDates.any(
      (
        completedDate,
      ) =>
          completedDate.year ==
              date.year &&
          completedDate.month ==
              date.month &&
          completedDate.day ==
              date.day,
    );
  }

  // Get recent activity (last 7 days)
  List<
    Map<
      String,
      dynamic
    >
  >
  getRecentActivity() {
    final today = DateTime.now();
    final recentDays =
        <
          Map<
            String,
            dynamic
          >
        >[];

    for (
      int i = 0;
      i <
          7;
      i++
    ) {
      final date = today.subtract(
        Duration(
          days: i,
        ),
      );
      final completed = isDateCompleted(
        date,
      );

      String dayLabel;
      if (i ==
          0) {
        dayLabel = 'Today';
      } else if (i ==
          1) {
        dayLabel = 'Yesterday';
      } else {
        dayLabel = '$i days ago';
      }

      recentDays.add(
        {
          'day': dayLabel,
          'date': date,
          'completed': completed,
          'streak':
              completed &&
              _isPartOfCurrentStreak(
                date,
              ),
        },
      );
    }

    return recentDays;
  }

  // Check if a date is part of the current streak
  bool
  _isPartOfCurrentStreak(
    DateTime date,
  ) {
    final today = DateTime.now();
    final daysDifference = today
        .difference(
          date,
        )
        .inDays;

    // If it's within the current streak range and completed
    return daysDifference <
            _currentStreak &&
        isDateCompleted(
          date,
        );
  }

  // Reset streak (for testing purposes)
  void
  resetStreak() {
    _currentStreak = 0;
    _todayCompleted = false;
    _completedDates.clear();
    _lastSelfieDate = null;
  }

  // Get time until next selfie opportunity (for gamification)
  Duration
  getTimeUntilNextSelfie() {
    final now = DateTime.now();
    final tomorrow = DateTime(
      now.year,
      now.month,
      now.day +
          1,
    );
    return tomorrow.difference(
      now,
    );
  }

  // Get motivational message based on streak
  String
  getMotivationalMessage() {
    if (_currentStreak ==
        0) {
      return "Start your selfie journey today! 📸";
    } else if (_currentStreak <
        7) {
      return "Great start! Keep building your streak 🔥";
    } else if (_currentStreak <
        30) {
      return "Amazing consistency! You're on fire! 🚀";
    } else {
      return "Selfie legend! Your dedication is inspiring! 👑";
    }
  }

  // Get streak level (for gamification)
  String
  getStreakLevel() {
    if (_currentStreak <
        7) {
      return "Beginner";
    }
    if (_currentStreak <
        30) {
      return "Enthusiast";
    }
    if (_currentStreak <
        100) {
      return "Expert";
    }
    return "Legend";
  }
}
