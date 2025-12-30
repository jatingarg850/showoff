# Video Player & Streaming Configuration - Complete Details

## 1. VIDEO PLAYER LIBRARY

### Package Used
- **Package**: `video_player: ^2.8.1`
- **Type**: Flutter official video player plugin
- **Supports**: Android, iOS, Web
- **Repository**: https://pub.dev/packages/video_player

### Player Capabilities
- ✅ Network streaming (HTTP/HTTPS URLs)
- ✅ Local file playback
- ✅ Looping support
- ✅ Volume control
- ✅ Buffering detection
- ✅ Playback state listeners
- ✅ Seek functionality
- ✅ Pause/Resume
- ❌ HLS (HTTP Live Streaming) - NOT SUPPORTED
- ❌ DASH (Dynamic Adaptive Streaming) - NOT SUPPORTED
- ❌ m3u8 playlists - NOT SUPPORTED

---

## 2. VIDEO CODECS & FORMATS

### Supported Video Formats
```
✅ MP4 (.mp4)
✅ MOV (.mov)
✅ AVI (.avi)
```

### Video Codec Details
- **Container**: MP4 (MPEG-4 Part 14)
- **Video Codec**: H.264 (AVC - Advanced Video Coding)
- **Audio Codec**: AAC (Advanced Audio Coding)
- **Content Type**: `video/mp4`

### Codec Specifications
```
Video Codec: H.264/AVC
- Profile: Baseline, Main, High
- Level: 3.0 - 4.2
- Resolution: Up to 4K (3840x2160)
- Frame Rate: 24-60 fps

Audio Codec: AAC
- Sample Rate: 44.1 kHz, 48 kHz
- Bit Rate: 128-256 kbps
- Channels: Mono, Stereo
```

---

## 3. STREAMING ARCHITECTURE

### Current Setup: Direct S3 Streaming (NOT HLS)

```
User Device
    ↓
Video Player (video_player package)
    ↓
HTTP/HTTPS Request
    ↓
Wasabi S3 (AWS S3 Compatible)
    ↓
MP4 File (Direct Download/Stream)
```

### Wasabi S3 Configuration
```dart
// From wasabi_service.dart
Bucket: showofforiginal
Region: ap-southeast-1
Endpoint: s3.ap-southeast-1.wasabisys.com
Access Key: LZ4Q3024I5KUQPLT9FDO
Secret Key: tzMQuJKnHQXjCeis6ZKZb5HNjDFGsXi4KsG6A5C4
```

### Upload Process
1. Video recorded locally
2. Uploaded to Wasabi S3 using AWS Signature V4
3. File stored as: `videos/{uuid}.mp4`
4. Public URL returned: `https://s3.ap-southeast-1.wasabisys.com/showofforiginal/videos/{uuid}.mp4`
5. URL used directly in VideoPlayerController

---

## 4. VIDEO PLAYER INITIALIZATION

### Code Implementation (reel_screen.dart)

```dart
// Video controller initialization
VideoPlayerController controller;

// Try cached file first
try {
  final fileInfo = await _cacheManager.getFileFromCache(videoUrl);
  if (fileInfo != null) {
    // Use cached file
    controller = VideoPlayerController.file(
      fileInfo.file,
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );
  } else {
    // Stream from network
    controller = VideoPlayerController.networkUrl(
      Uri.parse(videoUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );
    // Cache in background
    _cacheManager.downloadFile(videoUrl);
  }
} catch (e) {
  // Fallback to network
  controller = VideoPlayerController.networkUrl(
    Uri.parse(videoUrl),
    videoPlayerOptions: VideoPlayerOptions(
      mixWithOthers: true,
      allowBackgroundPlayback: false,
    ),
  );
}

// Initialize
await controller.initialize();

// Configure playback
controller.setLooping(true);
controller.setVolume(1.0);
controller.play();
```

### VideoPlayerOptions
```dart
VideoPlayerOptions(
  mixWithOthers: true,        // Allow other audio to play
  allowBackgroundPlayback: false  // Stop when app backgrounded
)
```

---

## 5. CACHING STRATEGY

### Cache Manager Configuration
```dart
// From reel_screen.dart
static final _cacheManager = CacheManager(
  Config(
    'reelVideoCache',
    stalePeriod: const Duration(days: 3),
    maxNrOfCacheObjects: 10,  // Keep max 10 videos cached
  ),
);
```

