import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'storage_service.dart';

class WebSocketService {
  static WebSocketService?
  _instance;
  static WebSocketService
  get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  IO.Socket?
  _socket;
  bool
  _isConnected = false;

  // Notification callbacks
  Function(
    Map<
      String,
      dynamic
    >,
  )?
  onNewNotification;
  Function(
    int,
  )?
  onUnreadCountUpdate;
  Function(
    String,
    String,
  )?
  onUserStatusUpdate;
  Function(
    String,
    bool,
  )?
  onUserTyping;
  Function(
    Map<
      String,
      dynamic
    >,
  )?
  onSystemNotification;

  bool
  get isConnected => _isConnected;

  Future<
    void
  >
  connect() async {
    try {
      final token = await StorageService.getToken();
      if (token ==
          null) {
        print(
          '❌ No auth token available for WebSocket connection',
        );
        return;
      }

      // Disconnect existing connection
      disconnect();

      // Use the same base URL as API but without /api suffix
      const serverUrl = 'http://10.0.2.2:3000'; // Android Emulator
      // const serverUrl = 'http://localhost:3000'; // iOS Simulator
      // const serverUrl = 'http://192.168.1.100:3000'; // Real Device

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(
              [
                'websocket',
              ],
            )
            .enableAutoConnect()
            .setAuth(
              {
                'token': token,
              },
            )
            .build(),
      );

      _socket!.onConnect(
        (
          _,
        ) {
          _isConnected = true;
          print(
            '✅ WebSocket connected',
          );

          // Request initial unread count
          _socket!.emit(
            'getUnreadCount',
          );
        },
      );

      _socket!.onDisconnect(
        (
          _,
        ) {
          _isConnected = false;
          print(
            '❌ WebSocket disconnected',
          );
        },
      );

      _socket!.onConnectError(
        (
          error,
        ) {
          _isConnected = false;
          print(
            '❌ WebSocket connection error: $error',
          );
        },
      );

      // Listen for new notifications
      _socket!.on(
        'newNotification',
        (
          data,
        ) {
          print(
            '📱 New notification received: $data',
          );
          if (onNewNotification !=
              null) {
            onNewNotification!(
              Map<
                String,
                dynamic
              >.from(
                data,
              ),
            );
          }
        },
      );

      // Listen for unread count updates
      _socket!.on(
        'unreadCountUpdate',
        (
          data,
        ) {
          print(
            '🔢 Unread count update: $data',
          );
          if (onUnreadCountUpdate !=
                  null &&
              data['unreadCount'] !=
                  null) {
            onUnreadCountUpdate!(
              data['unreadCount'],
            );
          }
        },
      );

      // Listen for user status updates
      _socket!.on(
        'userStatusUpdate',
        (
          data,
        ) {
          if (onUserStatusUpdate !=
              null) {
            onUserStatusUpdate!(
              data['userId'],
              data['status'],
            );
          }
        },
      );

      // Listen for typing indicators
      _socket!.on(
        'userTyping',
        (
          data,
        ) {
          if (onUserTyping !=
              null) {
            onUserTyping!(
              data['userId'],
              data['isTyping'],
            );
          }
        },
      );

      // Listen for system notifications
      _socket!.on(
        'systemNotification',
        (
          data,
        ) {
          print(
            '🔔 System notification: $data',
          );
          if (onSystemNotification !=
              null) {
            onSystemNotification!(
              Map<
                String,
                dynamic
              >.from(
                data,
              ),
            );
          }
        },
      );

      _socket!.connect();
    } catch (
      e
    ) {
      print(
        '❌ Error connecting to WebSocket: $e',
      );
    }
  }

  void
  disconnect() {
    if (_socket !=
        null) {
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
      _isConnected = false;
      print(
        '🔌 WebSocket disconnected',
      );
    }
  }

  // Send notification read acknowledgment
  void
  markNotificationAsRead(
    String notificationId,
  ) {
    if (_isConnected &&
        _socket !=
            null) {
      _socket!.emit(
        'notificationRead',
        notificationId,
      );
    }
  }

  // Update user status
  void
  updateStatus(
    String status,
  ) {
    if (_isConnected &&
        _socket !=
            null) {
      _socket!.emit(
        'updateStatus',
        status,
      );
    }
  }

  // Send typing indicator
  void
  sendTypingIndicator(
    String recipientId,
    bool isTyping,
  ) {
    if (_isConnected &&
        _socket !=
            null) {
      _socket!.emit(
        'typing',
        {
          'recipientId': recipientId,
          'isTyping': isTyping,
        },
      );
    }
  }

  // Request unread count
  void
  requestUnreadCount() {
    if (_isConnected &&
        _socket !=
            null) {
      _socket!.emit(
        'getUnreadCount',
      );
    }
  }

  // Set notification callback
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

  // Set unread count callback
  void
  setOnUnreadCountUpdate(
    Function(
      int,
    )
    callback,
  ) {
    onUnreadCountUpdate = callback;
  }

  // Set user status callback
  void
  setOnUserStatusUpdate(
    Function(
      String,
      String,
    )
    callback,
  ) {
    onUserStatusUpdate = callback;
  }

  // Set typing callback
  void
  setOnUserTyping(
    Function(
      String,
      bool,
    )
    callback,
  ) {
    onUserTyping = callback;
  }

  // Set system notification callback
  void
  setOnSystemNotification(
    Function(
      Map<
        String,
        dynamic
      >,
    )
    callback,
  ) {
    onSystemNotification = callback;
  }

  // Clear all callbacks
  void
  clearCallbacks() {
    onNewNotification = null;
    onUnreadCountUpdate = null;
    onUserStatusUpdate = null;
    onUserTyping = null;
    onSystemNotification = null;
  }
}
