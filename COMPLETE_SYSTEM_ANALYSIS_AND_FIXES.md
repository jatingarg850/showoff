# Complete Video Upload & Playback System - Analysis & Fixes

## Executive Summary

**Current State**: Videos upload as MP4, music is stored separately, HLS doesn't work, audio/video are out of sync.

**Root Cause**: The system was designed to upload raw MP4 files, but HLS implementation was added without:
1. Converting videos to HLS format
2. Merging audio with video
3. Synchronizing playback
4. Generating HLS playlists on server

**Solution**: Implement proper HLS pipeline with audio merging and sync.

---

## CRITICAL ISSUES (Must Fix)

### 1. **HLS Not Being Generated** ❌

**Problem**: Videos upload as MP4, but app tries to load them as HLS (`.m3u8`)

**Current Code** (reel_screen.dart, line 1006):
```dart
String _getHlsUrl(String videoUrl) {
  final baseUrl = videoUrl.replaceAll(RegExp(r'\.[^.]+$'), '');
  return '$baseUrl.m3u8';  // ❌ This URL doesn't exist!
}
```

**Why It Fails**:
- Server stores: `https://wasabisys.com/videos/reel.mp4`
- App requests: `https://wasabisys.com/videos/reel.m3u8` → **404 Not Found**
- Video never loads

**Fix**: Don't try to convert URLs. Instead, generate HLS on upload.

---

### 2. **Audio Not Merged with Video** 🔇

**Problem**: Background music is stored as metadata, not embedded in video

**Current Flow**:
1. User selects music (ID stored)
2. Video uploaded as MP4 (no audio)
3. Server stores: `Post { mediaUrl: "video.mp4", backgroundMusic: "music-id" }`
4. On playback: App loads video + loads music separately

**Result**: Music and video are out of sync or don't play together

**Fix**: Merge audio with video BEFORE uploading

---

### 3. **Music Playback Out of Sync** 🎵

**Problem**: Music loads asynchronously after video starts

**Current Code** (reel_screen.dart, line 800):
```dart
void _loadMusicForReel(int index) {
  _musicLoadTimer?.cancel();
  _musicLoadTimer = Timer(const Duration(milliseconds: 200), () {
    _playBackgroundMusicForReel(index);  // ← Loads 200ms AFTER page change
  });
}
```

**Result**: Video plays, then music starts 200ms later (noticeable delay)

**Fix**: Embed audio in video so it plays automatically

---

## IMPLEMENTATION PLAN

### Phase 1: Server-Side HLS Generation (CRITICAL)

**Goal**: Generate HLS playlists when videos are uploaded

**Steps**:
1. Install FFmpeg on server
2. Create HLS generation service
3. Update upload endpoint to generate HLS
4. Store HLS files in Wasabi

**Files to Create/Modify**:
- `server/services/hlsService.js` (NEW)
- `server/controllers/postController.js` (MODIFY)
- `server/controllers/sytController.js` (MODIFY)

---

### Phase 2: Audio-Video Merging (CRITICAL)

**Goal**: Merge background music with video before upload

**Steps**:
1. Create audio merge service on server
2. Extract audio from music file
3. Merge with video using FFmpeg
4. Generate HLS from merged video

**Files to Create/Modify**:
- `server/services/audioMergeService.js` (NEW)
- `server/controllers/postController.js` (MODIFY)

---

### Phase 3: Client-Side Updates (HIGH)

**Goal**: Use HLS URLs instead of trying to convert them

**Steps**:
1. Remove HLS URL conversion logic
2. Use mediaUrl directly (will be HLS URL from server)
3. Remove async music loading (audio is embedded)
4. Update playback logic

**Files to Modify**:
- `apps/lib/reel_screen.dart`
- `apps/lib/syt_reel_screen.dart`
- `apps/lib/preview_screen.dart`

---

## DETAILED FIXES

### Fix 1: Remove Broken HLS URL Conversion

**File**: `apps/lib/reel_screen.dart`

**Current Code** (line 1006):
```dart
String _getHlsUrl(String videoUrl) {
  if (videoUrl.endsWith('.m3u8')) {
    return videoUrl;
  }
  final baseUrl = videoUrl.replaceAll(RegExp(r'\.[^.]+$'), '');
  return '$baseUrl.m3u8';  // ❌ BROKEN
}
```

**Fixed Code**:
```dart
String _getVideoUrl(String videoUrl) {
  // Server now returns HLS URLs directly
  // No conversion needed
  return videoUrl;
}
```

