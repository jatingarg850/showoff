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
  googleAuth,
  googleRedirect,
  googleCallback
} = require('../controllers/authController');
const { protect } = require('../middleware/auth');

router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);
router.post('/resend-otp', sendOTP); // Reuse sendOTP for resend
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

module.exports = router;
