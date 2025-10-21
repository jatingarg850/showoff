import 'dart:async';

class SelfieNotification {
  final String
  id;
  final String
  title;
  final String
  message;
  final DateTime
  scheduledTime;
  final bool
  isRecurring;

  const SelfieNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.scheduledTime,
    this.isRecurring = false,
  });
}

class SelfieNotificationManager {
  static final SelfieNotificationManager
  _instance = SelfieNotificationManager._internal();
  factory SelfieNotificationManager() => _instance;
  SelfieNotificationManager._internal();

  final List<
    SelfieNotification
  >
  _notifications = [];
  Timer?
  _reminderTimer;

  // Notification templates
  static const List<
    Map<
      String,
      String
    >
  >
  _reminderMessages = [
    {
      'title': '📸 Daily Selfie Reminder',
      'message': 'Don\'t break your streak! Take your daily selfie now.',
    },
    {
      'title': '🔥 Keep Your Streak Alive!',
      'message': 'Your selfie streak is waiting for today\'s photo.',
    },
    {
      'title': '⏰ Selfie Time!',
      'message': 'Time for your daily selfie challenge. Let\'s go!',
    },
    {
      'title': '🌟 Streak Reminder',
      'message': 'You\'re doing great! Don\'t forget today\'s selfie.',
    },
    {
      'title': '📱 Daily Challenge',
      'message': 'Your daily selfie challenge is ready. Tap to continue!',
    },
  ];

  // Schedule daily reminder notifications
  void
  scheduleDailyReminders() {
    // Cancel existing timer
    _reminderTimer?.cancel();

    // Schedule reminders at different times throughout the day
    final reminderTimes = [
      const Duration(
        hours: 9,
      ), // 9 AM
      const Duration(
        hours: 14,
      ), // 2 PM
      const Duration(
        hours: 18,
      ), // 6 PM
      const Duration(
        hours: 20,
      ), // 8 PM
    ];

    for (final time in reminderTimes) {
      _scheduleNotificationAt(
        time,
      );
    }
  }

  void
  _scheduleNotificationAt(
    Duration timeOfDay,
  ) {
    final now = DateTime.now();
    final scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      timeOfDay.inHours,
      timeOfDay.inMinutes %
          60,
    );

    // If the time has passed today, schedule for tomorrow
    final targetTime =
        scheduledTime.isBefore(
          now,
        )
        ? scheduledTime.add(
            const Duration(
              days: 1,
            ),
          )
        : scheduledTime;

    final delay = targetTime.difference(
      now,
    );

    Timer(
      delay,
      () {
        _showReminderNotification();
        // Reschedule for next day
        _scheduleNotificationAt(
          timeOfDay,
        );
      },
    );
  }

  void
  _showReminderNotification() {
    final message =
        _reminderMessages[DateTime.now().millisecond %
            _reminderMessages.length];

    // In a real app, this would use flutter_local_notifications
    // For now, we'll just store the notification
    final notification = SelfieNotification(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: message['title']!,
      message: message['message']!,
      scheduledTime: DateTime.now(),
      isRecurring: true,
    );

    _notifications.add(
      notification,
    );

    // Keep only last 10 notifications
    if (_notifications.length >
        10) {
      _notifications.removeAt(
        0,
      );
    }
  }

  // Schedule streak milestone notifications
  void
  scheduleStreakMilestone(
    int streakDays,
  ) {
    String title;
    String message;

    if (streakDays ==
        7) {
      title = '🎉 Week Warrior!';
      message = 'Congratulations! You\'ve completed 7 days of selfies!';
    } else if (streakDays ==
        30) {
      title = '👑 Month Master!';
      message = 'Amazing! 30 days of consistent selfies. You\'re a legend!';
    } else if (streakDays ==
        100) {
      title = '💎 Century Club!';
      message = 'Incredible! 100 days of selfies. You\'re unstoppable!';
    } else if (streakDays %
            10 ==
        0) {
      title = '🔥 Streak Milestone!';
      message = 'Wow! $streakDays days of selfies. Keep it up!';
    } else {
      return; // No notification for this milestone
    }

    final notification = SelfieNotification(
      id: 'milestone_$streakDays',
      title: title,
      message: message,
      scheduledTime: DateTime.now(),
    );

    _notifications.add(
      notification,
    );
  }

  // Get recent notifications
  List<
    SelfieNotification
  >
  getRecentNotifications({
    int limit = 5,
  }) {
    final sorted =
        List<
            SelfieNotification
          >.from(
            _notifications,
          )
          ..sort(
            (
              a,
              b,
            ) => b.scheduledTime.compareTo(
              a.scheduledTime,
            ),
          );

    return sorted
        .take(
          limit,
        )
        .toList();
  }

  // Clear all notifications
  void
  clearNotifications() {
    _notifications.clear();
  }

  // Get motivational push notification message based on streak
  String
  getMotivationalMessage(
    int currentStreak,
    bool todayCompleted,
  ) {
    if (todayCompleted) {
      return 'Great job completing today\'s selfie! Your $currentStreak day streak continues! 🔥';
    }

    if (currentStreak ==
        0) {
      return 'Start your selfie journey today! Every expert was once a beginner. 📸';
    } else if (currentStreak <
        7) {
      return 'You\'re $currentStreak days in! Don\'t break the momentum now. 💪';
    } else if (currentStreak <
        30) {
      return 'Your $currentStreak day streak is impressive! Keep the fire burning! 🔥';
    } else {
      return 'Legend status! $currentStreak days and counting. You inspire others! 👑';
    }
  }

  // Schedule evening reminder if selfie not taken
  void
  scheduleEveningReminder() {
    final now = DateTime.now();
    final eveningTime = DateTime(
      now.year,
      now.month,
      now.day,
      20,
      0,
    ); // 8 PM

    if (eveningTime.isAfter(
      now,
    )) {
      final delay = eveningTime.difference(
        now,
      );
      Timer(
        delay,
        () {
          final notification = SelfieNotification(
            id: 'evening_reminder_${now.day}',
            title: '🌅 Last Call!',
            message: 'Don\'t let your streak end today. Take your selfie before bed!',
            scheduledTime: DateTime.now(),
          );
          _notifications.add(
            notification,
          );
        },
      );
    }
  }

  void
  dispose() {
    _reminderTimer?.cancel();
  }
}
