const admin = require('firebase-admin');
const path = require('path');
const fs = require('fs');

// Initialize Firebase Admin
let isInitialized = false;
let initializationError = null;

function initializeFirebase() {
  if (isInitialized) return true;
  if (initializationError) return false; // Already tried and failed

  try {
    const serviceAccountPath = path.join(__dirname, '../firebase-service-account.json');
    
    // Check if file exists
    if (!fs.existsSync(serviceAccountPath)) {
      initializationError = 'firebase-service-account.json not found';
      console.error('❌ Firebase initialization failed: firebase-service-account.json not found');
      console.error('   Location: ' + serviceAccountPath);
      console.error('   Please download from Firebase Console and place in server folder');
      return false;
    }

    const serviceAccount = require(serviceAccountPath);

    // Validate service account structure
    if (!serviceAccount.project_id || !serviceAccount.private_key || !serviceAccount.client_email) {
      initializationError = 'Invalid service account JSON structure';
      console.error('❌ Firebase initialization failed: Invalid service account JSON');
      console.error('   Missing required fields: project_id, private_key, or client_email');
      return false;
    }

    admin.initializeApp({
      credential: admin.credential.cert(serviceAccount),
    });

    isInitialized = true;
    console.log('✅ Firebase Admin initialized successfully');
    console.log('   Project: ' + serviceAccount.project_id);
    return true;
  } catch (error) {
    initializationError = error.message;
    console.error('❌ Firebase Admin initialization failed:', error.message);
    
    // Provide helpful error messages
    if (error.message.includes('Invalid JWT')) {
      console.error('   Cause: Invalid JWT Signature - credentials may be revoked or corrupted');
      console.error('   Fix: Generate new service account key from Firebase Console');
    } else if (error.message.includes('ENOENT')) {
      console.error('   Cause: File not found');
      console.error('   Fix: Download firebase-service-account.json from Firebase Console');
    } else if (error.message.includes('JSON')) {
      console.error('   Cause: Invalid JSON format');
      console.error('   Fix: Ensure the file is valid JSON');
    }
    
    return false;
  }
}

/**
 * Send FCM notification to a user
 * Works for all login methods: phone, email, Gmail
 */
exports.sendFCMNotification = async (userId, notification) => {
  // If Firebase not initialized, log warning but don't crash
  if (!initializeFirebase()) {
    console.warn(`⚠️  FCM disabled: ${initializationError}`);
    console.warn('   Notifications will not be sent, but app will continue working');
    return false;
  }

  try {
    const User = require('../models/User');
    const user = await User.findById(userId).select('fcmToken');

    if (!user) {
      console.log(`⚠️  User not found: ${userId}`);
      return false;
    }

    if (!user.fcmToken) {
      console.log(`⚠️  No FCM token for user: ${userId} (user may not have opened app yet)`);
      return false;
    }

    const message = {
      notification: {
        title: notification.title || 'ShowOff',
        body: notification.message || notification.body || 'New notification',
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
    console.log(`✅ FCM sent to user ${userId} (login method: ${user.loginMethod || 'unknown'})`);
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
    
    // Don't crash the app - just log the error
    return false;
  }
};

/**
 * Send FCM notification to multiple users
 * Works for all login methods: phone, email, Gmail
 */
exports.sendBulkFCMNotifications = async (userIds, notification) => {
  // If Firebase not initialized, log warning but don't crash
  if (!initializeFirebase()) {
    console.warn(`⚠️  FCM disabled: ${initializationError}`);
    return 0;
  }

  try {
    const User = require('../models/User');
    const users = await User.find({
      _id: { $in: userIds },
      fcmToken: { $exists: true, $ne: null },
    }).select('fcmToken loginMethod');

    if (users.length === 0) {
      console.log('⚠️  No users with FCM tokens found');
      return 0;
    }

    const tokens = users.map(u => u.fcmToken);

    const message = {
      notification: {
        title: notification.title || 'ShowOff',
        body: notification.message || notification.body || 'New notification',
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
    console.log(`   Users: ${users.map(u => u.loginMethod || 'unknown').join(', ')}`);

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
    // Don't crash - just return 0
    return 0;
  }
};
