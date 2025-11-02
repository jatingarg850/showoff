# Quick Notification Test

## Test the notification system in 2 minutes:

### Step 1: Get your auth token

Open terminal and run:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "your_email_here",
    "password": "your_password_here"
  }'
```

Copy the `token` from the response.

### Step 2: Test direct notification

Replace `YOUR_TOKEN_HERE` with your actual token:
```bash
curl -X POST http://localhost:3000/api/notifications/test/direct \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

### Step 3: Check results

You should see:
1. **Server logs**: Notification creation messages
2. **Flutter app**: Push notification appears on phone
3. **Notification screen**: New notification appears

### Step 4: If it works

The system is working! The issue is you're testing with your own posts.

**Solution**: 
- Create a second account
- Like/comment from second account on first account's posts
- Notifications will appear instantly

### Step 5: If it doesn't work

Check the debug guide in `DEBUG_NOTIFICATIONS.md` for detailed troubleshooting.

## Expected Server Response:

```json
{
  "success": true,
  "message": "Direct test notification created successfully",
  "notificationId": "..."
}
```

## Expected Server Logs:

```
🧪 Direct test notification requested for user: 6901078b5a65292cddac98d7
📝 Creating notification: {...}
✅ Notification created in database: ...
🔌 Emitting WebSocket notification to user_6901078b5a65292cddac98d7
✅ WebSocket notification emitted successfully
```

## Expected Flutter Logs:

```
📱 New notification received: {...}
🔔 Showing push notification: ...
✅ Push notification sent: 🧪 Direct Test
```

Try this test first! 🧪