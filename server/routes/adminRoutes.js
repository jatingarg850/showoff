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

// Simple middleware to check if user is admin via JWT
const adminProtect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    token = req.headers.authorization.split(' ')[1];
  }

  if (!token) {
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

module.exports = router;