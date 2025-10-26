const express = require('express');
const router = express.Router();
const {
  watchAd,
  spinWheel,
  getTransactions,
  sendGift,
  getBalance,
} = require('../controllers/coinController');
const { protect } = require('../middleware/auth');

router.post('/watch-ad', protect, watchAd);
router.post('/spin-wheel', protect, spinWheel);
router.get('/transactions', protect, getTransactions);
router.post('/gift', protect, sendGift);
router.get('/balance', protect, getBalance);

module.exports = router;
