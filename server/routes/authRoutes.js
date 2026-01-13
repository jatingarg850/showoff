const express = require('express');
const router = express.Router();
const { 
  register, 
  login, 
  getMe, 
  sendOTP, 
  verifyOTP, 
  checkUsername,
  checkEmail,
  checkPhone,
  phoneLogin, 
  phoneEmailVerify,
  signInPhoneOTP,
  googleAuth,
  googleRedirect,
  googleCallback
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);
router.post('/resend-otp', sendOTP); // Reuse sendOTP for resend
router.post('/signin-phone-otp', signInPhoneOTP); // Sign in with phone OTP
router.post('/check-username', checkUsername);
router.post('/check-email', checkEmail);
router.post('/check-phone', checkPhone);
router.post('/register', register);
router.post('/login', login);
router.post('/phone-login', phoneLogin); // Phone.email login (Flutter app)
router.post('/phone-email-verify', phoneEmailVerify); // Phone.email web button verification
router.options('/phone-email-verify', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type');
  res.sendStatus(200);
}); // Handle CORS preflight

// Google OAuth routes
router.post('/google', googleAuth); // Google Sign-In with ID token (Flutter/Mobile)
router.get('/google/redirect', googleRedirect); // Web OAuth flow - redirect to Google
router.get('/google/callback', googleCallback); // Web OAuth flow - callback from Google

router.get('/me', protect, getMe);

// Get Gemini API Key for AI features (public endpoint, no auth required)
router.get('/config/gemini-key', (req, res) => {
  try {
    const geminiKey = process.env.GEMINI_API_KEY;
    
    if (!geminiKey) {
      return res.status(500).json({
        success: false,
        message: 'Gemini API key not configured on server',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        apiKey: geminiKey,
        model: 'gemini-2.5-flash',
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

// Get Razorpay Key for payments (public endpoint, returns only public key)
router.get('/config/razorpay-key', (req, res) => {
  try {
    const razorpayKey = process.env.RAZORPAY_KEY_ID;
    
    if (!razorpayKey) {
      return res.status(500).json({
        success: false,
        message: 'Razorpay key not configured on server',
      });
    }

    res.status(200).json({
      success: true,
      key: razorpayKey,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
});

module.exports = router;
