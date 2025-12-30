# HLS Code Examples

## Frontend Examples

### 1. Using HLS Service Directly

```dart
import 'services/hls_service.dart';

// Check if URL is HLS
final isHls = HlsService.isHlsUrl('https://example.com/video.m3u8');
print(isHls); // true

// Convert MP4 to HLS
final videoUrl = 'https://wasabisys.com/videos/reel.mp4';
final hlsUrl = HlsService.convertToHlsUrl(videoUrl);
print(hlsUrl); // https://wasabisys.com/videos/reel.m3u8

// Get recommended bitrate
final bitrate = HlsService.getRecommendedBitrate(
  isWifi: true,
  signalStrength: 4,
);
print(bitrate); // 5000 kbps

// Get buffer duration
final buffer = HlsService.getBufferDuration(2500);
print(buffer); // 8 seconds
```

### 2. Fetching and Parsing HLS Playlist

```dart
import 'services/hls_service.dart';

// Fetch and parse playlist
final playlist = await HlsService.fetchPlaylist(
  'https://example.com/video.m3u8'
);

if (playlist != null) {
  print('Live: ${playlist.isLive}');
  print('Target Duration: ${playlist.targetDuration}');
  print('Variants: ${playlist.variants.length}');
  
  // Get best variant for 2.5 Mbps
  final variant = playlist.getBestVariant(2500);
  if (variant != null) {
    print('Best variant: ${variant.qualityLabel}');
    print('URL: ${variant.url}');
  }
}
```

### 3. Custom Video Player with HLS

```dart
import 'package:video_player/video_player.dart';
import 'services/hls_service.dart';

class HlsVideoPlayer extends StatefulWidget {
  final String videoUrl;

  const HlsVideoPlayer({required this.videoUrl});

  @override
  State<HlsVideoPlayer> createState() => _HlsVideoPlayerState();
}

class _HlsVideoPlayerState extends State<HlsVideoPlayer> {
  late VideoPlayerController _controller;
  bool _isBuffering = false;

  @override
  void initState() {
    super.initState();
    _initializeHlsPlayer();
  }

  Future<void> _initializeHlsPlayer() async {
    // Convert to HLS URL
    final hlsUrl = HlsService.convertToHlsUrl(widget.videoUrl);

    // Create controller
    _controller = VideoPlayerController.networkUrl(
      Uri.parse(hlsUrl),
      videoPlayerOptions: VideoPlayerOptions(
        mixWithOthers: true,
        allowBackgroundPlayback: false,
      ),
    );

    // Listen for buffering
    _controller.addListener(() {
      setState(() {
        _isBuffering = _controller.value.isBuffering;
      });
    });

    // Initialize
    await _controller.initialize();
    _controller.play();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        VideoPlayer(_controller),
        if (_isBuffering)
          const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```

## Server Examples

### 1. Generate HLS on Upload (Node.js)

```javascript
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
        '-hls_time 10',
        '-hls_list_size 0',
        '-hls_segment_filename',
        segmentPattern,
        '-hls_flags independent_segments'
      ])
      .on('end', () => {
        console.log('✅ HLS generated:', outputPath);
        resolve(outputPath);
      })
      .on('error', (err) => {
        console.error('❌ Error:', err);
        reject(err);
      })
      .run();
  });
}

// Usage
app.post('/upload-video', async (req, res) => {
  try {
    const videoPath = req.file.path;
    const hlsPath = await generateHlsPlaylist(videoPath);
    
    res.json({
      success: true,
      hlsUrl: hlsPath
    });
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});
```

### 2. Generate Multiple Bitrates

```javascript
async function generateMultiBitrateHls(videoPath) {
  const baseDir = path.dirname(videoPath);
  const baseName = path.basename(videoPath, path.extname(videoPath));

  const qualities = [
    { name: '360p', bitrate: '500k', scale: '640:360' },
    { name: '480p', bitrate: '1000k', scale: '854:480' },
    { name: '720p', bitrate: '2500k', scale: '1280:720' },
  ];

  const variants = [];

  for (const quality of qualities) {
    const outputDir = path.join(baseDir, quality.name);
    fs.mkdirSync(outputDir, { recursive: true });

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
          console.log(`✅ Generated ${quality.name}`);
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
  const masterContent = generateMasterPlaylist(variants);
  const masterPath = path.join(baseDir, 'master.m3u8');
  fs.writeFileSync(masterPath, masterContent);

  return masterPath;
}

function generateMasterPlaylist(variants) {
  let content = '#EXTM3U\n#EXT-X-VERSION:3\n#EXT-X-TARGETDURATION:10\n\n';
  
  for (const variant of variants) {
    const bandwidth = parseInt(variant.bitrate) * 1000;
    content += `#EXT-X-STREAM-INF:BANDWIDTH=${bandwidth}\n`;
    content += `${variant.path}\n\n`;
  }

  return content;
}
```

### 3. Serve HLS with Express

```javascript
const express = require('express');
const path = require('path');
const fs = require('fs');

const app = express();

// Serve HLS playlist
app.get('/videos/:id.m3u8', (req, res) => {
  const playlistPath = path.join(
    __dirname,
    'uploads',
    `${req.params.id}.m3u8`
  );

  if (!fs.existsSync(playlistPath)) {
    return res.status(404).json({ error: 'Playlist not found' });
  }

  res.type('application/vnd.apple.mpegurl');
  res.sendFile(playlistPath);
});

