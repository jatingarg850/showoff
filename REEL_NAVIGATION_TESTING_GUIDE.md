# Reel Navigation ID-Based Fix - Testing Guide

## Quick Test Steps

### Test 1: Navigate to Post from User Profile
1. Open the app and go to any user's profile
2. Click on one of their posts (not the first one)
3. **Expected:** The reel screen opens directly to that post
4. **Verify:** The post ID matches what you clicked on

### Test 2: Navigate to Post from Liked Posts
1. Go to your profile
2. Tap on "Liked" section
3. Click on any liked post
4. **Expected:** Reel screen opens to that specific post
5. **Verify:** You can scroll up/down to see other posts

### Test 3: Navigate to SYT Entry
1. Go to Talent/SYT section
2. Click on any SYT entry
3. **Expected:** SYT reel screen opens to that entry
4. **Verify:** Entry details are displayed correctly

### Test 4: Deep Link Navigation
1. Get a deep link to a specific post (e.g., from share functionality)
2. Open the link in the app
3. **Expected:** App navigates directly to that post
4. **Verify:** Post is displayed correctly

### Test 5: Scroll After Navigation
1. Navigate to a specific post (using any method above)
2. Scroll up and down through the feed
3. **Expected:** Smooth scrolling, videos load correctly
4. **Verify:** No crashes or loading issues

### Test 6: Upload Video with Background Music
1. Create a new post with a video
2. Select background music
3. Go to preview screen
4. Tap "Upload"
5. **Expected:** Video uploads successfully with music metadata
6. **Verify:** Post appears in feed with music info

### Test 7: Upload Video without Background Music
1. Create a new post with a video
2. Don't select background music
3. Go to preview screen
4. Tap "Upload"
5. **Expected:** Video uploads successfully
6. **Verify:** Post appears in feed

### Test 8: Upload Image
1. Create a new post with an image
2. Add caption
3. Go to preview screen
4. Tap "Upload"
5. **Expected:** Image uploads successfully
6. **Verify:** Post appears in feed

## Debug Logging

When testing, check the console for these debug messages:

### Successful Navigation
```
✅ Found initial post at index: 0 (ID: 507f1f77bcf36cd799439011)
```

### Post Fetched from API
```
🔍 Initial post not in feed, fetching separately: 507f1f77bcf36cd799439011
✅ Initial post fetched and inserted at index 0
```

### Video Upload
```
📤 Submitting SYT entry with:
  - title: My Talent
  - category: singing
  - backgroundMusicId: 507f1f77bcf36cd799439012
✅ Video ready with music metadata
  - Video file: /path/to/video.mp4
  - Music ID: 507f1f77bcf36cd799439012
```

## Common Issues & Solutions

### Issue: Post not found after navigation
**Solution:** Check if the post ID is being passed correctly through MainScreen
```dart
// In profile_screen.dart or user_profile_screen.dart
MainScreen(initialIndex: 0, initialPostId: post['_id'])
```

### Issue: Video upload fails with "Media file not found"
**Solution:** Ensure the media path is correct and file exists
- Check that `widget.mediaPath` is not null
- Verify the file exists at that path
- Check file permissions

### Issue: Background music not playing in preview
**Solution:** Verify music ID and audio URL
- Check that `widget.backgroundMusicId` is set
- Verify the music exists in the database
- Check that the audio URL is accessible

### Issue: Slow navigation to post
**Solution:** This is expected if the post needs to be fetched from API
- First navigation might take 1-2 seconds
- Subsequent navigations use cached data
- Check network connectivity if it takes longer

## Performance Notes

- **First Load:** ~1-2 seconds (fetches feed + initial post if needed)
- **Subsequent Loads:** <500ms (uses cached data)
- **Video Compression:** ~5-30 seconds depending on video size
- **Upload:** Depends on file size and network speed

## Rollback Instructions

If issues occur, revert these files:
1. `apps/lib/reel_screen.dart` - Revert `_loadFeed()` and `_getInitialIndex()` methods
2. `apps/lib/preview_screen.dart` - Revert media file validation and `fileToUpload` initialization

## Success Criteria

✅ All 8 test steps pass without errors
✅ No crashes when navigating to posts
✅ Videos upload successfully with/without music
✅ Smooth scrolling through feed after navigation
✅ Debug logs show correct post IDs and navigation flow
