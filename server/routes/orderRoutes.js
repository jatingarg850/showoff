const express = require('express');
const router = express.Router();
const {
  createRazorpayOrder,
  verifyPayment,
  createOrder,
  getOrders,
  getOrder,
} = require('../controllers/orderController');
const { protect } = require('../middleware/auth');

router.post('/create-razorpay-order', protect, createRazorpayOrder);
router.post('/verify-payment', protect, verifyPayment);
router.post('/', protect, createOrder);
router.get('/', protect, getOrders);
router.get('/:id', protect, getOrder);

module.exports = router;
