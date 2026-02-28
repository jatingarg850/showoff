# HLS Video Streaming Setup Guide

## Overview
The SYT (Show Your Talent) reel system now supports HLS (HTTP Live Streaming) for better video streaming performance. HLS provides adaptive bitrate streaming and better compatibility across devices.

## What Changed
- Videos uploaded to SYT are now converted to HLS format (.m3u8 playlists with .ts segments)
- Original MP4 videos are used as fallback if HLS conversion fails
- FFmpeg is required for HLS conversion

## Installation

### Prerequisites
- Node.js 14+ (already installed)
- FFmpeg (needs to be installed)

### Step 1: Install FFmpeg

**Linux (Ubuntu/Debian):**
```bash
sudo apt-get update
sudo apt-get install ffmpeg
```

**Linux (CentOS/RHEL):**
```bash
sudo yum install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
```bash
choco install ffmpeg
```

Or download from: https://ffmpeg.org/download.html

### Step 2: Verify FFmpeg Installation
```bash
ffmpeg -version
```

You should see version information if installed correctly.

### Step 3: Install Node Dependencies
```bash
cd server
npm install
```

This will install `fluent-ffmpeg` package which is now in package.json.

### Step 4: Restart Server
```bash
npm run dev
# or
npm start
```

## How It Works

### Upload Flow
1. User uploads video via SYT reel screen
2. Video is uploaded to Wasabi S3 as MP4
3. Server attempts HLS conversion (30-second timeout)
4. If successful: HLS URL is stored in database
5. If failed: Original MP4 URL is stored as fallback

### Playback
- Videos are served via HLS for better streaming
- Adaptive bitrate: automatically adjusts quality based on connection
- 10-second segments for smooth playback
- Falls back to MP4 if HLS is unavailable

## Troubleshooting

### FFmpeg Not Found
**Error:** "FFmpeg not available - HLS conversion will be skipped"

**Solution:**
1. Install FFmpeg (see Installation section above)
2. Verify installation: `ffmpeg -version`
3. Restart server

### HLS Conversion Timeout
**Error:** "HLS conversion timeout"

**Solution:**
- This is normal for large videos
- Video will be stored as MP4 and still playable
- Consider optimizing video size before upload

### Disk Space Issues
**Error:** "No space left on device"

**Solution:**
- HLS conversion uses `/tmp` directory
- Ensure at least 5GB free space on server
- Check: `df -h`

### Permission Denied
**Error:** "Permission denied" when creating temp files

**Solution:**
```bash
# Ensure /tmp is writable
chmod 1777 /tmp
```

## Performance Tips

1. **Video Size**: Keep videos under 100MB for faster conversion
2. **Server Resources**: HLS conversion is CPU-intensive
3. **Concurrent Uploads**: Limit concurrent uploads to prevent server overload
4. **Monitoring**: Check server logs for conversion progress

## Monitoring

Check server logs for HLS conversion status:
```bash
# Look for these log messages:
# ✅ HLS conversion completed
# ⚠️ HLS conversion failed
# 🎬 Starting HLS conversion process
```

## Rollback (If Needed)

If you need to disable HLS conversion temporarily:

1. Edit `server/utils/hlsConverter.js`
2. Change `ffmpegAvailable = true` to `ffmpegAvailable = false`
3. Restart server

Videos will be stored as MP4 but will still be playable.

## Next Steps

- Monitor HLS conversion success rate in logs
- Optimize FFmpeg settings if needed (in hlsConverter.js)
- Consider adding HLS conversion queue for high-volume uploads
