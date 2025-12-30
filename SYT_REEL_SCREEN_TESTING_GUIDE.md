# SYT Reel Screen Testing Guide

## Overview
This guide provides comprehensive testing procedures to verify the HLS implementation in the SYT reel screen.

## Pre-Testing Setup

### 1. Enable Debug Logging
The implementation includes detailed logging with emoji prefixes:
- 🎬 Video operations
- 🔇 Volume/mute operations
- ⚠️ Warnings
- ❌ Errors

Monitor the console during testing to verify operations.

### 2. Test Environment
- Device: Physical device or emulator (emulator recommended for initial testing)
- Network: Test with both WiFi and mobile data
- Video: Mix of HLS and MP4 videos

### 3. Prepare Test Data
Ensure you have:
- At least 10 SYT competition entries
- Mix of HLS (.m3u8) and MP4 videos
- Videos of varying sizes (small, medium, large)
- Videos from Wasabi storage (if applicable)

---

## Test Cases

### Test 1: Basic Video Playback

**Objective**: Verify videos play correctly

**Steps**:
1. Open SYT reel screen
2. Observe first video
3. Verify video plays automatically
4. Check console for "🎬 Using HLS URL" or "🎬 Using MP4 URL"

**Expected Results**:
- ✅ Video displays
- ✅ Video plays automatically
- ✅ Audio is audible
- ✅ No console errors

**Pass/Fail**: ___

---

### Test 2: HLS Streaming

**Objective**: Verify HLS (.m3u8) videos work correctly

**Prerequisite**: Have at least one HLS video in test data

**Steps**:
1. Navigate to HLS video
2. Observe playback
3. Check console for "🎬 Using HLS URL"
4. Verify smooth playback

**Expected Results**:
- ✅ HLS URL detected
- ✅ Video plays smoothly
- ✅ No buffering issues
- ✅ Console shows HLS URL

**Pass/Fail**: ___

---

### Test 3: MP4 Playback

**Objective**: Verify MP4 videos still work

**Prerequisite**: Have at least one MP4 video in test data

**Steps**:
1. Navigate to MP4 video
2. Observe playback
3. Check console for "🎬 Using MP4 URL"
4. Verify smooth playback

**Expected Results**:
- ✅ MP4 URL detected
- ✅ Video plays smoothly
- ✅ No buffering issues
- ✅ Console shows MP4 URL

**Pass/Fail**: ___

---

### Test 4: Buffering Detection

**Objective**: Verify buffering detection and auto-play

**Steps**:
1. Open SYT reel screen
2. Observe first video loading
3. Watch console for buffering progress
4. Verify auto-play triggers when 15% buffered

**Expected Results**:
- ✅ Video starts buffering
- ✅ Auto-play triggers at ~15% buffered
- ✅ No premature playback
- ✅ Smooth transition to playback

**Pass/Fail**: ___

---

### Test 5: Video Caching

**Objective**: Verify video caching works

**Steps**:
1. Play first video (note load time)
2. Scroll to next video
3. Scroll back to first video
4. Observe load time (should be faster)
5. Check console for cache operations

**Expected Results**:
- ✅ First load: ~500-1000ms
- ✅ Cached load: ~100-200ms
- ✅ 5x faster on cached video
- ✅ No console errors

**Pass/Fail**: ___

---

### Test 6: Smooth Scrolling

**Objective**: Verify smooth scrolling with pre-loading

**Steps**:
1. Open SYT reel screen
2. Rapidly scroll through 5-10 videos
3. Observe smoothness
4. Check memory usage (should stay low)

**Expected Results**:
- ✅ Smooth scrolling (no stutters)
- ✅ Videos play immediately
- ✅ Memory usage stays low
- ✅ No crashes

**Pass/Fail**: ___

---

### Test 7: Memory Management

**Objective**: Verify memory cleanup works

**Steps**:
1. Open SYT reel screen
2. Scroll through 20+ videos
3. Monitor memory usage
4. Verify memory doesn't grow unbounded

