# HLS Server Setup Guide

## Overview

This guide shows how to set up your server to generate and serve HLS playlists for video streaming.

## Prerequisites

- FFmpeg installed on server
- Node.js with fluent-ffmpeg package
- Video storage (Wasabi S3, local, or other)

## Installation

### 1. Install FFmpeg

**Ubuntu/Debian:**
```bash
sudo apt-get install ffmpeg
```

**macOS:**
```bash
brew install ffmpeg
```

**Windows:**
Download from https://ffmpeg.org/download.html

### 2. Install Node Packages

```bash
npm install fluent-ffmpeg
```

## Implementation

### Option 1: Generate HLS on Upload (Recommended)

```javascript
// In your video upload endpoint
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs');

async function generateHlsPlaylist(videoPath) {
  return new Promise((resolve, reject) => {
    const outputPath = videoPath.replace(/\.[^.]+$/, '.m3u8');
    const segmentPattern = videoPath.replace(/\.[^.]+$/, '_%03d.ts');

    ffmpeg(videoPath)
      .output(outputPath)
      .outputOptions([
        '-hls_time 10',              // 10 second segments
        '-hls_list_size 0',          // Keep all segments
        '-hls_segment_filename',
        segmentPattern,
        '-hls_flags independent_segments'
      ])
      .on('start', (cmd) => {
        console.log('🎬 HLS generation started:', cmd);
      })
      .on('progress', (progress) => {
        console.log(`🎬 HLS progress: ${progress.percent}%`);
      })
      .on('end', () => {
        console.log('✅ HLS playlist generated:', outputPath);
        resolve(outputPath);
      })
      .on('error', (err) => {
        console.error('❌ HLS generation error:', err);
        reject(err);
      })
      .run();
  });
}

// Usage in upload handler
app.post('/upload-video', async (req, res) => {
  try {
    // ... handle video upload ...
    const videoPath = req.file.path;

    // Generate HLS playlist
    const hlsPath = await generateHlsPlaylist(videoPath);

    res.json({
      success: true,
      videoUrl: videoPath,
      hlsUrl: hlsPath,
      message: 'Video uploaded and HLS playlist generated'
    });
  } catch (error) {
    console.error('Upload error:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});
```

### Option 2: Generate Multiple Bitrates (Advanced)

For better adaptive streaming, generate multiple quality levels:

```javascript
async function generateMultiBitrateHls(videoPath) {
  const baseDir = path.dirname(videoPath);
  const baseName = path.basename(videoPath, path.extname(videoPath));

  const bitrates = [
    { name: '360p', bitrate: '500k', scale: '640:360' },
    { name: '480p', bitrate: '1000k', scale: '854:480' },
    { name: '720p', bitrate: '2500k', scale: '1280:720' },
  ];

  const variants = [];

  for (const quality of bitrates) {
    const outputDir = path.join(baseDir, quality.name);
    if (!fs.existsSync(outputDir)) {
      fs.mkdirSync(outputDir, { recursive: true });
    }

    const playlistPath = path.join(outputDir, 'playlist.m3u8');
    const segmentPattern = path.join(outputDir, 'segment_%03d.ts');

    await new Promise((resolve, reject) => {
      ffmpeg(videoPath)
        .output(playlistPath)
        .outputOptions([
          `-b:v ${quality.bitrate}`,
          `-vf scale=${quality.scale}`,
          '-hls_time 10',
          '-hls_list_size 0',
          '-hls_segment_filename',
          segmentPattern
        ])
        .on('end', () => {
          console.log(`✅ Generated ${quality.name} variant`);
          variants.push({
            name: quality.name,
            bitrate: quality.bitrate,
            path: playlistPath
          });
          resolve();
        })
        .on('error', reject)
        .run();
    });
  }

  // Generate master playlist
  const masterPlaylist = generateMasterPlaylist(variants);
  const masterPath = path.join(baseDir, 'master.m3u8');
  fs.writeFileSync(masterPath, masterPlaylist);

  console.log('✅ Master playlist generated:', masterPath);
  return masterPath;
}

function generateMasterPlaylist(variants) {
  let content = '#EXTM3U\n';
  content += '#EXT-X-VERSION:3\n';
  content += '#EXT-X-TARGETDURATION:10\n\n';

  for (const variant of variants) {
    const bandwidth = parseInt(variant.bitrate) * 1000;
    content += `#EXT-X-STREAM-INF:BANDWIDTH=${bandwidth}\n`;
    content += `${variant.path}\n\n`;
  }

  return content;
}
```

### Option 3: On-Demand HLS Generation

Generate HLS playlist when video is first requested:

```javascript
const cache = new Map();

