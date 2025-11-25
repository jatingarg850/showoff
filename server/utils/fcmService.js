const admin = require('firebase-admin');
const path = require('path');

// Initialize Firebase Admin
let isInitialized = false;

function initializeFirebase() {
  if (isInitialized) return true;

  try {
    const serviceAccountPath = path.join(__dirname, '../firebase-service-account.json');
    const serviceAccount = require(serviceAccountPath);

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    isInitialized = true;
    console.log('✅ Firebase Admin initialized');
    return true;
  } catch (error) {
    console.error('❌ Firebase Admin initialization failed:', error.message);
    console.error('   Make sure firebase-service-account.json exists in server folder');
    return false;
  }
}

/**
 * Send FCM notification to a user
 */
exports.sendFCMNotification = async (userId, notification) => {
  if (!initializeFirebase()) {
    return false;
  }

  try {
    const User = require('../models/User');
    const user = await User.findById(userId).select('fcmToken');

    if (!user || !user.fcmToken) {
      console.log(`⚠️  No FCM token for user: ${userId}`);
      return false;
    }

    const message = {
      notification: {
        title: notification.title,
        body: notification.message || notification.body,
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
    console.log(`✅ FCM notification sent to user ${userId}`);
    return true;
  } catch (error) {
    console.error(`❌ FCM error for user ${userId}:`, error.message);
    // If token is invalid, remove it from database
    if (error.code === 'messaging/invalid-registration-token' ||
        error.code === 'messaging/registration-token-not-registered') {
      try {
        const User = require('../models/User');
        await User.findByIdAndUpdate(userId, { fcmToken: null });
        console.log(`   Removed invalid FCM token for user ${userId}`);
      } catch (e) {
        // Ignore error
      }
    }
    return false;
  }
};

/**
 * Send FCM notification to multiple users
 */
exports.sendBulkFCMNotifications = async (userIds, notification) => {
  if (!initializeFirebase()) {
    return 0;
  }

  try {
    const User = require('../models/User');
    const users = await User.find({
      _id: { $in: userIds },
      fcmToken: { $exists: true, $ne: null },
    }).select('fcmToken');

    if (users.length === 0) {
      console.log('⚠️  No users with FCM tokens found');
      return 0;
    }

    const tokens = users.map(u => u.fcmToken);

    const message = {
      notification: {
        title: notification.title,
        body: notification.message || notification.body,
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

    // Remove invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success && 
            (resp.error?.code === 'messaging/invalid-registration-token' ||
             resp.error?.code === 'messaging/registration-token-not-registered')) {
          invalidTokens.push(tokens[idx]);
        }
      });

      if (invalidTokens.length > 0) {
        await User.updateMany(
          { fcmToken: { $in: invalidTokens } },
          { fcmToken: null }
        );
        console.log(`   Removed ${invalidTokens.length} invalid FCM tokens`);
      }
    }

    return response.successCount;
  } catch (error) {
    console.error('❌ FCM bulk send error:', error.message);
    return 0;
  }
};
