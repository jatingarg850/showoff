const multer = require('multer');
const multerS3 = require('multer-s3');
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const wasabiClient = require('../config/wasabi');
const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs');

// File filter
const fileFilter = (req, file, cb) => {
  // Default allowed types if env vars are not set
  const defaultImageTypes = ['image/jpeg', 'image/png', 'image/jpg', 'image/webp'];
  const defaultVideoTypes = ['video/mp4', 'video/mpeg', 'video/quicktime', 'video/x-msvideo'];
  
  const allowedImageTypes = process.env.ALLOWED_IMAGE_TYPES 
    ? process.env.ALLOWED_IMAGE_TYPES.split(',').map(type => type.trim())
    : defaultImageTypes;
  const allowedVideoTypes = process.env.ALLOWED_VIDEO_TYPES 
    ? process.env.ALLOWED_VIDEO_TYPES.split(',').map(type => type.trim())
    : defaultVideoTypes;
  const allowedTypes = [...allowedImageTypes, ...allowedVideoTypes];

  console.log('File mimetype:', file.mimetype);
  console.log('File originalname:', file.originalname);

  // Check if mimetype is valid
  if (allowedTypes.includes(file.mimetype)) {
    cb(null, true);
    return;
  }

  // Handle application/octet-stream by checking file extension
  if (file.mimetype === 'application/octet-stream') {
    const ext = path.extname(file.originalname).toLowerCase();
    const imageExtensions = ['.jpg', '.jpeg', '.png', '.webp'];
    const videoExtensions = ['.mp4', '.mpeg', '.mov', '.avi'];
    
    if (imageExtensions.includes(ext)) {
      console.log('Accepting file based on image extension:', ext);
      // Override mimetype for proper handling
      file.mimetype = 'image/jpeg';
      cb(null, true);
      return;
    }
    
    if (videoExtensions.includes(ext)) {
      console.log('Accepting file based on video extension:', ext);
      // Override mimetype for proper handling
      file.mimetype = 'video/mp4';
      cb(null, true);
      return;
    }
  }

  console.log('Rejected file - Invalid type');
  cb(new Error(`Invalid file type: ${file.mimetype}. Only images and videos are allowed.`), false);
};

// Check if S3 is configured with real values (not placeholders)
const isS3Configured = process.env.WASABI_BUCKET_NAME && 
                       process.env.WASABI_ACCESS_KEY_ID && 
                       process.env.WASABI_SECRET_ACCESS_KEY &&
                       !process.env.WASABI_ACCESS_KEY_ID.includes('your_') &&
                       !process.env.WASABI_BUCKET_NAME.includes('your_');

let storage;

if (isS3Configured && wasabiClient) {
  console.log('✅ Using Wasabi S3 for file uploads');
  // Use S3 storage when configured
  try {
    storage = multerS3({
      s3: wasabiClient,
      bucket: process.env.WASABI_BUCKET_NAME,
      acl: 'public-read',
      contentType: multerS3.AUTO_CONTENT_TYPE,
      metadata: function (req, file, cb) {
        cb(null, { fieldName: file.fieldname });
      },
      key: function (req, file, cb) {
        // Determine folder based on mimetype or file extension
        let folder = 'images';
        if (file.mimetype.startsWith('video/')) {
          folder = 'videos';
        } else if (file.mimetype.startsWith('image/')) {
          folder = 'images';
        } else {
          // Fallback to extension check
          const ext = path.extname(file.originalname).toLowerCase();
          const videoExtensions = ['.mp4', '.mpeg', '.mov', '.avi'];
          folder = videoExtensions.includes(ext) ? 'videos' : 'images';
        }
        
        const fileName = `${folder}/${uuidv4()}${path.extname(file.originalname)}`;
        cb(null, fileName);
      },
    });
  } catch (error) {
    console.error('❌ Error configuring Wasabi S3:', error.message);
    console.log('⚠️  Falling back to local storage');
    isS3Configured = false;
  }
}

if (!isS3Configured || !wasabiClient) {
  // Use local storage as fallback
  console.log('⚠️  S3 not configured, using local storage for uploads');
  
  // Create uploads directory if it doesn't exist
  const uploadDir = path.join(__dirname, '../uploads');
  if (!fs.existsSync(uploadDir)) {
    fs.mkdirSync(uploadDir, { recursive: true });
  }
  
  storage = multer.diskStorage({
    destination: function (req, file, cb) {
      // Determine folder based on mimetype or file extension
      let folder = 'images';
      if (file.mimetype.startsWith('video/')) {
        folder = 'videos';
      } else if (file.mimetype.startsWith('image/')) {
        folder = 'images';
      } else {
        // Fallback to extension check
        const ext = path.extname(file.originalname).toLowerCase();
        const videoExtensions = ['.mp4', '.mpeg', '.mov', '.avi'];
        folder = videoExtensions.includes(ext) ? 'videos' : 'images';
      }
      
      const folderPath = path.join(__dirname, '../uploads', folder);
      
      if (!fs.existsSync(folderPath)) {
        fs.mkdirSync(folderPath, { recursive: true });
      }
      
      cb(null, folderPath);
    },
    filename: function (req, file, cb) {
      const fileName = `${uuidv4()}${path.extname(file.originalname)}`;
      cb(null, fileName);
    }
  });
}

const upload = multer({
  storage: storage,
  fileFilter: fileFilter,
  limits: {
    // 500MB limit - use env var or default to 500MB
    fileSize: parseInt(process.env.MAX_FILE_SIZE) || 500 * 1024 * 1024,
  },
});

module.exports = upload;
