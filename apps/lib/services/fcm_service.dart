import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:http/http.dart' as http;
import '../firebase_options.dart';
import 'push_notification_service.dart';
import 'api_service.dart';
import 'storage_service.dart';

// Background message handler (MUST be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } on FirebaseException catch (e) {
    if (e.code != 'duplicate-app') rethrow;
  }
  print('📱 Background notification: ${message.notification?.title}');
}

class FCMService {
  static FCMService? _instance;
  static FCMService get instance => _instance ??= FCMService._();

  FCMService._();

  FirebaseMessaging? _messaging;
  String? _fcmToken;
  bool _isInitialized = false;

  String? get fcmToken => _fcmToken;

  Future<void> initialize() async {
    if (_isInitialized) {
      print('⚠️ FCM already initialized');
      return;
    }

    try {
      // Initialize Firebase first with platform-specific options (if not already initialized)
      try {
        if (Firebase.apps.isEmpty) {
          await Firebase.initializeApp(
            options: DefaultFirebaseOptions.currentPlatform,
          );
          print('✅ Firebase initialized');
        } else {
          print('✅ Firebase already initialized');
        }
      } on FirebaseException catch (e) {
        if (e.code == 'duplicate-app') {
          print('✅ Firebase already initialized (caught duplicate)');
        } else {
          rethrow;
        }
      }

      // Now initialize messaging after Firebase is ready
      _messaging = FirebaseMessaging.instance;

      // Register background handler
      FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler,
      );

      // Request permission
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM permission granted');

        // Get FCM token
        _fcmToken = await _messaging!.getToken();
        if (_fcmToken != null) {
          print('📱 FCM Token: ${_fcmToken!.substring(0, 20)}...');

          // Send token to server
          await _sendTokenToServer(_fcmToken!);
        }

        // Listen for token refresh
        _messaging!.onTokenRefresh.listen(_sendTokenToServer);

        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

        // Handle notification tap (app opened from notification)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

        // Check if app was opened from a terminated state
        RemoteMessage? initialMessage = await _messaging!.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
      } else {
        print('❌ FCM permission denied');
      }

      _isInitialized = true;
    } catch (e) {
      print('❌ Error initializing FCM: $e');
      _isInitialized = false;
    }
  }

  Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await StorageService.getToken();
      if (authToken == null) {
        print('⚠️ No auth token, will send FCM token after login');
        return;
      }

      // Send FCM token to server
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/users/fcm-token'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
        body: jsonEncode({'fcmToken': token}),
      );

      if (response.statusCode == 200) {
        print('✅ FCM token sent to server');
      } else {
        print('⚠️ Failed to send FCM token: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error sending FCM token: $e');
    }
  }

  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Foreground FCM notification: ${message.notification?.title}');

    // Show local notification even in foreground
    if (message.notification != null) {
      PushNotificationService.instance.showNotification(
        title: message.notification!.title ?? 'ShowOff.life',
        body: message.notification!.body ?? '',
        payload: message.data['type'] ?? 'general',
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    print('🔔 Notification tapped: ${message.data}');

    // TODO: Navigate based on notification type
    final type = message.data['type'];
    final id = message.data['id'];

    print('   Type: $type, ID: $id');
    // Example navigation:
    // if (type == 'post') {
    //   Navigator.pushNamed(context, '/post', arguments: id);
    // }
  }

  // Call this after user logs in
  Future<void> updateTokenAfterLogin() async {
    if (_fcmToken != null) {
      await _sendTokenToServer(_fcmToken!);
    }
  }
}
