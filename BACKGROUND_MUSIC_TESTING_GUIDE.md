# Background Music Playback Testing Guide

## Overview
This guide covers testing the complete background music system from upload to playback in reels.

## Prerequisites
- App built and running on emulator/device
- Server running with music endpoints
- Admin account for uploading music
- User account for testing

## Test Scenarios

### Scenario 1: Upload Music (Admin)
**Objective**: Verify music can be uploaded and approved

**Steps**:
1. Log in as admin
2. Navigate to Admin Panel → Music Management
3. Upload a test music file (MP3, WAV, etc.)
4. Verify upload completes successfully
5. Approve the music
6. Verify music appears in approved list

**Expected Result**: ✅ Music is uploaded, approved, and available for selection

---

### Scenario 2: Select Music in Preview Screen
**Objective**: Verify music selection works and plays in preview

**Steps**:
1. Log in as regular user
2. Record or select a video
3. Navigate to music selection screen
4. Select the uploaded music
5. Verify "Background Music Added" badge appears in preview
6. Listen to preview screen
7. Verify music plays at 85% volume

**Expected Result**: ✅ Music plays in preview_screen with correct volume

---

### Scenario 3: Upload Post with Music
**Objective**: Verify post uploads with background music metadata

**Steps**:
1. From preview screen with music selected
2. Click "Upload" button
3. Wait for upload to complete
4. Verify success message
5. Check server logs for post creation with backgroundMusicId

**Expected Result**: ✅ Post created with backgroundMusicId field populated

---

### Scenario 4: View Reel with Music (First Reel)
**Objective**: Verify music plays automatically when viewing first reel

**Steps**:
1. Navigate to Reels tab
2. Wait for feed to load
3. First reel should display
4. Listen for background music
5. Verify music plays automatically (no user action needed)
6. Verify music volume is appropriate (85%)

**Expected Result**: ✅ Music plays automatically when reel is displayed

---

### Scenario 5: Scroll to Next Reel with Different Music
**Objective**: Verify music switches when scrolling to different reel

**Steps**:
1. From Scenario 4, scroll down to next reel
2. Verify previous music stops
3. Wait for new reel to load
4. Listen for new background music
5. Verify new music plays (if reel has music)

**Expected Result**: ✅ Previous music stops, new music plays for new reel

---

### Scenario 6: Scroll to Reel Without Music
**Objective**: Verify music stops when viewing reel without background music

**Steps**:
1. From any reel with music playing
2. Scroll to a reel that has no background music
3. Listen for music
4. Verify music stops

**Expected Result**: ✅ Music stops when reel has no background music

---

### Scenario 7: App Goes to Background
**Objective**: Verify music pauses when app goes to background

**Steps**:
1. Playing a reel with music
2. Press home button (app goes to background)
3. Wait 2-3 seconds
4. Listen for music (should be paused)

**Expected Result**: ✅ Music pauses when app goes to background

---

### Scenario 8: App Returns to Foreground
**Objective**: Verify music resumes when app returns to foreground

**Steps**:
1. From Scenario 7 (app in background)
2. Tap app icon to return to foreground
3. Wait 1-2 seconds
4. Listen for music
5. Verify music resumes playing

**Expected Result**: ✅ Music resumes when app returns to foreground

---

### Scenario 9: Leave Reel Screen
**Objective**: Verify music stops when leaving reel screen

**Steps**:
1. Playing a reel with music
2. Navigate to different tab (e.g., Profile, Search)
3. Listen for music
4. Verify music stops

**Expected Result**: ✅ Music stops when leaving reel_screen

---

### Scenario 10: SYT Reel with Music
**Objective**: Verify music plays for SYT competition entries

**Steps**:
1. Navigate to Talent/SYT tab
2. View SYT entries
3. Find entry with background music
4. Listen for music
5. Verify music plays automatically
6. Scroll to next entry
7. Verify music switches appropriately

**Expected Result**: ✅ Music plays for SYT entries with background music

---

### Scenario 11: Music URL Conversion
**Objective**: Verify relative URLs are converted to full URLs

**Steps**:
1. Enable network debugging (Charles Proxy or similar)
2. Play a reel with music
3. Monitor network requests
4. Verify music request uses full URL (http://server:port/uploads/music/...)
5. Verify NOT using relative URL (/uploads/music/...)

**Expected Result**: ✅ Full URLs used for music requests

---

### Scenario 12: Error Handling - Missing Music
**Objective**: Verify graceful handling when music fetch fails

**Steps**:
1. Simulate network error (disable network)
2. Play reel with music
3. Verify app doesn't crash
4. Verify error logged in console
5. Verify music doesn't play (graceful failure)
6. Re-enable network
7. Scroll to different reel
8. Verify music plays normally

**Expected Result**: ✅ App handles missing music gracefully

---

### Scenario 13: Same Music Optimization
**Objective**: Verify same music isn't reloaded unnecessarily

**Steps**:
1. Play reel with music (e.g., "Song A")
2. Note music starts playing
3. Scroll back to same reel
4. Verify music continues playing (not restarted)
5. Check console logs for "Same music already playing" message

**Expected Result**: ✅ Same music not reloaded, continues playing

---

### Scenario 14: Music Looping
**Objective**: Verify music loops when it ends

**Steps**:
1. Play reel with short music file (< 30 seconds)
2. Wait for music to end
3. Verify music restarts from beginning
4. Verify no gap between loops

**Expected Result**: ✅ Music loops seamlessly

---

### Scenario 15: Multiple Reels Rapid Scrolling
**Objective**: Verify music handles rapid scrolling without crashes

**Steps**:
1. Play reel with music
2. Rapidly scroll up/down through multiple reels
3. Verify app doesn't crash
4. Verify music switches appropriately
5. Verify no audio glitches

**Expected Result**: ✅ App handles rapid scrolling smoothly

---

## Debug Logging

### Console Output to Monitor

**Music Playback**:
```
🎵 Loading background music for reel: [musicId]
🎵 Playing background music: [audioUrl]
✅ Background music loaded and playing for reel
```

**Music Switching**:
```
🎵 Same music already playing, skipping reload
🎵 No background music for this reel, stopping music
```

**Lifecycle Events**:
```
🎵 Background music paused
🎵 Background music resumed
🎵 Background music stopped on dispose
```

**Errors**:
```
❌ Error loading background music: [error]
❌ Failed to fetch music: [message]
❌ Audio URL is empty or null
```

---

## Performance Metrics

### Expected Performance
- Music starts playing within 1-2 seconds of reel display
- Music switches within 500ms when scrolling
- No audio glitches or stuttering
- No memory leaks (check RAM usage over time)
- No CPU spikes when playing music

### Tools for Monitoring
- Android Studio Profiler (Memory, CPU)
- Logcat (console output)
- Network Monitor (URL verification)

---

## Known Issues & Workarounds

### Issue: Music doesn't play on first reel
**Workaround**: Scroll to next reel and back

### Issue: Music continues after leaving reel screen
**Workaround**: Ensure dispose() is called (check navigation)

### Issue: Music plays but no sound
**Workaround**: Check device volume, verify audio permissions

---

## Rollback Plan

If issues occur:
1. Revert changes to reel_screen.dart and syt_reel_screen.dart
2. Remove BackgroundMusicService import
3. Remove music playback calls
4. Rebuild and test

---

## Sign-Off

- [ ] All 15 scenarios tested
- [ ] No crashes observed
- [ ] Music plays correctly
- [ ] Performance acceptable
- [ ] Ready for production

**Tested By**: _______________
**Date**: _______________
**Notes**: _______________