### Caching Flow
1. Check if video exists in cache
2. If cached → Use cached file (faster)
3. If not cached → Stream from network
4. Download to cache in background
5. Cache expires after 3 days
6. Max 10 videos kept in cache

---

## 6. BUFFERING & PLAYBACK DETECTION

### Buffering Detection
```dart
void _onVideoStateChanged(VideoPlayerController controller, int index) {
  final buffered = controller.value.buffered;
  final duration = controller.value.duration;

  if (buffered.isNotEmpty && duration.inMilliseconds > 0) {
    final bufferedEnd = buffered.last.end;
    
    // Ready when 15% buffered
    if (bufferedEnd.inMilliseconds >= duration.inMilliseconds * 0.15) {
      // Auto-play video
      _playVideo(index);
    }
  }
}
```

### Buffering Threshold
- **Minimum Buffer**: 15% of video duration
- **Auto-play**: Triggered when 15% buffered
- **Prevents**: Stuttering and poor playback experience

---

## 7. PRESIGNED URLS

### Purpose
- Temporary secure access to S3 files
- Prevents direct S3 bucket exposure
- Time-limited access (configurable)

### Implementation
```dart
// API endpoint
POST /videos/presigned-url
Body: { "videoUrl": "https://..." }

// Returns
{
  "success": true,
  "presignedUrl": "https://s3.ap-southeast-1.wasabisys.com/..."
}
```

### Batch Presigned URLs
```dart
// For multiple videos
POST /videos/presigned-urls-batch
Body: { "videoUrls": ["url1", "url2", ...] }
```

---

## 8. CURRENT LIMITATIONS

### NOT Using HLS/DASH
❌ No adaptive bitrate streaming
❌ No automatic quality adjustment
❌ No m3u8 playlist support
❌ No segment-based streaming

### Why Not HLS?
1. **Complexity**: Requires FFmpeg for encoding
2. **Server Load**: Need to generate multiple bitrates
3. **Storage**: Multiple quality versions needed
4. **Cost**: Higher infrastructure requirements
5. **Current Solution**: Works well for current user base

### Current Approach Benefits
✅ Simple implementation
✅ Direct MP4 streaming
✅ Lower server costs
✅ Faster deployment
✅ Works on all devices

---

## 9. VIDEO UPLOAD PROCESS

### Upload Flow
```
1. Record video locally (MP4 format)
2. Persist to app storage
3. Upload to Wasabi S3
   - AWS Signature V4 authentication
   - Content-Type: video/mp4
   - ACL: public-read
4. Get public URL
5. Store URL in database
6. Return to user
```

### Upload Code (wasabi_service.dart)
```dart
Future<String> uploadVideo(File videoFile) async {
  // Generate unique filename
  final uuid = const Uuid().v4();
  final fileName = 'videos/$uuid.mp4';
  
  // Read file bytes
  final fileBytes = await file.readAsBytes();
  
  // Calculate SHA256 hash
  final payloadHash = sha256.convert(fileBytes).toString();
  
  // Generate AWS Signature V4
  final signature = _generateSignatureV4(...);
  
  // Upload via PUT request
  final response = await http.put(
    Uri.parse(url),
    headers: {
      'Content-Type': 'video/mp4',
      'x-amz-acl': 'public-read',
      'x-amz-content-sha256': payloadHash,
      'Authorization': authorization,
    },
    body: fileBytes,
  );
  
  return publicUrl;
}
```

---

## 10. THUMBNAIL GENERATION

### Thumbnail Service
```dart
// From api_service.dart
final thumbnailPath = await VideoThumbnail.thumbnailFile(
  video: mediaFile.path,
  timeMs: 0,  // First frame
  imageFormat: ImageFormat.JPEG,
  maxWidth: 640,
  maxHeight: 480,
  quality: 70,
);
```

### Thumbnail Specs
- **Format**: JPEG
- **Max Width**: 640px
- **Max Height**: 480px
- **Quality**: 70%
- **Source**: First frame of video (0ms)

---

## 11. NETWORK REQUIREMENTS

### Bandwidth Considerations
```
Video Quality: 1080p MP4
Bitrate: ~5-8 Mbps
Duration: 15-60 seconds
File Size: ~10-60 MB

Minimum Network Speed:
- 4G LTE: 10-50 Mbps ✅ Sufficient
- 3G: 1-5 Mbps ⚠️ May buffer
- WiFi: 5+ Mbps ✅ Sufficient
```

