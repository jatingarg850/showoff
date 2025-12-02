const express = require('express');
const router = express.Router();
const {
  getPresignedUrl,
  getPresignedUrlsBatch,
} = require('../controllers/videoController');

// Public routes for faster video loading
router.post('/presigned-url', getPresignedUrl);
router.post('/presigned-urls-batch', getPresignedUrlsBatch);

module.exports = router;