// Serve HLS segments
app.get('/videos/:id_:segment.ts', (req, res) => {
  const segmentPath = path.join(
    __dirname,
    'uploads',
    `${req.params.id}_${req.params.segment}.ts`
  );

  if (!fs.existsSync(segmentPath)) {
    return res.status(404).json({ error: 'Segment not found' });
  }

  res.type('video/mp2t');
  res.sendFile(segmentPath);
});

app.listen(3000, () => {
  console.log('HLS server running on port 3000');
});
```

### 4. Upload to Wasabi with HLS

```javascript
const AWS = require('aws-sdk');
const ffmpeg = require('fluent-ffmpeg');
const fs = require('fs');
const path = require('path');

const s3 = new AWS.S3({
  endpoint: 'https://s3.wasabisys.com',
  accessKeyId: process.env.WASABI_ACCESS_KEY,
  secretAccessKey: process.env.WASABI_SECRET_KEY,
  region: 'us-east-1'
});

async function uploadVideoWithHls(localVideoPath, s3Key) {
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

## Testing Examples

### 1. Test HLS URL Conversion

```dart
void testHlsConversion() {
  // Test MP4 to HLS conversion
  final mp4Url = 'https://wasabisys.com/videos/reel.mp4';
  final hlsUrl = HlsService.convertToHlsUrl(mp4Url);
  
  assert(hlsUrl.endsWith('.m3u8'));
  assert(hlsUrl.contains('wasabisys.com'));
  print('✅ HLS conversion test passed');
}
```

### 2. Test Bitrate Selection

```dart
void testBitrateSelection() {
  // WiFi - high bitrate
  final wifiBitrate = HlsService.getRecommendedBitrate(
    isWifi: true,
    signalStrength: 4,
  );
  assert(wifiBitrate == 5000);

  // 4G strong - medium bitrate
  final mobileBitrate = HlsService.getRecommendedBitrate(
    isWifi: false,
    signalStrength: 3,
  );
  assert(mobileBitrate == 1500);

  print('✅ Bitrate selection test passed');
}
```

### 3. Test Buffer Duration

```dart
void testBufferDuration() {
  // High bitrate - long buffer
  final highBuffer = HlsService.getBufferDuration(5000);
  assert(highBuffer.inSeconds == 10);

  // Low bitrate - short buffer
  final lowBuffer = HlsService.getBufferDuration(400);
  assert(lowBuffer.inSeconds == 4);

  print('✅ Buffer duration test passed');
}
```

### 4. Test Playlist Parsing

```dart
void testPlaylistParsing() {
  final m3u8Content = '''#EXTM3U
#EXT-X-VERSION:3
#EXT-X-TARGETDURATION:10
#EXTINF:10.0,
segment_001.ts
#EXTINF:10.0,
segment_002.ts
#EXT-X-ENDLIST''';

  final playlist = HlsPlaylist.parse(m3u8Content, 'https://example.com');
  
  assert(playlist.segments.length == 2);
  assert(!playlist.isLive);
  assert(playlist.targetDuration.inSeconds == 10);
  
  print('✅ Playlist parsing test passed');
}
```

## CLI Commands

### Generate HLS with FFmpeg

```bash
# Basic HLS generation
ffmpeg -i video.mp4 -hls_time 10 -hls_list_size 0 \
  -hls_segment_filename "segment_%03d.ts" output.m3u8

# With specific bitrate
ffmpeg -i video.mp4 -b:v 2500k -hls_time 10 \
  -hls_list_size 0 output.m3u8

# Multiple bitrates
ffmpeg -i video.mp4 \
  -b:v 500k -s 640x360 -hls_time 10 360p/output.m3u8 \
  -b:v 1000k -s 854x480 -hls_time 10 480p/output.m3u8 \
  -b:v 2500k -s 1280x720 -hls_time 10 720p/output.m3u8
```

### Test HLS Playback

```bash
# Using ffplay
ffplay https://example.com/video.m3u8

# Using curl to check playlist
curl https://example.com/video.m3u8

# Check segment availability
curl -I https://example.com/segment_001.ts
```

## Debugging

### Check HLS Service Logs

```dart
// Enable debug logging
debugPrint('🎬 HLS URL: $hlsUrl');
debugPrint('🎬 Playlist parsed: ${playlist.variants.length} variants');
debugPrint('🎬 Recommended bitrate: $bitrate kbps');
```

### Monitor Video Player

```dart
_controller.addListener(() {
  debugPrint('Buffering: ${_controller.value.isBuffering}');
  debugPrint('Position: ${_controller.value.position}');
  debugPrint('Duration: ${_controller.value.duration}');
});
```

## Performance Monitoring

```dart
// Track startup time
final startTime = DateTime.now();
await _controller.initialize();
final duration = DateTime.now().difference(startTime);
debugPrint('Startup time: ${duration.inMilliseconds}ms');

// Track buffering events
int bufferingCount = 0;
_controller.addListener(() {
  if (_controller.value.isBuffering) {
    bufferingCount++;
  }
});
```
