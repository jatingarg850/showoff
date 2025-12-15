# Reel Scrolling Like Notification Bug Fix

## Problem
When scrolling through reels, the app was automatically sending like notifications to post owners without the user actually liking the post. This was happening every time a reel came into view.

## Root Cause
The `_trackView()` method in `ReelScreen` was calling the wrong API endpoint:

```dart
// WRONG - This toggles like and sends notification
await ApiService.toggleLike(postId);

// CORRECT - This should increment view count
await ApiService.incrementView(postId);
```

The method was supposed to track views (increment view count), but it was calling `toggleLike()` instead, which:
1. Toggles the like status
2. Sends a like notification to the post owner
3. Increments like count

This was being called every time a reel scrolled into view, causing false like notifications.

## Solution
Changed the `_trackView()` method to call the correct endpoint:

```dart
Future<void> _trackView(String postId) async {
  try {
    // Track view - increment view count (NOT toggle like)
    await ApiService.incrementView(postId);
  } catch (e) {
    print('Error tracking view: $e');
  }
}
```

## Files Modified
- `apps/lib/reel_screen.dart` - Fixed `_trackView()` method

## Where _trackView is Called
The method is called in three places:
1. When initializing the first reel (line 258)
2. When jumping to a specific reel (line 323)
3. When scrolling to a new reel (line 948)

All these calls now correctly increment view count instead of toggling like.

## Expected Behavior After Fix

### Before (Broken)
```
User scrolls to reel
  ↓
_trackView() called
  ↓
toggleLike() called (WRONG)
  ↓
Like notification sent to post owner
  ↓
Like count incremented
  ↓
User sees reel (hasn't liked it yet)
```

### After (Fixed)
```
User scrolls to reel
  ↓
_trackView() called
  ↓
incrementView() called (CORRECT)
  ↓
View count incremented
  ↓
No notification sent
  ↓
User sees reel
  ↓
User can manually like if they want
```

## Testing

1. Open Reel Screen
2. Scroll through several reels without liking any
3. Check server logs - should see view increments, NOT like notifications
4. Check post owner's notifications - should NOT receive like notifications from scrolling
5. Manually like a reel - should receive like notification

## API Endpoints

### incrementView (Correct)
- Endpoint: `POST /api/posts/{postId}/view`
- Effect: Increments view count
- Notification: None

### toggleLike (Wrong for view tracking)
- Endpoint: `POST /api/posts/{postId}/like`
- Effect: Toggles like status, increments/decrements like count
- Notification: Sends like notification to post owner

## Impact
- Post owners no longer receive false like notifications from users just scrolling
- View counts are now accurately tracked
- Like counts are only incremented when users actually like posts
- Notification system is more reliable and trustworthy
