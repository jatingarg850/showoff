const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs').promises;
const AWS = require('aws-sdk');
const { v4: uuidv4 } = require('uuid');

// Check if FFmpeg is available
let ffmpegAvailable = false;
try {
  ffmpeg.setFfmpegPath(require('ffmpeg-static'));
  ffmpegAvailable = true;
  console.log('✅ FFmpeg is available');
} catch (e) {
  console.warn('⚠️ FFmpeg not found - HLS conversion will be skipped');
  console.warn('   Install FFmpeg: apt-get install ffmpeg (Linux) or brew install ffmpeg (Mac)');
}

// Configure Wasabi S3
const s3 = new AWS.S3({
  accessKeyId: process.env.WASABI_ACCESS_KEY_ID,
  secretAccessKey: process.env.WASABI_SECRET_ACCESS_KEY,
  endpoint: process.env.WASABI_ENDPOINT || 's3.ap-southeast-1.wasabisys.com',
  region: process.env.WASABI_REGION || 'ap-southeast-1',
  s3ForcePathStyle: true,
  signatureVersion: 'v4',
});

/**
 * Convert video to HLS format
 * @param {string} inputPath - Path to input video file
 * @param {string} outputDir - Directory to save HLS files
 * @returns {Promise<string>} - Path to generated m3u8 file
 */
async function convertToHLS(inputPath, outputDir) {
  return new Promise((resolve, reject) => {
    const m3u8Path = path.join(outputDir, 'playlist.m3u8');
    const segmentPattern = path.join(outputDir, 'segment_%03d.ts');

    console.log('🎬 Converting video to HLS format...');
    console.log(`  - Input: ${inputPath}`);
    console.log(`  - Output: ${m3u8Path}`);

    ffmpeg(inputPath)
      .outputOptions([
        '-c:v libx264',           // Video codec
        '-preset medium',          // Encoding speed (fast, medium, slow)
        '-crf 23',                 // Quality (0-51, lower is better)
        '-c:a aac',               // Audio codec
        '-b:a 128k',              // Audio bitrate
        '-hls_time 10',           // Segment duration (10 seconds)
        '-hls_list_size 0',       // Keep all segments in playlist
        '-hls_segment_type mpegts', // Segment format
      ])
      .output(m3u8Path)
      .on('start', (cmd) => {
        console.log('🎬 FFmpeg command:', cmd);
      })
      .on('progress', (progress) => {
        console.log(`  - Progress: ${progress.percent}%`);
      })
      .on('error', (err) => {
        console.error('❌ FFmpeg error:', err);
        reject(err);
      })
      .on('end', () => {
        console.log('✅ HLS conversion completed');
        resolve(m3u8Path);
      })
      .run();
  });
}

/**
 * Upload HLS files to Wasabi S3
 * @param {string} hlsDir - Directory containing HLS files
 * @param {string} s3Prefix - S3 prefix for files
 * @returns {Promise<string>} - URL to m3u8 file
 */
async function uploadHLSToS3(hlsDir, s3Prefix) {
  try {
    console.log('📤 Uploading HLS files to S3...');
    console.log(`  - Directory: ${hlsDir}`);
    console.log(`  - S3 Prefix: ${s3Prefix}`);

    const files = await fs.readdir(hlsDir);
    const bucketName = process.env.WASABI_BUCKET_NAME;
    const region = process.env.WASABI_REGION || 'ap-southeast-1';

    for (const file of files) {
      const filePath = path.join(hlsDir, file);
      const fileContent = await fs.readFile(filePath);
      const s3Key = `${s3Prefix}/${file}`;

      // Determine content type
      let contentType = 'application/octet-stream';
      if (file.endsWith('.m3u8')) {
        contentType = 'application/vnd.apple.mpegurl';
      } else if (file.endsWith('.ts')) {
        contentType = 'video/mp2t';
      }

      const params = {
        Bucket: bucketName,
        Key: s3Key,
        Body: fileContent,
        ContentType: contentType,
        ACL: 'public-read',
      };

      await s3.putObject(params).promise();
      console.log(`  ✅ Uploaded: ${s3Key}`);
    }

    // Return URL to m3u8 file
    const m3u8Url = `https://s3.${region}.wasabisys.com/${bucketName}/${s3Prefix}/playlist.m3u8`;
    console.log(`✅ HLS URL: ${m3u8Url}`);
    return m3u8Url;
  } catch (error) {
    console.error('❌ Error uploading HLS to S3:', error);
    throw error;
  }
}

/**
 * Convert video file to HLS and upload to S3
 * @param {string} videoPath - Path to video file (local or S3 URL)
 * @param {string} videoId - Unique ID for the video
 * @returns {Promise<string>} - URL to HLS m3u8 file or original video URL if conversion fails
 */
