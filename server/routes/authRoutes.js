const express = require('express');
const router = express.Router();
const { register, login, getMe, sendOTP, verifyOTP, checkUsername, phoneLogin } = require('../controllers/authController');
const { protect } = require('../middleware/auth');

router.post('/send-otp', sendOTP);
router.post('/verify-otp', verifyOTP);
router.post('/resend-otp', sendOTP); // Reuse sendOTP for resend
router.post('/check-username', checkUsername);
router.post('/register', register);
router.post('/login', login);
router.post('/phone-login', phoneLogin); // Phone.email login
router.get('/me', protect, getMe);

module.exports = router;
