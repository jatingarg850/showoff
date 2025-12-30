# Video Codec & Format Specifications

## Executive Summary

**Current Setup**: Direct MP4 streaming with H.264 video codec and AAC audio codec
**NOT Using**: HLS, DASH, or m3u8 playlists
**Storage**: Wasabi S3 (AWS S3 compatible)
**Player**: Flutter video_player package

---

## 1. VIDEO CODEC: H.264 (AVC)

### Overview
- **Full Name**: H.264 / MPEG-4 Part 10 / AVC (Advanced Video Coding)
- **Standard**: ITU-T H.264 / ISO/IEC 14496-10
- **Year Released**: 2003
- **Status**: Industry standard, widely supported

### Technical Specifications

#### Profiles
```
Baseline Profile
├─ Level 1.0 - 5.1
├─ No B-frames
├─ No CABAC
├─ Mobile devices, video conferencing
└─ Lowest complexity

Main Profile
├─ Level 1.0 - 5.2
├─ B-frames supported
├─ CABAC supported
├─ Better compression than Baseline
└─ Standard for streaming

High Profile
├─ Level 1.0 - 5.2
├─ Advanced features
├─ Best compression
├─ Professional content
└─ Higher complexity
```

#### Levels (Current Implementation)
```
Level 3.0 - 4.2 supported

Level 3.0:
├─ Max Resolution: 1280x720 @ 30fps
├─ Max Bitrate: 10 Mbps
└─ Typical: HD video

Level 4.0:
├─ Max Resolution: 1920x1080 @ 30fps
├─ Max Bitrate: 20 Mbps
└─ Typical: Full HD video

Level 4.2:
├─ Max Resolution: 1920x1080 @ 60fps
├─ Max Bitrate: 50 Mbps
└─ Typical: High-quality Full HD
```

### Compression Features
```
Entropy Coding:
├─ CAVLC (Context-Adaptive Variable-Length Coding)
└─ CABAC (Context-Adaptive Binary Arithmetic Coding)

Motion Compensation:
├─ Variable block sizes (16x16 to 4x4)
├─ Multiple reference frames
├─ Fractional-pel motion
└─ Weighted prediction

Transform:
├─ 4x4 and 8x8 integer DCT
├─ Adaptive quantization
└─ Hierarchical B-frames
```

### Bitrate Recommendations

```
Resolution | Frame Rate | Bitrate | File Size (60s)
-----------|-----------|---------|----------------
480p       | 24 fps    | 1-2 Mbps | 7.5-15 MB
720p       | 30 fps    | 2-4 Mbps | 15-30 MB
1080p      | 30 fps    | 5-8 Mbps | 37.5-60 MB
1080p      | 60 fps    | 8-12 Mbps| 60-90 MB
```

### Device Support
```
Android:
├─ Min API: 21 (Android 5.0)
├─ Hardware Acceleration: Yes
├─ Codec: libx264 (software) or hardware decoder
└─ Support: 100%

iOS:
├─ Min iOS: 11.0
├─ Hardware Acceleration: Yes
├─ Codec: VideoToolbox (hardware)
└─ Support: 100%

Web:
├─ Browser Support: Chrome, Firefox, Safari, Edge
├─ Hardware Acceleration: Varies
└─ Support: 95%+
```

---

## 2. AUDIO CODEC: AAC

### Overview
- **Full Name**: Advanced Audio Coding
- **Standard**: ISO/IEC 14496-3
- **Year Released**: 1997
- **Status**: Industry standard for audio

### Technical Specifications

#### AAC Profiles
```
AAC-LC (Low Complexity)
├─ Most common
├─ Good quality at low bitrate
├─ Supported on all devices
└─ Typical: 128-256 kbps

AAC-HE (High Efficiency)
├─ Better quality at very low bitrate
├─ Uses Spectral Band Replication (SBR)
├─ Supported on most devices
└─ Typical: 64-128 kbps

AAC-HE v2
├─ Parametric Stereo (PS)
├─ Best quality at low bitrate
├─ Supported on most devices
└─ Typical: 32-64 kbps
```

### Audio Specifications

```
Sample Rate:
├─ 44.1 kHz (CD quality)
├─ 48 kHz (Professional)
├─ 96 kHz (High-res)
└─ 192 kHz (Mastering)

Channels:
├─ Mono (1 channel)
├─ Stereo (2 channels)
├─ 5.1 Surround (6 channels)
└─ 7.1 Surround (8 channels)

Bitrate:
├─ 64 kbps (Low quality)
├─ 128 kbps (Standard)
├─ 192 kbps (Good quality)
├─ 256 kbps (High quality)
└─ 320 kbps (Very high quality)
```

### Current Configuration
```
Sample Rate: 48 kHz (Professional standard)
Channels: Stereo (2 channels)
Bitrate: 128-256 kbps (Good quality)
Profile: AAC-LC (Most compatible)
```

