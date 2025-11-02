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

// Test endpoint to check Razorpay configuration
router.get('/test-razorpay', protect, async (req, res) => {
  try {
    console.log('🧪 Testing Razorpay configuration...');
    console.log('RAZORPAY_KEY_ID:', process.env.RAZORPAY_KEY_ID ? 'Set' : 'Not set');
    console.log('RAZORPAY_KEY_SECRET:', process.env.RAZORPAY_KEY_SECRET ? 'Set' : 'Not set');
    
    const Razorpay = require('razorpay');
    const testRazorpay = new Razorpay({
      key_id: process.env.RAZORPAY_KEY_ID,
      key_secret: process.env.RAZORPAY_KEY_SECRET,
    });
    
    // Try to create a test order
    const testOrder = await testRazorpay.orders.create({
      amount: 100, // ₹1.00 in paise
      currency: 'INR',
      receipt: `test_${Date.now()}`,
      notes: {
        test: 'true'
      }
    });
    
    res.json({
      success: true,
      message: 'Razorpay is working correctly',
      testOrderId: testOrder.id,
      razorpayConfigured: true
    });
  } catch (error) {
    console.error('❌ Razorpay test failed:', error);
    res.status(500).json({
      success: false,
      message: 'Razorpay configuration error',
      error: error.message,
      razorpayConfigured: false
    });
  }
});

// Test signature verification
router.post('/test-signature', protect, async (req, res) => {
  try {
    const { razorpayOrderId, razorpayPaymentId, razorpaySignature } = req.body;
    
    console.log('🧪 Testing signature verification...');
    console.log('Order ID:', razorpayOrderId);
    console.log('Payment ID:', razorpayPaymentId);
    console.log('Signature:', razorpaySignature);
    
    const crypto = require('crypto');
    const sign = razorpayOrderId + '|' + razorpayPaymentId;
    const expectedSign = crypto
      .createHmac('sha256', process.env.RAZORPAY_KEY_SECRET)
      .update(sign.toString())
      .digest('hex');
    
    console.log('Expected signature:', expectedSign);
    console.log('Signatures match:', razorpaySignature === expectedSign);
    
    res.json({
      success: true,
      signatureValid: razorpaySignature === expectedSign,
      expectedSignature: expectedSign,
      receivedSignature: razorpaySignature
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Test demo payment
router.post('/test-demo-payment', protect, async (req, res) => {
  try {
    console.log('🧪 Testing demo payment...');
    
    // Simulate a demo payment
    const demoPaymentData = {
      amount: 100,
      gateway: 'razorpay',
      paymentData: {
        razorpayOrderId: 'order_demo_test',
        razorpayPaymentId: 'pay_demo_' + Date.now(),
        razorpaySignature: 'demo_signature'
      }
    };
    
    console.log('Demo payment data:', demoPaymentData);
    
    res.json({
      success: true,
      message: 'Demo payment data generated',
      demoPaymentData,
      note: 'Use this data to test the /api/coins/add-money endpoint'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
