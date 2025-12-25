const express = require('express');
const router = express.Router();
const {
  getDashboardStats,
  getUsers,
  getPosts,
  getFinancialOverview,
  updateUserStatus
} = require('../controllers/adminController');
const { protect, adminOnly } = require('../middleware/auth');

// Middleware to check if user is admin via session or JWT
const adminProtect = async (req, res, next) => {
  console.log('🔐 Admin Protect Middleware');
  console.log('  - Path:', req.path);
  console.log('  - Method:', req.method);
  console.log('  - Session ID:', req.sessionID);
  console.log('  - Session Data:', req.session);
  console.log('  - Has Authorization Header:', !!req.headers.authorization);
  
  // Check for session-based authentication first (for web admin panel)
  if (req.session && req.session.isAdmin) {
    console.log('✅ Admin authenticated via session');
    req.user = { role: 'admin', id: 'admin' };
    return next();
  }

  // Fallback to JWT authentication (for API calls)
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
    console.log('❌ No session or JWT token found');
    return res.status(401).json({
      success: false,
      message: 'Not authorized to access this route',
    });
  }

  try {
    const jwt = require('jsonwebtoken');
    const User = require('../models/User');
    
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    const user = await User.findById(decoded.id);
    
    if (!user) {
      return res.status(401).json({
        success: false,
        message: 'User not found',
      });
    }

    if (user.role !== 'admin') {
      return res.status(403).json({
        success: false,
        message: 'Admin access required',
      });
    }

    req.user = user;
    next();
  } catch (error) {
    return res.status(401).json({
      success: false,
      message: 'Not authorized to access this route',
    });
  }
};

// Apply admin protection to all routes
router.use(adminProtect);

// Dashboard
router.get('/dashboard', getDashboardStats);

// User Management
router.get('/users', getUsers);
router.get('/users/:id', require('../controllers/adminController').getUserDetails);
router.put('/users/:id/status', updateUserStatus);
router.put('/users/:id/verify', require('../controllers/adminController').updateUserVerification);
router.put('/users/:id/coins', require('../controllers/adminController').updateUserCoins);
router.delete('/users/:id', require('../controllers/adminController').deleteUser);

// Content Moderation
router.get('/posts', getPosts);
router.put('/posts/:id/status', require('../controllers/adminController').updatePostStatus);
router.delete('/posts/:id', require('../controllers/adminController').deletePost);

// Analytics
router.get('/analytics', require('../controllers/adminController').getSystemAnalytics);

// System Settings
router.get('/settings', require('../controllers/adminController').getSystemSettings);
router.put('/settings', require('../controllers/adminController').updateSystemSettings);

// Financial Management
router.get('/financial', getFinancialOverview);

// Withdrawal Management
router.get('/withdrawals', require('../controllers/adminController').getWithdrawals);
router.get('/withdrawals/:id', require('../controllers/adminController').getWithdrawalDetails);
router.put('/withdrawals/:id', require('../controllers/adminController').updateWithdrawalStatus);
router.put('/withdrawals/:id/approve', require('../controllers/adminController').approveWithdrawal);
router.put('/withdrawals/:id/reject', require('../controllers/adminController').rejectWithdrawal);

// Product Management
const upload = require('../middleware/upload');
router.post('/products', require('../controllers/adminController').createProduct);
router.put('/products/:id', require('../controllers/adminController').updateProduct);
router.delete('/products/:id', require('../controllers/adminController').deleteProduct);
router.put('/products/:id/toggle', require('../controllers/adminController').toggleProductStatus);
router.post('/products/upload-images', upload.array('images', 5), require('../controllers/adminController').uploadProductImages);

// SYT/Talent Management
router.get('/syt', require('../controllers/adminController').getSYTEntries);
router.put('/syt/:id/toggle', require('../controllers/adminController').toggleSYTEntry);
router.put('/syt/:id/winner', require('../controllers/adminController').declareSYTWinner);
router.delete('/syt/:id', require('../controllers/adminController').deleteSYTEntry);

// Rewarded Ads Management
router.get('/rewarded-ads', require('../controllers/adminController').getRewardedAds);
router.get('/rewarded-ads/:adNumber', require('../controllers/adminController').getRewardedAdById);
router.put('/rewarded-ads/:adNumber', require('../controllers/adminController').updateRewardedAd);
router.post('/rewarded-ads/:adNumber/reset-stats', require('../controllers/adminController').resetAdStats);

// Music Management
router.get('/music', require('../controllers/adminController').getMusic);
router.put('/music/:id/approve', require('../controllers/adminController').approveMusic);
router.delete('/music/:id', require('../controllers/adminController').deleteMusic);

// User Earnings
router.get('/users/:id/earnings', require('../controllers/adminController').getUserEarnings);
router.get('/top-earners', require('../controllers/adminController').getTopEarners);

// Public Ad Routes (for mobile app)
router.get('/ads', require('../controllers/adminController').getAdsForApp);
router.post('/ads/:adNumber/click', require('../controllers/adminController').trackAdClick);
router.post('/ads/:adNumber/conversion', require('../controllers/adminController').trackAdConversion);

// System Integration Testing
const SystemTestController = require('../controllers/systemTestController');

