const express = require('express');
const router = express.Router();
const {
  getVideoAdsForApp,
  getAllVideoAds,
  createVideoAd,
  updateVideoAd,
  deleteVideoAd,
  trackVideoAdView,
  trackVideoAdCompletion,
  resetVideoAdStats
} = require('../controllers/videoAdController');
const { protect, adminOnly } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes
router.get('/video-ads', getVideoAdsForApp);
router.post('/video-ads/:id/view', protect, trackVideoAdView);
router.post('/video-ads/:id/complete', protect, trackVideoAdCompletion);

// Admin routes
router.get('/admin/video-ads', protect, adminOnly, getAllVideoAds);
router.post('/admin/video-ads', protect, adminOnly, upload.single('video'), createVideoAd);
router.put('/admin/video-ads/:id', protect, adminOnly, updateVideoAd);
router.delete('/admin/video-ads/:id', protect, adminOnly, deleteVideoAd);
router.post('/admin/video-ads/:id/reset-stats', protect, adminOnly, resetVideoAdStats);

module.exports = router;
