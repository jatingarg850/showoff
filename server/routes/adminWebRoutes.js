const express = require('express');
const router = express.Router();
const User = require('../models/User');
const Post = require('../models/Post');
const Product = require('../models/Product');
const Transaction = require('../models/Transaction');
const upload = require('../middleware/upload');

// Middleware to check if user is admin (simplified for web interface)
const checkAdminWeb = async (req, res, next) => {
  console.log('🔍 Admin Auth Check:', {
    hasSession: !!req.session,
    isAdmin: req.session?.isAdmin,
    sessionId: req.sessionID
  });
  
  // Simple session check - in production, use proper session management
  if (req.session && req.session.isAdmin) {
    try {
      // Get admin user from database by email
      let adminUser = await User.findOne({ email: req.session.adminEmail || 'admin@showofflife.com' });
      
      // If admin user not found by email, try to find any user with admin email
      if (!adminUser) {
        console.log('⚠️ Admin user not found by email, searching by ID...');
        if (req.session.adminUserId) {
          adminUser = await User.findById(req.session.adminUserId);
        }
      }
      
      if (adminUser) {
        // Create a req.user object with the actual admin user ID
        req.user = {
          id: adminUser._id.toString(),
          email: adminUser.email,
          username: adminUser.username,
        };
        console.log('✅ Admin user found:', req.user.id);
        next();
      } else {
        console.warn('⚠️ Admin user not found in database');
        console.log('   Searching email:', req.session.adminEmail || 'admin@showofflife.com');
        console.log('   Searching ID:', req.session.adminUserId);
        
        // For development, allow access even if user not found
        if (process.env.NODE_ENV === 'development') {
          console.log('⚠️ Development mode: allowing access without user');
          req.user = {
            id: req.session.adminUserId || 'admin_session',
            email: req.session.adminEmail || 'admin@showofflife.com',
            username: 'admin',
          };
          next();
        } else {
          return res.status(401).json({
            success: false,
            message: 'Admin user not found'
          });
        }
      }
    } catch (error) {
      console.error('Error fetching admin user:', error);
      return res.status(500).json({
        success: false,
        message: 'Error authenticating admin'
      });
    }
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

    // Get total amounts - use approvedAmount if available, otherwise use localAmount
    const totalAmounts = await Withdrawal.aggregate([
      { $match: { status: 'completed' } },
      { 
        $group: { 
          _id: null, 
          total: { 
            $sum: {
              $cond: [
                { $ne: ['$approvedAmount', null] },
                '$approvedAmount',
                '$localAmount'
              ]
            }
          }
        } 
      }
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

// Approve withdrawal
router.post('/withdrawals/:id/approve', checkAdminWeb, async (req, res) => {
  try {
    const { adminNotes, transactionId } = req.body;
    const Withdrawal = require('../models/Withdrawal');
    const Transaction = require('../models/Transaction');
    
    const withdrawal = await Withdrawal.findById(req.params.id);
    if (!withdrawal) {
      return res.status(404).json({
        success: false,
        message: 'Withdrawal request not found'
      });
    }

    if (withdrawal.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Only pending withdrawals can be approved'
      });
    }

    withdrawal.status = 'completed';
    withdrawal.adminNotes = adminNotes;
    withdrawal.transactionId = transactionId || `TXN${Date.now()}`;
    withdrawal.processedBy = req.user.id;
    withdrawal.processedAt = new Date();

    await withdrawal.save();

    // Update transaction status
    await Transaction.updateOne(
      { 
        user: withdrawal.user,
        type: 'withdrawal',
        amount: -withdrawal.coinAmount,
        status: 'pending'
      },
      { 
        status: 'completed',
        description: `Withdrawal completed - ${withdrawal.method}`
      }
    );

    res.json({
      success: true,
      message: 'Withdrawal approved successfully',
      data: withdrawal
    });
  } catch (error) {
    console.error('❌ Error approving withdrawal:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Reject withdrawal
router.post('/withdrawals/:id/reject', checkAdminWeb, async (req, res) => {
  try {
    const { rejectionReason } = req.body;
    const Withdrawal = require('../models/Withdrawal');
    const Transaction = require('../models/Transaction');
    const User = require('../models/User');
    
    const withdrawal = await Withdrawal.findById(req.params.id);
    if (!withdrawal) {
      return res.status(404).json({
        success: false,
        message: 'Withdrawal request not found'
      });
    }

    if (withdrawal.status !== 'pending') {
      return res.status(400).json({
        success: false,
        message: 'Only pending withdrawals can be rejected'
      });
    }

    withdrawal.status = 'rejected';
    withdrawal.adminNotes = rejectionReason;
    withdrawal.processedBy = req.user.id;
    withdrawal.processedAt = new Date();

    await withdrawal.save();

    // Refund coins to user
    const user = await User.findById(withdrawal.user);
    user.coinBalance += withdrawal.coinAmount;
    await user.save();

    // Update transaction status
    await Transaction.updateOne(
      { 
        user: withdrawal.user,
        type: 'withdrawal',
        amount: -withdrawal.coinAmount,
        status: 'pending'
      },
      { 
        status: 'rejected',
        description: `Withdrawal rejected - ${rejectionReason}`
      }
    );

    res.json({
      success: true,
      message: 'Withdrawal rejected successfully',
      data: withdrawal
    });
  } catch (error) {
    console.error('❌ Error rejecting withdrawal:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Talent/SYT Management
router.get('/talent', checkAdminWeb, async (req, res) => {
  try {
    const SYTEntry = require('../models/SYTEntry');
    
    const { type, category } = req.query;
    
    let query = {};
    if (type && type !== 'all') {
      query.competitionType = type;
    }
    if (category && category !== 'all') {
      query.category = category;
    }

    // Get all entries
    const entries = await SYTEntry.find(query)
      .populate('user', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 })
      .limit(50);

    // Get leaderboard (top entries by votes)
    const leaderboard = await SYTEntry.find({ isActive: true })
      .populate('user', 'username displayName profilePicture isVerified')
      .sort({ votesCount: -1 })
      .limit(10);

    // Get stats
    const totalEntries = await SYTEntry.countDocuments();
    const weeklyEntries = await SYTEntry.countDocuments({ competitionType: 'weekly' });
    const winners = await SYTEntry.countDocuments({ isWinner: true });
    const totalCoinsAwarded = await SYTEntry.aggregate([
      { $group: { _id: null, total: { $sum: '$prizeCoins' } } }
    ]);

    res.render('admin/talent', {
      currentPage: 'talent',
      pageTitle: 'Talent Management',
      entries,
      leaderboard,
      stats: {
        totalEntries,
        weeklyEntries,
        winners,
        totalCoinsAwarded: totalCoinsAwarded[0]?.total || 0
      }
    });
  } catch (error) {
    console.error('Talent page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Notifications Management
router.get('/notifications', checkAdminWeb, async (req, res) => {
  try {
    res.render('admin/notifications', {
      currentPage: 'notifications',
      pageTitle: 'Notification Center'
    });
  } catch (error) {
    console.error('Notifications page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// System Integration Testing
router.get('/system-testing', checkAdminWeb, async (req, res) => {
  try {
    res.render('admin/system-testing', {
      currentPage: 'system-testing',
      pageTitle: 'System Integration Testing'
    });
  } catch (error) {
    console.error('System testing page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Rewarded Ads Management
router.get('/rewarded-ads', checkAdminWeb, async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    
    // Get all rewarded ads
    const ads = await RewardedAd.find().sort({ adNumber: 1 });
    
    // Get statistics for each ad
    const adsWithStats = ads.map(ad => ({
      ...ad.toObject(),
      ctr: ad.impressions > 0 ? ((ad.clicks / ad.impressions) * 100).toFixed(2) : 0,
      conversionRate: ad.clicks > 0 ? ((ad.conversions / ad.clicks) * 100).toFixed(2) : 0
    }));
    
    // Get total stats
    const totalStats = {
      totalImpressions: ads.reduce((sum, ad) => sum + ad.impressions, 0),
      totalClicks: ads.reduce((sum, ad) => sum + ad.clicks, 0),
      totalConversions: ads.reduce((sum, ad) => sum + ad.conversions, 0),
      totalServed: ads.reduce((sum, ad) => sum + ad.servedCount, 0)
    };
    
    res.render('admin/rewarded-ads', {
      currentPage: 'rewarded-ads',
      pageTitle: 'Rewarded Ads Management',
      ads: adsWithStats,
      stats: totalStats
    });
  } catch (error) {
    console.error('Rewarded ads page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Create Rewarded Ad (API endpoint for AJAX)
router.post('/rewarded-ads/create', checkAdminWeb, async (req, res) => {
  try {
    console.log('📝 Rewarded ad creation request:', req.body);
    
    const { adNumber, title, description, adLink, adProvider, rewardCoins, icon, color, adType, rotationOrder, isActive } = req.body;
    
    if (!adNumber || !title || !adLink) {
      return res.status(400).json({
        success: false,
        message: 'Ad number, title, and ad link are required'
      });
    }
    
    const RewardedAd = require('../models/RewardedAd');
    
    // Check if ad number already exists
    const existingAd = await RewardedAd.findOne({ adNumber: parseInt(adNumber) });
    if (existingAd) {
      return res.status(400).json({
        success: false,
        message: `Ad number ${adNumber} already exists`
      });
    }
    
    const rewardedAd = await RewardedAd.create({
      adNumber: parseInt(adNumber),
      title,
      description: description || 'Rewarded Ad',
      adLink,
      adProvider: adProvider || 'admob',
      rewardCoins: parseInt(rewardCoins) || 10,
      icon: icon || 'gift',
      color: color || '#667eea',
      adType: adType || 'watch-ads',
      rotationOrder: parseInt(rotationOrder) || 0,
      isActive: isActive === 'true' || isActive === true,
    });
    
    console.log('✅ Rewarded ad created:', rewardedAd._id);
    
    res.json({
      success: true,
      message: 'Rewarded ad created successfully',
      data: rewardedAd
    });
  } catch (error) {
    console.error('❌ Error creating rewarded ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Update Rewarded Ad (API endpoint for AJAX)
router.post('/rewarded-ads/:id/update', checkAdminWeb, async (req, res) => {
  try {
    console.log('📝 Rewarded ad update request:', req.body);
    
    const { title, description, adLink, adProvider, rewardCoins, icon, color, adType, rotationOrder, isActive } = req.body;
    
    const RewardedAd = require('../models/RewardedAd');
    let rewardedAd = await RewardedAd.findById(req.params.id);
    
    if (!rewardedAd) {
      return res.status(404).json({
        success: false,
        message: 'Rewarded ad not found'
      });
    }
    
    // Update fields
    if (title) rewardedAd.title = title;
    if (description) rewardedAd.description = description;
    if (adLink) rewardedAd.adLink = adLink;
    if (adProvider) rewardedAd.adProvider = adProvider;
    if (rewardCoins) rewardedAd.rewardCoins = parseInt(rewardCoins);
    if (icon) rewardedAd.icon = icon;
    if (color) rewardedAd.color = color;
    if (adType) rewardedAd.adType = adType;
    if (rotationOrder !== undefined) rewardedAd.rotationOrder = parseInt(rotationOrder);
    if (isActive !== undefined) rewardedAd.isActive = isActive === 'true' || isActive === true;
    
    await rewardedAd.save();
    
    console.log('✅ Rewarded ad updated:', rewardedAd._id);
    
    res.json({
      success: true,
      message: 'Rewarded ad updated successfully',
      data: rewardedAd
    });
  } catch (error) {
    console.error('❌ Error updating rewarded ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Delete Rewarded Ad (API endpoint for AJAX)
router.post('/rewarded-ads/:id/delete', checkAdminWeb, async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const rewardedAd = await RewardedAd.findByIdAndDelete(req.params.id);
    
    if (!rewardedAd) {
      return res.status(404).json({
        success: false,
        message: 'Rewarded ad not found'
      });
    }
    
    console.log('✅ Rewarded ad deleted:', req.params.id);
    
    res.json({
      success: true,
      message: 'Rewarded ad deleted successfully'
    });
  } catch (error) {
    console.error('❌ Error deleting rewarded ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Reset Rewarded Ad Stats (API endpoint for AJAX)
router.post('/rewarded-ads/:id/reset-stats', checkAdminWeb, async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const rewardedAd = await RewardedAd.findById(req.params.id);
    
    if (!rewardedAd) {
      return res.status(404).json({
        success: false,
        message: 'Rewarded ad not found'
      });
    }
    
    rewardedAd.impressions = 0;
    rewardedAd.clicks = 0;
    rewardedAd.conversions = 0;
    rewardedAd.servedCount = 0;
    await rewardedAd.save();
    
    console.log('✅ Rewarded ad stats reset:', req.params.id);
    
    res.json({
      success: true,
      message: 'Rewarded ad statistics reset',
      data: rewardedAd
    });
  } catch (error) {
    console.error('❌ Error resetting rewarded ad stats:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Terms & Conditions Management
router.get('/terms-and-conditions', checkAdminWeb, async (req, res) => {
  try {
    res.render('admin/terms-and-conditions', {
      currentPage: 'terms',
      pageTitle: 'Terms & Conditions Management'
    });
  } catch (error) {
    console.error('Terms page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Subscriptions Management
router.get('/subscriptions', checkAdminWeb, async (req, res) => {
  try {
    const { SubscriptionPlan, UserSubscription } = require('../models/Subscription');
    
    // Get all subscription plans
    const plans = await SubscriptionPlan.find().sort({ displayOrder: 1 });
    
    console.log('📊 Subscription Plans Found:', plans.length);
    plans.forEach(p => {
      console.log(`  - ${p.name} (${p.tier}): price=${p.price}, legacyPrice=${JSON.stringify(p.legacyPrice)}`);
    });
    
    // Get subscriber counts for each plan
    const subscriberCounts = await UserSubscription.aggregate([
      { $match: { status: 'active' } },
      { $group: { _id: '$plan', count: { $sum: 1 } } }
    ]);
    
    const plansWithCounts = plans.map(plan => {
      const planObj = plan.toObject();
      
      // Handle price - support both old (object) and new (number) formats
      let price = planObj.price;
      if (typeof price === 'object' && price !== null) {
        // Old format: { monthly: 2499, yearly: 24990 }
        price = price.monthly || 249900; // Default to monthly or convert yearly
      }
      
      // Handle features - support both old (object) and new (array) formats
      let features = planObj.features || [];
      if (typeof features === 'object' && !Array.isArray(features)) {
        // Old format: convert object to array
        features = Object.entries(features)
          .filter(([key, value]) => value === true || typeof value === 'number')
          .map(([key, value]) => {
            // Convert camelCase to readable text
            return key.replace(/([A-Z])/g, ' $1').trim();
          });
      }
      
      return {
        ...planObj,
        price: price,
        features: features || planObj.highlightedFeatures || [],
        subscriberCount: subscriberCounts.find(s => s._id.equals(plan._id))?.count || 0
      };
    });
    
    console.log('✅ Plans with counts:', plansWithCounts.map(p => ({ name: p.name, price: p.price, subscribers: p.subscriberCount })));
    
    // Get recent subscriptions
    const recentSubscriptions = await UserSubscription.find()
      .populate('user', 'username displayName email profilePicture')
      .populate('plan', 'name tier')
      .sort({ createdAt: -1 })
      .limit(10);
    
    // Get revenue stats
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
    
    console.log('💰 Revenue Stats:', revenueStats[0] || { totalRevenue: 0, count: 0 });
    
    res.render('admin/subscriptions', {
      currentPage: 'subscriptions',
      pageTitle: 'Subscription Management',
      plans: plansWithCounts,
      recentSubscriptions: recentSubscriptions,
      stats: revenueStats[0] || { totalRevenue: 0, count: 0 }
    });
  } catch (error) {
    console.error('❌ Subscriptions page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Music Management
const musicController = require('../controllers/musicController');

// Music Upload (must come before /:id routes)
router.post('/music/upload', checkAdminWeb, musicController.upload.single('audio'), musicController.uploadMusic);

// Get Music Page or List (handles both HTML and JSON)
router.get('/music', checkAdminWeb, async (req, res) => {
  try {
    // If it's an AJAX request (has query params), return JSON
    if (req.query.page || req.query.limit || req.query.isApproved || req.query.genre || req.query.mood) {
      return musicController.getAllMusic(req, res);
    }
    
    // Otherwise render the HTML page
    res.render('admin/music', {
      currentPage: 'music',
      pageTitle: 'Music Management'
    });
  } catch (error) {
    console.error('Music page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Get Music Stats
router.get('/music/stats', checkAdminWeb, musicController.getMusicStats);

// Get Single Music
router.get('/music/:id', checkAdminWeb, musicController.getMusic);

// Approve Music
router.post('/music/:id/approve', checkAdminWeb, musicController.approveMusic);

// Reject Music
router.post('/music/:id/reject', checkAdminWeb, musicController.rejectMusic);

// Update Music
router.put('/music/:id', checkAdminWeb, musicController.updateMusic);

// Delete Music
router.delete('/music/:id', checkAdminWeb, musicController.deleteMusic);

// Video Ads Management
router.get('/video-ads', checkAdminWeb, async (req, res) => {
  try {
    const VideoAd = require('../models/VideoAd');
    
    // Get all video ads
    const videoAds = await VideoAd.find()
      .populate('uploadedBy', 'username email')
      .sort({ createdAt: -1 });
    
    // Calculate stats for each ad
    const adsWithStats = videoAds.map(ad => ({
      ...ad.toObject(),
      ctr: ad.impressions > 0 ? ((ad.clicks / ad.impressions) * 100).toFixed(2) : 0,
      conversionRate: ad.clicks > 0 ? ((ad.conversions / ad.clicks) * 100).toFixed(2) : 0,
      completionRate: ad.views > 0 ? ((ad.completions / ad.views) * 100).toFixed(2) : 0
    }));
    
    // Get total stats
    const totalStats = {
      totalImpressions: videoAds.reduce((sum, ad) => sum + ad.impressions, 0),
      totalClicks: videoAds.reduce((sum, ad) => sum + ad.clicks, 0),
      totalConversions: videoAds.reduce((sum, ad) => sum + ad.conversions, 0),
      totalViews: videoAds.reduce((sum, ad) => sum + ad.views, 0),
      totalCompletions: videoAds.reduce((sum, ad) => sum + ad.completions, 0),
      totalServed: videoAds.reduce((sum, ad) => sum + ad.servedCount, 0)
    };
    
    res.render('admin/video-ads', {
      currentPage: 'video-ads',
      pageTitle: 'Video Ads Management',
      videoAds: adsWithStats,
      stats: totalStats
    });
  } catch (error) {
    console.error('Video ads page error:', error);
    res.status(500).send('Internal Server Error');
  }
});

// Create Video Ad (API endpoint for AJAX)
router.post('/video-ads/create', checkAdminWeb, upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), async (req, res) => {
  try {
    console.log('📤 Video ad creation request received');
    console.log('   Files:', req.files ? Object.keys(req.files) : 'none');
    console.log('   Body:', req.body);
    
    const { title, description, duration, rewardCoins, icon, color, rotationOrder, isActive, usage } = req.body;
    
    if (!title) {
      return res.status(400).json({
        success: false,
        message: 'Title is required'
      });
    }
    
    if (!req.files?.video || req.files.video.length === 0) {
      console.log('❌ No video file provided');
      return res.status(400).json({
        success: false,
        message: 'Video file is required'
      });
    }
    
    const videoFile = req.files.video[0];
    const thumbnailFile = req.files.thumbnail?.[0];
    
    console.log('📹 Video file details:');
    console.log('   Filename:', videoFile.filename);
    console.log('   Path:', videoFile.path);
    console.log('   Size:', videoFile.size);
    console.log('   Mimetype:', videoFile.mimetype);
    
    if (thumbnailFile) {
      console.log('🖼️ Thumbnail file details:');
      console.log('   Filename:', thumbnailFile.filename);
      console.log('   Path:', thumbnailFile.path);
      console.log('   Size:', thumbnailFile.size);
      console.log('   Mimetype:', thumbnailFile.mimetype);
    }
    
    // Determine file URLs
    const videoUrl = videoFile.path || videoFile.location || videoFile.filename;
    const thumbnailUrl = thumbnailFile?.path || thumbnailFile?.location || thumbnailFile?.filename || null;
    
    console.log('📝 File URLs:');
    console.log('   Video URL:', videoUrl);
    console.log('   Thumbnail URL:', thumbnailUrl);
    
    if (!videoUrl) {
      return res.status(400).json({
        success: false,
        message: 'Video file upload failed - no URL generated'
      });
    }
    
    const VideoAd = require('../models/VideoAd');
    const videoAd = await VideoAd.create({
      title,
      description: description || 'Watch this video to earn coins',
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl || null,  // Allow null thumbnails
      duration: parseInt(duration) || 30,
      rewardCoins: parseInt(rewardCoins) || 10,
      icon: icon || 'video',
      color: color || '#667eea',
      rotationOrder: parseInt(rotationOrder) || 0,
      isActive: isActive === 'true' || isActive === true,
      usage: usage || 'watch-ads',
      // Only set uploadedBy if it's a valid ObjectId
      ...(req.user?.id && req.user.id.length === 24 ? { uploadedBy: req.user.id } : {}),
    });
    
    console.log('✅ Video ad created:', videoAd._id);
    
    res.json({
      success: true,
      message: 'Video ad created successfully',
      data: videoAd
    });
  } catch (error) {
    console.error('❌ Error creating video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Update Video Ad (API endpoint for AJAX)
router.post('/video-ads/:id/update', checkAdminWeb, upload.fields([
  { name: 'video', maxCount: 1 },
  { name: 'thumbnail', maxCount: 1 }
]), async (req, res) => {
  try {
    const { title, description, duration, rewardCoins, icon, color, isActive, rotationOrder, usage } = req.body;
    
    const VideoAd = require('../models/VideoAd');
    let videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    // Update fields
    if (title) videoAd.title = title;
    if (description) videoAd.description = description;
    if (req.files?.video) {
      videoAd.videoUrl = req.files.video[0].path || req.files.video[0].filename;
      console.log('📹 Updated video:', videoAd.videoUrl);
    }
    if (req.files?.thumbnail) {
      videoAd.thumbnailUrl = req.files.thumbnail[0].path || req.files.thumbnail[0].filename;
      console.log('🖼️ Updated thumbnail:', videoAd.thumbnailUrl);
    }
    if (duration) videoAd.duration = duration;
    if (rewardCoins) videoAd.rewardCoins = rewardCoins;
    if (icon) videoAd.icon = icon;
    if (color) videoAd.color = color;
    if (isActive !== undefined) videoAd.isActive = isActive === 'true' || isActive === true;
    if (rotationOrder !== undefined) videoAd.rotationOrder = rotationOrder;
    if (usage) videoAd.usage = usage;
    
    await videoAd.save();
    
    console.log('✅ Video ad updated:', videoAd._id);
    
    res.json({
      success: true,
      message: 'Video ad updated successfully',
      data: videoAd
    });
  } catch (error) {
    console.error('❌ Error updating video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Delete Video Ad (API endpoint for AJAX)
router.post('/video-ads/:id/delete', checkAdminWeb, async (req, res) => {
  try {
    const VideoAd = require('../models/VideoAd');
    const videoAd = await VideoAd.findByIdAndDelete(req.params.id);
    
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    res.json({
      success: true,
      message: 'Video ad deleted successfully'
    });
  } catch (error) {
    console.error('Error deleting video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

// Reset Video Ad Stats (API endpoint for AJAX)
router.post('/video-ads/:id/reset-stats', checkAdminWeb, async (req, res) => {
  try {
    const VideoAd = require('../models/VideoAd');
    const videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    videoAd.impressions = 0;
    videoAd.clicks = 0;
    videoAd.conversions = 0;
    videoAd.views = 0;
    videoAd.completions = 0;
    videoAd.servedCount = 0;
    await videoAd.save();
    
    res.json({
      success: true,
      message: 'Video ad statistics reset',
      data: videoAd
    });
  } catch (error) {
    console.error('Error resetting stats:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
});

module.exports = router;
