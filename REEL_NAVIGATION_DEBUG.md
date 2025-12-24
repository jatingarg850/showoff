# Reel Navigation Debug Guide

## Issue
When clicking on a reel in profile_screen.dart or user_profile_screen.dart, the app is opening a browser instead of navigating to the reel within the app.

## Root Cause Analysis

The navigation code in both profile screens is correct:
```dart
Navigator.pushReplacement(
  context,
  MaterialPageRoute(
    builder: (context) =>
        MainScreen(initialIndex: 0, initialPostId: post['_id']),
  ),
);
```

However, the reel might be opening in a browser due to:

1. **Deep Link Interception**: The deep link handler in main.dart might be interfering
2. **URL Launch**: Some code might be launching the share URL instead of navigating
3. **Post Data Issue**: The `post['_id']` might contain a URL instead of an ID

## Debug Steps

### Step 1: Check Console Logs
When you click on a reel in the profile, you should see:
```
🎬 Reel tapped: {postId}
```

If you don't see this log, the GestureDetector is not being triggered.

### Step 2: Verify Post Data
Add this debug code to check what's in the post object:
```dart
print('Post data: ${post.toString()}');
print('Post ID: ${post['_id']}');
print('Post ID type: ${post['_id'].runtimeType}');
```

### Step 3: Check Deep Link Handler
The deep link handler should only trigger when:
- App is launched from a link (initial deep link)
- App receives a deep link while running (stream listener)

It should NOT trigger during normal app navigation.

### Step 4: Verify MainScreen Navigation
Add logging to main_screen.dart:
```dart
@override
void initState() {
  super.initState();
  print('MainScreen initialized with initialPostId: ${widget.initialPostId}');
  // ... rest of code
}
```

### Step 5: Verify ReelScreen Navigation
Add logging to reel_screen.dart:
```dart
@override
void initState() {
  super.initState();
  print('ReelScreen initialized with initialPostId: ${widget.initialPostId}');
  // ... rest of code
}
```

## Possible Solutions

### Solution 1: Ensure GestureDetector is Wrapping Entire Item
Make sure the GestureDetector wraps the entire grid item and nothing else is intercepting the tap.

### Solution 2: Disable Deep Link During App Navigation
Modify the deep link handler to not trigger if we're already navigating:
```dart
void _handleDeepLink(String link) {
  // Only handle deep links from external sources
  // Don't handle if we're already in the app
  if (!mounted) return;
  
  print('🔗 Deep link received: $link');
  // ... rest of handler
}
```

### Solution 3: Check for URL in Post ID
Add validation to ensure post['_id'] is actually an ID and not a URL:
```dart
final postId = post['_id'];
if (postId.startsWith('http')) {
  print('ERROR: Post ID is a URL, not an ID: $postId');
  return;
}
```

### Solution 4: Use pushNamed Instead of pushReplacement
Try using named routes instead:
```dart
Navigator.pushNamed(
  context,
  '/reel',
  arguments: {'postId': post['_id']},
);
```

## Files to Check

1. **apps/lib/profile_screen.dart** - Line ~684 (reel tap handler)
2. **apps/lib/user_profile_screen.dart** - Line ~733 (reel tap handler)
3. **apps/lib/main_screen.dart** - Verify initialPostId is passed correctly
4. **apps/lib/reel_screen.dart** - Verify initialPostId is used correctly
5. **apps/lib/main.dart** - Deep link handler might be interfering

## Testing

1. Run the app in debug mode
2. Navigate to your profile
3. Click on a reel
4. Check the console for logs
5. Verify the reel opens in the app (not in browser)

## Expected Behavior

1. Click reel in profile
2. Console shows: `🎬 Reel tapped: {postId}`
3. App navigates to MainScreen
4. ReelScreen loads with the specific reel
5. Reel plays automatically

## Actual Behavior (Issue)

1. Click reel in profile
2. Browser opens with URL like: `https://showofflife.app/reel/{postId}`
3. App doesn't navigate to the reel

## Next Steps

1. Add the debug logging mentioned above
2. Run the app and click on a reel
3. Share the console output
4. We can then identify exactly where the issue is occurring