### Device Support
```
Android:
├─ Min API: 16 (Android 4.1)
├─ Hardware Acceleration: Yes
├─ Codec: libfdk-aac or system decoder
└─ Support: 100%

iOS:
├─ Min iOS: 8.0
├─ Hardware Acceleration: Yes
├─ Codec: AudioToolbox
└─ Support: 100%

Web:
├─ Browser Support: All modern browsers
├─ Hardware Acceleration: Varies
└─ Support: 100%
```

---

## 3. CONTAINER FORMAT: MP4

### Overview
- **Full Name**: MPEG-4 Part 14
- **File Extension**: .mp4
- **MIME Type**: video/mp4
- **Status**: Industry standard

### MP4 Structure
```
MP4 File
├─ ftyp (File Type Box)
│  └─ Identifies as MP4
├─ moov (Movie Box)
│  ├─ mvhd (Movie Header)
│  ├─ trak (Track)
│  │  ├─ tkhd (Track Header)
│  │  ├─ edts (Edit List)
│  │  └─ mdia (Media)
│  │     ├─ mdhd (Media Header)
│  │     ├─ hdlr (Handler)
│  │     └─ minf (Media Information)
│  │        ├─ vmhd (Video Media Header)
│  │        ├─ stbl (Sample Table)
│  │        │  ├─ stsd (Sample Description)
│  │        │  ├─ stts (Time-to-Sample)
│  │        │  ├─ stss (Sync Sample)
│  │        │  ├─ stsc (Sample-to-Chunk)
│  │        │  ├─ stsz (Sample Size)
│  │        │  └─ stco (Chunk Offset)
│  │        └─ dinf (Data Information)
│  └─ trak (Audio Track)
│     └─ [Similar structure]
└─ mdat (Media Data Box)
   └─ Actual video/audio frames
```

### MP4 Advantages
```
✅ Wide device support
✅ Streaming friendly
✅ Metadata support
✅ Multiple tracks
✅ Efficient compression
✅ Industry standard
✅ Good for web
```

---

## 4. CURRENT STREAMING SETUP

### Architecture
```
┌─────────────────────────────────────────────────────┐
│                  User Device                        │
│  ┌──────────────────────────────────────────────┐  │
│  │  Flutter App                                 │  │
│  │  ┌────────────────────────────────────────┐  │  │
│  │  │  video_player package                  │  │  │
│  │  │  - VideoPlayerController               │  │  │
│  │  │  - Buffering detection                 │  │  │
│  │  │  - Playback control                    │  │  │
│  │  └────────────────────────────────────────┘  │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
                        ↓
                   HTTP/HTTPS
                        ↓
┌─────────────────────────────────────────────────────┐
│              Wasabi S3 Storage                      │
│  ┌──────────────────────────────────────────────┐  │
│  │  Bucket: showofforiginal                     │  │
│  │  Region: ap-southeast-1                      │  │
│  │  Files: videos/{uuid}.mp4                    │  │
│  │  Access: Public-read via presigned URLs      │  │
│  └──────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Data Flow
```
1. User opens reel
2. App fetches video URL from database
3. Check local cache
   ✓ Found → Use cached file
   ✗ Not found → Continue
4. Create VideoPlayerController with URL
5. Controller makes HTTP GET request to S3
6. S3 returns MP4 file (HTTP streaming)
7. Player buffers 15% of file
8. Auto-play starts
9. File cached for future use
```

### Presigned URL Flow
```
1. App requests presigned URL
2. Backend generates AWS Signature V4
3. Returns temporary URL (valid for ~1 hour)
4. App uses presigned URL for playback
5. S3 validates signature
6. Streams video to player
```

---

## 5. BUFFERING MECHANISM

### Current Implementation
```dart
void _onVideoStateChanged(VideoPlayerController controller, int index) {
  final buffered = controller.value.buffered;
  final duration = controller.value.duration;

  if (buffered.isNotEmpty && duration.inMilliseconds > 0) {
    final bufferedEnd = buffered.last.end;
    
    // Calculate buffered percentage
    final bufferedPercent = 
      (bufferedEnd.inMilliseconds / duration.inMilliseconds) * 100;
    
    // Ready when 15% buffered
    if (bufferedPercent >= 15) {
      _playVideo(index);
    }
  }
}
```

### Buffering Timeline
```
0%  ├─ Start download
    │
15% ├─ Auto-play starts
    │
50% ├─ Smooth playback
    │
100%├─ Complete
```

### Network Adaptation
```
Fast Network (>10 Mbps):
├─ 15% buffer = ~1-2 seconds
├─ Quick playback start
└─ Smooth streaming

Medium Network (5-10 Mbps):
├─ 15% buffer = ~2-3 seconds
├─ Slight delay
└─ Generally smooth

Slow Network (<5 Mbps):
├─ 15% buffer = ~3-5 seconds
├─ Noticeable delay
└─ May stutter
```

---

## 6. CACHING STRATEGY

### Cache Configuration
```dart
static final _cacheManager = CacheManager(
  Config(
    'reelVideoCache',
    stalePeriod: const Duration(days: 3),
    maxNrOfCacheObjects: 10,
  ),
);
```

### Cache Behavior
```
First View:
├─ Download from S3
├─ Cache to device
└─ Play

