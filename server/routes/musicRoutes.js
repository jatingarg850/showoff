const express = require('express');
const router = express.Router();
const musicController = require('../controllers/musicController');
const { protect } = require('../middleware/auth');

// Public music endpoints
router.get('/approved', musicController.getApprovedMusic);
router.get('/search', musicController.searchMusic);
router.get('/:id', musicController.getMusic);

module.exports = router;
