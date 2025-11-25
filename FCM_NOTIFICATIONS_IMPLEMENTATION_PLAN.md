# FCM Notifications Implementation Plan

## Overview
Implement Firebase Cloud Messaging (FCM) notifications for all user interactions including likes, comments, follows, votes, and messages.

## Current State Analysis

### ✅ Already Implemented
1. **FCM Infrastructure**
   - FCM service initialized in Flutter app
   - Firebase Admin SDK configured on server
   - FCM token registration and storage
   - Background notification handler
   - Notification icon and color customization

2. **Notification Helper Functions**
   - `createLikeNotification()`
   - `createCommentNotification()`
   - `createFollowNotification()`
   - `createVoteNotification()`
   - `createGiftNotification()`
   - `createSystemNotification()`

3. **Partial Integration**
   - Like notifications (posts only)
   - Comment notifications (posts only)

### ❌ Missing Implementations

#### Server-Side
1. **Follow notifications** - Not integrated in followController
2. **SYT vote notifications** - Not integrated in sytController
3. **SYT like notifications** - Not integrated in sytController
4. **Message notifications** - Not integrated in chatController
5. **Post like notifications for SYT** - Missing

#### Flutter-Side
1. **Notification tap handling** - Navigate to specific screens
2. **In-app notification display** - Show notifications while app is open
3. **Notification badge counts** - Update UI with unread counts

## Implementation Plan

### Phase 1: Server-Side Integration (Priority: HIGH)

#### 1.1 Follow Notifications
**File:** `server/controllers/followController.js`
**Location:** `followUser` function
**Action:** Add notification after successful follow

```javascript
// After creating follow
const { createFollowNotification } = require('../utils/notificationHelper');
await createFollowNotification(req.user.id, userToFollow);
```

#### 1.2 SYT Vote Notifications
**File:** `server/controllers/sytController.js`
**Location:** `voteEntry` function
**Action:** Add notification after successful vote

```javascript
// After creating vote
const { createVoteNotification } = require('../utils/notificationHelper');
await createVoteNotification(entry._id, req.user.id, entry.user);
```

#### 1.3 SYT Like Notifications
**File:** `server/controllers/sytController.js`
**Location:** `toggleLike` function
**Action:** Add notification when liking (not unliking)

```javascript
// After creating like
if (!existingLike && entry.user.toString() !== req.user.id) {
  const { createLikeNotification } = require('../utils/notificationHelper');
  await createLikeNotification(entry._id, req.user.id, entry.user);
}
```

#### 1.4 Message Notifications
**File:** `server/controllers/chatController.js`
**Location:** `sendMessage` function
**Action:** Create new message notification helper and integrate

**New Helper Function:**
```javascript
// In notificationHelper.js
exports.createMessageNotification = async (senderId, recipientId, messageText) => {
  const truncatedMessage = messageText.length > 50 
    ? messageText.substring(0, 50) + '...' 
    : messageText;
  
  await createNotification({
    recipient: recipientId,
    sender: senderId,
    type: 'message',
    title: 'New Message',
    message: truncatedMessage,
    data: {
      senderId: senderId.toString(),
    },
  });
};
```

### Phase 2: Notification Model Updates (Priority: HIGH)

#### 2.1 Add Message Type to Notification Model
**File:** `server/models/Notification.js`
**Action:** Add 'message' to type enum if not present

```javascript
type: {
  type: String,
  enum: ['like', 'comment', 'follow', 'vote', 'gift', 'achievement', 'system', 'admin_announcement', 'message'],
  required: true,
},
```

### Phase 3: Flutter Notification Handling (Priority: MEDIUM)

#### 3.1 Update Notification Tap Handler
**File:** `apps/lib/services/fcm_service.dart`
**Location:** `_handleNotificationTap` function
**Action:** Implement navigation based on notification type

```dart
void _handleNotificationTap(RemoteMessage message) {
  final type = message.data['type'];
  final id = message.data['id'];
  
  switch (type) {
    case 'like':
    case 'comment':
      // Navigate to post detail screen
      NavigationService.navigateToPost(id);
      break;
    case 'follow':
      // Navigate to user profile
      NavigationService.navigateToProfile(message.data['senderId']);
      break;
    case 'vote':
      // Navigate to SYT entry
      NavigationService.navigateToSYTEntry(message.data['sytEntryId']);
      break;
    case 'message':
      // Navigate to chat screen
      NavigationService.navigateToChat(message.data['senderId']);
      break;
  }
}
```

