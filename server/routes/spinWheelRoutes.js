const express = require('express');
const router = express.Router();
const { getSpinStatus, spinWheel } = require('../controllers/spinWheelController');
const { protect } = require('../middleware/auth');

router.get('/status', protect, getSpinStatus);
router.post('/spin', protect, spinWheel);

module.exports = router;
