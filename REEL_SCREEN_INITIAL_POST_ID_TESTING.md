# ReelScreen Initial Post ID Handling - Testing Guide

## Pre-Testing Setup

1. Ensure the app is built and running
2. Have multiple posts available in the feed
3. Have posts in your liked posts
4. Have SYT entries available
5. Enable debug logging to see console messages

## Test Cases

### Test 1: Navigate to Post from User Profile
**Objective:** Verify navigation to a specific post from user profile

**Steps:**
1. Open the app and go to any user's profile
2. Click on one of their posts (preferably not the first one)
3. Observe the reel screen

**Expected Results:**
- ✅ Reel screen opens
- ✅ The clicked post is displayed
- ✅ Debug log shows: `🔄 MainScreen: initialPostId changed from null to [postId]`
- ✅ Debug log shows: `✅ Found initial post at index: [index]`
- ✅ Can scroll up/down to see other posts

**Failure Indicators:**
- ❌ Wrong post displayed
- ❌ Reel screen shows first post instead of clicked post
- ❌ No debug logs appear

---

### Test 2: Navigate to Post from Liked Posts
**Objective:** Verify navigation from liked posts section

**Steps:**
1. Go to your profile
2. Tap on "Liked" section
3. Click on any liked post
4. Observe the reel screen

**Expected Results:**
- ✅ Reel screen opens to the liked post
- ✅ Post is displayed correctly
- ✅ Debug logs show post ID change
- ✅ Can scroll to see other posts

**Failure Indicators:**
- ❌ Different post displayed
- ❌ Crash or error

---

### Test 3: Navigate to SYT Entry
**Objective:** Verify navigation to SYT entries

**Steps:**
1. Go to Talent/SYT section
2. Click on any SYT entry
3. Observe the SYT reel screen

**Expected Results:**
- ✅ SYT reel screen opens
- ✅ Correct entry is displayed
- ✅ Entry details are shown
- ✅ Can vote and interact

**Failure Indicators:**
- ❌ Wrong entry displayed
- ❌ Navigation fails

---

### Test 4: Deep Link Navigation
**Objective:** Verify deep link navigation to specific posts

**Steps:**
1. Get a deep link to a post (from share functionality)
2. Open the link in the app
3. Observe the reel screen

**Expected Results:**
- ✅ App navigates to the post
- ✅ Correct post is displayed
- ✅ Debug logs show post ID
- ✅ Post is playable

**Failure Indicators:**
- ❌ Wrong post or first post displayed
- ❌ App doesn't navigate

---

### Test 5: Rapid Navigation Between Posts
**Objective:** Verify handling of rapid navigation changes

**Steps:**
1. Click on post #1 from profile
2. Immediately click on post #2 from profile
3. Immediately click on post #3 from profile
4. Observe the reel screen

