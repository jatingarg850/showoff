# Admin Notification System - Complete Guide

## Overview
The admin notification system allows administrators to send custom notifications to users with advanced targeting options, both from the web admin panel and directly from the server using CLI scripts.

## Features

### 🎯 Targeting Options
1. **All Users** - Send to all active users
2. **Verified Users** - Only verified users
3. **Active Users** - Users active in the last 7 days
4. **New Users** - Users registered in the last 30 days
5. **Custom Targeting** - Advanced criteria-based targeting

### 🔧 Custom Targeting Criteria
- Minimum/Maximum balance
- Registration date range
- Last active date
- Minimum followers count
- Exclude specific user IDs

### 📊 Features
- Real-time recipient count preview
- Batch sending (100 users per batch)
- Delivery statistics tracking
- Notification history
- Action buttons (open URL, screen, or post)
- Image support

---

## Web Admin Panel

### Access
1. Navigate to: `http://localhost:3000/admin/notifications`
2. Login with admin credentials
3. Use the notification center interface

### Sending Notifications
1. Fill in the notification title and message
2. Select target audience
3. (Optional) Add image URL
4. (Optional) Configure action type and data
5. Preview recipient count
6. Click "Send Notification"

---

## Server-Side CLI Scripts

### 1. Simple Notification Sender

**Location:** `server/scripts/sendNotification.js`

**Usage:**
```bash
# Send to all users
node server/scripts/sendNotification.js --title "Welcome!" --message "Thanks for joining" --target all

# Send to verified users
node server/scripts/sendNotification.js --title "Update" --message "New features available" --target verified

# Send to active users
node server/scripts/sendNotification.js --title "Stay Active" --message "Keep engaging!" --target active

# Send to specific users
node server/scripts/sendNotification.js --title "Special" --message "For you" --target selected --ids "userId1,userId2,userId3"

# With image and action
node server/scripts/sendNotification.js \
  --title "Check this out" \
  --message "New content available" \
  --target all \
  --image "https://example.com/image.jpg" \
  --action open_url \
  --actionData "https://example.com/page"
```

**Options:**
- `--title` - Notification title (required)
- `--message` - Notification message (required)
- `--target` - Target type: all, selected, verified, active, new (default: all)
- `--ids` - Comma-separated user IDs (required if target is "selected")
- `--image` - Image URL (optional)
- `--action` - Action type: none, open_url, open_screen, open_post (default: none)
- `--actionData` - Action data (URL, screen name, or post ID)
- `--adminId` - Admin user ID (optional)

---

### 2. Bulk Notification Sender (Advanced)

**Location:** `server/scripts/bulkNotification.js`

**Usage:**
```bash
node server/scripts/bulkNotification.js --config notification-config.json
```

**Configuration File Format:**
```json
{
  "title": "🎉 Welcome Bonus!",
  "message": "Congratulations! You've received 50 bonus coins for being an active user.",
  "imageUrl": "https://example.com/bonus-image.jpg",
  "actionType": "open_screen",
  "actionData": "wallet",
  "adminId": null,
  "targeting": {
    "type": "custom",
    "criteria": {
      "isVerified": true,
      "minBalance": 0,
      "maxBalance": 500,
      "registeredAfter": "2024-01-01",
      "lastActiveAfter": "2024-11-01",
      "minFollowers": 5,
      "excludeUserIds": []
    }
  }
}
```

**Example Configurations:**

**1. Welcome New Users:**
```json
{
  "title": "👋 Welcome to ShowOff!",
  "message": "Start your journey by creating your first post!",
  "actionType": "open_screen",
  "actionData": "create_post",
  "targeting": {
    "type": "custom",
    "criteria": {
      "registeredAfter": "2024-11-20",
      "minBalance": 0,
      "maxBalance": 100
    }
  }
}
```

