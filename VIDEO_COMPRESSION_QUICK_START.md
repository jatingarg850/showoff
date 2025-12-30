# Video Compression - Quick Start Guide

## Installation

1. **Update dependencies**:
```bash
cd apps
flutter pub get
```

2. **Rebuild the app**:
```bash
flutter clean
flutter pub get
flutter run
```

## Testing Video Compression

### Step 1: Record a Test Video
1. Open the app
2. Navigate to "Create" or "Upload Reel"
3. Record a video (any length, any resolution)
4. The app will automatically compress it

### Step 2: Monitor Compression
Watch the console logs for compression output:
```
🎬 Starting video compression...
  - Input: /path/to/original.mp4
  - Output: /path/to/compressed_uuid.mp4
  - FFmpeg command: ...
✅ Video compression successful!
  - Original size: 75.50 MB
  - Compressed size: 15.25 MB
  - Compression ratio: 79.8%
  - Output: /path/to/compressed_uuid.mp4
```

### Step 3: Upload and Verify
1. Add caption and music
2. Click "Upload"
3. Video uploads (should be much faster now)
4. Post is created successfully

### Step 4: Playback Test
1. View the reel in the feed
2. Video should play smoothly at 720p
3. No buffering or quality issues

## Expected Results

### File Size Reduction
- **Before**: 50-150 MB (1080p @ 30fps)
- **After**: 10-30 MB (720p @ 24fps)
- **Reduction**: 70-80% smaller

### Upload Speed
- **Before**: 2-5 minutes (large files)
- **After**: 20-60 seconds (compressed files)
- **Improvement**: 5-10x faster

### Playback Quality
- **Resolution**: 720p (1280x720)
- **Frame Rate**: 24fps (smooth for short-form video)
- **Audio**: 128kbps AAC (good quality)

## Troubleshooting

### Issue: Compression Takes Too Long
**Solution**: 
- Check device storage (needs ~2x video size for temp files)
- Reduce video length for testing
- Check device CPU usage

### Issue: Compression Fails Silently
**Solution**:
- Check console logs for error messages
- Verify video file is not corrupted
- Try with a different video
- Original video will be uploaded as fallback

### Issue: Compressed Video Quality Is Poor
**Solution**:
- This is normal for 720p @ 24fps
- Quality is optimized for mobile viewing
- Adjust CRF in compression service if needed (lower = better)

### Issue: App Crashes During Compression
**Solution**:
- Ensure FFmpeg is properly installed
- Check device has enough RAM
- Try with shorter video
- Check logcat for detailed error

## Console Log Examples

### Successful Compression
```
🎬 Starting video compression...
  - Input: /data/user/0/com.showofflife.app/cache/video_12345.mp4
  - Output: /data/user/0/com.showofflife.app/cache/compressed_abc123.mp4
  - FFmpeg command: -i "/data/user/0/com.showofflife.app/cache/video_12345.mp4" -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2" -r 24 -c:v libx264 -preset fast -crf 28 -c:a aac -b:a 128k "/data/user/0/com.showofflife.app/cache/compressed_abc123.mp4"
✅ Video compression successful!
  - Original size: 85.50 MB
  - Compressed size: 18.25 MB
  - Compression ratio: 78.6%
  - Output: /data/user/0/com.showofflife.app/cache/compressed_abc123.mp4
```

### Compression Failure (Falls Back to Original)
```
🎬 Starting video compression...
  - Input: /data/user/0/com.showofflife.app/cache/video_12345.mp4
  - Output: /data/user/0/com.showofflife.app/cache/compressed_abc123.mp4
❌ FFmpeg compression failed
  - Return code: 1
  - Error: [error message]
⚠️ Video compression failed: [error]
  - Uploading original video
```

## Performance Metrics

### Compression Time
- **Short video (30 sec)**: 10-20 seconds
- **Medium video (1 min)**: 20-40 seconds
- **Long video (2 min)**: 40-80 seconds

### Upload Time (After Compression)
- **Compressed 720p**: 20-60 seconds
- **Original 1080p**: 2-5 minutes
- **Improvement**: 5-10x faster

### Storage Savings
- **Per video**: 60-80 MB saved
- **100 videos**: 6-8 GB saved
- **1000 videos**: 60-80 GB saved

## Advanced Configuration

### Adjust Compression Quality

Edit `apps/lib/services/video_compression_service.dart`:

```dart
// Change CRF value (0-51, lower = better quality, slower)
// Current: 28 (good balance)
// Lower quality (faster): 32-35
// Higher quality (slower): 20-25

// Change preset (ultrafast, superfast, veryfast, faster, fast, medium, slow, slower, veryslow)
// Current: fast (good balance)
// Faster: veryfast, faster
// Better quality: medium, slow
```

### Adjust Resolution

Edit the FFmpeg command in `compressVideo()`:

```dart
// Current: 1280:720 (720p)
// For 480p: 854:480
// For 1080p: 1920:1080
// For 360p: 640:360
```

### Adjust Frame Rate

Edit the FFmpeg command:

```dart
// Current: -r 24 (24fps)
// For 30fps: -r 30
// For 15fps: -r 15
// For 60fps: -r 60
```

## Testing Checklist

- [ ] Dependencies installed (`flutter pub get`)
- [ ] App builds without errors
- [ ] Can record video
- [ ] Compression starts automatically
- [ ] Console shows compression stats
- [ ] Compressed file is smaller
- [ ] Upload completes successfully
- [ ] Video plays in reel feed
- [ ] Playback is smooth (no stuttering)
- [ ] Audio is clear
- [ ] No crashes during compression
- [ ] Works with different video lengths
- [ ] Works with different aspect ratios

## Next Steps

1. Test with various video sizes
2. Monitor upload speeds
3. Gather user feedback on quality
4. Adjust compression settings if needed
5. Consider adding UI progress indicator
6. Monitor server storage usage

## Support

If you encounter issues:
1. Check console logs for error messages
2. Verify FFmpeg is installed
3. Check device storage space
4. Try with a different video
5. Check device RAM availability
