const express = require('express');
const router = express.Router();
const {
  submitEntry,
  getEntries,
  voteEntry,
  getLeaderboard,
} = require('../controllers/sytController');
const { protect } = require('../middleware/auth');
const upload = require('../middleware/upload');

router.post('/submit', protect, upload.single('video'), submitEntry);
router.get('/entries', getEntries);
router.post('/:id/vote', protect, voteEntry);
router.get('/leaderboard', getLeaderboard);

module.exports = router;
