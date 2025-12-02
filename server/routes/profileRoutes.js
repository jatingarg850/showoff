const express = require('express');
const router = express.Router();
const {
  updateProfile,
  uploadProfilePicture,
  getUserProfile,
  getMyStats,
  applyReferralCode,
} = require('../controllers/profileController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.put('/', protect, updateProfile);
router.post('/picture', protect, upload.single('image'), uploadProfilePicture);
router.post('/apply-referral', protect, applyReferralCode);
router.get('/stats', protect, getMyStats);
router.get('/:username', getUserProfile);

module.exports = router;
