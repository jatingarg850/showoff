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
  checkUserWeeklySubmission,
  checkUserSubmission,
  getCurrentCompetitionInfo,
  getCompetitions,
  createCompetition,
  updateCompetition,
  deleteCompetition,
  shareSYTEntry,
} = require('../controllers/sytController');
const { protect, adminOnly, checkAdminSession } = require('../middleware/auth');
const upload = require('../middleware/upload');

// Public routes
router.get('/entries', getEntries);
router.get('/leaderboard', getLeaderboard);
router.get('/current-competition', getCurrentCompetitionInfo);
router.get('/competitions/all', getCompetitions); // Get all competitions (for debugging)

// Protected routes (require authentication)
router.post('/submit', protect, upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), submitEntry);
router.post('/:id/vote', protect, voteEntry);
router.post('/:id/like', protect, toggleLike);
router.post('/:id/bookmark', protect, toggleBookmark);
router.post('/:id/share', protect, shareSYTEntry);
router.get('/:id/stats', protect, getEntryStats);
router.get('/check-submission', protect, checkUserSubmission);
router.get('/weekly-check', protect, checkUserWeeklySubmission); // Legacy endpoint

// Admin routes (JWT-based for API)
router.get('/admin/competitions', protect, adminOnly, getCompetitions);
router.post('/admin/competitions', protect, adminOnly, createCompetition);
router.put('/admin/competitions/:id', protect, adminOnly, updateCompetition);
router.delete('/admin/competitions/:id', protect, adminOnly, deleteCompetition);

// Admin routes (Session-based for web admin panel)
router.get('/admin-web/competitions', checkAdminSession, getCompetitions);
router.post('/admin-web/competitions', checkAdminSession, createCompetition);
router.put('/admin-web/competitions/:id', checkAdminSession, updateCompetition);
router.delete('/admin-web/competitions/:id', checkAdminSession, deleteCompetition);

module.exports = router;