**2. Re-engage Inactive Users:**
```json
{
  "title": "🔥 We Miss You!",
  "message": "Come back and see what's new! Claim your 20 bonus coins.",
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

**3. Reward Top Users:**
```json
{
  "title": "⭐ VIP Reward!",
  "message": "Thank you for being an amazing community member! Here's 100 bonus coins.",
  "actionType": "open_screen",
  "actionData": "wallet",
  "targeting": {
    "type": "custom",
    "criteria": {
      "isVerified": true,
      "minFollowers": 100,
      "minBalance": 500
    }
  }
}
```

**4. Promote Feature to Active Users:**
```json
{
  "title": "🎬 New Feature: Reels!",
  "message": "Create short videos and reach more people. Try it now!",
  "imageUrl": "https://example.com/reels-promo.jpg",
  "actionType": "open_screen",
  "actionData": "create_reel",
  "targeting": {
    "type": "active"
  }
}
```

---

## API Endpoints

### Send Notification (Web Admin)
```
POST /api/notifications/admin-web/send
```

**Request Body:**
```json
{
  "title": "Notification Title",
  "message": "Notification message",
  "imageUrl": "https://example.com/image.jpg",
  "targetType": "custom",
  "customCriteria": {
    "isVerified": true,
    "minBalance": 100,
    "maxBalance": 1000,
    "registeredAfter": "2024-01-01",
    "lastActiveAfter": "2024-11-01",
    "minFollowers": 10
  },
  "actionType": "open_url",
  "actionData": "https://example.com"
}
```

### Preview Recipient Count
```
POST /api/notifications/admin-web/preview-count
```

**Request Body:**
```json
{
  "targetType": "custom",
  "customCriteria": {
    "isVerified": true,
    "minBalance": 100
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "targetType": "custom",
    "recipientCount": 1234
  }
}
```

### Get Notification List
```
GET /api/notifications/admin-web/list?page=1&limit=20&status=sent
```

### Get Notification Statistics
```
GET /api/notifications/admin-web/:id/stats
```

---

## Database Models

### AdminNotification Model
```javascript
{
  title: String,              // Notification title
  message: String,            // Notification message
  imageUrl: String,           // Optional image URL
  targetType: String,         // all, selected, verified, active, new, custom
  targetUsers: [ObjectId],    // Array of user IDs (for selected type)
  actionType: String,         // none, open_url, open_screen, open_post
  actionData: String,         // Action data
  scheduledFor: Date,         // Scheduled send time
  sentAt: Date,               // Actual send time
  status: String,             // draft, scheduled, sent, failed
  totalRecipients: Number,    // Total target users
  deliveredCount: Number,     // Successfully delivered
  readCount: Number,          // Read by users
  clickCount: Number,         // Action clicked
  createdBy: ObjectId,        // Admin user ID
  createdAt: Date,
  updatedAt: Date
}
```

---

## Best Practices

### 1. Targeting
- Start with small test groups before sending to all users
- Use preview count to verify targeting criteria
- Avoid sending too many notifications to the same users

### 2. Content
- Keep titles under 50 characters
- Keep messages under 200 characters for better readability
- Use emojis sparingly for visual appeal
- Include clear call-to-action

### 3. Timing
- Send during peak user activity hours
- Avoid sending multiple notifications in short succession
- Consider user time zones for global audiences

### 4. Performance
- Batch sending handles 100 users per batch automatically
- Large sends (>10,000 users) may take several minutes
- Monitor server resources during bulk sends

### 5. Testing
- Always test with a small group first
- Verify links and action data before sending
- Check notification appearance on different devices

---

## Monitoring & Analytics

### Delivery Statistics
- Total recipients
- Delivered count
- Read count
- Click count
- Delivery rate
- Read rate
- Click-through rate

### Access Statistics
```
GET /api/notifications/admin-web/:id/stats
```

**Response:**
```json
{
  "success": true,
  "data": {
    "totalRecipients": 1000,
    "deliveredCount": 985,
    "readCount": 750,
    "clickCount": 320,
    "deliveryRate": "98.50",
    "readRate": "76.14",
    "clickRate": "32.49"
  }
}
```

---

## Troubleshooting

### Notifications Not Sending
1. Check MongoDB connection
2. Verify admin authentication
3. Check server logs for errors
4. Ensure target users exist and are active

### Low Delivery Rate
1. Verify user devices have push notifications enabled
2. Check WebSocket connections
3. Review user active status

### Script Errors
1. Ensure `.env` file is configured
2. Check MongoDB URI is correct
3. Verify Node.js version (14+ required)
4. Install dependencies: `npm install`

---

## Security Considerations

1. **Authentication**: Only authenticated admins can send notifications
2. **Rate Limiting**: API endpoints are rate-limited
3. **Input Validation**: All inputs are validated and sanitized
4. **Batch Processing**: Prevents server overload with large sends
5. **Audit Trail**: All notifications are logged with admin ID

---

## Future Enhancements

- [ ] Scheduled notifications
- [ ] A/B testing for notification content
- [ ] Rich media support (videos, GIFs)
- [ ] Notification templates
- [ ] User preference management
- [ ] Analytics dashboard
- [ ] Notification campaigns
- [ ] Automated triggers based on user behavior

---

## Support

For issues or questions:
1. Check server logs: `server/logs/`
2. Review error messages in console
3. Verify configuration in `.env`
4. Test with simple notification first

---

## Quick Reference

### Send to All Users
```bash
node server/scripts/sendNotification.js \
  --title "Announcement" \
  --message "Important update" \
  --target all
```

### Send to Verified Users with Image
```bash
node server/scripts/sendNotification.js \
  --title "New Feature" \
  --message "Check out our latest update" \
  --target verified \
  --image "https://example.com/feature.jpg" \
  --action open_url \
  --actionData "https://example.com/features"
```

### Send with Custom Criteria
```bash
node server/scripts/bulkNotification.js --config my-notification.json
```

---

**Last Updated:** November 25, 2024
**Version:** 1.0.0
