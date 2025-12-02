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

// @desc    Generate pre-signed URL for video streaming
// @route   POST /api/videos/presigned-url
// @access  Public (for faster loading)
exports.getPresignedUrl = async (req, res) => {
  try {
    const { videoUrl } = req.body;

    if (!videoUrl) {
      return res.status(400).json({
        success: false,
        message: 'Video URL is required',
      });
    }

    // Extract key from Wasabi URL
    let key;
    if (videoUrl.includes('wasabisys.com')) {
      // Extract key from full Wasabi URL
      const urlParts = videoUrl.split('.com/');
      if (urlParts.length > 1) {
        const pathParts = urlParts[1].split('/');
        // Remove bucket name and get the rest
        key = pathParts.slice(1).join('/');
      }
    } else if (videoUrl.startsWith('videos/') || videoUrl.startsWith('images/')) {
      // Already a key
      key = videoUrl;
    } else {
      return res.status(400).json({
        success: false,
        message: 'Invalid video URL format',
      });
    }

    // Generate pre-signed URL with 1 hour expiry
    const params = {
      Bucket: process.env.WASABI_BUCKET_NAME,
      Key: key,
      Expires: 3600, // 1 hour
      ResponseCacheControl: 'max-age=3600',
      ResponseContentType: 'video/mp4',
    };

    const presignedUrl = await s3.getSignedUrlPromise('getObject', params);

    res.json({
      success: true,
      data: {
        presignedUrl,
        expiresIn: 3600,
        originalUrl: videoUrl,
      },
    });
  } catch (error) {
    console.error('Error generating pre-signed URL:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate pre-signed URL',
      error: error.message,
    });
  }
};

// @desc    Generate pre-signed URLs for multiple videos (batch)
// @route   POST /api/videos/presigned-urls-batch
// @access  Public
exports.getPresignedUrlsBatch = async (req, res) => {
  try {
    const { videoUrls } = req.body;

    if (!videoUrls || !Array.isArray(videoUrls)) {
      return res.status(400).json({
        success: false,
        message: 'videoUrls array is required',
      });
    }

    const results = await Promise.all(
      videoUrls.map(async (videoUrl) => {
        try {
          // Extract key from Wasabi URL
          let key;
          if (videoUrl.includes('wasabisys.com')) {
            const urlParts = videoUrl.split('.com/');
            if (urlParts.length > 1) {
              const pathParts = urlParts[1].split('/');
              key = pathParts.slice(1).join('/');
            }
          } else if (videoUrl.startsWith('videos/') || videoUrl.startsWith('images/')) {
            key = videoUrl;
          } else {
            return {
              originalUrl: videoUrl,
              presignedUrl: videoUrl,
              error: 'Invalid URL format',
            };
          }

          const params = {
            Bucket: process.env.WASABI_BUCKET_NAME,
            Key: key,
            Expires: 3600,
            ResponseCacheControl: 'max-age=3600',
            ResponseContentType: 'video/mp4',
          };

          const presignedUrl = await s3.getSignedUrlPromise('getObject', params);

          return {
            originalUrl: videoUrl,
            presignedUrl,
            expiresIn: 3600,
          };
        } catch (error) {
          return {
            originalUrl: videoUrl,
            presignedUrl: videoUrl,
            error: error.message,
          };
        }
      })
    );

    res.json({
      success: true,
      data: results,
    });
  } catch (error) {
    console.error('Error generating batch pre-signed URLs:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate pre-signed URLs',
      error: error.message,
    });
  }
};
