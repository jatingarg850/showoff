const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Post = require('../models/Post');
const Product = require('../models/Product');
const Transaction = require('../models/Transaction');

// Middleware to check if user is admin (simplified for web interface)
const checkAdminWeb = async (req, res, next) => {
  console.log('🔍 Admin Auth Check:', {
    hasSession: !!req.session,
    isAdmin: req.session?.isAdmin,
    sessionId: req.sessionID
  });
  
  // Simple session check - in production, use proper session management
  if (req.session && req.session.isAdmin) {
    next();
  } else {
    console.log('❌ Admin auth failed, redirecting to login');
    res.redirect('/admin/login');
  }
};

// Login page
router.get('/login', (req, res) => {
  if (req.session && req.session.isAdmin) {
    return res.redirect('/admin');
  }
  res.render('admin/login', { layout: false });
});

// Login handler
router.post('/login', async (req, res) => {
  const { email, password } = req.body;
  
  console.log('🔐 Admin login attempt:', { email, hasPassword: !!password });
  
  // Simple demo authentication - replace with real authentication
  if (email === 'admin@showofflife.com' && password === 'admin123') {
    req.session.isAdmin = true;
    req.session.adminEmail = email;
    console.log('✅ Admin login successful, session created');
    res.redirect('/admin');
  } else {
    console.log('❌ Admin login failed');
    res.render('admin/login', { 
      layout: false, 
      error: 'Invalid email or password' 
    });
  }
});

// Logout
router.get('/logout', (req, res) => {
  req.session.destroy();
  res.redirect('/admin/login');
});

