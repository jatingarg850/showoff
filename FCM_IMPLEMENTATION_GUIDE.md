# Firebase Cloud Messaging - Complete Implementation Guide

## 🎯 Goal
Enable background and closed-app notifications for ShowOff using Firebase Cloud Messaging.

---

## 📋 Step-by-Step Implementation

### Step 1: Firebase Project Setup (5 minutes)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create/Select Project**:
   - Click "Add project" or select existing
   - Name: "ShowOff" (or your choice)
   - Disable Google Analytics (optional)
   - Click "Create project"

3. **Add Android App**:
   - Click Android icon
   - Package name: `com.example.apps` (from your build.gradle.kts)
   - App nickname: "ShowOff Android"
   - Click "Register app"

4. **Download google-services.json**:
   - Download the file
   - Place it in: `apps/android/app/google-services.json`

5. **Enable Cloud Messaging**:
   - Go to Project Settings → Cloud Messaging
   - Note: Cloud Messaging API is enabled by default

---

### Step 2: Update Android Configuration (5 minutes)

#### 2.1 Update `apps/android/build.gradle`
```gradle
buildscript {
    ext.kotlin_version = '1.9.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
        // Add this line:
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

#### 2.2 Update `apps/android/app/build.gradle.kts`
Add at the **bottom** of the file:
```kotlin
// At the very bottom, after all other code:
apply(plugin = "com.google.gms.google-services")
```

#### 2.3 Update `apps/android/app/src/main/AndroidManifest.xml`
Add inside `<application>` tag:
```xml
<application>
    <!-- Existing code... -->
    
    <!-- FCM Service -->
    <service
        android:name="com.google.firebase.messaging.FirebaseMessagingService"
        android:exported="false">
        <intent-filter>
            <action android:name="com.google.firebase.MESSAGING_EVENT" />
        </intent-filter>
    </service>
    
    <!-- FCM default notification channel -->
    <meta-data
        android:name="com.google.firebase.messaging.default_notification_channel_id"
        android:value="showoff_notifications" />
</application>
```

---

### Step 3: Add Flutter Dependencies (2 minutes)

```bash
cd apps
flutter pub add firebase_core firebase_messaging
flutter pub get
```

---

### Step 4: Create FCM Service (10 minutes)

Create `apps/lib/services/fcm_service.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'push_notification_service.dart';
import 'api_service.dart';
import 'storage_service.dart';

// Background message handler (MUST be top-level function)
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
      print('✅ Firebase initialized');
      
      // Register background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
      
      // Request permission
      NotificationSettings settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
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
        
        // Check if app was opened from a terminated state
        RemoteMessage? initialMessage = await _messaging.getInitialMessage();
        if (initialMessage != null) {
          _handleNotificationTap(initialMessage);
        }
        
      } else {
        print('❌ FCM permission denied');
      }
    } catch (e) {
      print('❌ Error initializing FCM: $e');
    }
  }
  
  Future<void> _sendTokenToServer(String token) async {
    try {
      final authToken = await StorageService.getToken();
      if (authToken == null) {
        print('⚠️ No auth token, skipping FCM token upload');
        return;
      }
      
      await ApiService.post('/users/fcm-token', {'fcmToken': token});
      print('✅ FCM token sent to server');
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
    
    // Example navigation:
    // if (type == 'post') {
    //   Navigator.pushNamed(context, '/post', arguments: id);
    // }
  }
}
```

---

### Step 5: Initialize FCM in main.dart (2 minutes)

Update `apps/lib/main.dart`:

```dart
import 'services/fcm_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase Cloud Messaging
  await FCMService.instance.initialize();

  // Initialize AdMob
  await AdMobService.initialize();

  runApp(
    MultiProvider(
      providers: [
        // ... existing providers
      ],
      child: const MyApp(),
    ),
  );
}
```

---

### Step 6: Server-Side Implementation (15 minutes)

#### 6.1 Install Firebase Admin SDK

```bash
cd server
npm install firebase-admin
```

#### 6.2 Get Firebase Service Account Key

1. Go to Firebase Console → Project Settings → Service Accounts
2. Click "Generate new private key"
3. Save as `server/firebase-service-account.json`
4. **Add to .gitignore**: `firebase-service-account.json`

#### 6.3 Create FCM Service

Create `server/utils/fcmService.js`:

```javascript
const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
try {
  const serviceAccount = require(path.join(__dirname, '../firebase-service-account.json'));
  
  admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
  });
  
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.error('❌ Firebase Admin initialization failed:', error.message);
}

/**
 * Send FCM notification to a user
 */
