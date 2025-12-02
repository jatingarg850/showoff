# Reel Audio Quick Fix

## Problem
Reels playing but no sound.

## Solution
1. Changed `mixWithOthers: false` to `mixWithOthers: true` in video player options
2. Added explicit `setVolume(1.0)` calls before every video play operation

## Quick Test

1. **Rebuild app:**
   ```bash
   cd apps
   flutter run
   ```

2. **Test audio:**
   - Open Reels tab
   - Play a video
   - Check if sound is playing
   - Adjust device volume to verify

## What Was Changed

**File:** `apps/lib/reel_screen.dart`

1. All video player controllers now use:
```dart
VideoPlayerOptions(
  mixWithOthers: true,  // ✅ Fixed - was false
  allowBackgroundPlayback: false,
)
```

2. Added `controller.setVolume(1.0)` before every play operation:
   - In `_onPageChanged` when switching reels
   - In video controller listener when auto-playing
   - In video controller listener when auto-resuming
   - In `_waitForFullLoad` when starting playback
   - In `_waitForFullLoad` timeout fallback

## Debug Console Output

Look for these messages when videos play:
```
🔊 Audio enabled for video 0 (volume: 1.0)
🔊 Setting volume to 1.0 for video 2
🔊 Auto-playing video 1 with volume 1.0
🔊 Auto-resuming video 2 with volume 1.0
🔊 Playing video 3 with volume 1.0
```

## If Audio Still Doesn't Work

1. **Check device volume** - Use volume buttons to increase
2. **Check video has audio** - Test with a known video with sound
3. **Restart app** - Close and reopen the app
4. **Clear cache:**
   ```bash
   flutter clean
   flutter pub get
   flutter run
   ```

## Common Issues

| Issue | Solution |
|-------|----------|
| Device muted | Unmute device and increase volume |
| Video has no audio | Upload a video with audio track |
| App needs restart | Close and reopen app |
| Cache issue | Run `flutter clean` |

## Success Indicators

✅ Sound plays when reel starts
✅ Volume buttons control audio
✅ Audio continues between reels
✅ Console shows "🔊 Audio enabled"

## Files Modified

- `apps/lib/reel_screen.dart` - Changed mixWithOthers to true (6 locations)

## Next Steps

If audio still doesn't work after this fix, check:
1. Video file actually has audio
2. Device audio settings
3. App permissions in device settings
4. Console logs for errors