**Expected Results**:
- ✅ Memory usage stays relatively constant
- ✅ No memory leaks
- ✅ Cleanup happens on scroll
- ✅ No crashes after long scrolling

**Pass/Fail**: ___

---

### Test 8: Pre-signed URLs (Wasabi)

**Objective**: Verify pre-signed URL support

**Prerequisite**: Have videos from Wasabi storage

**Steps**:
1. Navigate to Wasabi video
2. Observe playback
3. Check console for pre-signed URL handling
4. Verify video plays

**Expected Results**:
- ✅ Pre-signed URL fetched
- ✅ Video plays smoothly
- ✅ No access denied errors
- ✅ Console shows URL handling

**Pass/Fail**: ___

---

### Test 9: Page Transitions

**Objective**: Verify smooth page transitions

**Steps**:
1. Play first video
2. Scroll to next video
3. Observe transition
4. Verify previous video stops
5. Verify new video plays

**Expected Results**:
- ✅ Previous video stops immediately
- ✅ New video plays smoothly
- ✅ No audio overlap
- ✅ Smooth visual transition

**Pass/Fail**: ___

---

### Test 10: Background Music

**Objective**: Verify background music still works

**Steps**:
1. Open SYT reel screen
2. Verify background music plays
3. Scroll to next video
4. Verify music changes appropriately
5. Verify audio mixing works

**Expected Results**:
- ✅ Background music plays
- ✅ Music changes on scroll
- ✅ Audio mixing works
- ✅ No audio conflicts

**Pass/Fail**: ___

---

### Test 11: Voting/Interaction

**Objective**: Verify voting still works

**Steps**:
1. Open SYT reel screen
2. Vote on current video
3. Verify vote count increases
4. Scroll to next video
5. Verify vote state persists

**Expected Results**:
- ✅ Vote registers
- ✅ Vote count updates
- ✅ Vote state persists
- ✅ No errors

**Pass/Fail**: ___

---

### Test 12: Stats Loading

**Objective**: Verify stats load correctly

**Steps**:
1. Open SYT reel screen
2. Observe stats (likes, comments, etc.)
3. Scroll to next video
4. Verify stats load for new video
5. Scroll back to first video
6. Verify stats are still correct

**Expected Results**:
- ✅ Stats load correctly
- ✅ Stats update on scroll
- ✅ No stale data
- ✅ Accurate counts

**Pass/Fail**: ___

---

### Test 13: Error Handling

**Objective**: Verify graceful error handling

**Steps**:
1. Disable network connection
2. Try to play video
3. Observe error handling
4. Re-enable network
5. Verify recovery

**Expected Results**:
- ✅ No crashes
- ✅ Graceful error messages
- ✅ Recovery works
- ✅ Console shows errors

**Pass/Fail**: ___

---

### Test 14: Rapid Scrolling

**Objective**: Verify stability under rapid scrolling

**Steps**:
1. Open SYT reel screen
2. Rapidly scroll up and down
3. Continue for 30+ seconds
4. Monitor for crashes
5. Check memory usage

**Expected Results**:
- ✅ No crashes
- ✅ Smooth scrolling
- ✅ Memory stays low
- ✅ No console errors

**Pass/Fail**: ___

---

### Test 15: Long Session

**Objective**: Verify stability during long usage

**Steps**:
1. Open SYT reel screen
2. Use for 5+ minutes
3. Scroll through 50+ videos
4. Monitor memory usage
5. Check for memory leaks

**Expected Results**:
- ✅ No crashes
- ✅ Memory stays low
- ✅ Smooth performance
- ✅ No degradation

**Pass/Fail**: ___

---

## Performance Benchmarks

### Expected Performance Metrics

| Metric | Target | Acceptable | Poor |
|--------|--------|-----------|------|
| First Video Load | <500ms | <1000ms | >1000ms |
| Cached Video Load | <200ms | <500ms | >500ms |
| Buffering Threshold | 15% | 10-20% | >20% |
| Memory per Video | 5-10MB | 10-20MB | >20MB |
| Scroll FPS | 60 | 50+ | <50 |
| Auto-play Delay | <3s | <5s | >5s |