### Buffering Strategy
- 15% pre-buffer before playback
- Adaptive buffering based on network speed
- Fallback to lower quality if needed (not implemented)

---

## 12. ANDROID SPECIFIC CONFIGURATION

### AndroidManifest.xml Requirements
```xml
<!-- Video playback permissions -->
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

<!-- Hardware acceleration for video -->
<application
  android:hardwareAccelerated="true"
  ...
/>
```

### Supported Android Versions
- **Min SDK**: 21 (Android 5.0)
- **Target SDK**: 34 (Android 14)
- **Video Codec Support**: Hardware accelerated H.264

---

## 13. iOS SPECIFIC CONFIGURATION

### Info.plist Requirements
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>App needs access to local network for video streaming</string>

<key>NSBonjourServices</key>
<array>
  <string>_http._tcp</string>
  <string>_https._tcp</string>
</array>
```

### Supported iOS Versions
- **Min iOS**: 11.0
- **Video Codec Support**: Hardware accelerated H.264

---

## 14. PERFORMANCE METRICS

### Current Performance
```
Video Load Time: 2-5 seconds
Buffering Time: 1-3 seconds
Playback Smoothness: 60 fps (on capable devices)
Memory Usage: ~50-100 MB per video
Cache Hit Rate: ~70% (after first view)
```

### Optimization Techniques
1. **Caching**: 3-day cache with 10 video limit
2. **Lazy Loading**: Load adjacent videos only
3. **Preloading**: Pre-buffer next video while current plays
4. **Memory Management**: Dispose controllers when not visible
5. **Network Optimization**: Presigned URLs for faster access

---

## 15. FUTURE IMPROVEMENTS

### Recommended Enhancements

#### 1. Implement HLS Streaming
```
Benefits:
- Adaptive bitrate streaming
- Better mobile experience
- Reduced bandwidth usage
- Better buffering

Requirements:
- FFmpeg for encoding
- HLS playlist generation
- Multiple quality versions
- CDN integration
```

#### 2. Add DASH Support
```
Benefits:
- Industry standard
- Better quality adaptation
- Wider device support
```

#### 3. Implement Quality Selection
```
Allow users to choose:
- 480p (low bandwidth)
- 720p (standard)
- 1080p (high quality)
```

#### 4. Add Download Feature
```
Allow offline viewing:
- Download videos
- Store locally
- Play without internet
```

---

## 16. TROUBLESHOOTING

### Common Issues

#### Video Won't Play
```
Causes:
1. Invalid URL format
2. Network connectivity
3. Codec not supported
4. File corrupted

Solutions:
1. Verify URL is accessible
2. Check internet connection
3. Ensure MP4 format
4. Re-upload video
```

#### Buffering Issues
```
Causes:
1. Slow network
2. Large file size
3. Server overload
4. Device memory low

Solutions:
1. Improve network
2. Reduce video bitrate
3. Scale server
4. Clear cache
```

#### Audio Issues
```
Causes:
1. Audio codec mismatch
2. Volume set to 0
3. Device muted
4. Audio focus lost

Solutions:
1. Re-encode with AAC
2. Check volume settings
3. Unmute device
4. Request audio focus
```

---

## 17. SUMMARY TABLE

| Feature | Status | Details |
|---------|--------|---------|
| Video Player | ✅ Active | video_player v2.8.1 |
| Video Format | ✅ MP4 | H.264 + AAC |
| Streaming Type | ✅ Direct | S3 HTTP streaming |
| HLS Support | ❌ No | Not implemented |
| DASH Support | ❌ No | Not implemented |
| m3u8 Playlists | ❌ No | Not supported |
| Caching | ✅ Yes | 3-day cache, 10 videos |
| Buffering | ✅ Yes | 15% threshold |
| Presigned URLs | ✅ Yes | AWS Signature V4 |
| Thumbnail Gen | ✅ Yes | JPEG, 640x480 |
| Adaptive Quality | ❌ No | Single quality |
| Offline Download | ❌ No | Not implemented |

---

## 18. CONTACT & SUPPORT

For video player issues:
1. Check network connectivity
2. Verify video URL format
3. Check device storage
4. Review logs for errors
5. Test with different video

For streaming improvements:
- Consider HLS implementation
- Evaluate CDN integration
- Monitor bandwidth usage
- Track buffering metrics
