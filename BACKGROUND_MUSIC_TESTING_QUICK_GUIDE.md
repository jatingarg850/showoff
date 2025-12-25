# Background Music Scroll Fix - Testing Guide

## Quick Test Steps

### Test 1: Music Stops When Scrolling to Reel Without Music
1. Open app and navigate to Reel Screen
2. Find a reel WITH background music (music should be playing)
3. Scroll down to a reel WITHOUT background music
4. **Expected**: Music stops immediately, no audio continues
5. **Verify**: Console shows "🎵 No background music for this reel, stopping music"

### Test 2: Music Switches When Scrolling to Different Music
1. Open app and navigate to Reel Screen
2. Find a reel with Music A (music should be playing)
3. Scroll down to a reel with Music B (different music)
4. **Expected**: Music A stops, Music B starts playing
5. **Verify**: Console shows "🎵 Stopping previous music before playing new music"

### Test 3: Music Continues When Scrolling to Same Music
1. Open app and navigate to Reel Screen
2. Find a reel with Music A (music should be playing)
3. Scroll down to another reel with Music A (same music)
4. **Expected**: Music continues without restart or interruption
5. **Verify**: Console shows "🎵 Same music already playing, skipping reload"

### Test 4: Music Stops When Leaving Reel Screen
1. Open app and navigate to Reel Screen
2. Play a reel with background music
3. Navigate to a different screen (Profile, Search, etc.)
4. **Expected**: Music stops immediately
5. **Verify**: Console shows "🎵 Background music stopped on dispose"

### Test 5: Music Pauses/Resumes with App Lifecycle
1. Open app and navigate to Reel Screen
2. Play a reel with background music
3. Press home button (app goes to background)
4. **Expected**: Music pauses
5. **Verify**: Console shows "🎵 Background music paused"
6. Return to app
7. **Expected**: Music resumes
8. **Verify**: Console shows "🎵 Background music resumed"

### Test 6: Rapid Scrolling (Stress Test)
1. Open app and navigate to Reel Screen
2. Rapidly scroll up and down between multiple reels
3. **Expected**: No audio glitches, overlapping music, or crashes
4. **Verify**: Music switches cleanly without stuttering

## Console Output to Look For

### Success Indicators
```
🎵 No background music for this reel, stopping music
🎵 Stopping previous music before playing new music
🎵 Same music already playing, skipping reload
✅ Background music loaded and playing for reel
🎵 Background music paused
🎵 Background music resumed
🎵 Background music stopped on dispose
```

### Error Indicators (Should NOT see these)
```
❌ Error loading background music
❌ Failed to fetch music
❌ Audio URL is empty or null
```

## Performance Metrics

- **Music stop latency**: Should be < 100ms
- **Music switch time**: Should be < 500ms (includes API fetch)
- **No audio overlap**: Previous music should stop before new music plays
- **Memory**: No memory leaks from lingering audio players

## Rollback Plan

If issues occur, revert these files:
1. `apps/lib/reel_screen.dart` - Revert `_playBackgroundMusicForReel()` and `dispose()` methods
2. `apps/lib/services/background_music_service.dart` - Revert `stopBackgroundMusic()` method

## Notes

- The fix ensures music is stopped BEFORE new music plays (prevents overlap)
- Same music detection prevents unnecessary reloads (optimization)
- All music operations are awaited to ensure completion
- Music tracking is reset on stop to prevent state issues