### Measurement Instructions

**Load Time**:
1. Note timestamp when video starts loading
2. Note timestamp when video starts playing
3. Calculate difference

**Memory Usage**:
1. Open Android Studio / Xcode profiler
2. Monitor memory during scrolling
3. Note peak and average usage

**Scroll FPS**:
1. Enable performance overlay in Flutter
2. Scroll through videos
3. Observe FPS counter

---

## Console Log Analysis

### Expected Log Patterns

**Successful Video Load**:
```
🎬 Video URL for SYT video 0: https://...
🎬 Using HLS URL: https://...m3u8
✅ Video initialized
```

**Buffering Detection**:
```
🎬 Video URL for SYT video 0: https://...
[buffering progress...]
✅ Video ready (15% buffered)
```

**Caching**:
```
🎬 Video URL for SYT video 0: https://...
[cache hit or network load]
✅ Video initialized
```

### Warning Signs

**Memory Issues**:
```
⚠️ Memory usage increasing
❌ Controller not disposed
```

**Buffering Issues**:
```
⚠️ Buffering stalled
❌ Network error
```

**Disposal Issues**:
```
⚠️ Screen disposed, skipping operation
❌ Accessing disposed controller
```

---

## Regression Testing

### Features to Verify Still Work

- [ ] Voting on entries
- [ ] Bookmarking entries
- [ ] Sharing entries
- [ ] Comments loading
- [ ] Gift sending
- [ ] Background music
- [ ] Stats loading
- [ ] User profiles
- [ ] Navigation

---

## Bug Report Template

If you find an issue, please report:

```
**Title**: [Brief description]

**Steps to Reproduce**:
1. [Step 1]
2. [Step 2]
3. [Step 3]

**Expected Result**:
[What should happen]

**Actual Result**:
[What actually happened]

**Console Logs**:
[Relevant console output]

**Device Info**:
- Device: [Model]
- OS: [Android/iOS version]
- Network: [WiFi/Mobile]

**Video Type**:
- [ ] HLS
- [ ] MP4
- [ ] Wasabi

**Reproducibility**:
- [ ] Always
- [ ] Sometimes
- [ ] Rarely
```

---

## Sign-Off

### Test Completion Checklist

- [ ] All 15 test cases completed
- [ ] All performance benchmarks met
- [ ] No critical bugs found
- [ ] No memory leaks detected
- [ ] Smooth scrolling verified
- [ ] HLS support verified
- [ ] Caching verified
- [ ] Error handling verified
- [ ] Regression tests passed
- [ ] Console logs reviewed

### Approval

**Tester Name**: _______________

**Date**: _______________

**Status**: 
- [ ] PASS - Ready for production
- [ ] PASS WITH NOTES - Ready with caveats
- [ ] FAIL - Issues found, needs fixes

**Notes**:
```
[Any additional notes or observations]
```

---

## Troubleshooting

### Video Won't Play

**Check**:
1. Is video URL valid?
2. Is network connection active?
3. Check console for errors
4. Try different video format

**Solution**:
- Verify URL is accessible
- Check network connectivity
- Review error logs
- Try MP4 if HLS fails

### Memory Issues

**Check**:
1. Are controllers being disposed?
2. Is cleanup happening?
3. Monitor memory growth

**Solution**:
- Force garbage collection
- Restart app
- Check for memory leaks
- Reduce cache size

### Buffering Problems

**Check**:
1. Network speed
2. Video file size
3. Buffering threshold
4. Device performance

**Solution**:
- Increase buffering threshold
- Use smaller video files
- Improve network
- Upgrade device

### Crashes

**Check**:
1. Console for exceptions
2. Memory usage
3. Disposal state
4. Network errors

**Solution**:
- Check error logs
- Monitor memory
- Verify disposal
- Test network

---

## Support

For issues or questions:
1. Review this testing guide
2. Check console logs
3. Verify test environment
4. Report using bug template
5. Contact development team
