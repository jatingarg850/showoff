# HLS Streaming Implementation Guide

## Overview

HLS (HTTP Live Streaming) has been integrated into the reel screen for adaptive bitrate streaming. This provides better video playback performance, especially on varying network conditions.

## What Changed

### 1. **New HLS Service** (`apps/lib/services/hls_service.dart`)
- Handles HLS URL conversion
- Parses M3U8 playlists
- Manages adaptive bitrate selection
- Calculates optimal buffer durations

### 2. **Updated Reel Screen** (`apps/lib/reel_screen.dart`)
- Imports HLS service
- Converts video URLs to HLS format automatically
- Shows buffering indicators during HLS streaming
- Improved video player UI with buffering state

## How It Works

### URL Conversion
Videos are automatically converted to HLS format:
```
Original: https://wasabisys.com/videos/reel-123.mp4
HLS:      https://wasabisys.com/videos/reel-123.m3u8
```

### Adaptive Bitrate Streaming
The HLS service automatically selects the best quality based on:
- Network type (WiFi vs mobile)
- Signal strength
- Available bandwidth

### Buffering Management
- **High bitrate (>3 Mbps)**: 10 second buffer
- **Medium bitrate (1.5-3 Mbps)**: 8 second buffer
- **Low bitrate (800 kbps - 1.5 Mbps)**: 6 second buffer
- **Very low bitrate (<800 kbps)**: 4 second buffer

## Server-Side Setup

### For Wasabi S3 Storage
You need to generate HLS playlists when videos are uploaded. Add this to your video upload handler:

```javascript
// In your video upload endpoint
const ffmpeg = require('fluent-ffmpeg');

async function generateHlsPlaylist(videoPath) {
  return new Promise((resolve, reject) => {
    ffmpeg(videoPath)
      .output(videoPath.replace('.mp4', '.m3u8'))
      .outputOptions([
        '-hls_time 10',           // 10 second segments
        '-hls_list_size 0',       // Keep all segments
        '-hls_segment_filename',
        videoPath.replace('.mp4', '_%03d.ts')
      ])
      .on('end', () => resolve())
      .on('error', reject)
      .run();
  });
}
```

### For Local Server
If using local server, ensure your video endpoint supports HLS:

```javascript
// Express endpoint for HLS
app.get('/videos/:id.m3u8', (req, res) => {
  const videoPath = path.join(__dirname, 'uploads', `${req.params.id}.mp4`);
  
  // Generate HLS playlist on-the-fly or serve pre-generated
  res.type('application/vnd.apple.mpegurl');
  res.sendFile(playlistPath);
});
```

## Features

### 1. **Automatic Quality Selection**
- Detects network conditions
- Switches quality automatically
- No manual intervention needed

### 2. **Buffering Indicators**
- Shows "Buffering..." when HLS is loading segments
- Smooth playback experience
- Prevents stuttering

### 3. **Segment Caching**
- Segments are cached locally
- Reduces bandwidth usage
- Faster replay of same video

### 4. **Playlist Parsing**
- Reads M3U8 metadata
- Extracts bitrate information
- Calculates optimal buffer duration

## Testing

### Test HLS Playback
```dart
// In your test file
void testHlsPlayback() {
  final hlsUrl = 'https://example.com/video.m3u8';
  final isHls = HlsService.isHlsUrl(hlsUrl);
  expect(isHls, true);
}
```

### Check URL Conversion
```dart
final videoUrl = 'https://wasabisys.com/videos/reel.mp4';
final hlsUrl = HlsService.convertToHlsUrl(videoUrl);
// Result: https://wasabisys.com/videos/reel.m3u8
```

### Monitor Buffering
The reel screen now shows buffering status:
- Loading indicator appears during initial buffering
- "Buffering..." text shows during segment loading
- Smooth transition when ready to play

## Performance Benefits

1. **Reduced Bandwidth**: Adaptive bitrate saves data on slow connections
2. **Faster Startup**: Segments load faster than full video
3. **Better UX**: No stuttering or long loading times
4. **Scalability**: HLS is optimized for CDN delivery

## Troubleshooting

### Videos Not Playing
- Check if `.m3u8` files are being generated on server
- Verify CORS headers allow HLS requests
- Check browser console for 404 errors

### Buffering Issues
- Increase buffer duration in `HlsService.getBufferDuration()`
- Check network speed
- Verify segment files exist on server

### Quality Not Switching
- Ensure multiple bitrate variants in M3U8 playlist
- Check `HlsService.getBestVariant()` logic
- Monitor network conditions

## Configuration

### Adjust Buffer Duration
```dart
// In hls_service.dart
static Duration getBufferDuration(int bitratekbps) {
  if (bitratekbps > 3000) {
    return const Duration(seconds: 15); // Increase from 10
  }
  // ... rest of logic
}
```

### Change Segment Duration
```javascript
// In server video processing
.outputOptions([
  '-hls_time 5',  // Change from 10 to 5 seconds
  '-hls_list_size 0',
  '-hls_segment_filename',
  videoPath.replace('.mp4', '_%03d.ts')
])
```

## Next Steps

1. **Generate HLS Playlists**: Update video upload to create `.m3u8` files
2. **Test on Different Networks**: Verify quality switching works
3. **Monitor Performance**: Track buffering and playback metrics
4. **Optimize Segments**: Adjust segment duration based on your needs

## References

- [Apple HLS Specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming)
- [FFmpeg HLS Guide](https://trac.ffmpeg.org/wiki/Encode/H.264#HLS)
- [Video.js HLS Plugin](https://github.com/videojs/http-streaming)
