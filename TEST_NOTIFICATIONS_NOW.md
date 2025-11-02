# Test Notifications Right Now! 🧪

## Quick Test (2 minutes)

### Option 1: Use PowerShell Script (Easiest)
```bash
powershell -ExecutionPolicy Bypass -File test_notifications.ps1
```

### Option 2: Manual Commands

#### Step 1: Login and get token
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "your_email_here",
    "password": "your_password_here"
  }'
```

#### Step 2: Copy the token from response and test
```bash
# Replace YOUR_TOKEN_HERE with actual token
curl -X POST http://localhost:3000/api/notifications/test/direct \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

## What Should Happen

### 1. Server Logs (in your server console):
```
🧪 Direct test notification requested for user: [your_user_id]
📝 Creating notification: {...}
✅ Notification created in database: [notification_id]
✅ Notification populated with sender data
📱 Sending in-app notification to: [your_username]
🔌 Emitting WebSocket notification to user_[your_user_id], unread count: 1
✅ WebSocket notification emitted successfully
```

### 2. Flutter App Logs:
```
📱 New notification received: {...}
🔔 Showing push notification: ShowOff.life - This is a direct test notification...
✅ Push notification sent: 🧪 Direct Test
```

### 3. On Your Phone:
- **Push notification appears**: "🧪 Direct Test - This is a direct test notification to verify the system is working!"
- **Notification sound/vibration**
- **Badge count updates**

### 4. In Your App:
- **Notification screen updates** with new notification
- **Badge shows unread count**
- **Real-time update** without refresh

## If It Works ✅

The notification system is working perfectly! 

**Why you didn't see notifications before:**
- You were testing with your own posts
- Notifications only go to **post owners** when **others** like/comment
- You need **different accounts** to test real scenarios

**Next steps:**
1. Create a second account
2. Like/comment from second account on first account's posts
3. Notifications will appear instantly!

## If It Doesn't Work ❌

### Check These:

1. **Server Running?**
   ```bash
   curl http://localhost:3000/health
   ```

2. **WebSocket Connected?**
   - Look for "✅ WebSocket connected" in Flutter logs
   - Check server shows active connections

3. **Notification Permissions?**
   - Android: Settings → Apps → ShowOff.life → Notifications → Enable
   - Check Flutter logs for permission status

4. **Network Issues?**
   - Android Emulator: Use `10.0.2.2:3000`
   - Real Device: Use your computer's IP address

## Real-World Test

Once the direct test works:

1. **Create Account A** (your main account)
2. **Create Account B** (test account) 
3. **Post a reel** from Account A
4. **Like the reel** from Account B
5. **Account A gets notification**: "❤️ New Like - [Account B] liked your reel"

## Test All Types

```bash
# Test like notification
curl -X POST http://localhost:3000/api/notifications/test/like \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test comment notification  
curl -X POST http://localhost:3000/api/notifications/test/comment \
  -H "Authorization: Bearer YOUR_TOKEN"

# Test follow notification
curl -X POST http://localhost:3000/api/notifications/test/follow \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Expected API Response

```json
{
  "success": true,
  "message": "Direct test notification created successfully",
  "notificationId": "673f8a1b2c3d4e5f6789abcd"
}
```

## Troubleshooting

- **500 Error**: Check server logs for detailed error
- **401 Error**: Token expired, login again
- **No push notification**: Check Android notification permissions
- **No WebSocket**: Check network connection and server

**Try the test now!** 🚀

The system is fully implemented and should work. The most likely issue was testing with your own posts instead of different accounts.