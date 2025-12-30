# Reel Index Navigation Fix

## Problem
When clicking on a reel from the profile screen, the app was navigating to the first reel instead of the clicked reel. Additionally, when a reel was deleted from admin, the app would show a different reel because it was using array indices instead of post IDs.

## Root Cause
The code was using **index-based navigation** instead of **ID-based navigation**:

1. When you click a reel, it passes the `postId` to MainScreen
2. MainScreen passes it to ReelScreen as `initialPostId`
3. ReelScreen loads the feed and finds the post index using `indexWhere`
4. The PageController jumps to that index
5. **Problem**: If the feed refreshes or reels are deleted, the indices change, causing the wrong reel to display

## Solution
Changed the tracking mechanism from index-based to ID-based:

### Changes Made:

1. **Added `_currentPostId` variable** (line ~41)
   - Tracks the current post by its ID instead of just the index
   - Survives feed refreshes and deletions

2. **Updated `_onPageChanged` method** (line ~729)
   - Now sets `_currentPostId = _posts[index]['_id']` when page changes
   - This ensures we always know which post is being viewed by its ID

3. **Updated `_loadFeed` method** (line ~250)
   - Initializes `_currentPostId` when loading the feed
   - Sets it to the initial post's ID if specified

4. **Added `_getIndexByPostId` helper method** (line ~298)
   - Utility method to find a post's current index by its ID
   - Returns -1 if post not found (e.g., if deleted)

## How It Works Now

1. User clicks a reel from profile → passes `postId`
2. ReelScreen receives `initialPostId` and finds its index in the feed
3. PageController jumps to that index
4. `_onPageChanged` is called and sets `_currentPostId` to the post's ID
5. If the feed refreshes or reels are deleted:
   - The app still knows which post was being viewed (by ID)
   - Can find the new index using `_getIndexByPostId()`
   - Navigation remains correct

## Benefits
- ✅ Clicking a reel now shows the correct reel
- ✅ Deleting reels from admin doesn't break navigation
- ✅ Feed refreshes don't cause wrong reels to display
- ✅ More robust and maintainable code

## Testing
1. Click on a reel from your profile → should show that specific reel
2. Delete a reel from admin → remaining reels should display correctly
3. Refresh the feed → current reel should remain the same
