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

module.exports = router;