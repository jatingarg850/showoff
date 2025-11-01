const express = require('express');
const router = express.Router();
const {
  watchAd,
  spinWheel,
  getTransactions,
  sendGift,
  getBalance,
  purchaseCoins,
  createCoinPurchaseOrder,
  createStripePaymentIntent,
  confirmStripePayment,
  addMoney,
} = require('../controllers/coinController');
const { protect } = require('../middleware/auth');

router.post('/watch-ad', protect, watchAd);
router.post('/spin-wheel', protect, spinWheel);
router.get('/transactions', protect, getTransactions);
router.post('/gift', protect, sendGift);
router.get('/balance', protect, getBalance);
router.post('/purchase', protect, purchaseCoins);
router.post('/create-purchase-order', protect, createCoinPurchaseOrder);
router.post('/create-stripe-intent', protect, createStripePaymentIntent);
router.post('/confirm-stripe-payment', protect, confirmStripePayment);
router.post('/add-money', protect, addMoney);

module.exports = router;
