const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const fs = require('fs').promises;
const AWS = require('aws-sdk');

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
 * Generate thumbnail from video URL
 * @param {string} videoUrl - URL of the video (local or S3)
 * @param {string} outputPath - Where to save the thumbnail locally
 * @returns {Promise<string>} - Path to generated thumbnail
 */
async function generateThumbnailFromUrl(videoUrl, outputPath) {
  return new Promise((resolve, reject) => {
    ffmpeg(videoUrl)
      .on('error', (err) => {
        console.error('FFmpeg error:', err);
        reject(err);
      })
      .on('end', () => {
        console.log('✅ Thumbnail generated:', outputPath);
        resolve(outputPath);
      })
      .screenshot({
        count: 1,
        filename: path.basename(outputPath),
        folder: path.dirname(outputPath),
        size: '640x1080', // Portrait size for mobile
        timestamps: ['1%'], // Take screenshot at 1% of video (very beginning)
      });
  });
}

/**
 * Upload thumbnail to Wasabi S3
 * @param {string} localPath - Local path to thumbnail file
 * @param {string} fileName - Name for the file in S3
 * @returns {Promise<string>} - S3 URL of uploaded thumbnail
 */
async function uploadThumbnailToS3(localPath, fileName) {
  try {
    const fileContent = await fs.readFile(localPath);
    
    const params = {
      Bucket: process.env.WASABI_BUCKET_NAME,
      Key: `thumbnails/${fileName}`,
      Body: fileContent,
      ContentType: 'image/jpeg',
      ACL: 'public-read',
    };

    const result = await s3.upload(params).promise();
    
    // Construct public URL
    const region = process.env.WASABI_REGION || 'ap-southeast-1';
    const bucketName = process.env.WASABI_BUCKET_NAME;
    const thumbnailUrl = `https://s3.${region}.wasabisys.com/${bucketName}/thumbnails/${fileName}`;
    
    console.log('✅ Thumbnail uploaded to S3:', thumbnailUrl);
    return thumbnailUrl;
  } catch (error) {
    console.error('Error uploading thumbnail to S3:', error);
    throw error;
  }
}

/**
 * Generate and upload thumbnail for a video
 * @param {string} videoUrl - URL of the video
 * @param {string} videoId - ID of the video (for naming)
 * @returns {Promise<string>} - S3 URL of the generated thumbnail
 */
async function generateAndUploadThumbnail(videoUrl, videoId) {
  try {
    // Create temp directory if it doesn't exist
    const tempDir = path.join(__dirname, '../temp');
    try {
      await fs.mkdir(tempDir, { recursive: true });
    } catch (e) {
      // Directory might already exist
    }

    // Generate thumbnail locally
    const localThumbnailPath = path.join(tempDir, `thumb_${videoId}.jpg`);
    await generateThumbnailFromUrl(videoUrl, localThumbnailPath);

    // Upload to S3
    const fileName = `thumb_${videoId}_${Date.now()}.jpg`;
    const s3Url = await uploadThumbnailToS3(localThumbnailPath, fileName);

    // Clean up local file
    try {
      await fs.unlink(localThumbnailPath);
    } catch (e) {
      console.warn('Could not delete temp thumbnail:', e);
    }

    return s3Url;
  } catch (error) {
    console.error('Error in generateAndUploadThumbnail:', error);
    throw error;
  }
}

module.exports = {
  generateThumbnailFromUrl,
  uploadThumbnailToS3,
  generateAndUploadThumbnail,
};
