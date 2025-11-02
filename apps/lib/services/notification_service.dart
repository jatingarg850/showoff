import 'websocket_service.dart';
import 'storage_service.dart';
import 'push_notification_service.dart';

class NotificationService {
  static NotificationService?
  _instance;
  static NotificationService
  get instance => _instance ??= NotificationService._();

  NotificationService._();

  bool
  _isInitialized = false;
  int
  _unreadCount = 0;

  // Callbacks for UI updates
  Function(
    int,
  )?
  onUnreadCountChanged;
  Function(
    Map<
      String,
      dynamic
    >,
  )?
  onNewNotification;

  int
  get unreadCount => _unreadCount;

  Future<
    void
  >
  initialize() async {
    if (_isInitialized) return;

    try {
      // Check if user is logged in
      final token = await StorageService.getToken();
      if (token ==
              null ||
          token.isEmpty) {
        // Don't print error for this - it's normal when user isn't logged in
        return;
      }

      // Initialize push notifications
      await PushNotificationService.instance.initialize();

      // Set up listeners first
      _setupWebSocketListeners();

      // Connect to WebSocket
      await WebSocketService.instance.connect();

      _isInitialized = true;
      print(
        '✅ Notification service initialized',
      );
    } catch (
      e
    ) {
      print(
        '❌ Error initializing notification service: $e',
      );
    }
  }

  void
  _setupWebSocketListeners() {
    final wsService = WebSocketService.instance;

    // Listen for new notifications
    wsService.setOnNewNotification(
      (
        data,
      ) {
        print(
          '📱 New notification in service: $data',
        );

        // Update unread count
        if (data['unreadCount'] !=
            null) {
          _unreadCount = data['unreadCount'];
          onUnreadCountChanged?.call(
            _unreadCount,
          );
        }

        // Notify UI about new notification
        if (data['notification'] !=
            null) {
          onNewNotification?.call(
            data['notification'],
          );
          _showLocalNotification(
            data['notification'],
          );
        }
      },
    );

    // Listen for unread count updates
    wsService.setOnUnreadCountUpdate(
      (
        count,
      ) {
        _unreadCount = count;
        onUnreadCountChanged?.call(
          _unreadCount,
        );
      },
    );

    // Listen for system notifications
    wsService.setOnSystemNotification(
      (
        data,
      ) {
        print(
          '🔔 System notification: $data',
        );
        _showLocalNotification(
          data,
        );
      },
    );
  }

  void
  _showLocalNotification(
    Map<
      String,
      dynamic
    >
    notification,
  ) {
    final sender =
        notification['sender']
            as Map<
              String,
              dynamic
            >?;
    final senderName =
        sender?['displayName'] ??
        sender?['username'] ??
        'ShowOff.life';
    final message =
        notification['message'] ??
        notification['title'] ??
        'New notification';
    final type =
        notification['type']
            as String? ??
        'system';
    final data =
        notification['data']
            as Map<
              String,
              dynamic
            >? ??
        {};

    print(
      '🔔 Showing push notification: $senderName - $message',
    );

    // Show actual push notification based on type
    switch (type) {
      case 'like':
        PushNotificationService.instance.showLikeNotification(
          username: senderName,
          postId:
              data['postId'] ??
              '',
        );
        break;
      case 'comment':
        PushNotificationService.instance.showCommentNotification(
          username: senderName,
          comment: message,
          postId:
              data['postId'] ??
              '',
        );
        break;
      case 'follow':
        PushNotificationService.instance.showFollowNotification(
          username: senderName,
          userId:
              sender?['_id'] ??
              '',
        );
        break;
      case 'achievement':
        PushNotificationService.instance.showAchievementNotification(
          title:
              notification['title'] ??
              'Achievement Unlocked',
          description: message,
        );
        break;
      case 'gift':
        final amount =
            data['amount'] ??
            0;
        final giftType =
            data['metadata']?['giftType'] ??
            'coins';
        PushNotificationService.instance.showGiftNotification(
          username: senderName,
          amount: amount,
          giftType: giftType,
        );
        break;
      case 'vote':
        PushNotificationService.instance.showVoteNotification(
          username: senderName,
          entryId:
              data['sytEntryId'] ??
              '',
        );
        break;
      case 'system':
        PushNotificationService.instance.showSystemNotification(
          title:
              notification['title'] ??
              'ShowOff.life',
          message: message,
        );
        break;
      default:
        // Generic notification
        PushNotificationService.instance.showNotification(
          title:
              notification['title'] ??
              'ShowOff.life',
          body: message,
          payload: '$type:${data['postId'] ?? data['userId'] ?? 'general'}',
        );
        break;
    }
  }

  void
  disconnect() {
    WebSocketService.instance.disconnect();
    _isInitialized = false;
    _unreadCount = 0;
    print(
      '🔌 Notification service disconnected',
    );
  }

  void
  reconnect() async {
    if (!_isInitialized) {
      await initialize();
    } else {
      await WebSocketService.instance.connect();
    }
  }

  // Set callbacks for UI updates
  void
  setOnUnreadCountChanged(
    Function(
      int,
    )
    callback,
  ) {
    onUnreadCountChanged = callback;
  }

  void
  setOnNewNotification(
    Function(
      Map<
        String,
        dynamic
      >,
    )
    callback,
  ) {
    onNewNotification = callback;
  }

  // Clear callbacks
  void
  clearCallbacks() {
    onUnreadCountChanged = null;
    onNewNotification = null;
  }

  // Update user status
  void
  updateUserStatus(
    String status,
  ) {
    WebSocketService.instance.updateStatus(
      status,
    );
  }

  // Send typing indicator
  void
  sendTypingIndicator(
    String recipientId,
    bool isTyping,
  ) {
    WebSocketService.instance.sendTypingIndicator(
      recipientId,
      isTyping,
    );
  }

  // Mark notification as read
  void
  markNotificationAsRead(
    String notificationId,
  ) {
    WebSocketService.instance.markNotificationAsRead(
      notificationId,
    );
  }

  // Request unread count
  void
  requestUnreadCount() {
    WebSocketService.instance.requestUnreadCount();
  }
}
