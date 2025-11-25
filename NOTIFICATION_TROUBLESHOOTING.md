# Notification Troubleshooting Guide

## Issue: Not Receiving Notifications in Flutter App

### ✅ What Was Fixed

1. **WebSocket Stability** - Fixed constant reconnection loop
2. **Real-time Delivery** - Added WebSocket notification sending in admin controller
3. **Admin Announcement Handling** - Added support for `admin_announcement` type in Flutter

### 🔍 How to Test

#### Option 1: Use Test Script
```bash
node test_notification_flow.js
```

#### Option 2: Manual Testing
1. Open admin panel: `http://localhost:3000/admin/notifications`
2. Send a test notification to "All Users"
3. Check Flutter app for notification

### 📊 Debugging Steps

#### 1. Check Server Logs
Look for these messages:
```
✅ Admin notification sent to X users
✅ WebSocket notification sent to user [userId]
```

#### 2. Check Flutter Logs
Look for these messages:
```
✅ WebSocket connected
📱 New notification received: {...}
🔔 Showing push notification: ...
```

#### 3. Check WebSocket Connection
In Flutter console, you should see:
```
✅ WebSocket connected
🔢 Unread count update: {unreadCount: X}
```

NOT constantly disconnecting/reconnecting.

### 🐛 Common Issues

#### Issue 1: WebSocket Keeps Disconnecting
**Symptoms:**
```
✅ WebSocket connected
❌ WebSocket disconnected
✅ WebSocket connected
❌ WebSocket disconnected
```

**Solution:** Already fixed! The new WebSocket service has:
- Exponential backoff
- Max 5 reconnection attempts
- Proper connection state management

#### Issue 2: Notification Sent But Not Received
**Possible Causes:**
1. User not logged in
2. WebSocket not connected
3. Wrong user ID
4. Notification permissions disabled

**Check:**
```bash
# Check server health and connections
curl http://localhost:3000/health

# Should show:
# "activeConnections": 1 (or more)
```

#### Issue 3: No Users Found
**Error:** "No users match the selected criteria"

**Solution:**
- Make sure you have users in the database
- Check targeting criteria
- Try "All Users" first

### 🔧 Manual Verification

#### 1. Check Database
```javascript
// In MongoDB
db.notifications.find().sort({createdAt: -1}).limit(1)
```

Should show the notification with:
- `type: "admin_announcement"`
- `user: [userId]`
- `title` and `message`

#### 2. Check WebSocket Delivery
In server console, look for:
```
✅ User [username] connected via WebSocket
✅ WebSocket notification sent to user [userId]
```

#### 3. Check Flutter App State
In Flutter console:
```
✅ Notification service initialized
✅ WebSocket connected
📱 New notification received: {notification: {...}}
```

### 📱 Flutter App Checklist

- [ ] User is logged in
- [ ] WebSocket is connected (check logs)
- [ ] Notification service is initialized
- [ ] Push notification permissions granted
- [ ] App is in foreground or background (not killed)

### 🚀 Quick Test

#### Send Test Notification
```bash
# Windows
send_notification.bat "Test" "Hello from admin" all

# Linux/Mac
node server/scripts/sendNotification.js --title "Test" --message "Hello from admin" --target all
```

#### Expected Result
1. Server logs: `✅ Admin notification sent to X users`
2. Server logs: `✅ WebSocket notification sent to user [userId]`
3. Flutter logs: `📱 New notification received`
4. Flutter logs: `🔔 Showing push notification`
5. Notification appears in app

### 🔍 Advanced Debugging

#### Enable Verbose Logging

**Server (server.js):**
```javascript
// Add after WebSocket setup
io.on('connection', (socket) => {
  console.log('🔌 Socket connected:', socket.id, 'User:', socket.userId);
  
  socket.onAny((event, ...args) => {
    console.log('📡 Socket event:', event, args);
  });
});
```

**Flutter (websocket_service.dart):**
```dart
// Add in connect() method
_socket!.onAny((event, data) {
  print('📡 Socket event: $event, data: $data');
});
```

#### Check Active Connections
```bash
curl http://localhost:3000/health
```

Look for:
```json
{
  "websocket": {
    "enabled": true,
    "activeConnections": 1
  }
}
```

If `activeConnections` is 0, the Flutter app is not connected.

### 💡 Solutions

#### Solution 1: Restart Everything
```bash
# 1. Stop server (Ctrl+C)
# 2. Stop Flutter app
# 3. Start server
cd server
npm start

# 4. Start Flutter app
cd apps
flutter run
```

#### Solution 2: Clear App Data
```bash
# Android
flutter clean
flutter pub get
flutter run

# Or in Android Studio:
# Settings > Apps > ShowOff > Storage > Clear Data
```

#### Solution 3: Check Token
In Flutter, check if token is valid:
```dart
final token = await StorageService.getToken();
print('Token: ${token?.substring(0, 20)}...');
```

If token is null or invalid, log in again.

### 📞 Still Not Working?

1. **Check server logs** for errors
2. **Check Flutter logs** for connection issues
3. **Verify MongoDB** is running and connected
4. **Test with simple notification** to one user
5. **Check network connectivity** between app and server

### ✅ Success Indicators

When everything works, you should see:

**Server:**
```
✅ User jatingarg connected via WebSocket
✅ Admin notification sent to 1 users (1 total)
✅ WebSocket notification sent to user 6925455a0916073edcd40dad
```

**Flutter:**
```
✅ WebSocket connected
🔢 Unread count update: {unreadCount: 0}
📱 New notification received: {notification: {...}}
🔔 Showing push notification: ShowOff.life - Test message
```

**App:**
- Notification appears in notification center
- Unread count updates
- Notification shows in app

---

## Quick Reference

### Send Notification
```bash
# Web
http://localhost:3000/admin/notifications

# CLI
node server/scripts/sendNotification.js --title "Test" --message "Hello" --target all

# Test
node test_notification_flow.js
```

### Check Status
```bash
# Server health
curl http://localhost:3000/health

# Recent notifications
curl http://localhost:3000/api/notifications/admin-web/list
```

### Logs to Watch
- Server: WebSocket connection and notification sending
- Flutter: WebSocket connection and notification receiving
- MongoDB: Notification documents created

---

**Last Updated:** November 25, 2024
