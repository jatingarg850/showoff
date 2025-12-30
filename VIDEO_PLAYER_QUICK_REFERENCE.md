# Video Player Quick Reference

## TL;DR - What We're Using

### Video Player
- **Package**: `video_player: ^2.8.1` (Flutter official)
- **Type**: Direct MP4 streaming (NOT HLS/DASH)
- **Streaming**: HTTP/HTTPS from Wasabi S3

### Video Format
- **Container**: MP4
- **Video Codec**: H.264 (AVC)
- **Audio Codec**: AAC
- **Supported Formats**: .mp4, .mov, .avi

### Streaming Method
```
NOT using HLS or m3u8 files
NOT using DASH
NOT using adaptive bitrate

USING: Direct MP4 download/streaming from S3
```

---

## Key Components

### 1. Video Player Library
```dart
import 'package:video_player/video_player.dart';

// Network streaming
VideoPlayerController.networkUrl(Uri.parse(url))

// Local file
VideoPlayerController.file(file)
```

### 2. Storage
- **Wasabi S3** (AWS S3 compatible)
- **Bucket**: showofforiginal
- **Region**: ap-southeast-1
- **Upload**: AWS Signature V4

### 3. Caching
- **Cache Manager**: flutter_cache_manager
- **Cache Duration**: 3 days
- **Max Videos**: 10 cached
- **Strategy**: Check cache first, then network

### 4. Buffering
- **Threshold**: 15% of video duration
- **Auto-play**: When 15% buffered
- **Prevents**: Stuttering and poor UX

---

## Video Upload Flow

```
1. Record video → MP4 file
2. Persist locally
3. Upload to Wasabi S3
4. Get public URL
5. Store URL in database
6. Stream to users
```

---

## Video Playback Flow

```
1. Load video URL from database
2. Check if cached
   ✓ If cached → Use cached file
   ✗ If not → Stream from S3
3. Initialize VideoPlayerController
4. Wait for 15% buffered
5. Auto-play video
6. Cache in background
```

---

## Codec Details

### H.264 Video
- Profile: Baseline, Main, High
- Level: 3.0 - 4.2
- Resolution: Up to 4K
- Frame Rate: 24-60 fps

### AAC Audio
- Sample Rate: 44.1 kHz, 48 kHz
- Bit Rate: 128-256 kbps
- Channels: Mono, Stereo

---

## Performance

| Metric | Value |
|--------|-------|
| Load Time | 2-5 sec |
| Buffer Time | 1-3 sec |
| Smoothness | 60 fps |
| Memory | 50-100 MB |
| Cache Hit | ~70% |

---

## Limitations

❌ **NOT Supported**
- HLS streaming
- DASH streaming
- m3u8 playlists
- Adaptive bitrate
- Quality selection
- Offline download

✅ **Supported**
- Direct MP4 streaming
- Local file playback
- Caching
- Looping
- Volume control
- Pause/Resume

---

## Why Not HLS?

1. **Complexity**: Requires FFmpeg encoding
2. **Cost**: Multiple quality versions needed
3. **Storage**: Higher storage requirements
4. **Current**: Works well for current scale

---

## Network Requirements

```
Minimum Speed:
- 4G LTE: 10-50 Mbps ✅
- 3G: 1-5 Mbps ⚠️
- WiFi: 5+ Mbps ✅

Video Bitrate: 5-8 Mbps
File Size: 10-60 MB (15-60 sec video)
```

---

## Common Issues & Fixes

### Video Won't Play
- Check URL is accessible
- Verify internet connection
- Ensure MP4 format
- Check file not corrupted

### Buffering Issues
- Improve network speed
- Reduce video bitrate
- Clear cache
- Check device memory

### Audio Issues
- Verify AAC codec
- Check volume not muted
- Ensure audio focus
- Re-encode if needed

---

## File Locations

### Video Player Code
- `apps/lib/reel_screen.dart` - Main player
- `apps/lib/syt_reel_screen.dart` - SYT player
- `apps/lib/preview_screen.dart` - Preview player

### Storage Service
- `apps/lib/services/wasabi_service.dart` - S3 upload
- `apps/lib/services/api_service.dart` - API calls

### Configuration
- `apps/pubspec.yaml` - Dependencies
- `apps/android/app/src/main/AndroidManifest.xml` - Android config

---

## Dependencies

```yaml
video_player: ^2.8.1          # Video playback
flutter_cache_manager: ^3.3.1 # Caching
video_thumbnail: ^0.5.3       # Thumbnail generation
http: ^1.1.0                  # HTTP requests
crypto: ^3.0.3                # AWS Signature V4
```

---

## Future Roadmap

### Phase 1: Current
- Direct MP4 streaming ✅
- Basic caching ✅
- Thumbnail generation ✅

### Phase 2: Recommended
- Implement HLS streaming
- Add quality selection
- Improve buffering

### Phase 3: Advanced
- DASH support
- Offline download
- Advanced analytics

---

## Quick Commands

### Check Video Format
```bash
ffprobe -v error -select_streams v:0 -show_entries stream=codec_name,width,height,r_frame_rate -of default=noprint_wrappers=1:nokey=1:nokey=1 video.mp4
```

### Convert to MP4
```bash
ffmpeg -i input.mov -c:v libx264 -c:a aac output.mp4
```

### Check Wasabi Upload
```bash
curl -I https://s3.ap-southeast-1.wasabisys.com/showofforiginal/videos/test.mp4
```

---

## Support

For issues:
1. Check network connectivity
2. Verify video URL
3. Check device storage
4. Review logs
5. Test with different video

For improvements:
- Consider HLS implementation
- Evaluate CDN integration
- Monitor bandwidth
- Track metrics