exports.sendFCMNotification = async (userId, notification) => {
  try {
    const User = require('../models/User');
    const user = await User.findById(userId).select('fcmToken');
    
    if (!user || !user.fcmToken) {
      console.log(`⚠️ No FCM token for user: ${userId}`);
      return false;
    }
    
    const message = {
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type || 'general',
        notificationId: notification._id?.toString() || '',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      token: user.fcmToken,
      android: {
        priority: 'high',
        notification: {
          channelId: 'showoff_notifications',
          sound: 'default',
          priority: 'high',
        },
      },
    };
    
    const response = await admin.messaging().send(message);
    console.log(`✅ FCM notification sent to user ${userId}:`, response);
    return true;
  } catch (error) {
    console.error(`❌ FCM error for user ${userId}:`, error.message);
    return false;
  }
};

/**
 * Send FCM notification to multiple users
 */
exports.sendBulkFCMNotifications = async (userIds, notification) => {
  try {
    const User = require('../models/User');
    const users = await User.find({
      _id: { $in: userIds },
      fcmToken: { $exists: true, $ne: null },
    }).select('fcmToken');
    
    if (users.length === 0) {
      console.log('⚠️ No users with FCM tokens found');
      return 0;
    }
    
    const tokens = users.map(u => u.fcmToken);
    
    const message = {
      notification: {
        title: notification.title,
        body: notification.message,
      },
      data: {
        type: notification.type || 'general',
        click_action: 'FLUTTER_NOTIFICATION_CLICK',
      },
      android: {
        priority: 'high',
        notification: {
          channelId: 'showoff_notifications',
          sound: 'default',
        },
      },
    };
    
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      ...message,
    });
    
    console.log(`✅ FCM bulk send: ${response.successCount}/${tokens.length} successful`);
    return response.successCount;
  } catch (error) {
    console.error('❌ FCM bulk send error:', error.message);
    return 0;
  }
};
```

#### 6.4 Update User Model

Add to `server/models/User.js`:

```javascript
fcmToken: {
  type: String,
  default: null,
},
```

#### 6.5 Add FCM Token Endpoint

Add to `server/routes/userRoutes.js`:

```javascript
router.post('/fcm-token', protect, updateFCMToken);
```

Add to `server/controllers/userController.js`:

```javascript
exports.updateFCMToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;
    
    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        message: 'FCM token is required',
      });
    }
    
    await User.findByIdAndUpdate(req.user.id, {
      fcmToken,
    });
    
    console.log(`✅ FCM token updated for user ${req.user.username}`);
    
    res.json({
      success: true,
      message: 'FCM token updated successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
```

#### 6.6 Update Notification Controller

Update `server/controllers/notificationController.js`:

```javascript
const { sendWebSocketNotification } = require('../utils/pushNotifications');
const { sendFCMNotification } = require('../utils/fcmService');

// In sendCustomNotification, after creating notifications:
createdNotifications.forEach(async (notification) => {
  // Try WebSocket first (for foreground users)
  sendWebSocketNotification(notification.recipient || notification.user, notification);
  
  // Also send via FCM (for background/closed app)
  await sendFCMNotification(notification.recipient || notification.user, notification);
});
```

---

### Step 7: Test Everything (10 minutes)

#### 7.1 Rebuild Flutter App
```bash
cd apps
flutter clean
flutter pub get
flutter run
```

#### 7.2 Check FCM Token
Look for in Flutter console:
```
✅ Firebase initialized
✅ FCM permission granted
📱 FCM Token: [long token string]
✅ FCM token sent to server
```

#### 7.3 Test Foreground
1. Keep app open
2. Send notification from admin panel
3. Should see notification

#### 7.4 Test Background
1. Press HOME button
2. Send notification
3. **Should see push notification!** 🎉

#### 7.5 Test Closed App
1. Close app completely
2. Send notification
3. **Should see push notification!** 🎉

---

## 🐛 Troubleshooting

### Issue: No FCM token
**Check:**
- Firebase initialized?
- Permission granted?
- google-services.json in correct location?

### Issue: Token not sent to server
**Check:**
- User logged in?
- API endpoint exists?
- Network connection?

### Issue: No background notifications
**Check:**
- Firebase service account key correct?
- FCM token saved in database?
- Server sending FCM notifications?

### Issue: Build errors
```bash
cd apps/android
./gradlew clean
cd ../..
flutter clean
flutter pub get
flutter run
```

---

## ✅ Verification Checklist

- [ ] Firebase project created
- [ ] google-services.json added
- [ ] build.gradle updated
- [ ] Flutter dependencies added
- [ ] FCM service created
- [ ] main.dart updated
- [ ] Firebase Admin SDK installed
- [ ] Service account key added
- [ ] FCM service created (server)
- [ ] User model updated
- [ ] FCM token endpoint added
- [ ] Notification controller updated
- [ ] App rebuilt and tested
- [ ] Foreground notifications work
- [ ] Background notifications work
- [ ] Closed app notifications work

---

## 🎉 Success!

Once complete, you'll have:
- ✅ Foreground notifications
- ✅ Background notifications
- ✅ Closed app notifications
- ✅ Lock screen notifications
- ✅ Reliable delivery
- ✅ Battery efficient

---

**Estimated Time:** 30-45 minutes  
**Difficulty:** Medium  
**Result:** Production-ready push notifications