#### 3.2 Create Navigation Service
**File:** `apps/lib/services/navigation_service.dart` (NEW)
**Action:** Create centralized navigation service

```dart
class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  
  static void navigateToPost(String postId) {
    navigatorKey.currentState?.pushNamed('/post', arguments: postId);
  }
  
  static void navigateToProfile(String userId) {
    navigatorKey.currentState?.pushNamed('/profile', arguments: userId);
  }
  
  static void navigateToSYTEntry(String entryId) {
    navigatorKey.currentState?.pushNamed('/syt-entry', arguments: entryId);
  }
  
  static void navigateToChat(String userId) {
    navigatorKey.currentState?.pushNamed('/chat', arguments: userId);
  }
}
```

#### 3.3 Update Main App
**File:** `apps/lib/main.dart`
**Action:** Add navigatorKey to MaterialApp

```dart
MaterialApp(
  navigatorKey: NavigationService.navigatorKey,
  // ... rest of config
)
```

### Phase 4: Testing & Validation (Priority: MEDIUM)

#### 4.1 Test Scenarios
1. **Follow Flow**
   - User A follows User B
   - User B receives notification (foreground, background, closed)
   - Tap notification → Navigate to User A's profile

2. **Like Flow (Posts)**
   - User A likes User B's post
   - User B receives notification
   - Tap notification → Navigate to post

3. **Like Flow (SYT)**
   - User A likes User B's SYT entry
   - User B receives notification
   - Tap notification → Navigate to SYT entry

4. **Comment Flow**
   - User A comments on User B's post
   - User B receives notification
   - Tap notification → Navigate to post with comments

5. **Vote Flow**
   - User A votes for User B's SYT entry
   - User B receives notification
   - Tap notification → Navigate to SYT entry

6. **Message Flow**
   - User A sends message to User B
   - User B receives notification
   - Tap notification → Navigate to chat with User A

### Phase 5: Optimization (Priority: LOW)

#### 5.1 Notification Batching
- Group multiple likes/comments from same user
- "John and 5 others liked your post"

#### 5.2 Notification Preferences
- Allow users to enable/disable specific notification types
- Quiet hours configuration

#### 5.3 Sound & Vibration
- Custom notification sounds per type
- Vibration patterns

## Implementation Order

### Step 1: Server-Side (30 minutes)
1. Add follow notification to followController ✅
2. Add vote notification to sytController ✅
3. Add like notification to sytController ✅
4. Create and add message notification ✅

### Step 2: Model Updates (5 minutes)
1. Add 'message' type to Notification model ✅

### Step 3: Testing (15 minutes)
1. Test each notification type
2. Verify FCM delivery
3. Check notification appearance

### Step 4: Flutter Navigation (45 minutes)
1. Create NavigationService
2. Update FCM tap handler
3. Add routes to MaterialApp
4. Test navigation from notifications

## Success Criteria

✅ All user interactions trigger notifications
✅ Notifications delivered via FCM (background & closed app)
✅ Notifications displayed correctly with custom icon
✅ Tapping notifications navigates to correct screen
✅ No duplicate notifications
✅ No self-notifications (user doesn't get notified of own actions)

## Files to Modify

### Server
1. `server/controllers/followController.js` - Add follow notification
2. `server/controllers/sytController.js` - Add vote & like notifications
3. `server/controllers/chatController.js` - Add message notification
4. `server/utils/notificationHelper.js` - Add message notification helper
5. `server/models/Notification.js` - Add message type to enum

### Flutter
1. `apps/lib/services/fcm_service.dart` - Update tap handler
2. `apps/lib/services/navigation_service.dart` - NEW: Create navigation service
3. `apps/lib/main.dart` - Add navigatorKey
4. `apps/lib/services/push_notification_service.dart` - Update notification display

## Estimated Time
- **Server-Side Integration:** 30 minutes
- **Flutter Navigation Setup:** 45 minutes
- **Testing & Debugging:** 30 minutes
- **Total:** ~2 hours

## Notes
- All notification helpers already exist except message notification
- FCM infrastructure is fully set up and working
- Main work is integrating existing helpers into controllers
- Flutter navigation needs to be set up for proper deep linking
