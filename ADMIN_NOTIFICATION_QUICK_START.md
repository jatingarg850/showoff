# Admin Notification System - Quick Start Guide

## 🚀 Quick Access

### Web Admin Panel
```
http://localhost:3000/admin/notifications
```
Login with admin credentials to access the notification center.

---

## 📱 Three Ways to Send Notifications

### 1. Web Admin Panel (Easiest)
1. Go to `http://localhost:3000/admin/notifications`
2. Fill in title and message
3. Select target audience
4. Click "Preview Recipient Count"
5. Click "Send Notification"

### 2. Command Line (Quick)
```bash
# Windows
send_notification.bat "Title" "Message" all

# Linux/Mac
node server/scripts/sendNotification.js --title "Title" --message "Message" --target all
```

### 3. Bulk with Config File (Advanced)
```bash
node server/scripts/bulkNotification.js --config notification-config.json
```

---

## 🎯 Target Options

| Target | Description | Example Use Case |
|--------|-------------|------------------|
| `all` | All active users | System announcements |
| `verified` | Verified users only | Premium features |
| `active` | Active in last 7 days | Engagement campaigns |
| `new` | Registered in last 30 days | Welcome messages |
| `custom` | Advanced criteria | Targeted promotions |

---

## 💡 Quick Examples

### Welcome New Users
```bash
node server/scripts/sendNotification.js \
  --title "👋 Welcome to ShowOff!" \
  --message "Start your journey by creating your first post" \
  --target new
```

### Announce New Feature
```bash
node server/scripts/sendNotification.js \
  --title "🎉 New Feature: Reels!" \
  --message "Create short videos and reach more people" \
  --target all \
  --action open_screen \
  --actionData "create_reel"
```

### Reward Active Users
```bash
node server/scripts/sendNotification.js \
  --title "⭐ Thank You!" \
  --message "You've earned 50 bonus coins for being active" \
  --target active \
  --action open_screen \
  --actionData "wallet"
```

### Custom Targeting (Config File)
Create `my-notification.json`:
```json
{
  "title": "🎁 Special Offer!",
  "message": "Get 100 bonus coins - limited time only!",
  "actionType": "open_screen",
  "actionData": "store",
  "targeting": {
    "type": "custom",
    "criteria": {
      "isVerified": true,
      "minBalance": 0,
      "maxBalance": 500,
      "minFollowers": 10
    }
  }
}
```

Then run:
```bash
node server/scripts/bulkNotification.js --config my-notification.json
```

---

## 📊 Check Results

### View in Admin Panel
1. Go to `http://localhost:3000/admin/notifications`
2. See recent notifications in the right panel
3. Check delivery statistics

### View via API
```bash
curl http://localhost:3000/api/notifications/admin-web/list
```

---

## 🔧 Testing

### Test the System
```bash
node test_admin_notification.js
```

### Send Test Notification
```bash
# Windows
send_notification.bat "Test" "This is a test" verified

# Linux/Mac
node server/scripts/sendNotification.js --title "Test" --message "This is a test" --target verified
```

---

## 📝 Action Types

| Action Type | Description | Action Data Example |
|-------------|-------------|---------------------|
| `none` | No action | - |
| `open_url` | Open external URL | `https://example.com` |
| `open_screen` | Open app screen | `wallet`, `profile`, `store` |
| `open_post` | Open specific post | Post ID |

---

## ⚡ Performance Tips

1. **Preview First**: Always preview recipient count before sending
2. **Batch Automatically**: System handles batching (100 users/batch)
3. **Monitor Logs**: Check server logs for delivery status
4. **Test Small**: Test with small groups before mass sending

---

## 🛠️ Troubleshooting

### Notifications Not Sending?
1. Check server is running: `http://localhost:3000/health`
2. Verify MongoDB connection
3. Check admin authentication
4. Review server logs

### Low Delivery Rate?
1. Verify users are active
2. Check WebSocket connections
3. Ensure push notifications enabled

### Script Errors?
1. Check `.env` file exists
2. Verify MongoDB URI
3. Run `npm install` in server folder
4. Check Node.js version (14+ required)

---

## 📚 Full Documentation

For complete documentation, see:
- `ADMIN_NOTIFICATION_SYSTEM.md` - Complete guide
- `notification-config.example.json` - Example config file
- `server/scripts/sendNotification.js` - Simple sender
- `server/scripts/bulkNotification.js` - Bulk sender

---

## 🎨 Example Notification Templates

### System Maintenance
```json
{
  "title": "🔧 Scheduled Maintenance",
  "message": "System will be down for 30 minutes tonight at 2 AM",
  "targetType": "all"
}
```

### Feature Announcement
```json
{
  "title": "🚀 New Feature Alert!",
  "message": "Check out our brand new Stories feature",
  "actionType": "open_screen",
  "actionData": "stories",
  "targetType": "active"
}
```

### Engagement Boost
```json
{
  "title": "💎 Daily Bonus Available!",
  "message": "Log in now to claim your daily reward",
  "actionType": "open_screen",
  "actionData": "daily_bonus",
  "targetType": "verified"
}
```

### Re-engagement
```json
{
  "title": "😢 We Miss You!",
  "message": "Come back and see what's new. Here's 50 bonus coins!",
  "actionType": "open_screen",
  "actionData": "home",
  "targeting": {
    "type": "custom",
    "criteria": {
      "lastActiveAfter": "2024-10-01",
      "registeredBefore": "2024-11-01"
    }
  }
}
```

---

## 🔐 Security Notes

- Only authenticated admins can send notifications
- All inputs are validated and sanitized
- Rate limiting applied to API endpoints
- All notifications logged with admin ID
- Batch processing prevents server overload

---

## 📞 Support

Need help? Check:
1. Server logs in console
2. MongoDB connection status
3. `.env` configuration
4. Network connectivity

---

**Quick Start Complete!** 🎉

Start sending notifications now:
```bash
send_notification.bat "Hello World" "Testing the system" all
```

Or visit: `http://localhost:3000/admin/notifications`