async function convertVideoToHLS(videoPath, videoId) {
  // If FFmpeg is not available, return original video URL
  if (!ffmpegAvailable) {
    console.warn('⚠️ FFmpeg not available - returning original video URL');
    console.warn('   To enable HLS conversion, install FFmpeg:');
    console.warn('   Linux: apt-get install ffmpeg');
    console.warn('   Mac: brew install ffmpeg');
    console.warn('   Windows: choco install ffmpeg');
    return videoPath; // Return original video URL
  }

  let localVideoPath = videoPath;
  let tempDir = null;

  try {
    console.log('🎬 Starting HLS conversion process...');
    console.log(`  - Video: ${videoPath}`);
    console.log(`  - Video ID: ${videoId}`);

    // If video is on S3, download it first
    if (videoPath.includes('wasabisys.com') || videoPath.includes('s3.')) {
      console.log('📥 Downloading video from S3...');
      const tempFile = path.join('/tmp', `video_${videoId}.mp4`);
      
      // Download from S3
      const bucketName = process.env.WASABI_BUCKET_NAME;
      let key;
      
      // Extract key from Wasabi URL format: https://s3.region.wasabisys.com/bucket/key
      if (videoPath.includes('wasabisys.com')) {
        const urlParts = videoPath.split('.com/');
        if (urlParts.length > 1) {
          const pathParts = urlParts[1].split('/');
          // Remove bucket name and get the rest
          key = pathParts.slice(1).join('/');
        }
      } else {
        // Fallback for other S3 formats
        const s3Url = new URL(videoPath);
        key = s3Url.pathname.replace(`/${bucketName}/`, '').replace(/^\//, '');
      }

      console.log(`  - Bucket: ${bucketName}`);
      console.log(`  - Key: ${key}`);

      const params = {
        Bucket: bucketName,
        Key: key,
      };

      const data = await s3.getObject(params).promise();
      await fs.writeFile(tempFile, data.Body);
      localVideoPath = tempFile;
      console.log(`✅ Video downloaded to: ${tempFile}`);
    }

    // Create temporary directory for HLS files
    tempDir = path.join('/tmp', `hls_${videoId}`);
    await fs.mkdir(tempDir, { recursive: true });
    console.log(`📁 Created temp directory: ${tempDir}`);

    // Convert to HLS
    const m3u8Path = await convertToHLS(localVideoPath, tempDir);
    console.log(`✅ HLS conversion completed: ${m3u8Path}`);

    // Upload HLS files to S3
    const s3Prefix = `hls/${videoId}`;
    const hlsUrl = await uploadHLSToS3(tempDir, s3Prefix);
    console.log(`✅ HLS uploaded to S3: ${hlsUrl}`);

    return hlsUrl;
  } catch (error) {
    console.error('❌ Error in HLS conversion:', error.message);
    console.warn('⚠️ Falling back to original video URL');
    return videoPath; // Return original video URL as fallback
  } finally {
    // Cleanup temporary files
    if (tempDir) {
      try {
        await fs.rm(tempDir, { recursive: true, force: true });
        console.log(`🗑️ Cleaned up temp directory: ${tempDir}`);
      } catch (cleanupError) {
        console.warn('⚠️ Error cleaning up temp directory:', cleanupError);
      }
    }

    // Cleanup downloaded video if it was from S3
    if (localVideoPath !== videoPath && localVideoPath.includes('/tmp')) {
      try {
        await fs.unlink(localVideoPath);
        console.log(`🗑️ Cleaned up downloaded video: ${localVideoPath}`);
      } catch (cleanupError) {
        console.warn('⚠️ Error cleaning up downloaded video:', cleanupError);
      }
    }
  }
}

module.exports = {
  convertToHLS,
  uploadHLSToS3,
  convertVideoToHLS,
  convertVideoToHLSAsync,
};

/**
 * Async background HLS conversion (non-blocking)
 * Converts video to HLS in the background and updates the entry when done
 * @param {string} videoUrl - URL of the video
 * @param {string} videoId - Unique ID for the video
 * @param {string} entryId - SYT Entry ID to update
 */
async function convertVideoToHLSAsync(videoUrl, videoId, entryId) {
  // Run conversion in background without blocking
  setImmediate(async () => {
    try {
      console.log(`🎬 Starting async HLS conversion for entry ${entryId}...`);
      const hlsUrl = await convertVideoToHLS(videoUrl, videoId);
      
      if (hlsUrl !== videoUrl) {
        // HLS conversion was successful, update the entry
        const SYTEntry = require('../models/SYTEntry');
        await SYTEntry.findByIdAndUpdate(entryId, { videoUrl: hlsUrl });
        console.log(`✅ Entry ${entryId} updated with HLS URL: ${hlsUrl}`);
      }
    } catch (error) {
      console.error(`❌ Async HLS conversion failed for entry ${entryId}:`, error.message);
      // Entry already has original video URL, so it's not critical
    }
  });
}
