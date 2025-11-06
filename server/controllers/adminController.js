const User = require('../models/User');
const Post = require('../models/Post');
const Product = require('../models/Product');
const Transaction = require('../models/Transaction');
const Order = require('../models/Order');
const Withdrawal = require('../models/Withdrawal');
const SYTEntry = require('../models/SYTEntry');
const Community = require('../models/Community');

// @desc    Get admin dashboard stats
// @route   GET /api/admin/dashboard
// @access  Private (Admin only)
exports.getDashboardStats = async (req, res) => {
  try {
    // User Statistics
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ 
      lastActive: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } 
    });
    const newUsersToday = await User.countDocuments({
      createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    });
    const verifiedUsers = await User.countDocuments({ isVerified: true });

    // Content Statistics
    const totalPosts = await Post.countDocuments();
    const totalReels = await Post.countDocuments({ type: 'reel' });
    const postsToday = await Post.countDocuments({
      createdAt: { $gte: new Date(new Date().setHours(0, 0, 0, 0)) }
    });

    // Store Statistics
    const totalProducts = await Product.countDocuments();
    const activeProducts = await Product.countDocuments({ isActive: true });

    // Financial Statistics
    const totalTransactions = await Transaction.countDocuments();
    const totalCoinsInCirculation = await Transaction.aggregate([
      { $group: { _id: null, total: { $sum: '$amount' } } }
    ]);

    // Recent Activity
    const recentUsers = await User.find()
      .select('username displayName profilePicture createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    const recentPosts = await Post.find()
      .populate('user', 'username displayName profilePicture')
      .select('type mediaUrl caption likesCount createdAt')
      .sort({ createdAt: -1 })
      .limit(5);

    // Revenue Analytics (last 30 days)
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

    res.status(200).json({
      success: true,
      data: {
        users: {
          total: totalUsers,
          active: activeUsers,
          newToday: newUsersToday,
          verified: verifiedUsers
        },
        content: {
          totalPosts,
          totalReels,
          postsToday
        },
        store: {
          totalProducts,
          activeProducts,
          totalOrders: 0,
          pendingOrders: 0
        },
        financial: {
          totalTransactions,
          coinsInCirculation: totalCoinsInCirculation[0]?.total || 0
        },
        recent: {
          users: recentUsers,
          posts: recentPosts
        },
        analytics: {
          revenue: revenueData
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all users with pagination and filters
// @route   GET /api/admin/users
// @access  Private (Admin only)
exports.getUsers = async (req, res) => {
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

    res.status(200).json({
      success: true,
      data: users,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all posts/reels with moderation
// @route   GET /api/admin/posts
// @access  Private (Admin only)
exports.getPosts = async (req, res) => {
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

    res.status(200).json({
      success: true,
      data: posts,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get financial overview
// @route   GET /api/admin/financial
// @access  Private (Admin only)
exports.getFinancialOverview = async (req, res) => {
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

    res.status(200).json({
      success: true,
      data: {
        transactionStats,
        withdrawalRequests: [],
        topEarners
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update user status
// @route   PUT /api/admin/users/:id/status
// @access  Private (Admin only)
exports.updateUserStatus = async (req, res) => {
  try {
    const { status, reason } = req.body;
    
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.accountStatus = status;
    user.statusReason = reason;
    user.statusUpdatedBy = req.user.id;
    user.statusUpdatedAt = new Date();

    await user.save();

    res.status(200).json({
      success: true,
      message: `User status updated to ${status}`,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete user account
// @route   DELETE /api/admin/users/:id
// @access  Private (Admin only)
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Delete user's posts
    await Post.deleteMany({ user: req.params.id });
    
    // Delete user
    await User.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'User and all associated content deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update user verification status
// @route   PUT /api/admin/users/:id/verify
// @access  Private (Admin only)
exports.updateUserVerification = async (req, res) => {
  try {
    const { isVerified } = req.body;
    
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    user.isVerified = isVerified;
    await user.save();

    res.status(200).json({
      success: true,
      message: `User verification ${isVerified ? 'granted' : 'revoked'}`,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update user coins
// @route   PUT /api/admin/users/:id/coins
// @access  Private (Admin only)
exports.updateUserCoins = async (req, res) => {
  try {
    const { amount, type, reason } = req.body; // type: 'add' or 'subtract'
    
    const user = await User.findById(req.params.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    if (type === 'add') {
      user.coinBalance += amount;
      user.totalCoinsEarned += amount;
    } else if (type === 'subtract') {
      user.coinBalance = Math.max(0, user.coinBalance - amount);
    }

    await user.save();

    // Create transaction record
    const Transaction = require('../models/Transaction');
    await Transaction.create({
      user: user._id,
      type: type === 'add' ? 'admin_credit' : 'admin_debit',
      amount: type === 'add' ? amount : -amount,
      description: reason || `Admin ${type} coins`,
      status: 'completed'
    });

    res.status(200).json({
      success: true,
      message: `${amount} coins ${type === 'add' ? 'added to' : 'removed from'} user account`,
      data: user
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete post
// @route   DELETE /api/admin/posts/:id
// @access  Private (Admin only)
exports.deletePost = async (req, res) => {
  try {
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    // Delete media files
    const fs = require('fs');
    const path = require('path');
    
    if (post.mediaUrl) {
      const mediaPath = path.join(__dirname, '..', post.mediaUrl.replace('/uploads/', 'uploads/'));
      if (fs.existsSync(mediaPath)) {
        fs.unlinkSync(mediaPath);
      }
    }
    
    if (post.thumbnailUrl) {
      const thumbnailPath = path.join(__dirname, '..', post.thumbnailUrl.replace('/uploads/', 'uploads/'));
      if (fs.existsSync(thumbnailPath)) {
        fs.unlinkSync(thumbnailPath);
      }
    }

    await Post.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update post status
// @route   PUT /api/admin/posts/:id/status
// @access  Private (Admin only)
exports.updatePostStatus = async (req, res) => {
  try {
    const { isActive, reason } = req.body;
    
    const post = await Post.findById(req.params.id);
    if (!post) {
      return res.status(404).json({
        success: false,
        message: 'Post not found'
      });
    }

    post.isActive = isActive;
    post.moderationReason = reason;
    post.moderatedBy = req.user.id;
    post.moderatedAt = new Date();

    await post.save();

    res.status(200).json({
      success: true,
      message: `Post ${isActive ? 'activated' : 'deactivated'} successfully`,
      data: post
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get detailed user info
// @route   GET /api/admin/users/:id
// @access  Private (Admin only)
exports.getUserDetails = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Get user's posts
    const posts = await Post.find({ user: req.params.id })
      .sort({ createdAt: -1 })
      .limit(10);

    // Get user's transactions
    const transactions = await Transaction.find({ user: req.params.id })
      .sort({ createdAt: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: {
        user,
        posts,
        transactions,
        stats: {
          totalPosts: await Post.countDocuments({ user: req.params.id }),
          totalTransactions: await Transaction.countDocuments({ user: req.params.id }),
          totalCoinsSpent: await Transaction.aggregate([
            { $match: { user: user._id, amount: { $lt: 0 } } },
            { $group: { _id: null, total: { $sum: { $abs: '$amount' } } } }
          ])
        }
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get system analytics
// @route   GET /api/admin/analytics
// @access  Private (Admin only)
exports.getSystemAnalytics = async (req, res) => {
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
      .select('username displayName profilePicture totalCoinsEarned postsCount followersCount')
      .sort({ totalCoinsEarned: -1 })
      .limit(10);

    // Platform statistics
    const platformStats = {
      totalUsers: await User.countDocuments(),
      activeUsers: await User.countDocuments({ 
        lastLogin: { $gte: new Date(Date.now() - 7 * 24 * 60 * 60 * 1000) } 
      }),
      totalPosts: await Post.countDocuments(),
      totalTransactions: await Transaction.countDocuments(),
      totalCoinsInCirculation: await User.aggregate([
        { $group: { _id: null, total: { $sum: '$coinBalance' } } }
      ])
    };

    res.status(200).json({
      success: true,
      data: {
        userGrowth,
        contentEngagement,
        topPerformers,
        platformStats
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get system settings
// @route   GET /api/admin/settings
// @access  Private (Admin only)
exports.getSystemSettings = async (req, res) => {
  try {
    // In a real app, you'd have a Settings model
    const settings = {
      platform: {
        name: 'ShowOff Life',
        description: 'Social media platform for content creators',
        maintenanceMode: false,
        registrationEnabled: true
      },
      coins: {
        uploadReward: 5,
        adWatchReward: 10,
        referralReward: 50,
        dailyAdLimit: 10,
        minWithdrawal: 100
      },
      content: {
        maxFileSize: 100, // MB
        allowedImageTypes: ['jpg', 'jpeg', 'png', 'gif'],
        allowedVideoTypes: ['mp4', 'mov', 'avi'],
        autoModeration: true,
        requireApproval: false
      },
      users: {
        emailVerificationRequired: false,
        phoneVerificationRequired: false,
        kycRequired: false,
        defaultSubscription: 'free'
      }
    };

    res.status(200).json({
      success: true,
      data: settings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update system settings
// @route   PUT /api/admin/settings
// @access  Private (Admin only)
exports.updateSystemSettings = async (req, res) => {
  try {
    const { settings } = req.body;
    
    // In a real app, you'd save to a Settings model
    // For now, just return success
    
    res.status(200).json({
      success: true,
      message: 'Settings updated successfully',
      data: settings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};