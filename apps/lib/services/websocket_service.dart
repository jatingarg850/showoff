import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'storage_service.dart';
import '../config/api_config.dart';

class WebSocketService {
  static WebSocketService? _instance;
  static WebSocketService get instance => _instance ??= WebSocketService._();

  WebSocketService._();

  IO.Socket? _socket;
  bool _isConnected = false;
  bool _isConnecting = false;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;
  Timer? _reconnectTimer;

  // Notification callbacks
  Function(Map<String, dynamic>)? onNewNotification;
  Function(int)? onUnreadCountUpdate;
  Function(String, String)? onUserStatusUpdate;
  Function(String, bool)? onUserTyping;
  Function(Map<String, dynamic>)? onSystemNotification;

  bool get isConnected => _isConnected;

  Future<void> connect() async {
    // Prevent multiple simultaneous connection attempts
    if (_isConnecting || _isConnected) {
      return;
    }

    try {
      _isConnecting = true;

      final token = await StorageService.getToken();
      if (token == null || token.isEmpty) {
        print('⚠️ No auth token available for WebSocket connection');
        _isConnecting = false;
        return;
      }

      // Only disconnect if socket exists and is connected
      if (_socket != null && _isConnected) {
        _cleanupSocket();
      }

      // Use the centralized WebSocket URL from ApiConfig
      final serverUrl = ApiConfig.wsUrl;

      _socket = IO.io(
        serverUrl,
        IO.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect() // Disable auto-reconnect to control it manually
            .setReconnectionDelay(
              2000,
            ) // 2 seconds between reconnection attempts
            .setReconnectionDelayMax(10000) // Max 10 seconds
            .setReconnectionAttempts(_maxReconnectAttempts)
            .setAuth({'token': token})
            .build(),
      );

      _setupSocketListeners();
      _socket!.connect();
    } catch (e) {
      print('❌ Error connecting to WebSocket: $e');
      _isConnecting = false;
      _cleanupSocket();
    }
  }

  void _setupSocketListeners() {
    if (_socket == null) return;

    _socket!.onConnect((_) {
      _isConnected = true;
      _isConnecting = false;
      _reconnectAttempts = 0;
      _reconnectTimer?.cancel();
      print('✅ WebSocket connected');

      // Request initial unread count
      _socket!.emit('getUnreadCount');
    });

    _socket!.onDisconnect((reason) {
      _isConnected = false;
      _isConnecting = false;
      print('❌ WebSocket disconnected: $reason');

      // Only attempt reconnection if it wasn't a manual disconnect
      if (reason != 'io client disconnect' &&
          _reconnectAttempts < _maxReconnectAttempts) {
        _attemptReconnect();
      }
    });

    _socket!.onConnectError((error) {
      _isConnected = false;
      _isConnecting = false;
      print('❌ WebSocket connection error: $error');

      // Attempt reconnection with backoff
      if (_reconnectAttempts < _maxReconnectAttempts) {
        _attemptReconnect();
      }
    });

    // Listen for new notifications
    _socket!.on('newNotification', (data) {
      print('📱 New notification received: $data');
      if (onNewNotification != null) {
        onNewNotification!(Map<String, dynamic>.from(data));
      }
    });

    // Listen for unread count updates
    _socket!.on('unreadCountUpdate', (data) {
      print('🔢 Unread count update: $data');
      if (onUnreadCountUpdate != null && data['unreadCount'] != null) {
        onUnreadCountUpdate!(data['unreadCount']);
      }
    });

    // Listen for user status updates
    _socket!.on('userStatusUpdate', (data) {
      if (onUserStatusUpdate != null) {
        onUserStatusUpdate!(data['userId'], data['status']);
      }
    });

    // Listen for typing indicators
    _socket!.on('userTyping', (data) {
      if (onUserTyping != null) {
        onUserTyping!(data['userId'], data['isTyping']);
      }
    });

    // Listen for system notifications
    _socket!.on('systemNotification', (data) {
      print('🔔 System notification: $data');
      if (onSystemNotification != null) {
        onSystemNotification!(Map<String, dynamic>.from(data));
      }
    });
  }

  void _attemptReconnect() {
    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Exponential backoff: 2s, 4s, 8s, 16s, 32s
    final delay = Duration(seconds: (2 * _reconnectAttempts).clamp(2, 32));

    print(
      '🔄 Attempting reconnect in ${delay.inSeconds}s (attempt $_reconnectAttempts/$_maxReconnectAttempts)',
    );

    _reconnectTimer = Timer(delay, () {
      if (!_isConnected && !_isConnecting) {
        connect();
      }
    });
  }

  void _cleanupSocket() {
    _reconnectTimer?.cancel();
    if (_socket != null) {
      _socket!.clearListeners();
      _socket!.disconnect();
      _socket!.dispose();
      _socket = null;
    }
    _isConnected = false;
    _isConnecting = false;
  }

  void disconnect() {
    _reconnectAttempts = _maxReconnectAttempts; // Prevent auto-reconnect
    _cleanupSocket();
    print('🔌 WebSocket disconnected');
  }

  // Send notification read acknowledgment
  void markNotificationAsRead(String notificationId) {
    if (_isConnected && _socket != null) {
      _socket!.emit('notificationRead', notificationId);
    }
  }

  // Update user status
  void updateStatus(String status) {
    if (_isConnected && _socket != null) {
      _socket!.emit('updateStatus', status);
    }
  }

  // Send typing indicator
  void sendTypingIndicator(String recipientId, bool isTyping) {
    if (_isConnected && _socket != null) {
      _socket!.emit('typing', {
        'recipientId': recipientId,
        'isTyping': isTyping,
      });
    }
  }

  // Request unread count
  void requestUnreadCount() {
    if (_isConnected && _socket != null) {
      _socket!.emit('getUnreadCount');
    }
  }

  // Set notification callback
  void setOnNewNotification(Function(Map<String, dynamic>) callback) {
    onNewNotification = callback;
  }

  // Set unread count callback
  void setOnUnreadCountUpdate(Function(int) callback) {
    onUnreadCountUpdate = callback;
  }

  // Set user status callback
  void setOnUserStatusUpdate(Function(String, String) callback) {
    onUserStatusUpdate = callback;
  }

  // Set typing callback
  void setOnUserTyping(Function(String, bool) callback) {
    onUserTyping = callback;
  }

  // Set system notification callback
  void setOnSystemNotification(Function(Map<String, dynamic>) callback) {
    onSystemNotification = callback;
  }

  // Clear all callbacks
  void clearCallbacks() {
    onNewNotification = null;
    onUnreadCountUpdate = null;
    onUserStatusUpdate = null;
    onUserTyping = null;
    onSystemNotification = null;
  }

  // Reset reconnection attempts (useful when app comes to foreground)
  void resetReconnection() {
    _reconnectAttempts = 0;
    if (!_isConnected && !_isConnecting) {
      connect();
    }
  }
}