**Usage** (line 1050):
```dart
// BEFORE
final hlsUrl = _getHlsUrl(videoUrl);
final controller = VideoPlayerController.networkUrl(Uri.parse(hlsUrl));

// AFTER
final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
```

---

### Fix 2: Remove Async Music Loading

**File**: `apps/lib/reel_screen.dart`

**Current Code** (line 800):
```dart
void _loadMusicForReel(int index) {
  _musicLoadTimer?.cancel();
  _musicLoadTimer = Timer(const Duration(milliseconds: 200), () {
    _playBackgroundMusicForReel(index);  // ← Async load
  });
}
```

**Fixed Code**:
```dart
void _loadMusicForReel(int index) {
  // Music is now embedded in video, no need to load separately
  // This method can be removed or kept for legacy support
  debugPrint('🎵 Music is embedded in video, no separate loading needed');
}
```

---

### Fix 3: Update Preview Screen Upload

**File**: `apps/lib/preview_screen.dart`

**Current Code** (line 753):
```dart
mediaUrl = await wasabiService.uploadVideo(fileToUpload);
```

**Fixed Code**:
```dart
// Server will handle HLS generation and audio merging
// Just upload the video file
mediaUrl = await wasabiService.uploadVideo(fileToUpload);
// mediaUrl will now be HLS URL returned by server
```

---

## SERVER-SIDE IMPLEMENTATION

### Create HLS Service

**File**: `server/services/hlsService.js`

```javascript
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs').promises;
const { v4: uuidv4 } = require('uuid');

class HLSService {
  static async generateHLS(videoPath, outputDir) {
    return new Promise((resolve, reject) => {
      const playlistPath = path.join(outputDir, 'playlist.m3u8');
      const segmentPattern = path.join(outputDir, 'segment_%03d.ts');

      ffmpeg(videoPath)
        .output(playlistPath)
        .outputOptions([
          '-hls_time 10',
          '-hls_list_size 0',
          '-hls_segment_filename',
          segmentPattern
        ])
        .on('end', () => {
          console.log('✅ HLS generated:', playlistPath);
          resolve(playlistPath);
        })
        .on('error', reject)
        .run();
    });
  }

  static async uploadHLSToWasabi(hlsDir, wasabiService, basePath) {
    // Upload all .m3u8 and .ts files to Wasabi
    const files = await fs.readdir(hlsDir);
    const uploadedFiles = [];

    for (const file of files) {
      if (file.endsWith('.m3u8') || file.endsWith('.ts')) {
        const filePath = path.join(hlsDir, file);
        const s3Key = `${basePath}/${file}`;
        // Upload to Wasabi
        uploadedFiles.push(s3Key);
      }
    }

    return uploadedFiles;
  }
}

module.exports = HLSService;
```

---

## MIGRATION STRATEGY

### For Existing Videos (MP4):

1. **Option A**: Keep playing as MP4 (no conversion needed)
   - Update reel_screen to detect MP4 URLs
   - Play directly without HLS conversion

2. **Option B**: Convert on-demand
   - Create endpoint to convert MP4 to HLS
   - Cache converted files
   - Serve HLS URLs

### For New Videos:

1. Generate HLS on upload
2. Store HLS URL in database
3. Play HLS directly

---

## TESTING CHECKLIST

- [ ] Upload video with background music
- [ ] Verify HLS playlist is generated
- [ ] Verify audio is merged with video
- [ ] Play video in reel screen
- [ ] Verify audio plays with video (synced)
- [ ] Verify music doesn't load separately
- [ ] Test on different network speeds
- [ ] Verify adaptive bitrate switching
- [ ] Test SYT video upload
- [ ] Test regular post upload

---

## TIMELINE

**Phase 1 (Server HLS)**: 2-3 hours
**Phase 2 (Audio Merge)**: 2-3 hours
**Phase 3 (Client Updates)**: 1-2 hours
**Testing**: 1-2 hours

**Total**: ~8-10 hours

---

## RISKS & MITIGATION

| Risk | Mitigation |
|------|-----------|
| FFmpeg not installed on server | Install before deployment |
| HLS generation takes too long | Run in background job queue |
| Audio merge fails | Fall back to video-only upload |
| Existing MP4 videos break | Support both MP4 and HLS |
| Storage space increases | Implement cleanup for old files |

---

## NEXT STEPS

1. **Immediate**: Fix reel_screen to not try HLS conversion
2. **Short-term**: Implement server-side HLS generation
3. **Medium-term**: Implement audio merging
4. **Long-term**: Optimize for different network speeds

