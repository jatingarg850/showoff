# Background Notifications - Complete Solution

## ✅ Current Status

### Working:
- ✅ Foreground notifications (app open)
- ✅ WebSocket real-time delivery
- ✅ In-app notification list
- ✅ Unread count updates

### Not Working:
- ❌ Background notifications (app minimized)
- ❌ Closed app notifications
- ❌ Lock screen notifications

## 🔍 Why Background Doesn't Work

When your Flutter app goes to **background**, the **WebSocket disconnects**. This is normal Android behavior to save battery.

**Solutions:**
1. **Firebase Cloud Messaging (FCM)** ← Recommended
2. Background service (battery intensive)
3. Polling (not real-time)

---

## 🚀 Solution: Firebase Cloud Messaging (FCM)

FCM is the industry standard for push notifications. It works even when:
- App is in background
- App is completely closed
- Phone is locked
- No internet (queues notifications)

### Architecture:
```
Admin Panel → Server → FCM → User's Device → Flutter App
```

---

## 📋 Implementation Steps

### Step 1: Set Up Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create new project or use existing
3. Add Android app:
   - Package name: `com.example.apps` (from your build.gradle)
   - Download `google-services.json`
4. Enable **Cloud Messaging** in Firebase Console

### Step 2: Add Firebase to Flutter

#### 2.1 Add Dependencies
```yaml
# pubspec.yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0  # Already have this
```

#### 2.2 Add google-services.json
```bash
# Place downloaded file here:
apps/android/app/google-services.json
```

#### 2.3 Update build.gradle
```gradle
// apps/android/build.gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}

// apps/android/app/build.gradle
apply plugin: 'com.google.gms.google-services'
```

### Step 3: Create FCM Service

```dart
// apps/lib/services/fcm_service.dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';
import 'api_service.dart';

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📱 Background notification: ${message.notification?.title}');
}

class FCMService {
  static FCMService? _instance;
  static FCMService get instance => _instance ??= FCMService._();
  
  FCMService._();
  
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  String? _fcmToken;
  
  String? get fcmToken => _fcmToken;
  
  Future<void> initialize() async {
    try {
      // Initialize Firebase
      await Firebase.initializeApp();
      
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      
      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ FCM permission granted');
        
        // Get FCM token
        _fcmToken = await _messaging.getToken();
        print('📱 FCM Token: $_fcmToken');
        
        // Send token to server
        if (_fcmToken != null) {
          await _sendTokenToServer(_fcmToken!);
        }
        
        // Listen for token refresh
        _messaging.onTokenRefresh.listen(_sendTokenToServer);
        
        // Handle foreground messages
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
        
        // Handle notification tap (app opened from notification)
        FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);
        
      } else {
        print('❌ FCM permission denied');
      }
    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }
  
  Future<void> _sendTokenToServer(String token) async {
    try {
      await ApiService.post('/users/fcm-token', {'fcmToken': token});
      print('✅ FCM token sent to server');
    } catch (e) {
      print('❌ Error sending FCM token: $e');
    }
  }
  
  void _handleForegroundMessage(RemoteMessage message) {
    print('📱 Foreground notification: ${message.notification?.title}');
    
    // Show local notification
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
    // Navigate to appropriate screen based on message.data
  }
}
```

### Step 4: Update User Model (Server)

```javascript
// server/models/User.js
// Add FCM token field
fcmToken: {
  type: String,
  default: null,
},
fcmTokens: [{
  token: String,
  device: String,
  updatedAt: Date,
}],
```

### Step 5: Add FCM Token Endpoint (Server)

```javascript
// server/routes/userRoutes.js
router.post('/fcm-token', protect, updateFCMToken);

// server/controllers/userController.js
exports.updateFCMToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    
    await User.findByIdAndUpdate(req.user.id, {
      fcmToken,
      $push: {
        fcmTokens: {
          token: fcmToken,
          device: 'android',
          updatedAt: new Date(),
        },
      },
    });
    
    res.json({ success: true, message: 'FCM token updated' });
  } catch (error) {
    res.status(500).json({ success: false, message: error.message });
  }
};
```

### Step 6: Send via FCM (Server)

