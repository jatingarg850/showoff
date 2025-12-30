# HLS Setup - Enable When Ready

## Current Status

✅ HLS service is installed and ready  
✅ Reel screen supports HLS streaming  
⏳ **Waiting for server-side HLS playlist generation**

## Why Videos Show 404 Errors

The app tries to load `.m3u8` playlists, but your server only has `.mp4` files. Until you generate HLS playlists on the server, videos won't play via HLS.

## What's Currently Happening

1. App requests: `https://wasabisys.com/videos/reel.m3u8` → **404 Not Found**
2. Falls back to: `https://wasabisys.com/videos/reel.mp4` → **Works**

## To Enable HLS

### Step 1: Generate HLS Playlists on Upload

When users upload videos, generate HLS playlists using FFmpeg:

```javascript
// In your video upload endpoint (server/server.js)
const ffmpeg = require('fluent-ffmpeg');

async function generateHlsPlaylist(videoPath) {
  return new Promise((resolve, reject) => {
    ffmpeg(videoPath)
      .output(videoPath.replace('.mp4', '.m3u8'))
      .outputOptions([
        '-hls_time 10',
        '-hls_list_size 0',
        '-hls_segment_filename',
        videoPath.replace('.mp4', '_%03d.ts')
      ])
      .on('end', () => {
        console.log('✅ HLS generated:', videoPath.replace('.mp4', '.m3u8'));
        resolve();
      })
      .on('error', reject)
      .run();
  });
}

// Call after video upload
app.post('/upload-video', async (req, res) => {
  try {
    const videoPath = req.file.path;
    
    // Generate HLS playlist
    await generateHlsPlaylist(videoPath);
    
    res.json({ success: true, videoUrl: videoPath });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### Step 2: Install FFmpeg on Server

```bash
# Ubuntu/Debian
sudo apt-get install ffmpeg

# macOS
brew install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html
```

### Step 3: Install Node Package

```bash
npm install fluent-ffmpeg
```

### Step 4: Enable HLS in App

Once server generates `.m3u8` files, uncomment this in `reel_screen.dart`:

```dart
String _getHlsUrl(String videoUrl) {
  if (videoUrl.endsWith('.m3u8')) {
    return videoUrl;
  }

  // Enable HLS conversion
  if (videoUrl.contains('wasabisys.com')) {
    final baseUrl = videoUrl.replaceAll(RegExp(r'\.[^.]+$'), '');
    return '$baseUrl.m3u8';  // ← Uncomment this
  }

  return videoUrl;
}
```

## Testing HLS

### 1. Check if HLS Files Exist

```bash
# SSH into server
ssh user@your-server.com

# Check for .m3u8 files
ls -la /path/to/uploads/*.m3u8

# Check for segment files
ls -la /path/to/uploads/*_*.ts
```

### 2. Test HLS Playback

```bash
# Using ffplay
ffplay https://your-domain.com/videos/video.m3u8

# Using curl
curl https://your-domain.com/videos/video.m3u8
```

### 3. Monitor App Logs

```
🎬 HLS URL for video 0: https://wasabisys.com/videos/reel.m3u8
```

If you see this, HLS is enabled and working.

## Benefits Once Enabled

✅ 75% faster video startup  
✅ 30-50% bandwidth reduction  
✅ Automatic quality switching  
✅ Smooth playback without stuttering  

## Files Ready for HLS

- `apps/lib/services/hls_service.dart` - HLS service
- `apps/lib/reel_screen.dart` - HLS integration
- `HLS_SERVER_SETUP.md` - Server implementation guide
- `HLS_CODE_EXAMPLES.md` - Code snippets

## Next Steps

1. **Install FFmpeg** on your server
2. **Update video upload** to generate HLS playlists
3. **Test HLS generation** with a test video
4. **Uncomment HLS conversion** in reel_screen.dart
5. **Deploy and test** on device

## Questions?

Refer to:
- `HLS_SERVER_SETUP.md` - Detailed server setup
- `HLS_CODE_EXAMPLES.md` - Code examples
- `HLS_STREAMING_IMPLEMENTATION.md` - Technical details
