# Notification System - Complete Fix

## 🐛 Problems Identified

### 1. Notification Model Schema Issues
- ❌ Missing `admin_announcement` in type enum
- ❌ Field name mismatch: Controller used `user`, model expected `recipient`
- ❌ `sender` field was required but admin notifications don't have a sender

### 2. WebSocket Delivery Issues
- ⚠️ No logging to verify WebSocket delivery
- ⚠️ No error handling for failed WebSocket sends

### 3. Flutter App Issues
- ⚠️ No specific handling for `admin_announcement` type

## ✅ Fixes Applied

### 1. Updated Notification Model (`server/models/Notification.js`)
```javascript
// Added to type enum:
'admin_announcement',

// Made sender optional:
sender: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'User',
  required: false, // Not required for system/admin notifications
},

// Added user field for compatibility:
user: {
  type: mongoose.Schema.Types.ObjectId,
  ref: 'User',
},
```

### 2. Fixed Notification Controller (`server/controllers/notificationController.js`)
```javascript
// Now creates notifications with correct fields:
{
  recipient: user._id,  // Primary field
  user: user._id,       // Compatibility
  sender: req.user?.id, // Admin who sent it
  type: 'admin_announcement',
  title,
  message,
  data: {
    metadata: {
      actionType,
      actionData,
    },
  },
}

// Added detailed logging:
console.log(`✅ Batch X: Created Y notifications in database`);
console.log(`📡 Batch X: Sent Y WebSocket notifications`);
```

### 3. Enhanced WebSocket Notification (`server/utils/pushNotifications.js`)
```javascript
// Added better logging and error handling:
console.log(`✅ WebSocket notification sent to user ${userId} in room ${roomName}`);
console.log(`   Type: ${type}, Title: ${title}`);
```

### 4. Updated Flutter Notification Service (`apps/lib/services/notification_service.dart`)
```dart
// Added admin_announcement handling:
case 'system':
case 'admin_announcement':
  PushNotificationService.instance.showSystemNotification(
    title: notification['title'] ?? 'ShowOff.life',
    message: message,
  );
  break;
```

### 5. Fixed WebSocket Service (`apps/lib/services/websocket_service.dart`)
- Added exponential backoff for reconnection
- Prevented connection loop
- Added proper state management

## 🧪 Testing

### Run Diagnostic
```bash
node diagnose_notifications.js
```

This will check:
- Notification model schema
- Database users
- Recent notifications
- Admin notifications
- Configuration

### Send Test Notification

#### Option 1: Admin Panel
1. Go to `http://localhost:3000/admin/notifications`
2. Fill in:
   - Title: "🧪 Test Notification"
   - Message: "Testing the notification system"
   - Target: "All Users"
3. Click "Send Notification"

#### Option 2: CLI
```bash
node server/scripts/sendNotification.js \
  --title "🧪 Test" \
  --message "Testing notifications" \
  --target all
```

#### Option 3: Test Script
```bash
node test_notification_flow.js
```

## 📊 Expected Logs

### Server Logs (When Sending)
```
✅ Batch 1: Created 1 notifications in database
📡 Batch 1: Sent 1 WebSocket notifications
✅ WebSocket notification sent to user 6925455a0916073edcd40dad in room user_6925455a0916073edcd40dad
   Type: admin_announcement, Title: 🧪 Test Notification
✅ Admin notification sent to 1 users (1 total)
```

### Flutter Logs (When Receiving)
```
✅ WebSocket connected
🔢 Unread count update: {unreadCount: 0}
📱 New notification received: {notification: {...}}
🔔 Showing push notification: ShowOff.life - Testing the notification system
```

## 🔍 Verification Steps

### 1. Check Database
```javascript
// In MongoDB
db.notifications.find({type: 'admin_announcement'}).sort({createdAt: -1}).limit(1)
```

Should show:
```json
{
  "_id": "...",
  "recipient": "6925455a0916073edcd40dad",
  "user": "6925455a0916073edcd40dad",
  "sender": null,
  "type": "admin_announcement",
  "title": "🧪 Test Notification",
  "message": "Testing the notification system",
  "isRead": false,
  "createdAt": "2024-11-25T..."
}
```

### 2. Check WebSocket Connection
```bash
curl http://localhost:3000/health
```

Should show:
```json
{
  "websocket": {
    "enabled": true,
    "activeConnections": 1
  }
}
```

### 3. Check Flutter App
- Open notifications screen
- Should see the notification
- Notification should have title and message
- Tapping should work (if action configured)

## 🚀 Next Steps

1. **Restart Server**
   ```bash
   cd server
   npm start
   ```

2. **Hot Restart Flutter App**
   - Press `R` in terminal
   - Or restart from IDE

3. **Send Test Notification**
   - Use admin panel or CLI script

4. **Verify Receipt**
   - Check Flutter logs
   - Check notifications screen in app
   - Check notification badge/count

## 🐛 If Still Not Working

### Check These:

1. **User is logged in**
   ```dart
   final token = await StorageService.getToken();
   print('Token exists: ${token != null}');
   ```

2. **WebSocket is connected**
   ```
   Flutter logs should show:
   ✅ WebSocket connected
   ```

3. **User ID matches**
   ```
   Server logs should show the same user ID as Flutter app
   ```

4. **Notification permissions**
   ```
   Check Android settings > Apps > ShowOff > Notifications
   ```

5. **Server is running**
   ```bash
   curl http://localhost:3000/health
   ```

## 📝 Summary of Changes

### Files Modified:
1. `server/models/Notification.js` - Added admin_announcement type, made sender optional
2. `server/controllers/notificationController.js` - Fixed field names, added logging
3. `server/utils/pushNotifications.js` - Enhanced logging
4. `apps/lib/services/notification_service.dart` - Added admin_announcement handling
5. `apps/lib/services/websocket_service.dart` - Fixed connection stability

### Files Created:
1. `diagnose_notifications.js` - Diagnostic tool
2. `test_notification_flow.js` - End-to-end test
3. `NOTIFICATION_FIX_COMPLETE.md` - This document

## ✅ Success Criteria

- [ ] Server logs show notification created in database
- [ ] Server logs show WebSocket notification sent
- [ ] Flutter logs show notification received
- [ ] Flutter logs show push notification displayed
- [ ] Notification appears in app notifications screen
- [ ] Notification count updates
- [ ] No WebSocket disconnection loops

---

**Status:** All fixes applied, ready for testing
**Date:** November 25, 2024