// Dashboard
router.get('/', checkAdminWeb, async (req, res) => {
  try {
    // Get dashboard statistics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ 
      lastActive: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } 
    });
    const verifiedUsers = await User.countDocuments({ isVerified: true });
    const newUsersToday = await User.countDocuments({
      createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    });

    const totalPosts = await Post.countDocuments();
    const totalReels = await Post.countDocuments({ type: 'reel' });
    const postsToday = await Post.countDocuments({
      createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    });

    const totalProducts = await Product.countDocuments();
    const activeProducts = await Product.countDocuments({ isActive: true });

    const totalTransactions = await Transaction.countDocuments();
    const totalCoinsInCirculation = await Transaction.aggregate([
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    // Recent activity
    const recentUsers = await User.find()
      .select('username displayName profilePicture createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    const recentPosts = await Post.find()
      .populate('user', 'username displayName profilePicture')
      .select('type mediaUrl thumbnailUrl caption likesCount createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    // Revenue analytics (last 30 days)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const revenueData = await Transaction.aggregate([
      {
        $match: {
          type: { $in: ['purchase', 'add_money'] },
          createdAt: { $gte: thirtyDaysAgo }
        }
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          revenue: { $sum: '$amount' },
          transactions: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    const stats = {
      users: {
        total: totalUsers,
        active: activeUsers,
        verified: verifiedUsers,
        newToday: newUsersToday
      },
      content: {
        totalPosts,
        totalReels,
        postsToday
      },
      store: {
        totalProducts,
        activeProducts
      },
      financial: {
        totalTransactions,
        coinsInCirculation: totalCoinsInCirculation[0]?.total || 0
      }
    };

    res.render('admin/dashboard', {
      currentPage: 'dashboard',
      pageTitle: 'Dashboard',
      stats,
      recentUsers,
      recentPosts,
      analytics: { revenue: revenueData }
    });
  } catch (error) {
    console.error('Dashboard error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Users Management
router.get('/users', checkAdminWeb, async (req, res) => {
  try {
    const { page = 1, limit = 20, search, status, verified } = req.query;
    
    let query = {};
    
    if (search) {
      query.$or = [
        { username: { $regex: search, $options: 'i' } },
        { displayName: { $regex: search, $options: 'i' } },
        { email: { $regex: search, $options: 'i' } }
      ];
    }
    
    if (status) {
      query.accountStatus = status;
    }
    
    if (verified !== undefined) {
      query.isVerified = verified === 'true';
    }

    const users = await User.find(query)
      .select('-password')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await User.countDocuments(query);

    const pagination = {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    };

    res.render('admin/users', {
      currentPage: 'users',
      pageTitle: 'User Management',
      users,
      pagination
    });
  } catch (error) {
    console.error('Users page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Content Management
router.get('/content', checkAdminWeb, async (req, res) => {
  try {
    const { page = 1, limit = 20, type, status } = req.query;
    
    let query = {};
    
    if (type) {
      query.type = type;
    }

    const posts = await Post.find(query)
      .populate('user', 'username displayName profilePicture')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Post.countDocuments(query);

    const pagination = {
      page: parseInt(page),
      limit: parseInt(limit),
      total,
      pages: Math.ceil(total / limit)
    };

    res.render('admin/content', {
      currentPage: 'content',
      pageTitle: 'Content Moderation',
      posts,
      pagination
    });
  } catch (error) {
    console.error('Content page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Store Management
router.get('/store', checkAdminWeb, async (req, res) => {
  try {
    const products = await Product.find()
      .sort({ createdAt: -1 })
      .limit(50);

    const totalProducts = await Product.countDocuments();
    const activeProducts = await Product.countDocuments({ isActive: true });

    // Product analytics by category
    const productsByCategory = await Product.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$category', count: { $sum: 1 } } }
    ]);

    // Payment type distribution
    const paymentTypeDistribution = await Product.aggregate([
      { $match: { isActive: true } },
      { $group: { _id: '$paymentType', count: { $sum: 1 } } }
    ]);

    res.render('admin/store', {
      currentPage: 'store',
      pageTitle: 'Store Management',
      products,
      stats: {
        totalProducts,
        activeProducts,
        productsByCategory,
        paymentTypeDistribution
      }
    });
  } catch (error) {
    console.error('Store page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Financial Management
router.get('/financial', checkAdminWeb, async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const daysAgo = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);

    // Transaction analytics
    const transactionStats = await Transaction.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      {
        $group: {
          _id: '$type',
          count: { $sum: 1 },
          totalAmount: { $sum: '$amount' }
        }
      }
    ]);

    // Top earning users
    const topEarners = await User.find()
      .select('username displayName profilePicture coinBalance totalCoinsEarned')
      .sort({ totalCoinsEarned: -1 })
      .limit(10);

    // Calculate totals
    const totalCoinsInCirculation = transactionStats.reduce((total, stat) => {
      return stat._id === 'add_money' ? total + stat.totalAmount : total;
    }, 0);

    res.render('admin/financial', {
      currentPage: 'financial',
      pageTitle: 'Financial Management',
      transactionStats,
      topEarners,
      totalCoinsInCirculation,
      withdrawalRequests: [] // You can add withdrawal requests here
    });
  } catch (error) {
    console.error('Financial page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Analytics
router.get('/analytics', checkAdminWeb, async (req, res) => {
  try {
    const { period = '30' } = req.query;
    const daysAgo = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);

    // User growth analytics
    const userGrowth = await User.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          newUsers: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);

    // Content engagement analytics
    const contentEngagement = await Post.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      {
        $group: {
          _id: '$type',
          totalPosts: { $sum: 1 },
          totalLikes: { $sum: '$likesCount' },
          totalViews: { $sum: '$viewsCount' },
          avgEngagement: { $avg: { $add: ['$likesCount', '$commentsCount'] } }
        }
      }
    ]);

    // Top performing users
    const topPerformers = await User.find()
      .select('username displayName profilePicture totalCoinsEarned')
      .sort({ totalCoinsEarned: -1 })
      .limit(10);

    res.render('admin/analytics', {
      currentPage: 'analytics',
      pageTitle: 'Analytics & Insights',
      userGrowth,
      contentEngagement,
      topPerformers
    });
  } catch (error) {
    console.error('Analytics page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Settings
router.get('/settings', checkAdminWeb, async (req, res) => {
  try {
    // Get system statistics for settings page
    const stats = {
      totalUsers: await User.countDocuments(),
      totalPosts: await Post.countDocuments(),
      totalTransactions: await Transaction.countDocuments(),
      storageUsed: '2.5 GB', // This would be calculated from actual file sizes
      serverUptime: process.uptime()
    };

    res.render('admin/settings', {
      currentPage: 'settings',
      pageTitle: 'System Settings',
      stats
    });
  } catch (error) {
    console.error('Settings page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// KYC Management
router.get('/kyc', checkAdminWeb, async (req, res) => {
  try {
    const { status = 'pending', page = 1, limit = 20 } = req.query;
    
    const KYC = require('../models/KYC');
    
    let query = {};
    if (status && status !== 'all') {
      query.status = status;
    }

    const kycs = await KYC.find(query)
      .populate('user', 'username displayName email profilePicture')
      .sort({ submittedAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await KYC.countDocuments(query);

    // Get counts by status
    const statusCounts = await KYC.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);

    const counts = statusCounts.reduce((acc, item) => {
      acc[item._id] = item.count;
      return acc;
    }, {});

    res.render('admin/kyc', {
      currentPage: 'kyc',
      pageTitle: 'KYC Management',
      kycs,
      statusCounts: counts,
      currentStatus: status,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('KYC page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Fraud Dashboard
router.get('/fraud', checkAdminWeb, async (req, res) => {
  try {
    const FraudLog = require('../models/FraudLog');
    const UserSession = require('../models/UserSession');
    
    const { period = '7' } = req.query;
    const daysAgo = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);

    // Get fraud statistics
    const totalIncidents = await FraudLog.countDocuments({
      createdAt: { $gte: daysAgo }
    });

    const pendingReviews = await FraudLog.countDocuments({
      status: 'pending'
    });

    const highRiskUsers = await User.countDocuments({
      riskScore: { $gte: 50 }
    });

    // Recent incidents
    const recentIncidents = await FraudLog.find({
      createdAt: { $gte: daysAgo }
    })
      .populate('user', 'username displayName profilePicture')
      .sort({ createdAt: -1 })
      .limit(20);

    // Incidents by type
    const incidentsByType = await FraudLog.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      { $group: { _id: '$fraudType', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    // Incidents by severity
    const incidentsBySeverity = await FraudLog.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      { $group: { _id: '$severity', count: { $sum: 1 } } }
    ]);

    res.render('admin/fraud', {
      currentPage: 'fraud',
      pageTitle: 'Fraud Detection',
      stats: {
        totalIncidents,
        pendingReviews,
        highRiskUsers
      },
      recentIncidents,
      incidentsByType,
      incidentsBySeverity,
      period
    });
  } catch (error) {
    console.error('Fraud page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Withdrawals Management
router.get('/withdrawals', checkAdminWeb, async (req, res) => {
  try {
    const Withdrawal = require('../models/Withdrawal');
    
    const { status = 'pending', page = 1, limit = 20 } = req.query;
    
    let query = {};
    if (status && status !== 'all') {
      query.status = status;
    }

    const withdrawals = await Withdrawal.find(query)
      .populate('user', 'username displayName email profilePicture coinBalance')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Withdrawal.countDocuments(query);

    // Get counts by status
    const statusCounts = await Withdrawal.aggregate([
      { $group: { _id: '$status', count: { $sum: 1 } } }
    ]);

    const counts = statusCounts.reduce((acc, item) => {
      acc[item._id] = item.count;
      return acc;
    }, {});

    // Get total amounts
    const totalAmounts = await Withdrawal.aggregate([
      { $match: { status: 'completed' } },
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    res.render('admin/withdrawals', {
      currentPage: 'withdrawals',
      pageTitle: 'Withdrawal Management',
      withdrawals,
      statusCounts: counts,
      currentStatus: status,
      totalPaid: totalAmounts[0]?.total || 0,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    console.error('Withdrawals page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Subscriptions Management
router.get('/subscriptions', checkAdminWeb, async (req, res) => {
  try {
    const { SubscriptionPlan, UserSubscription } = require('../models/Subscription');
    
    const plans = await SubscriptionPlan.find().sort({ displayOrder: 1 });
    
    // Get subscriber counts
    const subscriberCounts = await UserSubscription.aggregate([
      { $match: { status: 'active' } },
      { $group: { _id: '$plan', count: { $sum: 1 } } }
    ]);

    const plansWithCounts = plans.map(plan => ({
      ...plan.toObject(),
      subscriberCount: subscriberCounts.find(s => s._id.equals(plan._id))?.count || 0
    }));

    // Recent subscriptions
    const recentSubscriptions = await UserSubscription.find()
      .populate('user', 'username displayName profilePicture')
      .populate('plan', 'name tier')
      .sort({ createdAt: -1 })
      .limit(10);

    // Revenue stats
    const revenueStats = await UserSubscription.aggregate([
      { $match: { status: 'active' } },
      {
        $group: {
          _id: null,
          totalRevenue: { $sum: '$amountPaid' },
          count: { $sum: 1 }
        }
      }
    ]);

    res.render('admin/subscriptions', {
      currentPage: 'subscriptions',
      pageTitle: 'Subscription Management',
      plans: plansWithCounts,
      recentSubscriptions,
      stats: revenueStats[0] || { totalRevenue: 0, count: 0 }
    });
  } catch (error) {
    console.error('Subscriptions page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

module.exports = router;