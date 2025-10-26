const express = require('express');
const router = express.Router();
const {
  submitDailySelfie,
  getDailySelfies,
  voteDailySelfie,
  getDailySelfieLeaderboard,
  getUserStreak,
  getTodayChallenge,
} = require('../controllers/dailySelfieController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes
router.get('/entries', getDailySelfies);
router.get('/leaderboard', getDailySelfieLeaderboard);
router.get('/today', getTodayChallenge);

// Protected routes
router.post('/submit', protect, upload.single('image'), submitDailySelfie);
router.post('/:id/vote', protect, voteDailySelfie);
router.get('/streak', protect, getUserStreak);

module.exports = router;