app.get('/videos/:id.m3u8', async (req, res) => {
  const videoId = req.params.id;
  const videoPath = path.join(__dirname, 'uploads', `${videoId}.mp4`);

  // Check if already generated
  if (cache.has(videoId)) {
    return res.type('application/vnd.apple.mpegurl').send(cache.get(videoId));
  }

  try {
    // Generate HLS playlist on-the-fly
    const playlist = await generateHlsPlaylist(videoPath);
    const content = fs.readFileSync(playlist, 'utf-8');

    cache.set(videoId, content);
    res.type('application/vnd.apple.mpegurl').send(content);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

## Wasabi S3 Integration

### Upload to Wasabi and Generate HLS

```javascript
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  endpoint: 'https://s3.wasabisys.com',
  accessKeyId: process.env.WASABI_ACCESS_KEY,
  secretAccessKey: process.env.WASABI_SECRET_KEY,
  region: 'us-east-1'
});

async function uploadVideoAndGenerateHls(localVideoPath, s3Key) {
  try {
    // 1. Generate HLS locally
    const hlsPath = await generateHlsPlaylist(localVideoPath);
    const baseDir = path.dirname(hlsPath);

    // 2. Upload master playlist
    const playlistContent = fs.readFileSync(hlsPath);
    await s3.putObject({
      Bucket: process.env.WASABI_BUCKET,
      Key: s3Key.replace(/\.[^.]+$/, '.m3u8'),
      Body: playlistContent,
      ContentType: 'application/vnd.apple.mpegurl'
    }).promise();

    // 3. Upload all segments
    const files = fs.readdirSync(baseDir);
    for (const file of files) {
      if (file.endsWith('.ts')) {
        const filePath = path.join(baseDir, file);
        const fileContent = fs.readFileSync(filePath);
        await s3.putObject({
          Bucket: process.env.WASABI_BUCKET,
          Key: `${path.dirname(s3Key)}/${file}`,
          Body: fileContent,
          ContentType: 'video/mp2t'
        }).promise();
      }
    }

    console.log('✅ Video and HLS uploaded to Wasabi');
    return {
      videoUrl: `https://${process.env.WASABI_BUCKET}.s3.wasabisys.com/${s3Key}`,
      hlsUrl: `https://${process.env.WASABI_BUCKET}.s3.wasabisys.com/${s3Key.replace(/\.[^.]+$/, '.m3u8')}`
    };
  } catch (error) {
    console.error('❌ Upload error:', error);
    throw error;
  }
}
```

## CORS Configuration

Ensure your server allows HLS requests:

```javascript
// Express CORS setup
const cors = require('cors');

app.use(cors({
  origin: '*',
  methods: ['GET', 'POST', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Range'],
  credentials: false
}));

// For Wasabi S3, configure CORS in bucket settings
// Allow GET requests from your domain
```

## Nginx Configuration

If using Nginx to serve HLS:

```nginx
server {
    listen 80;
    server_name your-domain.com;

    location /videos/ {
        alias /var/www/videos/;
        
        # HLS specific headers
        types {
            application/vnd.apple.mpegurl m3u8;
            video/mp2t ts;
        }
        
        # Allow range requests for streaming
        add_header Accept-Ranges bytes;
        
        # Cache control
        add_header Cache-Control "public, max-age=3600";
    }
}
```

## Testing

### Test HLS Playlist Generation

```bash
# Check if playlist was generated
ls -la /path/to/video.m3u8

# View playlist content
cat /path/to/video.m3u8

# Check segments
ls -la /path/to/video_*.ts
```

### Test HLS Playback

```bash
# Using ffplay (part of FFmpeg)
ffplay https://your-domain.com/videos/video.m3u8

# Using curl to check playlist
curl https://your-domain.com/videos/video.m3u8
```

## Performance Tips

1. **Segment Duration**: 10 seconds is optimal for most cases
2. **Bitrate Variants**: Generate 2-3 quality levels for adaptive streaming
3. **Caching**: Cache generated playlists to reduce CPU usage
4. **CDN**: Use CDN to distribute segments globally
5. **Cleanup**: Delete old HLS files after retention period

## Troubleshooting

### FFmpeg Not Found
```bash
# Check FFmpeg installation
which ffmpeg
ffmpeg -version

# Add to PATH if needed
export PATH=$PATH:/usr/local/bin
```

### Permission Denied
```bash
# Ensure write permissions
chmod 755 /path/to/video/directory
```

### Segments Not Found
- Verify segment files are created
- Check file permissions
- Ensure playlist path is correct

### Slow Generation
- Reduce video resolution
- Use hardware acceleration
- Generate in background job queue

## References

- [FFmpeg HLS Documentation](https://trac.ffmpeg.org/wiki/Encode/H.264#HLS)
- [Apple HLS Specification](https://tools.ietf.org/html/draft-pantos-http-live-streaming)
- [Fluent-FFmpeg Documentation](https://github.com/fluent-ffmpeg/node-fluent-ffmpeg)
