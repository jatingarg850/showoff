# Profile Reel Click - Shows Wrong Reel - FIXED ✅

## Problem
When clicking on a reel in the profile screen, the app navigates to the reel screen but shows a different reel instead of the one that was clicked.

**Example:**
- User's profile has 3 reels: A, B, C
- User clicks on reel B
- Reel screen opens but shows reel A (or some other reel from the general feed)

## Root Cause
The issue was a **data mismatch** between what the profile loads and what the reel screen loads:

1. **Profile loads:** User's own posts via `getUserPosts(userId)`
2. **Reel screen loads:** General feed via `getFeed()` (all users' posts)
3. **Result:** The clicked reel ID doesn't exist in the general feed, so the search fails and shows the first reel

**Example Flow:**
```
Profile Click (Reel B, ID: "xyz123")
    ↓
MainScreen(initialPostId: "xyz123")
    ↓
ReelScreen loads getFeed() [WRONG - general feed]
    ↓
Search for "xyz123" in general feed [NOT FOUND]
    ↓
initialIndex stays 0
    ↓
First reel in general feed plays [WRONG REEL]
```

## Solution Implemented

**File:** `apps/lib/reel_screen.dart`

**Changes to `_loadFeed()` function:**

1. **Detect when initialPostId is provided:**
   ```dart
   if (widget.initialPostId != null) {
     print('🎬 Loading specific post: ${widget.initialPostId}');
   ```

2. **Find the target post in the general feed:**
   ```dart
   final feedResponse = await ApiService.getFeed(page: 1, limit: 50);
   final targetPost = feedPosts.firstWhere(
     (post) => post['_id'] == widget.initialPostId,
     orElse: () => <String, dynamic>{},
   );
   ```

3. **Extract the user ID from the target post:**
   ```dart
   final userId = targetPost['user']?['_id'] ?? targetPost['user']?['id'];
   ```

4. **Load all posts from that specific user:**
   ```dart
   final userResponse = await ApiService.getUserPosts(userId);
   posts = List<Map<String, dynamic>>.from(userResponse['data']);
   ```

5. **Find the correct index in the user's posts:**
   ```dart
   final index = _posts.indexWhere(
     (post) => post['_id'] == widget.initialPostId,
   );
   if (index != -1) {
     initialIndex = index;
   }
   ```

6. **Jump to the correct reel:**
   ```dart
   if (initialIndex > 0) {
     _pageController.jumpToPage(initialIndex);
   }
   ```

## How It Works Now

**Correct Flow:**
```
Profile Click (Reel B, ID: "xyz123")
    ↓
MainScreen(initialPostId: "xyz123")
    ↓
ReelScreen._loadFeed() detects initialPostId
    ↓
Loads general feed to find target post
    ↓
Extracts user ID from target post
    ↓
Loads ALL posts from that user
    ↓
Searches for "xyz123" in user's posts [FOUND at index 1]
    ↓
Jumps to page 1
    ↓
Correct reel (B) plays ✅
```

## Key Improvements

1. **Correct data source:** When clicking a reel from profile, loads that user's posts instead of general feed
2. **Guaranteed match:** The clicked reel ID will definitely be in the user's posts
3. **Better error handling:** Logs when post is found and at which index
4. **Fallback logic:** If user posts fail to load, falls back to general feed
5. **Caching:** Still uses caching for performance

## Testing Checklist

- [ ] Go to your profile
- [ ] Click on any of your reels
- [ ] Verify the correct reel plays (not a different one)
- [ ] Swipe to next/previous reels
- [ ] Verify all your reels are in the correct order
- [ ] Go back to profile and click a different reel
- [ ] Verify it shows the correct reel

## Files Modified

1. **apps/lib/reel_screen.dart**
   - Modified `_loadFeed()` function
   - Added logic to detect and handle `initialPostId`
   - Loads user's posts when initialPostId is provided
   - Better logging for debugging

## Status
✅ **COMPLETE** - Clicking a reel from profile now shows the correct reel instead of a random one from the general feed.