**Expected Results:**
- ✅ Final post (#3) is displayed
- ✅ No crashes
- ✅ Smooth transitions
- ✅ Debug logs show all changes

**Failure Indicators:**
- ❌ Crash or freeze
- ❌ Wrong post displayed
- ❌ Inconsistent state

---

### Test 6: Scroll After Navigation
**Objective:** Verify scrolling works correctly after navigating to a post

**Steps:**
1. Navigate to a specific post
2. Scroll up and down through the feed
3. Observe video loading and playback

**Expected Results:**
- ✅ Smooth scrolling
- ✅ Videos load correctly
- ✅ No crashes
- ✅ Music plays for each post
- ✅ Can scroll back to original post

**Failure Indicators:**
- ❌ Stuttering or lag
- ❌ Videos don't load
- ❌ Crash during scroll

---

### Test 7: Video Playback After Navigation
**Objective:** Verify video plays correctly after navigation

**Steps:**
1. Navigate to a video post
2. Wait for video to load
3. Verify video plays
4. Tap to pause/play
5. Scroll to next post
6. Verify new video plays

**Expected Results:**
- ✅ Video loads and plays
- ✅ Pause/play works
- ✅ Smooth transitions between videos
- ✅ No audio issues
- ✅ Background music plays

**Failure Indicators:**
- ❌ Video doesn't load
- ❌ Black screen
- ❌ Audio issues
- ❌ Crash

---

### Test 8: Background Music After Navigation
**Objective:** Verify background music plays correctly

**Steps:**
1. Navigate to a post with background music
2. Wait for music to load
3. Verify music plays
4. Scroll to next post
5. Verify music changes

**Expected Results:**
- ✅ Music loads and plays
- ✅ Music changes when scrolling
- ✅ Music stops when navigating away
- ✅ No audio conflicts

**Failure Indicators:**
- ❌ Music doesn't play
- ❌ Wrong music plays
- ❌ Audio issues

---

### Test 9: Post Not in Initial Feed
**Objective:** Verify handling when post is not in initial feed

**Steps:**
1. Navigate to a post that's far down in the feed (e.g., post #50)
2. Observe the reel screen
3. Check debug logs

**Expected Results:**
- ✅ Post loads correctly
- ✅ Debug log shows: `🔍 Initial post not in feed, fetching separately`
- ✅ Debug log shows: `✅ Initial post fetched and inserted at index 0`
- ✅ Post is displayed at index 0
- ✅ Can scroll to see other posts

**Failure Indicators:**
- ❌ Post not found
- ❌ Wrong post displayed
- ❌ Crash

---

### Test 10: Navigation Away and Back
**Objective:** Verify state preservation when navigating away and back

**Steps:**
1. Navigate to a specific post
2. Navigate to another screen (e.g., profile)
3. Navigate back to reels
4. Observe the reel screen

**Expected Results:**
- ✅ Reel screen shows the same post
- ✅ Video state is preserved
- ✅ Smooth transition
- ✅ No crashes

**Failure Indicators:**
- ❌ Different post displayed
- ❌ Video resets
- ❌ Crash

---

## Debug Logging Checklist

When running tests, verify these debug messages appear:

### Navigation Change
```
🔄 MainScreen: initialPostId changed from [oldId] to [newId]
🔄 Initial post ID changed from [oldId] to [newId]
```

### Feed Loading
```
📺 Feed response: {...}
📺 Loaded [count] posts
```

### Post Fetching
```
🔍 Initial post not in feed, fetching separately: [postId]
✅ Initial post fetched and inserted at index 0
```

### Post Found
```
✅ Found initial post at index: [index] (ID: [postId])
```

### Video Initialization
```
🎬 Video URL for video [index]: [url]
✅ Video initialized and playing
```

### Music Loading
```
🎵 Found background music ID: [musicId] for reel [index]
🎵 Music started playing successfully
```

---

## Performance Benchmarks

| Operation | Expected Time | Acceptable Range |
|-----------|---------------|------------------|
| First navigation | 1-2 seconds | <3 seconds |
| Subsequent navigation | <500ms | <1 second |
| Video load | 1-3 seconds | <5 seconds |
| Music load | 500ms-1s | <2 seconds |
| Scroll transition | <200ms | <500ms |

---

## Common Issues and Solutions

### Issue: Wrong post displayed
**Solution:**
- Check debug logs for post ID
- Verify post exists in database
- Check API response

### Issue: Post not found
**Solution:**
- Verify post ID is correct
- Check network connectivity
- Check API endpoint

### Issue: Video doesn't load
**Solution:**
- Check video URL
- Verify video file exists
- Check network connectivity

### Issue: Crash on navigation
**Solution:**
- Check debug logs for errors
- Verify mounted checks
- Check for null references

### Issue: Slow navigation
**Solution:**
- Check network speed
- Verify API response time
- Check device performance

---

## Test Report Template

```
Test Date: [DATE]
Tester: [NAME]
Device: [MODEL]
OS Version: [VERSION]
App Version: [VERSION]

Test Results:
- Test 1: [PASS/FAIL]
- Test 2: [PASS/FAIL]
- Test 3: [PASS/FAIL]
- Test 4: [PASS/FAIL]
- Test 5: [PASS/FAIL]
- Test 6: [PASS/FAIL]
- Test 7: [PASS/FAIL]
- Test 8: [PASS/FAIL]
- Test 9: [PASS/FAIL]
- Test 10: [PASS/FAIL]

Issues Found:
1. [ISSUE]
2. [ISSUE]

Notes:
[ADDITIONAL NOTES]
```

---

## Success Criteria

✅ All 10 tests pass
✅ No crashes or errors
✅ Smooth navigation and scrolling
✅ Videos load and play correctly
✅ Background music plays correctly
✅ Debug logs show expected messages
✅ Performance within acceptable range
✅ No memory leaks
