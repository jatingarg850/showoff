# Testing the Real-time Notification System

## Quick Test Guide

### 1. Start the Server
```bash
cd server
npm start
```

You should see:
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                         ║
║                                                           ║
║   Server running on port 3000                            ║  
║   Environment: development                                ║       
║   WebSocket: ✅ Enabled                                   ║
║                                                           ║
║   API Documentation: http://localhost:3000/               ║  
║   Health Check: http://localhost:3000/health              ║ 
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

### 2. Check Server Health
```bash
curl http://localhost:3000/health
```

Expected response:
```json
{
  "success": true,
  "message": "Server is running",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "websocket": {
    "enabled": true,
    "activeConnections": 0
  }
}
```

### 3. Start the Flutter App
```bash
cd apps
flutter run
```

### 4. Test WebSocket Connection

#### Option A: Login and Check Connection
1. Open the app
2. Login with your credentials
3. Check the console logs for:
   ```
   ✅ WebSocket connected
   ✅ Notification service initialized
   ```

#### Option B: Check Server Logs
When a user connects, you should see:
```
✅ User [username] connected via WebSocket
```

### 5. Test Real-time Notifications

#### Method 1: Using Test API Endpoints

First, get your auth token by logging in:
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "your_email@example.com",
    "password": "your_password"
  }'
```

Save the token from the response, then test notifications:

```bash
# Create test notifications
curl -X POST http://localhost:3000/api/notifications/test/create \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Create a like notification
curl -X POST http://localhost:3000/api/notifications/test/like \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Create a comment notification  
curl -X POST http://localhost:3000/api/notifications/test/comment \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"

# Create a follow notification
curl -X POST http://localhost:3000/api/notifications/test/follow \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

#### Method 2: Using App Actions
1. Like a post → Should create like notification
2. Comment on a post → Should create comment notification
3. Follow a user → Should create follow notification

### 6. Verify Real-time Delivery

1. **Open Notification Screen**: Navigate to the notifications screen in the app
2. **Trigger Notification**: Use one of the test API endpoints above
3. **Watch for Real-time Update**: The notification should appear instantly without refreshing
4. **Check Badge**: The unread count badge should update in real-time

### 7. Test Notification Features

#### Mark as Read
- Tap on a notification → Should mark as read and update badge count

#### Mark All as Read  
- Tap "Mark all read" button → Should mark all notifications as read

#### Delete Notification
- Swipe left on a notification → Should delete it

#### Pull to Refresh
- Pull down on notification list → Should refresh notifications

### 8. Expected Console Logs

#### Server Side:
```
✅ User [username] connected via WebSocket
✅ WebSocket notification sent to user [userId]
✅ Test notification created
```

#### Client Side (Flutter):
```
✅ WebSocket connected
✅ Notification service initialized
📱 New notification received: {...}
🔢 Unread count update: {...}
```

### 9. Troubleshooting

#### WebSocket Connection Failed
- **Check server is running**: `curl http://localhost:3000/health`
- **Check port**: Server should be on port 3000, not 5000
- **Check network**: Use `10.0.2.2:3000` for Android emulator
- **Check token**: Make sure user is logged in

#### Notifications Not Appearing
- **Check WebSocket connection**: Look for connection success logs
- **Check database**: Verify notifications are being created in MongoDB
- **Check user ID**: Ensure notifications are being sent to correct user

#### Badge Not Updating
- **Check Provider**: Ensure NotificationProvider is properly initialized
- **Check Consumer**: Verify Consumer widgets are used correctly
- **Check WebSocket events**: Look for unreadCountUpdate events

### 10. Production Checklist

Before deploying to production:

1. **Remove test endpoints** from notification routes
2. **Update CORS settings** to specific client URLs
3. **Add rate limiting** for notification creation
4. **Set up proper logging** instead of console.log
5. **Configure environment variables** for production URLs
6. **Add error monitoring** and alerting
7. **Set up database indexes** for notification queries
8. **Configure SSL/TLS** for secure WebSocket connections

## Success Indicators

✅ Server starts with WebSocket enabled  
✅ Flutter app connects to WebSocket  
✅ Test notifications create successfully  
✅ Notifications appear in real-time  
✅ Badge count updates instantly  
✅ Mark as read functionality works  
✅ Delete notifications works  
✅ Pull to refresh works  

If all these work, your notification system is ready! 🎉