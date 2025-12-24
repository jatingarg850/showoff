const express = require('express');
const router = express.Router();
const {
  getCurrentTerms,
  acceptTerms,
  getTermsByVersion,
  createTerms,
  updateTerms,
  getAllTerms,
  deleteTerms,
} = require('../controllers/termsController');
const { protect, adminOnly } = require('../middleware/auth');

// Public routes
router.get('/current', getCurrentTerms);
router.get('/:version', getTermsByVersion);

// Private routes
router.post('/accept', protect, acceptTerms);

// Admin routes
router.post('/', protect, adminOnly, createTerms);
router.get('/', protect, adminOnly, getAllTerms);
router.put('/:id', protect, adminOnly, updateTerms);
router.delete('/:id', protect, adminOnly, deleteTerms);

module.exports = router;
