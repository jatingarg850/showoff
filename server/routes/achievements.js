const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/auth');
const {
  getUserAchievements,
  checkAndUnlockAchievements,
  initializeAchievements,
} = require('../controllers/achievementController');

// @route   GET /api/achievements
// @desc    Get user achievements with progress
// @access  Private
router.get('/', protect, getUserAchievements);

// @route   POST /api/achievements/check
// @desc    Check and unlock new achievements
// @access  Private
router.post('/check', protect, checkAndUnlockAchievements);

// @route   POST /api/achievements/init
// @desc    Initialize default achievements (Admin only)
// @access  Private
router.post('/init', protect, initializeAchievements);

module.exports = router;