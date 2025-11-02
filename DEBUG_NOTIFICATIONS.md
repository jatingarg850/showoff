# Debug Notification Issues

## Current Status
✅ WebSocket connected (1 active connection)  
✅ Server running on port 3000  
✅ Like/comment actions working  
❌ Notifications not appearing  

## Debugging Steps

### 1. Check if you're testing with your own posts
**Issue**: Notifications are only sent when OTHER users like/comment on YOUR posts.

**Solution**: 
- Create a second account
- Like/comment from the second account on the first account's posts
- OR use the test API endpoints

### 2. Test with API endpoints

Open a terminal and run these commands:

```bash
# First, get your auth token by logging in
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "your_email@example.com",
    "password": "your_password"
  }'
```

Copy the token from the response, then test notifications:

```bash
# Replace YOUR_TOKEN_HERE with the actual token
curl -X POST http://localhost:3000/api/notifications/test/direct \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### 3. Check server logs

When you run the test, you should see these logs in the server console:

```
🧪 Direct test notification requested for user: [userId]
📝 Creating notification: [notification data]
✅ Notification created in database: [notificationId]
✅ Notification populated with sender data
📱 Sending in-app notification to: [username]
🔌 Emitting WebSocket notification to user_[userId], unread count: [count]
✅ WebSocket notification emitted successfully
```

### 4. Check Flutter app logs

In the Flutter app console, you should see:

```
📱 New notification received: [notification data]
🔢 Unread count update: [data]
🔔 Showing push notification: [details]
✅ Push notification sent: [title]
```

### 5. Manual test with different users

1. **Create Account A** (your main account)
2. **Create Account B** (test account)
3. **Post a reel** from Account A
4. **Like the reel** from Account B
5. **Check Account A** for notifications

### 6. Test push notifications directly

Add this to your Flutter app to test push notifications:

```dart
// Test push notification
await PushNotificationService.instance.showNotification(
  title: '🧪 Test Push',
  body: 'This is a test push notification!',
  payload: 'test:notification',
);
```

### 7. Check notification permissions

Make sure notifications are enabled:

```dart
final status = await Permission.notification.status;
print('Notification permission: $status');

if (status.isDenied) {
  await Permission.notification.request();
}
```

### 8. Check Android notification settings

1. Go to **Settings** → **Apps** → **ShowOff.life**
2. Tap **Notifications**
3. Make sure notifications are **enabled**

## Expected Flow

1. **User B likes User A's reel**
2. **Server logs**: 
   ```
   🔍 Checking notification eligibility:
     Post owner ID: [User A ID]
     Liker ID: [User B ID]
     Same user? false
   ✅ Creating like notification...
   📝 Creating notification: {...}
   ✅ WebSocket notification emitted successfully
   ```
3. **Flutter logs**:
   ```
   📱 New notification received: {...}
   🔔 Showing push notification: User B - liked your reel
   ✅ Push notification sent: ❤️ New Like
   ```
4. **Phone**: Push notification appears
5. **App**: Notification screen updates, badge count increases

## Common Issues

### Issue: "Skipping notification - user liked own post"
**Solution**: Use a different account to like the post

### Issue: No server logs appearing
**Solution**: Check if notification helper file exists and functions are called

### Issue: WebSocket not connected
**Solution**: Check network settings, use correct IP (10.0.2.2 for Android emulator)

### Issue: Push notifications not appearing
**Solution**: Check Android permissions and notification settings

### Issue: Notifications created but not delivered
**Solution**: Check WebSocket connection and user room joining

## Quick Test Commands

```bash
# Test server health
curl http://localhost:3000/health

# Test direct notification (replace TOKEN)
curl -X POST http://localhost:3000/api/notifications/test/direct \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test like notification
curl -X POST http://localhost:3000/api/notifications/test/like \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test comment notification  
curl -X POST http://localhost:3000/api/notifications/test/comment \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Next Steps

1. **Try the API test endpoints** first
2. **Check server logs** for notification creation
3. **Check Flutter logs** for WebSocket delivery
4. **Test with different accounts** for real-world scenario
5. **Check push notification permissions** on device

The most likely issue is that you're testing with your own posts. Try the API endpoints or create a second account to test properly! 🧪