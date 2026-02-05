import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class PushNotificationService {
  static PushNotificationService? _instance;
  static PushNotificationService get instance =>
      _instance ??= PushNotificationService._();

  PushNotificationService._();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Request notification permissions
      await _requestPermissions();

      // Initialize the plugin
      await _initializePlugin();

      _isInitialized = true;
      debugPrint('✅ Push notification service initialized');
    } catch (e) {
      debugPrint('❌ Error initializing push notifications: $e');
    }
  }

  Future<void> _requestPermissions() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Request notification permission for Android 13+
      final status = await Permission.notification.request();
      if (status.isDenied) {
        debugPrint('⚠️ Notification permission denied');
      }
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // Request iOS permissions
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin
          >()
          ?.requestPermissions(alert: true, badge: true, sound: true);
    }
  }

  Future<void> _initializePlugin() async {
    try {
      // Android initialization settings - use app logo
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/launcher_icon');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: true,
            requestBadgePermission: true,
            requestSoundPermission: true,
          );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
            android: initializationSettingsAndroid,
            iOS: initializationSettingsIOS,
          );

      // Initialize the plugin
      await _flutterLocalNotificationsPlugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTapped,
      );
    } catch (e) {
      debugPrint('❌ Error initializing notification plugin: $e');
      rethrow;
    }
  }

  void _onNotificationTapped(NotificationResponse notificationResponse) {
    final payload = notificationResponse.payload;
    if (payload != null) {
      debugPrint('Notification tapped with payload: $payload');
      // Handle notification tap - navigate to specific screen
      _handleNotificationTap(payload);
    }
  }

  void _handleNotificationTap(String payload) {
    try {
      // Parse the payload to determine action
      // Format: "type:postId" or "type:userId" etc.
      final parts = payload.split(':');
      if (parts.length >= 2) {
        final type = parts[0];
        final id = parts[1];

        switch (type) {
          case 'like':
          case 'comment':
            // Navigate to post
            debugPrint('Navigate to post: $id');
            // NavigationService.navigateToPost(id);
            break;
          case 'follow':
            // Navigate to user profile
            debugPrint('Navigate to user profile: $id');
            // NavigationService.navigateToProfile(id);
            break;
          case 'achievement':
            // Navigate to achievements
            debugPrint('Navigate to achievements');
            // NavigationService.navigateToAchievements();
            break;
        }
      }
    } catch (e) {
      debugPrint('Error handling notification tap: $e');
    }
  }

  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String? imageUrl,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    try {
      final AndroidNotificationDetails
      androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'showoff_notifications',
        'ShowOff.life Notifications',
        channelDescription: 'Notifications for likes, comments, and follows',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/launcher_icon',
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/launcher_icon'),
        color: const Color(0xFF9C27B0),
        styleInformation: imageUrl != null
            ? BigPictureStyleInformation(
                FilePathAndroidBitmap(imageUrl),
                contentTitle: title,
                summaryText: body,
                largeIcon: const DrawableResourceAndroidBitmap(
                  '@mipmap/launcher_icon',
                ),
              )
            : null,
      );

      const DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      await _flutterLocalNotificationsPlugin.show(
        DateTime.now().millisecondsSinceEpoch.remainder(100000),
        title,
        body,
        platformChannelSpecifics,
        payload: payload,
      );

      debugPrint('✅ Push notification sent: $title');
    } catch (e) {
      debugPrint('❌ Error showing notification: $e');
    }
  }

  // Specific notification methods for different types
  Future<void> showLikeNotification({
    required String username,
    required String postId,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '❤️ New Like',
      body: '$username liked your Show',
      payload: 'like:$postId',
      imageUrl: imageUrl,
    );
  }

  Future<void> showCommentNotification({
    required String username,
    required String comment,
    required String postId,
    String? imageUrl,
  }) async {
    final truncatedComment = comment.length > 50
        ? '${comment.substring(0, 50)}...'
        : comment;

    await showNotification(
      title: '💬 New Comment',
      body: '$username: "$truncatedComment"',
      payload: 'comment:$postId',
      imageUrl: imageUrl,
    );
  }

  Future<void> showFollowNotification({
    required String username,
    required String userId,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '👤 New Follower',
      body: '$username started following you',
      payload: 'follow:$userId',
      imageUrl: imageUrl,
    );
  }

  Future<void> showAchievementNotification({
    required String title,
    required String description,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '🏆 Achievement Unlocked!',
      body: '$title: $description',
      payload: 'achievement:unlocked',
      imageUrl: imageUrl,
    );
  }

  Future<void> showGiftNotification({
    required String username,
    required int amount,
    required String giftType,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '🎁 Gift Received',
      body: '$username sent you $amount $giftType',
      payload: 'gift:received',
      imageUrl: imageUrl,
    );
  }

  Future<void> showVoteNotification({
    required String username,
    required String entryId,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '🗳️ New Vote',
      body: '$username voted for your SYT entry',
      payload: 'vote:$entryId',
      imageUrl: imageUrl,
    );
  }

  Future<void> showSystemNotification({
    required String title,
    required String message,
    String? imageUrl,
  }) async {
    await showNotification(
      title: '📢 $title',
      body: message,
      payload: 'system:info',
      imageUrl: imageUrl,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await _flutterLocalNotificationsPlugin.cancel(id);
  }

  // Get pending notifications
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}