```javascript
// server/utils/fcmNotifications.js
const admin = require('firebase-admin');

// Initialize Firebase Admin
const serviceAccount = require('../firebase-service-account.json');
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

exports.sendFCMNotification = async (userId, notification) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(userId).select('fcmToken');
    
    if (!user || !user.fcmToken) {
      console.log('No FCM token for user:', userId);
      return false;
    }
    
    const message = {
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type,
        notificationId: notification._id.toString(),
      },
      token: user.fcmToken,
    };
    
    const response = await admin.messaging().send(message);
    console.log('✅ FCM notification sent:', response);
    return true;
  } catch (error) {
    console.error('❌ FCM error:', error);
    return false;
  }
};
```

### Step 7: Update Notification Controller

```javascript
// server/controllers/notificationController.js
const { sendFCMNotification } = require('../utils/fcmNotifications');

// In sendCustomNotification, after creating notifications:
createdNotifications.forEach(async (notification) => {
  // Try WebSocket first (for foreground)
  const wsSent = sendWebSocketNotification(notification.recipient, notification);
  
  // Also send via FCM (for background/closed)
  await sendFCMNotification(notification.recipient, notification);
});
```

### Step 8: Initialize in Flutter

```dart
// apps/lib/main.dart
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize FCM
  await FCMService.instance.initialize();
  
  // Initialize AdMob
  await AdMobService.initialize();
  
  runApp(/* ... */);
}
```

---

## 🧪 Testing

### Test 1: Foreground
1. Keep app open
2. Send notification
3. Should see notification in app

### Test 2: Background
1. Press HOME button
2. Send notification
3. Should see push notification banner!

### Test 3: Closed
1. Close app completely
2. Send notification
3. Should see push notification!
4. Tap to open app

### Test 4: Lock Screen
1. Lock phone
2. Send notification
3. Should see on lock screen!

---

## 📊 Expected Results

### With FCM:
- ✅ Foreground notifications
- ✅ Background notifications
- ✅ Closed app notifications
- ✅ Lock screen notifications
- ✅ Notification queuing (offline)
- ✅ Battery efficient

---

## 🎯 Quick Start (Minimal Setup)

If you want to test quickly:

### 1. Add Firebase
```bash
cd apps
flutter pub add firebase_core firebase_messaging
```

### 2. Download google-services.json
From Firebase Console → Project Settings → Your Android App

### 3. Update build.gradle
Add Google Services plugin

### 4. Initialize in main.dart
```dart
await Firebase.initializeApp();
```

### 5. Get FCM token
```dart
String? token = await FirebaseMessaging.instance.getToken();
print('FCM Token: $token');
```

### 6. Test with FCM Console
Firebase Console → Cloud Messaging → Send test message

---

## 💡 Alternative: Simple Polling (Quick Fix)

If you don't want to set up FCM right now:

```dart
// Poll for new notifications every 30 seconds when in background
Timer.periodic(Duration(seconds: 30), (timer) async {
  if (AppLifecycleState.paused) {
    final response = await ApiService.get('/notifications/unread-count');
    if (response['unreadCount'] > 0) {
      // Show local notification
      PushNotificationService.instance.showNotification(
        title: 'New Notifications',
        body: 'You have ${response['unreadCount']} new notifications',
      );
    }
  }
});
```

**Pros:** Simple, no Firebase needed  
**Cons:** Not real-time, battery drain, delayed notifications

---

## 📝 Summary

### Current System:
- ✅ Foreground: Working perfectly
- ❌ Background: WebSocket disconnects

### Solution:
- 🚀 **FCM**: Best solution, industry standard
- ⚡ **Polling**: Quick fix, not ideal
- 🔋 **Background Service**: Battery intensive

### Recommendation:
**Implement FCM** for production-ready background notifications.

---

## 🎉 Your Choice

### Option 1: Implement FCM (Recommended)
- Takes 1-2 hours to set up
- Works perfectly in all scenarios
- Industry standard
- Battery efficient

### Option 2: Use Current System
- Works great for foreground
- Users must have app open
- Good for MVP/testing

### Option 3: Polling
- Quick 15-minute fix
- Not real-time
- Battery drain
- Good for temporary solution

---

**Current Status:** Foreground notifications ✅ WORKING  
**Next Step:** Choose FCM, Polling, or keep current system  
**Recommendation:** FCM for production app
