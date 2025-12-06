import 'package:flutter/foundation.dart';
import '../services/notification_service.dart';
import '../services/api_service.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = false;

  int get unreadCount => _unreadCount;
  List<Map<String, dynamic>> get notifications => _notifications;
  bool get isLoading => _isLoading;

  NotificationProvider() {
    // Don't initialize in constructor - it causes crashes
    // Initialize will be called manually after app is ready
  }

  Future<void> initialize() async {
    try {
      // Initialize the notification service
      await NotificationService.instance.initialize();

      // Listen for unread count changes
      NotificationService.instance.setOnUnreadCountChanged((count) {
        _unreadCount = count;
        notifyListeners();
      });

      // Listen for new notifications
      NotificationService.instance.setOnNewNotification((notification) {
        _notifications.insert(0, notification);
        notifyListeners();
      });

      // Load initial notifications
      await loadNotifications();
    } catch (e) {
      print('Error initializing notification service: $e');
    }
  }

  Future<void> loadNotifications() async {
    try {
      _isLoading = true;
      notifyListeners();

      final response = await ApiService.getNotifications(page: 1, limit: 50);

      if (response['success']) {
        _notifications = List<Map<String, dynamic>>.from(
          response['data'] ?? [],
        );
        _unreadCount = response['unreadCount'] ?? 0;
      }
    } catch (e) {
      print('Error loading notifications: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      final response = await ApiService.markNotificationAsRead(notificationId);
      if (response['success']) {
        // Update local state
        final index = _notifications.indexWhere(
          (n) => n['_id'] == notificationId,
        );
        if (index != -1 && !_notifications[index]['isRead']) {
          _notifications[index]['isRead'] = true;
          if (_unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }

        // Notify WebSocket
        NotificationService.instance.markNotificationAsRead(notificationId);
      }
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final response = await ApiService.markAllNotificationsAsRead();
      if (response['success']) {
        // Update local state
        for (var notification in _notifications) {
          notification['isRead'] = true;
        }
        _unreadCount = 0;
        notifyListeners();
      }
    } catch (e) {
      print('Error marking all notifications as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      final response = await ApiService.deleteNotification(notificationId);
      if (response['success']) {
        // Update local state
        final index = _notifications.indexWhere(
          (n) => n['_id'] == notificationId,
        );
        if (index != -1) {
          final wasUnread = !_notifications[index]['isRead'];
          _notifications.removeAt(index);
          if (wasUnread && _unreadCount > 0) {
            _unreadCount--;
          }
          notifyListeners();
        }
      }
    } catch (e) {
      print('Error deleting notification: $e');
    }
  }

  void updateUserStatus(String status) {
    NotificationService.instance.updateUserStatus(status);
  }

  void sendTypingIndicator(String recipientId, bool isTyping) {
    NotificationService.instance.sendTypingIndicator(recipientId, isTyping);
  }

  @override
  void dispose() {
    NotificationService.instance.clearCallbacks();
    super.dispose();
  }
}
