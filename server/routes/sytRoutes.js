const express = require('express');
const router = express.Router();
const {
  submitEntry,
  getEntries,
  voteEntry,
  getLeaderboard,
  toggleLike,
  getEntryStats,
  toggleBookmark,
} = require('../controllers/sytController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/submit', protect, upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), submitEntry);
router.get('/entries', getEntries);
router.post('/:id/vote', protect, voteEntry);
router.post('/:id/like', protect, toggleLike);
router.post('/:id/bookmark', protect, toggleBookmark);
router.get('/:id/stats', protect, getEntryStats);
router.get('/leaderboard', getLeaderboard);

module.exports = router;
