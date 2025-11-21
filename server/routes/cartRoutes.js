const express = require('express');
const router = express.Router();
const {
  getCart,
  addToCart,
  updateCartItem,
  removeFromCart,
  clearCart,
  checkout,
  processPayment,
  createCartRazorpayOrder,
} = require('../controllers/cartController');
const { protect } = require('../middleware/auth');

router.get('/', protect, getCart);
router.post('/add', protect, addToCart);
router.put('/update/:itemId', protect, updateCartItem);
router.delete('/remove/:itemId', protect, removeFromCart);
router.delete('/clear', protect, clearCart);
router.post('/checkout', protect, checkout);
router.post('/create-razorpay-order', protect, createCartRazorpayOrder);
router.post('/process-payment', protect, processPayment);

module.exports = router;
