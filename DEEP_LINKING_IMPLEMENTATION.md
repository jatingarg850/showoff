# Deep Linking Implementation Guide

## Overview
This document describes the deep linking system implemented for ShowOff Life app to load specific reels when selected from profile screens.

## Architecture

### 1. Profile Grid Selection Flow
```
Profile Screen Grid Tap
    ↓
Extract Post ID & Data
    ↓
Navigate to MainScreen with initialPostId & initialPostData
    ↓
MainScreen creates ReelScreen with parameters
    ↓
ReelScreen loads specific post first
    ↓
PageController jumps to post index
    ↓
Video initializes and plays
```

### 2. Deep Link Format
```
showoff://reel/{postId}
https://showoff.life/reel/{postId}
```

## Implementation Details

### Profile Screen (profile_screen.dart)
When user taps a reel in the grid:

```dart
onTap: () {
  final postId = post['_id'];
  print('🎬 Profile: Show tapped - ID: $postId');
  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => MainScreen(
        initialIndex: 0,
        initialPostId: postId,
        initialPostData: post, // Pass full post data for faster loading
      ),
    ),
  );
}
```

**Key Points:**
- Extracts post ID from grid item
- Passes full post data to avoid extra API call
- Uses `pushReplacement` to replace profile screen
- Sets `initialIndex: 0` to show reel tab

### User Profile Screen (user_profile_screen.dart)
Same implementation as profile_screen.dart for viewing other users' reels.

### Main Screen (main_screen.dart)
Receives parameters and passes to ReelScreen:

```dart
class MainScreen extends StatefulWidget {
  final int initialIndex;
  final String? initialPostId;
  final Map<String, dynamic>? initialPostData;

  const MainScreen({
    super.key,
    this.initialIndex = 0,
    this.initialPostId,
    this.initialPostData,
  });
}
```

**Initialization:**
```dart
_reelScreen = ReelScreen(
  key: _reelScreenKey,
  initialPostId: widget.initialPostId,
  initialPostData: widget.initialPostData,
);
```

### Reel Screen (reel_screen.dart)
Loads specific post and navigates to it:

```dart
class ReelScreen extends StatefulWidget {
  final String? initialPostId;
  final Map<String, dynamic>? initialPostData;

  const ReelScreen({
    super.key,
    this.initialPostId,
    this.initialPostData,
  });
}
```

**Loading Logic:**
```dart
// If we have initialPostData, use it directly (faster than API call)
if (widget.initialPostData != null) {
  final specificPost = Map<String, dynamic>.from(widget.initialPostData!);
  posts.add(specificPost);
  debugPrint('✅ Using provided post data: ${specificPost['_id']}');
} else if (widget.initialPostId != null) {
  // Fetch specific post from API if data not provided
  final postResponse = await ApiService.getPost(widget.initialPostId!);
  if (postResponse['success'] && postResponse['data'] != null) {
    final specificPost = Map<String, dynamic>.from(postResponse['data']);
    posts.add(specificPost);
  }
}
```

**Navigation to Post:**
```dart
if (initialIndex > 0) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pageController.jumpToPage(initialIndex);
  });
}
```

## Data Flow

### 1. Post Data Structure
```dart
{
  '_id': String,                    // Unique post ID
  'mediaUrl': String,               // Video URL
  'mediaType': String,              // 'video' or 'image'
  'thumbnailUrl': String,           // Thumbnail image
  'caption': String,                // Post caption
  'user': {
    '_id': String,
    'username': String,
    'displayName': String,
    'profilePicture': String,
  },
  'likes': int,
  'comments': int,
  'shares': int,
  'views': int,
  'isLiked': bool,
  'isBookmarked': bool,
  'createdAt': String,
}
```

### 2. API Endpoints Used
- **Get Single Post**: `GET /api/posts/{postId}`
- **Get Feed**: `GET /api/posts/feed?page=1&limit=20`
- **Get Pre-signed URL**: `POST /api/videos/presigned-url`

## Performance Optimizations

### 1. Avoid Redundant API Calls
- Pass full post data from profile grid to avoid fetching again
- Only fetch from API if data not provided

### 2. Video Caching
- Uses `CacheManager` for video caching
- Caches videos for 3 days
- Supports pre-signed URLs for Wasabi storage

### 3. Lazy Loading
- Only initializes video controllers for current, previous, and next posts
- Cleans up distant controllers to save memory

### 4. Batch Pre-signed URL Fetching
- Fetches pre-signed URLs for multiple posts at once
- Reduces API calls

## Testing Deep Links

### 1. Test from Profile Screen
1. Navigate to your profile
2. Tap any reel in the grid
3. Verify reel loads and plays immediately
4. Check console logs for "Using provided post data"

### 2. Test from User Profile Screen
1. Navigate to another user's profile
2. Tap any reel in their grid
3. Verify reel loads and plays immediately

### 3. Test with API Fallback
1. Modify profile screen to not pass `initialPostData`
2. Tap a reel
3. Verify reel still loads (via API call)
4. Check console logs for "Loaded specific post"

## Debugging

### Console Logs
```
🎬 Profile: Show tapped - ID: {postId}
✅ Using provided post data: {postId}
📺 Loaded {count} feed posts
✅ Initial post placed at index 0, total posts: {count}
🎬 Video URL for post {index}: {url}
```

### Common Issues

**Issue: Reel doesn't load**
- Check if `initialPostId` is being passed correctly
- Verify post data structure matches expected format
- Check API response for errors

**Issue: Wrong reel plays**
- Verify `initialIndex` is set to 0
- Check if `PageController.jumpToPage()` is being called
- Ensure post ID matches in data structure

**Issue: Video doesn't play**
- Check if video URL is valid
- Verify pre-signed URL is being fetched
- Check video format (HLS or MP4)

## Future Enhancements

1. **Deep Link Handling**: Implement URL scheme handling for external deep links
2. **Share Integration**: Generate shareable deep links for reels
3. **Analytics**: Track deep link usage and engagement
4. **Offline Support**: Cache reel data for offline viewing
5. **Transition Animation**: Add smooth transition when loading specific reel

## Related Files
- `apps/lib/profile_screen.dart` - Profile grid implementation
- `apps/lib/user_profile_screen.dart` - User profile grid implementation
- `apps/lib/main_screen.dart` - Main screen navigation
- `apps/lib/reel_screen.dart` - Reel display and loading
- `apps/lib/services/api_service.dart` - API calls
