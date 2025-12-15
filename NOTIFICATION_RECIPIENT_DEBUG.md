# 🔍 Notification Recipient Bug - Debugging Guide

## Problem
When a user likes a reel, the notification is being sent to all users instead of just the reel owner.

## Root Cause Investigation
Added comprehensive logging to trace the notification flow:

1. **postController.js** - When like is created
2. **notificationHelper.js** - When notification is prepared
3. **notificationController.js** - When notification is sent

## How to Debug

### Step 1: Restart Server
```bash
npm start
```

### Step 2: Check Logs When Liking a Post

Look for this sequence in server logs:

```
🔍 Checking notification eligibility:
  Post owner ID: 693fea1dbd0b31693bb4dc02
  Post owner ID type: object
  Liker ID: 692c533cf1eabe2640278b48
  Liker ID type: string
  Same user? false
✅ Creating like notification for post owner: 693fea1dbd0b31693bb4dc02
  Recipient type: object, value: 693fea1dbd0b31693bb4dc02

Creating like notification: post=..., liker=..., owner=693fea1dbd0b31693bb4dc02
  Recipient type: object, value: 693fea1dbd0b31693bb4dc02

📢 Creating notification: type=like, recipient=693fea1dbd0b31693bb4dc02, sender=692c533cf1eabe2640278b48
   Recipient type: object, value: 693fea1dbd0b31693bb4dc02
✅ Notification saved to DB with ID: ...
📡 Sending WebSocket notification to user: 693fea1dbd0b31693bb4dc02
📱 Sending FCM notification to user: 693fea1dbd0b31693bb4dc02
```

### Step 3: Verify Recipient ID

The recipient ID should be:
- **Post owner's ID** (the person who created the reel)
- NOT the liker's ID
- NOT all users

### Step 4: Check WebSocket Room

The WebSocket notification should be sent to room: `user_693fea1dbd0b31693bb4dc02`

NOT to all users or broadcast.

## Expected Behavior

### When User A Likes User B's Reel:
1. ✅ Notification created in DB for User B
2. ✅ WebSocket sent to User B only (room: `user_B_id`)
3. ✅ FCM sent to User B only
4. ❌ User A should NOT receive notification
5. ❌ Other users should NOT receive notification

### When User A Likes Their Own Reel:
1. ✅ Notification NOT created (skipped)
2. ✅ No WebSocket sent
3. ✅ No FCM sent

## Debugging Checklist

- [ ] Restart server after code changes
- [ ] Like a post from a different user
- [ ] Check server logs for recipient ID
- [ ] Verify recipient ID is post owner's ID
- [ ] Check if notification appears only for post owner
- [ ] Check if other users don't receive notification
- [ ] Test with multiple users

## If Bug Still Exists

### Check These:

1. **Is recipient ID correct?**
   - Should be post owner's ID
   - Should NOT be all users or null

2. **Is WebSocket room correct?**
   - Should be `user_{postOwnerId}`
   - Should NOT be broadcast or empty

3. **Is FCM sending to correct user?**
   - Should query User by recipient ID
   - Should get that user's FCM token
   - Should send to that token only

4. **Is there a broadcast somewhere?**
   - Search for `io.emit()` without `.to()`
   - Search for `socket.broadcast.emit()`
   - These would send to all users

## Log Output Format

Each notification creation should show:

```
🔍 Checking notification eligibility:
  Post owner ID: [OWNER_ID]
  Liker ID: [LIKER_ID]
  Same user? false

✅ Creating like notification for post owner: [OWNER_ID]

Creating like notification: post=[POST_ID], liker=[LIKER_ID], owner=[OWNER_ID]
  Recipient type: object, value: [OWNER_ID]

📢 Creating notification: type=like, recipient=[OWNER_ID], sender=[LIKER_ID]
   Recipient type: object, value: [OWNER_ID]

📡 Sending WebSocket notification to user: [OWNER_ID]
📱 Sending FCM notification to user: [OWNER_ID]
```

## Next Steps

1. Restart server
2. Like a post from different user
3. Check logs match expected format
4. Verify only post owner receives notification
5. If still broken, check WebSocket room name
6. If still broken, check FCM token lookup

## Files with Logging

- `server/controllers/postController.js` - Like creation
- `server/utils/notificationHelper.js` - Notification preparation
- `server/controllers/notificationController.js` - Notification sending
- `server/utils/pushNotifications.js` - WebSocket sending
- `server/utils/fcmService.js` - FCM sending
