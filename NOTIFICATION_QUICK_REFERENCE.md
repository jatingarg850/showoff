# Notification System - Quick Reference Guide

## 🚀 Quick Start

### Test Notifications
```bash
# 1. Start server
node server/server.js

# 2. Run Flutter app (in another terminal)
cd apps && flutter run

# 3. Configure and run test script
# Edit test_all_notifications.js with your tokens
node test_all_notifications.js
```

### Send Admin Notification
```
http://localhost:3000/admin/notifications
```

## 📱 Notification Types

| Type | When | Example |
|------|------|---------|
| `follow` | User follows you | "john_doe started following you" |
| `like` | User likes your post/SYT | "jane_smith liked your reel" |
| `comment` | User comments on your post | "mike_jones commented: 'Great!'" |
| `vote` | User votes for your SYT entry | "sarah_lee voted for your SYT entry" |
| `message` | User sends you a message | "Hello! How are you?" |
| `gift` | User sends you a gift | "alex_brown sent you 100 coins" |
| `achievement` | You unlock achievement | "Achievement Unlocked! First Post" |
| `system` | System announcement | "New feature available!" |
| `admin_announcement` | Admin broadcast | "Maintenance scheduled" |

## 🔧 Add New Notification Type

### 1. Add to Model
```javascript
// server/models/Notification.js
enum: ['like', 'comment', ..., 'your_new_type']
```

### 2. Create Helper
```javascript
// server/utils/notificationHelper.js
exports.createYourNotification = async (senderId, recipientId, data) => {
  await createNotification({
    recipient: recipientId,
    sender: senderId,
    type: 'your_new_type',
    title: 'Your Title',
    message: 'Your message',
    data: { ...data },
  });
};
```

### 3. Use in Controller
```javascript
// server/controllers/yourController.js
const { createYourNotification } = require('../utils/notificationHelper');
await createYourNotification(senderId, recipientId, data);
```

## 📊 Check Notification Status

### View User Notifications
```bash
GET /api/notifications/user
Authorization: Bearer <token>
```

### View Admin Notifications
```bash
GET /api/notifications/admin-web/list
```

### Mark as Read
```bash
PUT /api/notifications/:id/read
Authorization: Bearer <token>
```

## 🐛 Debug Checklist

### Notifications not working?
- [ ] Server running?
- [ ] Flutter app running?
- [ ] FCM token registered? (Check logs for "📱 FCM Token sent to server")
- [ ] Firebase Admin SDK initialized? (Check logs for "✅ Firebase Admin initialized")
- [ ] Notification permissions granted?
- [ ] User is not notifying themselves?

### Check Server Logs
```bash
# Look for these messages:
✅ Firebase Admin initialized
✅ Like notification created successfully
✅ Comment notification created successfully
✅ Follow notification created successfully
✅ Vote notification created successfully
✅ Message notification created successfully
```

### Check Flutter Logs
```bash
# Look for these messages:
✅ Firebase initialized
✅ FCM permission granted
📱 FCM Token: <token>
✅ FCM token sent to server
📱 Foreground FCM notification: <title>
```

## 🎯 Common Use Cases

### Notify on Follow
```javascript
// In followController.js
const { createFollowNotification } = require('../utils/notificationHelper');
await createFollowNotification(req.user.id, userToFollow);
```

### Notify on Like
```javascript
// In postController.js or sytController.js
const { createLikeNotification } = require('../utils/notificationHelper');
await createLikeNotification(postId, req.user.id, postOwnerId);
```

### Notify on Comment
```javascript
// In postController.js
const { createCommentNotification } = require('../utils/notificationHelper');
await createCommentNotification(postId, commentId, req.user.id, postOwnerId, commentText);
```

### Notify on Message
```javascript
// In chatController.js
const { createMessageNotification } = require('../utils/notificationHelper');
await createMessageNotification(req.user.id, recipientId, messageText);
```

### Send Admin Broadcast
```javascript
POST /api/notifications/admin-web/send
{
  "title": "Announcement",
  "message": "Important update!",
  "targetType": "all",
  "actionType": "none"
}
```

## 📈 Monitoring

### Count Unread Notifications
```javascript
const unreadCount = await Notification.countDocuments({
  recipient: userId,
  isRead: false
});
```

### Get Recent Notifications
```javascript
const notifications = await Notification.find({ recipient: userId })
  .sort({ createdAt: -1 })
  .limit(20)
  .populate('sender', 'username displayName profilePicture');
```

### Delete Old Notifications
```javascript
// Notifications older than 30 days
const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
await Notification.deleteMany({
  createdAt: { $lt: thirtyDaysAgo },
  isRead: true
});
```

## 🔐 Security Notes

- ✅ Users can only see their own notifications
- ✅ FCM tokens are stored securely
- ✅ No self-notifications allowed
- ✅ Admin notifications require admin role
- ✅ Notification data is validated

## 📚 Related Files

### Server
- `server/controllers/notificationController.js` - Main notification logic
- `server/utils/notificationHelper.js` - Helper functions
- `server/utils/fcmService.js` - FCM delivery
- `server/utils/pushNotifications.js` - WebSocket delivery
- `server/models/Notification.js` - Notification model

### Flutter
- `apps/lib/services/fcm_service.dart` - FCM client
- `apps/lib/services/push_notification_service.dart` - Local notifications
- `apps/lib/firebase_options.dart` - Firebase config
- `apps/android/app/src/main/res/drawable/ic_notification.xml` - Icon

### Documentation
- `FCM_NOTIFICATIONS_COMPLETE.md` - Full implementation details
- `NOTIFICATION_SYSTEM_SUMMARY.md` - Complete summary
- `FCM_NOTIFICATIONS_IMPLEMENTATION_PLAN.md` - Original plan
- `test_all_notifications.js` - Test script

## 💡 Tips

1. **Always check for self-notifications** - Users shouldn't notify themselves
2. **Use async/await** - Don't block main operations
3. **Handle errors gracefully** - Failed notifications shouldn't crash the app
4. **Truncate long messages** - Keep notifications concise
5. **Test in all app states** - Foreground, background, and closed
6. **Use meaningful titles** - Help users understand the notification
7. **Include relevant data** - For navigation when tapped

## 🎓 Best Practices

### DO ✅
- Create notifications asynchronously
- Check sender !== recipient
- Truncate long text
- Include relevant data for navigation
- Log notification creation
- Handle errors gracefully

### DON'T ❌
- Block main operations waiting for notifications
- Send notifications to self
- Include sensitive data in notification body
- Create duplicate notifications
- Ignore notification errors silently
- Send notifications without user consent

## 📞 Support

### Issues?
1. Check server logs
2. Check Flutter logs
3. Verify FCM configuration
4. Test with simple notification first
5. Review this guide

### Need Help?
- Review `NOTIFICATION_SYSTEM_SUMMARY.md` for complete details
- Check `FCM_NOTIFICATIONS_COMPLETE.md` for implementation guide
- Run `test_all_notifications.js` to verify setup

---

**Last Updated:** November 25, 2025
**Status:** ✅ Production Ready
