# Video-Audio Merge Implementation - Complete Guide

## Overview
When users upload a video with background music selected, the system now automatically merges the video and audio into a single MP4 file before uploading. This ensures the background music is permanently embedded in the video file.

## What Changed

### 1. New Service: VideoAudioMergeService
**File**: `apps/lib/services/video_audio_merge_service.dart`

A new service that handles video-audio merging using FFmpeg:

```dart
// Merge video with audio file
Future<String> mergeVideoWithAudio({
  required String videoPath,
  required String audioPath,
  String? outputFileName,
})

// Merge video with audio from URL (downloads audio first)
Future<String> mergeVideoWithAudioUrl({
  required String videoPath,
  required String audioUrl,
  String? outputFileName,
})
```

**Key Features**:
- Uses FFmpeg for fast, efficient merging
- Copies video codec (no re-encoding) for speed
- Encodes audio as AAC for compatibility
- Uses shortest stream length to avoid mismatches
- Automatically downloads audio from URL
- Cleans up temporary files

### 2. Updated Dependencies
**File**: `apps/pubspec.yaml`

Added:
```yaml
flutter_ffmpeg: ^0.4.1
```

### 3. Updated Preview Screen
**File**: `apps/lib/preview_screen.dart`

#### Changes:
1. **Import**: Added `import 'services/video_audio_merge_service.dart'`

2. **Regular Post Upload** (lines 625-730):
   - Before uploading video, checks if background music is selected
   - If music exists, fetches music details from API
   - Downloads audio from music URL
   - Merges video with audio using FFmpeg
   - Uploads merged video file instead of original
   - Falls back to original video if merge fails

3. **SYT Entry Upload** (lines 570-620):
   - Same merge logic applied to SYT competition entries
   - Ensures SYT videos also have embedded background music

## How It Works

### Flow Diagram
```
User clicks Upload
    ↓
Check if video + background music selected
    ↓
YES → Fetch music details from API
    ↓
Download audio file from music URL
    ↓
Merge video + audio using FFmpeg
    ↓
Upload merged MP4 file
    ↓
Create post with merged video URL
    ↓
Clean up temporary files
    ↓
Success!

NO → Upload original video
    ↓
Create post
    ↓
Success!
```

### FFmpeg Command Used
```
-i "video.mp4" -i "audio.mp3" -c:v copy -c:a aac -shortest "output.mp4"
```

**Explanation**:
- `-i "video.mp4"` - Input video file
- `-i "audio.mp3"` - Input audio file
- `-c:v copy` - Copy video codec (no re-encoding, fast)
- `-c:a aac` - Encode audio as AAC (compatible)
- `-shortest` - Use shortest stream length
- `"output.mp4"` - Output merged file

## Benefits

✅ **Single File Upload** - No separate audio/video files
✅ **Permanent Embedding** - Music is part of the video file
✅ **Automatic Playback** - Music plays automatically when viewing reel
✅ **No Sync Issues** - Audio and video are perfectly synced
✅ **Fast Processing** - Video codec copied (not re-encoded)
✅ **Fallback Support** - Works without music if merge fails
✅ **Clean Temporary Files** - Automatic cleanup of temp audio files

## Error Handling

The system gracefully handles errors:

1. **Music fetch fails** → Upload video without music
2. **Audio download fails** → Upload original video
3. **FFmpeg merge fails** → Upload original video
4. **File not found** → Clear error message to user

All errors are logged but don't block the upload process.

## Testing Checklist

- [ ] Upload video with background music selected
- [ ] Verify merged file is created in temp directory
- [ ] Verify merged file is uploaded to Wasabi
- [ ] Verify post is created with merged video URL
- [ ] Play reel and verify music plays automatically
- [ ] Upload video without background music (should work normally)
- [ ] Test with different music files
- [ ] Test with different video formats
- [ ] Verify temporary files are cleaned up
- [ ] Test SYT entry upload with music
- [ ] Test error scenarios (network failure, etc.)

## Console Output Examples

### Successful Merge
```
🎬 Merging video with background music...
🎵 Audio URL: http://...
🎬 Starting video-audio merge...
  - Video: /path/to/video.mp4
  - Audio: /path/to/audio.mp3
  - Output: /tmp/merged_1234567890.mp4
🎬 Running FFmpeg command: -i "/path/to/video.mp4" -i "/path/to/audio.mp3" -c:v copy -c:a aac -shortest "/tmp/merged_1234567890.mp4"
✅ Video-audio merge completed successfully
  - Output file: /tmp/merged_1234567890.mp4
  - File size: 45.23 MB
✅ Video merged successfully
  - Merged file: /tmp/merged_1234567890.mp4
📤 Creating post with:
  - mediaUrl: https://wasabi.../merged_video.mp4
  - mediaType: video
  - musicId: null (already embedded)
```

### Error Handling
```
⚠️ Error merging video with audio: [error details]
  - Continuing with original video
📤 Creating post with:
  - mediaUrl: https://wasabi.../original_video.mp4
  - mediaType: video
```

## Files Modified

1. **apps/lib/services/video_audio_merge_service.dart** (NEW)
   - Complete video-audio merge service

2. **apps/lib/preview_screen.dart**
   - Added import for VideoAudioMergeService
   - Updated regular post upload logic
   - Updated SYT entry upload logic

3. **apps/pubspec.yaml**
   - Added flutter_ffmpeg dependency

## Important Notes

1. **FFmpeg Installation**: flutter_ffmpeg automatically includes FFmpeg binaries for Android and iOS
2. **File Size**: Merged files may be slightly larger than original video (audio added)
3. **Processing Time**: Merging adds 5-30 seconds depending on video length
4. **Temporary Storage**: Requires temporary directory space for audio download and merge
5. **Network**: Audio download requires internet connection
6. **Fallback**: If merge fails, original video is uploaded (no music embedded)

## Future Enhancements

- [ ] Add progress indicator for merge operation
- [ ] Support for multiple audio tracks
- [ ] Audio volume adjustment before merge
- [ ] Video quality optimization during merge
- [ ] Batch merge for multiple videos
- [ ] Merge cancellation support