// Database Tests
router.post('/system-tests/db-connect', require('../middleware/auth').adminOnly, SystemTestController.testDatabaseConnection);
router.post('/system-tests/db-users', require('../middleware/auth').adminOnly, SystemTestController.testUsersCollection);
router.post('/system-tests/db-posts', require('../middleware/auth').adminOnly, SystemTestController.testPostsCollection);
router.post('/system-tests/db-transactions', require('../middleware/auth').adminOnly, SystemTestController.testTransactionsCollection);
router.post('/system-tests/db-indexes', require('../middleware/auth').adminOnly, SystemTestController.testDatabaseIndexes);

// API Tests
router.post('/system-tests/api-health', require('../middleware/auth').adminOnly, SystemTestController.testHealthCheck);
router.post('/system-tests/api-users', require('../middleware/auth').adminOnly, SystemTestController.testUsersAPI);
router.post('/system-tests/api-posts', require('../middleware/auth').adminOnly, SystemTestController.testPostsAPI);
router.post('/system-tests/api-coins', require('../middleware/auth').adminOnly, SystemTestController.testCoinsAPI);
router.post('/system-tests/api-auth', require('../middleware/auth').adminOnly, SystemTestController.testAuthAPI);

// Auth Tests
router.post('/system-tests/auth-register', require('../middleware/auth').adminOnly, SystemTestController.testUserRegistration);
router.post('/system-tests/auth-login', require('../middleware/auth').adminOnly, SystemTestController.testUserLogin);
router.post('/system-tests/auth-token', require('../middleware/auth').adminOnly, SystemTestController.testTokenValidation);
router.post('/system-tests/auth-refresh', require('../middleware/auth').adminOnly, SystemTestController.testTokenRefresh);
router.post('/system-tests/auth-logout', require('../middleware/auth').adminOnly, SystemTestController.testUserLogout);

// Notification Tests
router.post('/system-tests/notif-fcm', require('../middleware/auth').adminOnly, SystemTestController.testFCMConnection);
router.post('/system-tests/notif-send', require('../middleware/auth').adminOnly, SystemTestController.testSendNotification);
router.post('/system-tests/notif-receive', require('../middleware/auth').adminOnly, SystemTestController.testReceiveNotification);
router.post('/system-tests/notif-topics', require('../middleware/auth').adminOnly, SystemTestController.testTopicSubscriptions);

// Payment Tests
router.post('/system-tests/pay-stripe', require('../middleware/auth').adminOnly, SystemTestController.testStripeIntegration);
router.post('/system-tests/pay-razorpay', require('../middleware/auth').adminOnly, SystemTestController.testRazorpayIntegration);
router.post('/system-tests/pay-webhook', require('../middleware/auth').adminOnly, SystemTestController.testPaymentWebhooks);
router.post('/system-tests/pay-verify', require('../middleware/auth').adminOnly, SystemTestController.testPaymentVerification);

// Storage Tests
router.post('/system-tests/storage-wasabi', require('../middleware/auth').adminOnly, SystemTestController.testWasabiConnection);
router.post('/system-tests/storage-upload', require('../middleware/auth').adminOnly, SystemTestController.testFileUpload);
router.post('/system-tests/storage-download', require('../middleware/auth').adminOnly, SystemTestController.testFileDownload);
router.post('/system-tests/storage-delete', require('../middleware/auth').adminOnly, SystemTestController.testFileDeletion);

// Cache Tests
router.post('/system-tests/cache-redis', require('../middleware/auth').adminOnly, SystemTestController.testRedisConnection);
router.post('/system-tests/cache-set', require('../middleware/auth').adminOnly, SystemTestController.testCacheSet);
router.post('/system-tests/cache-get', require('../middleware/auth').adminOnly, SystemTestController.testCacheGet);
router.post('/system-tests/cache-clear', require('../middleware/auth').adminOnly, SystemTestController.testCacheClear);

// Email Tests
router.post('/system-tests/email-smtp', require('../middleware/auth').adminOnly, SystemTestController.testSMTPConnection);
router.post('/system-tests/email-send', require('../middleware/auth').adminOnly, SystemTestController.testSendEmail);
router.post('/system-tests/email-otp', require('../middleware/auth').adminOnly, SystemTestController.testOTPEmail);
router.post('/system-tests/email-verify', require('../middleware/auth').adminOnly, SystemTestController.testEmailVerification);

// Terms & Conditions Management
const termsController = require('../controllers/termsController');
router.post('/terms', termsController.createTerms);
router.get('/terms', termsController.getAllTerms);
router.put('/terms/:id', termsController.updateTerms);
router.delete('/terms/:id', termsController.deleteTerms);

// Music Management
const musicController = require('../controllers/musicController');
router.post('/music/upload', musicController.upload.single('audio'), musicController.uploadMusic);
router.get('/music/stats', musicController.getMusicStats);
router.post('/music/:id/approve', musicController.approveMusic);
router.post('/music/:id/reject', musicController.rejectMusic);
router.get('/music/:id', musicController.getMusic);
router.put('/music/:id', musicController.updateMusic);
router.delete('/music/:id', musicController.deleteMusic);
router.get('/music/approved', musicController.getApprovedMusic);
router.get('/music', musicController.getAllMusic);

module.exports = router;