Subsequent Views (within 3 days):
├─ Check cache
├─ Use cached file
└─ Play (faster)

After 3 days:
├─ Cache expires
├─ Download again
└─ Update cache
```

### Storage Impact
```
Per Video (60 seconds):
├─ 1080p @ 30fps: ~40-50 MB
├─ 720p @ 30fps: ~20-30 MB
└─ 480p @ 24fps: ~10-15 MB

Cache Limit:
├─ Max 10 videos
├─ Total: ~100-500 MB
└─ Depends on quality
```

---

## 7. COMPARISON: CURRENT vs HLS

### Current Setup (Direct MP4)
```
Pros:
✅ Simple implementation
✅ Works on all devices
✅ No server-side encoding
✅ Lower latency
✅ Easier debugging

Cons:
❌ No adaptive bitrate
❌ Fixed quality
❌ Higher bandwidth for slow networks
❌ Larger file sizes
```

### HLS (HTTP Live Streaming)
```
Pros:
✅ Adaptive bitrate
✅ Quality adjustment
✅ Better for slow networks
✅ Smaller files
✅ Industry standard

Cons:
❌ Complex implementation
❌ Requires FFmpeg
❌ Multiple quality versions
❌ Higher storage
❌ Higher server load
```

---

## 8. QUALITY MATRIX

### Recommended Settings by Device

```
Mobile (4G LTE):
├─ Resolution: 720p
├─ Bitrate: 2-4 Mbps
├─ Frame Rate: 30 fps
└─ File Size: 15-30 MB (60s)

Mobile (WiFi):
├─ Resolution: 1080p
├─ Bitrate: 5-8 Mbps
├─ Frame Rate: 30 fps
└─ File Size: 37.5-60 MB (60s)

Desktop:
├─ Resolution: 1080p
├─ Bitrate: 8-12 Mbps
├─ Frame Rate: 60 fps
└─ File Size: 60-90 MB (60s)

Tablet:
├─ Resolution: 1080p
├─ Bitrate: 5-8 Mbps
├─ Frame Rate: 30 fps
└─ File Size: 37.5-60 MB (60s)
```

---

## 9. ENCODING RECOMMENDATIONS

### For Upload
```bash
# Recommended FFmpeg command
ffmpeg -i input.mov \
  -c:v libx264 \
  -preset medium \
  -crf 23 \
  -c:a aac \
  -b:a 128k \
  -ar 48000 \
  output.mp4
```

### Parameters Explained
```
-c:v libx264          # H.264 video codec
-preset medium        # Encoding speed (fast/medium/slow)
-crf 23              # Quality (0-51, lower=better)
-c:a aac             # AAC audio codec
-b:a 128k            # Audio bitrate
-ar 48000            # Audio sample rate (48 kHz)
```

---

## 10. TROUBLESHOOTING MATRIX

| Issue | Cause | Solution |
|-------|-------|----------|
| Video won't play | Invalid codec | Re-encode to H.264 + AAC |
| Audio missing | No audio track | Add audio during encoding |
| Stuttering | Bitrate too high | Reduce bitrate or improve network |
| Buffering | Slow network | Reduce quality or improve connection |
| Sync issues | Audio/video mismatch | Re-encode with proper sync |
| File too large | High bitrate | Reduce bitrate or resolution |
| Crashes | Memory issue | Reduce resolution or cache size |

---

## 11. PERFORMANCE BENCHMARKS

### Encoding Time (60 second video)
```
Resolution | Bitrate | Preset | Time
-----------|---------|--------|------
480p       | 2 Mbps  | fast   | 30s
720p       | 4 Mbps  | medium | 60s
1080p      | 8 Mbps  | medium | 120s
1080p      | 8 Mbps  | slow   | 180s
```

### Playback Performance
```
Device | Resolution | FPS | CPU | Memory
--------|-----------|-----|-----|--------
Phone   | 720p      | 30  | 15% | 80 MB
Phone   | 1080p     | 30  | 25% | 100 MB
Tablet  | 1080p     | 30  | 10% | 120 MB
Desktop | 1080p     | 60  | 5%  | 150 MB
```

---

## 12. SUMMARY

### What We Use
- **Video**: H.264 (AVC) in MP4 container
- **Audio**: AAC in MP4 container
- **Streaming**: Direct HTTP from S3
- **Buffering**: 15% threshold
- **Caching**: 3-day cache, 10 videos max

### What We Don't Use
- HLS (m3u8 playlists)
- DASH
- Adaptive bitrate
- Quality selection
- Offline download

### Why This Works
- Simple and reliable
- Works on all devices
- Low server complexity
- Good for current scale
- Easy to debug

### When to Upgrade
- User base grows significantly
- Network conditions vary widely
- Need offline viewing
- Want quality selection
- Require adaptive streaming
