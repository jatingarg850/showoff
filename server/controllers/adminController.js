const User = require('../models/User');
const Post = require('../models/Post');
const Product = require('../models/Product');
const Transaction = require('../models/Transaction');
const Order = require('../models/Order');
const Withdrawal = require('../models/Withdrawal');
const SYTEntry = require('../models/SYTEntry');
const Community = require('../models/Community');
const { awardCoins } = require('../utils/coinSystem');

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

    // Get withdrawal requests
    const withdrawalRequests = await Withdrawal.find()
      .populate('user', 'username displayName profilePicture email phone')
      .sort({ createdAt: -1 })
      .limit(20);

    // Top earning users
    const topEarners = await User.find()
      .select('username displayName profilePicture coinBalance totalCoinsEarned')
      .sort({ totalCoinsEarned: -1 })
      .limit(10);

    res.status(200).json({
      success: true,
      data: {
        transactionStats,
        withdrawalRequests,
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

// @desc    Get all withdrawal requests
// @route   GET /api/admin/withdrawals
// @access  Private (Admin only)
exports.getWithdrawals = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    
    let query = {};
    if (status) {
      query.status = status;
    }

    const withdrawals = await Withdrawal.find(query)
      .populate('user', 'username displayName profilePicture email phone kycStatus')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Withdrawal.countDocuments(query);

    res.status(200).json({
      success: true,
      data: withdrawals,
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

// @desc    Get withdrawal details
// @route   GET /api/admin/withdrawals/:id
// @access  Private (Admin only)
exports.getWithdrawalDetails = async (req, res) => {
  try {
    const withdrawal = await Withdrawal.findById(req.params.id)
      .populate('user', 'username displayName email profilePicture coinBalance');
    
    if (!withdrawal) {
      return res.status(404).json({
        success: false,
        message: 'Withdrawal request not found'
      });
    }

    res.status(200).json({
      success: true,
      data: withdrawal
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update withdrawal status
// @route   PUT /api/admin/withdrawals/:id
// @access  Private (Admin only)
exports.updateWithdrawalStatus = async (req, res) => {
  try {
    const { status, adminNotes, transactionId } = req.body;
    
    const withdrawal = await Withdrawal.findById(req.params.id);
    if (!withdrawal) {
      return res.status(404).json({
        success: false,
        message: 'Withdrawal request not found'
      });
    }

    withdrawal.status = status;
    withdrawal.adminNotes = adminNotes;
    withdrawal.transactionId = transactionId;
    withdrawal.processedBy = req.user.id;
    withdrawal.processedAt = new Date();

    await withdrawal.save();

    // If rejected, refund the coins
    if (status === 'rejected') {
      const user = await User.findById(withdrawal.user);
      user.coinBalance += withdrawal.coinAmount;
      await user.save();

      // Create refund transaction
      await Transaction.create({
        user: user._id,
        type: 'withdrawal_refund',
        amount: withdrawal.coinAmount,
        balanceAfter: user.coinBalance,
        description: `Withdrawal refund - ${adminNotes || 'Request rejected'}`,
        status: 'completed',
      });
    }

    res.status(200).json({
      success: true,
      message: `Withdrawal ${status} successfully`,
      data: withdrawal
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Approve withdrawal
// @route   PUT /api/admin/withdrawals/:id/approve
// @access  Private (Admin only)
exports.approveWithdrawal = async (req, res) => {
  try {
    const { adminNotes, transactionId } = req.body;
    
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

    res.status(200).json({
      success: true,
      message: 'Withdrawal approved successfully',
      data: withdrawal
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Reject withdrawal
// @route   PUT /api/admin/withdrawals/:id/reject
// @access  Private (Admin only)
exports.rejectWithdrawal = async (req, res) => {
  try {
    const { rejectionReason } = req.body;
    
    if (!rejectionReason) {
      return res.status(400).json({
        success: false,
        message: 'Rejection reason is required'
      });
    }
    
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

    // Refund the coins
    const user = await User.findById(withdrawal.user);
    user.coinBalance += withdrawal.coinAmount;
    await user.save();

    // Create refund transaction
    await Transaction.create({
      user: user._id,
      type: 'withdrawal_refund',
      amount: withdrawal.coinAmount,
      balanceAfter: user.coinBalance,
      description: `Withdrawal refund - ${rejectionReason}`,
      status: 'completed',
    });

    res.status(200).json({
      success: true,
      message: 'Withdrawal rejected and coins refunded',
      data: withdrawal
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
  console.log('📝 Update User Status Controller');
  console.log('  - User ID:', req.params.id);
  console.log('  - Body:', req.body);
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
  console.log('🗑️ Delete User Controller');
  console.log('  - User ID:', req.params.id);
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
  console.log('✅ Update User Verification Controller');
  console.log('  - User ID:', req.params.id);
  console.log('  - Body:', req.body);
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
  console.log('💰 Update User Coins Controller');
  console.log('  - User ID:', req.params.id);
  console.log('  - Body:', req.body);
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

    // Delete media files from both local storage and S3
    const fs = require('fs');
    const path = require('path');
    const AWS = require('aws-sdk');

    // Configure Wasabi S3
    const s3 = new AWS.S3({
      accessKeyId: process.env.WASABI_ACCESS_KEY_ID,
      secretAccessKey: process.env.WASABI_SECRET_ACCESS_KEY,
      endpoint: process.env.WASABI_ENDPOINT || 's3.ap-southeast-1.wasabisys.com',
      region: process.env.WASABI_REGION || 'ap-southeast-1',
      s3ForcePathStyle: true,
      signatureVersion: 'v4',
    });

    // Delete media file
    if (post.mediaUrl) {
      // Check if it's a Wasabi S3 URL
      if (post.mediaUrl.includes('wasabisys.com')) {
        try {
          // Extract key from Wasabi URL
          const urlParts = post.mediaUrl.split('.com/');
          if (urlParts.length > 1) {
            const pathParts = urlParts[1].split('/');
            const key = pathParts.slice(1).join('/');
            
            await s3.deleteObject({
              Bucket: process.env.WASABI_BUCKET_NAME,
              Key: key
            }).promise();
            console.log('✅ Media file deleted from S3:', key);
          }
        } catch (error) {
          console.warn('⚠️ Failed to delete media from S3:', error.message);
        }
      } else {
        // Local file deletion
        const mediaPath = path.join(__dirname, '..', post.mediaUrl.replace('/uploads/', 'uploads/'));
        if (fs.existsSync(mediaPath)) {
          fs.unlinkSync(mediaPath);
          console.log('✅ Local media file deleted:', mediaPath);
        }
      }
    }
    
    // Delete thumbnail file
    if (post.thumbnailUrl) {
      // Check if it's a Wasabi S3 URL
      if (post.thumbnailUrl.includes('wasabisys.com')) {
        try {
          // Extract key from Wasabi URL
          const urlParts = post.thumbnailUrl.split('.com/');
          if (urlParts.length > 1) {
            const pathParts = urlParts[1].split('/');
            const key = pathParts.slice(1).join('/');
            
            await s3.deleteObject({
              Bucket: process.env.WASABI_BUCKET_NAME,
              Key: key
            }).promise();
            console.log('✅ Thumbnail deleted from S3:', key);
          }
        } catch (error) {
          console.warn('⚠️ Failed to delete thumbnail from S3:', error.message);
        }
      } else {
        // Local file deletion
        const thumbnailPath = path.join(__dirname, '..', post.thumbnailUrl.replace('/uploads/', 'uploads/'));
        if (fs.existsSync(thumbnailPath)) {
          fs.unlinkSync(thumbnailPath);
          console.log('✅ Local thumbnail file deleted:', thumbnailPath);
        }
      }
    }

    // Delete post from database
    await Post.findByIdAndDelete(req.params.id);
    console.log('✅ Post deleted from database:', req.params.id);

    res.status(200).json({
      success: true,
      message: 'Post deleted successfully'
    });
  } catch (error) {
    console.error('❌ Error deleting post:', error);
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
        minWithdrawal: 1000
      },
      ads: {
        enabled: true,
        adFrequency: 6, // Show ad after every 6 reels
        interstitialEnabled: true,
        rewardedEnabled: true,
        bannerEnabled: true
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
    
    // Validate ad frequency if provided
    if (settings.ads && settings.ads.adFrequency) {
      if (settings.ads.adFrequency < 1 || settings.ads.adFrequency > 50) {
        return res.status(400).json({
          success: false,
          message: 'Ad frequency must be between 1 and 50'
        });
      }
    }
    
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

// @desc    Create new product
// @route   POST /api/admin/products
// @access  Private (Admin only)
exports.createProduct = async (req, res) => {
  console.log('📦 Create Product Controller');
  console.log('  - Body:', req.body);
  try {
    const {
      name,
      description,
      price,
      originalPrice,
      category,
      images,
      sizes,
      colors,
      stock,
      badge,
      paymentType,
      coinPrice
    } = req.body;

    // Calculate mixed payment if needed
    let mixedPayment = null;
    let finalCoinPrice = coinPrice;

    if (paymentType === 'mixed') {
      mixedPayment = {
        cashAmount: price / 2,
        coinAmount: (price / 2) * 1 // 1 coin = 1 INR
      };
    } else if (paymentType === 'coins') {
      finalCoinPrice = coinPrice || price * 1;
    }

    const product = await Product.create({
      name,
      description,
      price: parseFloat(price),
      originalPrice: originalPrice ? parseFloat(originalPrice) : null,
      category,
      images: images || [],
      sizes: sizes || [],
      colors: colors || [],
      stock: parseInt(stock) || 0,
      badge: badge || '',
      paymentType,
      coinPrice: finalCoinPrice,
      mixedPayment,
      isActive: true
    });

    res.status(201).json({
      success: true,
      message: 'Product created successfully',
      data: product
    });
  } catch (error) {
    console.error('Create product error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update product
// @route   PUT /api/admin/products/:id
// @access  Private (Admin only)
exports.updateProduct = async (req, res) => {
  console.log('📝 Update Product Controller');
  console.log('  - Product ID:', req.params.id);
  console.log('  - Body:', req.body);
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    const {
      name,
      description,
      price,
      originalPrice,
      category,
      images,
      sizes,
      colors,
      stock,
      badge,
      paymentType,
      coinPrice,
      isActive
    } = req.body;

    // Calculate mixed payment if needed
    let mixedPayment = product.mixedPayment;
    let finalCoinPrice = coinPrice || product.coinPrice;

    if (paymentType === 'mixed') {
      mixedPayment = {
        cashAmount: price / 2,
        coinAmount: (price / 2) * 1 // 1 coin = 1 INR
      };
    } else if (paymentType === 'coins') {
      finalCoinPrice = coinPrice || price * 1;
    }

    // Update fields
    if (name) product.name = name;
    if (description) product.description = description;
    if (price) product.price = parseFloat(price);
    if (originalPrice !== undefined) product.originalPrice = originalPrice ? parseFloat(originalPrice) : null;
    if (category) product.category = category;
    if (images) product.images = images;
    if (sizes) product.sizes = sizes;
    if (colors) product.colors = colors;
    if (stock !== undefined) product.stock = parseInt(stock);
    if (badge !== undefined) product.badge = badge;
    if (paymentType) product.paymentType = paymentType;
    if (finalCoinPrice) product.coinPrice = finalCoinPrice;
    if (mixedPayment) product.mixedPayment = mixedPayment;
    if (isActive !== undefined) product.isActive = isActive;

    await product.save();

    res.status(200).json({
      success: true,
      message: 'Product updated successfully',
      data: product
    });
  } catch (error) {
    console.error('Update product error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete product
// @route   DELETE /api/admin/products/:id
// @access  Private (Admin only)
exports.deleteProduct = async (req, res) => {
  console.log('🗑️ Delete Product Controller');
  console.log('  - Product ID:', req.params.id);
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    await Product.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Product deleted successfully'
    });
  } catch (error) {
    console.error('Delete product error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Toggle product status
// @route   PUT /api/admin/products/:id/toggle
// @access  Private (Admin only)
exports.toggleProductStatus = async (req, res) => {
  console.log('🔄 Toggle Product Status Controller');
  console.log('  - Product ID:', req.params.id);
  try {
    const product = await Product.findById(req.params.id);
    if (!product) {
      return res.status(404).json({
        success: false,
        message: 'Product not found'
      });
    }

    product.isActive = !product.isActive;
    await product.save();

    res.status(200).json({
      success: true,
      message: `Product ${product.isActive ? 'activated' : 'deactivated'} successfully`,
      data: product
    });
  } catch (error) {
    console.error('Toggle product status error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Upload product images
// @route   POST /api/admin/products/upload-images
// @access  Private (Admin only)
exports.uploadProductImages = async (req, res) => {
  console.log('📸 Upload Product Images Controller');
  console.log('  - Files:', req.files?.length || 0);
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No images uploaded'
      });
    }

    // Get image URLs from uploaded files
    const imageUrls = req.files.map(file => {
      // For Wasabi S3
      if (file.location) {
        return file.location;
      }
      // For local storage
      return `/uploads/images/${file.filename}`;
    });

    console.log('  - Uploaded images:', imageUrls);

    res.status(200).json({
      success: true,
      message: `${imageUrls.length} images uploaded successfully`,
      data: {
        images: imageUrls
      }
    });
  } catch (error) {
    console.error('Upload product images error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Upload product images
// @route   POST /api/admin/products/upload-images
// @access  Private (Admin only)
exports.uploadProductImages = async (req, res) => {
  console.log('📸 Upload Product Images Controller');
  console.log('  - Files:', req.files?.length || 0);
  try {
    if (!req.files || req.files.length === 0) {
      return res.status(400).json({
        success: false,
        message: 'No images uploaded'
      });
    }

    // Get image URLs from uploaded files
    const imageUrls = req.files.map(file => {
      // For Wasabi/S3
      if (file.location) {
        return file.location;
      }
      // For local storage
      return `/uploads/images/${file.filename}`;
    });

    console.log('  - Uploaded URLs:', imageUrls);

    res.status(200).json({
      success: true,
      message: `${imageUrls.length} images uploaded successfully`,
      data: {
        images: imageUrls
      }
    });
  } catch (error) {
    console.error('Upload product images error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get SYT/Talent entries for admin
// @route   GET /api/admin/syt
// @access  Private (Admin only)
exports.getSYTEntries = async (req, res) => {
  try {
    const { type, category, page = 1, limit = 50 } = req.query;
    
    let query = {};
    if (type && type !== 'all') {
      query.competitionType = type;
    }
    if (category && category !== 'all') {
      query.category = category;
    }

    const entries = await SYTEntry.find(query)
      .populate('user', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await SYTEntry.countDocuments(query);

    // Get stats
    const totalEntries = await SYTEntry.countDocuments();
    const weeklyEntries = await SYTEntry.countDocuments({ competitionType: 'weekly' });
    const winners = await SYTEntry.countDocuments({ isWinner: true });
    const totalCoinsAwarded = await SYTEntry.aggregate([
      { $group: { _id: null, total: { $sum: '$prizeCoins' } } }
    ]);

    res.status(200).json({
      success: true,
      data: entries,
      stats: {
        totalEntries,
        weeklyEntries,
        winners,
        totalCoinsAwarded: totalCoinsAwarded[0]?.total || 0
      },
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

// @desc    Toggle SYT entry status
// @route   PUT /api/admin/syt/:id/toggle
// @access  Private (Admin only)
exports.toggleSYTEntry = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found'
      });
    }

    entry.isActive = !entry.isActive;
    await entry.save();

    res.status(200).json({
      success: true,
      message: `Entry ${entry.isActive ? 'activated' : 'deactivated'} successfully`,
      data: entry
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Declare SYT winner
// @route   PUT /api/admin/syt/:id/winner
// @access  Private (Admin only)
exports.declareSYTWinner = async (req, res) => {
  try {
    const { position } = req.body;
    
    if (!position || ![1, 2, 3].includes(position)) {
      return res.status(400).json({
        success: false,
        message: 'Position must be 1, 2, or 3'
      });
    }

    const entry = await SYTEntry.findById(req.params.id).populate('user');
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found'
      });
    }

    // Prize coins based on position
    const prizeCoins = position === 1 ? 1000 : position === 2 ? 500 : 250;

    entry.isWinner = true;
    entry.winnerPosition = position;
    entry.prizeCoins = prizeCoins;
    await entry.save();

    // Award coins to user
    await awardCoins(
      entry.user._id,
      prizeCoins,
      'syt_winner',
      `SYT Competition Winner - Position ${position}`
    );

    res.status(200).json({
      success: true,
      message: `Winner declared! ${prizeCoins} coins awarded.`,
      data: entry
    });
  } catch (error) {
    console.error('❌ Declare SYT Winner Error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete SYT entry
// @route   DELETE /api/admin/syt/:id
// @access  Private (Admin only)
exports.deleteSYTEntry = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found'
      });
    }

    await SYTEntry.findByIdAndDelete(req.params.id);

    res.status(200).json({
      success: true,
      message: 'Entry deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};


// ============================================
// REWARDED ADS MANAGEMENT
// ============================================

// @desc    Get all rewarded ads
// @route   GET /api/admin/rewarded-ads
// @access  Private (Admin only)
exports.getRewardedAds = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const ads = await RewardedAd.find().sort({ adNumber: 1 });
    
    res.status(200).json({
      success: true,
      data: ads
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update rewarded ad
// @route   PUT /api/admin/rewarded-ads/:adNumber
// @access  Private (Admin only)
exports.updateRewardedAd = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const { 
      adLink, 
      adProvider, 
      rewardCoins, 
      isActive, 
      title, 
      description, 
      icon, 
      color,
      providerConfig 
    } = req.body;
    
    let ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
    
    if (!ad) {
      ad = await RewardedAd.create({
        adNumber: parseInt(req.params.adNumber),
        adLink,
        adProvider,
        rewardCoins,
        isActive,
        title,
        description,
        icon,
        color,
        providerConfig: providerConfig || {}
      });
    } else {
      if (adLink) ad.adLink = adLink;
      if (adProvider) ad.adProvider = adProvider;
      if (rewardCoins !== undefined) ad.rewardCoins = rewardCoins;
      if (isActive !== undefined) ad.isActive = isActive;
      if (title) ad.title = title;
      if (description) ad.description = description;
      if (icon) ad.icon = icon;
      if (color) ad.color = color;
      
      // Update provider-specific configuration
      // Only save the config for the selected provider
      if (providerConfig && adProvider) {
        ad.providerConfig = {};
        ad.providerConfig[adProvider] = providerConfig[adProvider] || {};
      }
      
      await ad.save();
    }
    
    res.status(200).json({
      success: true,
      message: `Rewarded Ad ${req.params.adNumber} updated successfully`,
      data: ad
    });
  } catch (error) {
    console.error('Update rewarded ad error:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get single rewarded ad
// @route   GET /api/admin/rewarded-ads/:adNumber
// @access  Private (Admin only)
exports.getRewardedAdById = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Ad not found'
      });
    }
    
    res.status(200).json({
      success: true,
      data: ad
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Reset ad statistics
// @route   POST /api/admin/rewarded-ads/:adNumber/reset-stats
// @access  Private (Admin only)
exports.resetAdStats = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Ad not found'
      });
    }
    
    ad.impressions = 0;
    ad.clicks = 0;
    ad.conversions = 0;
    ad.servedCount = 0;
    ad.lastServedAt = null;
    await ad.save();
    
    res.status(200).json({
      success: true,
      message: `Statistics for Ad ${req.params.adNumber} reset successfully`,
      data: ad
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get ads for mobile app (with rotation)
// @route   GET /api/rewarded-ads
// @access  Public
exports.getAdsForApp = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    
    // Get active ads sorted by rotation order
    const ads = await RewardedAd.find({ isActive: true })
      .sort({ rotationOrder: 1, adNumber: 1 });
    
    if (ads.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        message: 'No active ads available'
      });
    }
    
    // Update impressions for each ad
    await Promise.all(ads.map(ad => {
      ad.impressions += 1;
      ad.lastServedAt = new Date();
      ad.servedCount += 1;
      return ad.save();
    }));
    
    // Return ads with necessary info for app
    const adsForApp = ads.map(ad => ({
      id: ad._id,
      adNumber: ad.adNumber,
      title: ad.title,
      description: ad.description,
      icon: ad.icon,
      color: ad.color,
      adLink: ad.adLink,
      adProvider: ad.adProvider,
      rewardCoins: ad.rewardCoins,
      isActive: ad.isActive,
      // Include provider-specific configuration
      providerConfig: ad.providerConfig
    }));
    
    res.status(200).json({
      success: true,
      data: adsForApp
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Track ad click
// @route   POST /api/rewarded-ads/:adNumber/click
// @access  Public
exports.trackAdClick = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Ad not found'
      });
    }
    
    ad.clicks += 1;
    await ad.save();
    
    res.status(200).json({
      success: true,
      message: 'Click tracked'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Track ad conversion
// @route   POST /api/rewarded-ads/:adNumber/conversion
// @access  Public
exports.trackAdConversion = async (req, res) => {
  try {
    const RewardedAd = require('../models/RewardedAd');
    const ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
    
    if (!ad) {
      return res.status(404).json({
        success: false,
        message: 'Ad not found'
      });
    }
    
    ad.conversions += 1;
    await ad.save();
    
    res.status(200).json({
      success: true,
      message: 'Conversion tracked'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// ============================================
// MUSIC MANAGEMENT
// ============================================

// @desc    Get all music
// @route   GET /api/admin/music
// @access  Private (Admin only)
exports.getMusic = async (req, res) => {
  try {
    const Music = require('../models/Music');
    const { page = 1, limit = 20, approved } = req.query;
    
    let query = {};
    if (approved !== undefined) {
      query.isApproved = approved === 'true';
    }
    
    const music = await Music.find(query)
      .populate('uploadedBy', 'username displayName')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await Music.countDocuments(query);
    
    res.status(200).json({
      success: true,
      data: music,
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

// @desc    Approve/Reject music
// @route   PUT /api/admin/music/:id/approve
// @access  Private (Admin only)
exports.approveMusic = async (req, res) => {
  try {
    const Music = require('../models/Music');
    const { isApproved } = req.body;
    
    const music = await Music.findById(req.params.id);
    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }
    
    music.isApproved = isApproved;
    await music.save();
    
    res.status(200).json({
      success: true,
      message: `Music ${isApproved ? 'approved' : 'rejected'} successfully`,
      data: music
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete music
// @route   DELETE /api/admin/music/:id
// @access  Private (Admin only)
exports.deleteMusic = async (req, res) => {
  try {
    const Music = require('../models/Music');
    const music = await Music.findById(req.params.id);
    
    if (!music) {
      return res.status(404).json({
        success: false,
        message: 'Music not found'
      });
    }
    
    // Delete audio file if local
    if (music.audioUrl && !music.audioUrl.includes('http')) {
      const fs = require('fs');
      const path = require('path');
      const audioPath = path.join(__dirname, '..', music.audioUrl.replace('/uploads/', 'uploads/'));
      if (fs.existsSync(audioPath)) {
        try {
          fs.unlinkSync(audioPath);
        } catch (err) {
          console.error('Error deleting audio file:', err);
        }
      }
    }
    
    await Music.findByIdAndDelete(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'Music deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// ============================================
// USER EARNINGS MANAGEMENT
// ============================================

// @desc    Get user earnings breakdown
// @route   GET /api/admin/users/:id/earnings
// @access  Private (Admin only)
exports.getUserEarnings = async (req, res) => {
  try {
    const user = await User.findById(req.params.id).select('username displayName profilePicture coinBalance totalCoinsEarned withdrawableBalance');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    // Calculate earnings breakdown from transactions
    const earningsBreakdown = await Transaction.aggregate([
      { $match: { user: user._id, amount: { $gt: 0 } } },
      {
        $group: {
          _id: '$type',
          total: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      }
    ]);
    
    // Map transaction types to earnings categories
    const earnings = {
      videoUploadEarnings: 0,
      contentSharingEarnings: 0,
      wheelSpinEarnings: 0,
      rewardedAdEarnings: 0,
      referralEarnings: 0,
      competitionEarnings: 0,
      giftEarnings: 0,
      otherEarnings: 0,
      totalEarnings: 0
    };
    
    earningsBreakdown.forEach(item => {
      switch(item._id) {
        case 'upload_reward':
        case 'view_reward':
          earnings.videoUploadEarnings += item.total;
          break;
        case 'ad_watch':
          earnings.rewardedAdEarnings += item.total;
          break;
        case 'spin_wheel':
          earnings.wheelSpinEarnings += item.total;
          break;
        case 'referral':
          earnings.referralEarnings += item.total;
          break;
        case 'competition_prize':
          earnings.competitionEarnings += item.total;
          break;
        case 'gift_received':
          earnings.giftEarnings += item.total;
          break;
        case 'vote_received':
          earnings.contentSharingEarnings += item.total;
          break;
        default:
          earnings.otherEarnings += item.total;
      }
      earnings.totalEarnings += item.total;
    });
    
    // Get all transactions for detailed history
    const allTransactions = await Transaction.find({ user: req.params.id })
      .sort({ createdAt: -1 });
    
    // Get earnings by date (last 30 days)
    const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
    const earningsByDate = await Transaction.aggregate([
      { 
        $match: { 
          user: user._id, 
          amount: { $gt: 0 },
          createdAt: { $gte: thirtyDaysAgo }
        } 
      },
      {
        $group: {
          _id: { $dateToString: { format: '%Y-%m-%d', date: '$createdAt' } },
          amount: { $sum: '$amount' },
          count: { $sum: 1 }
        }
      },
      { $sort: { _id: 1 } }
    ]);
    
    // Get top earning sources
    const topSources = earningsBreakdown
      .sort((a, b) => b.total - a.total)
      .slice(0, 5);
    
    // Get withdrawal history
    const Withdrawal = require('../models/Withdrawal');
    const withdrawals = await Withdrawal.find({ user: req.params.id })
      .sort({ createdAt: -1 })
      .limit(10);
    
    // Calculate statistics
    const stats = {
      totalEarnings: earnings.totalEarnings,
      currentBalance: user.coinBalance,
      withdrawableBalance: user.withdrawableBalance || 0,
      totalWithdrawn: withdrawals.reduce((sum, w) => sum + (w.coinAmount || 0), 0),
      averageDailyEarnings: earnings.totalEarnings / Math.max(1, Math.ceil((Date.now() - user.createdAt) / (1000 * 60 * 60 * 24))),
      transactionCount: allTransactions.length,
      withdrawalCount: withdrawals.length
    };
    
    res.status(200).json({
      success: true,
      data: {
        user: {
          _id: user._id,
          username: user.username,
          displayName: user.displayName,
          profilePicture: user.profilePicture,
          coinBalance: user.coinBalance,
          totalCoinsEarned: user.totalCoinsEarned,
          withdrawableBalance: user.withdrawableBalance || 0
        },
        earnings,
        earningsBreakdown,
        earningsByDate,
        topSources,
        stats,
        recentTransactions: allTransactions.slice(0, 20),
        withdrawalHistory: withdrawals
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get top earners
// @route   GET /api/admin/top-earners
// @access  Private (Admin only)
exports.getTopEarners = async (req, res) => {
  try {
    const { limit = 20, period = '30' } = req.query;
    const daysAgo = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);
    
    const topEarners = await User.find()
      .select('username displayName profilePicture coinBalance totalCoinsEarned createdAt')
      .sort({ totalCoinsEarned: -1 })
      .limit(parseInt(limit));
    
    // Get earnings breakdown for each user
    const UserEarnings = require('../models/UserEarnings');
    const earningsData = await Promise.all(
      topEarners.map(async (user) => {
        const earnings = await UserEarnings.findOne({ user: user._id });
        return {
          ...user.toObject(),
          earnings: earnings || {
            videoUploadEarnings: 0,
            contentSharingEarnings: 0,
            wheelSpinEarnings: 0,
            rewardedAdEarnings: 0,
            referralEarnings: 0,
            otherEarnings: 0,
            totalEarnings: 0
          }
        };
      })
    );
    
    res.status(200).json({
      success: true,
      data: earningsData
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get SYT entries
// @route   GET /api/admin/syt
// @access  Private (Admin only)
exports.getSYTEntries = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    
    let query = {};
    if (status) {
      query.status = status;
    }
    
    const entries = await SYTEntry.find(query)
      .populate('user', 'username displayName profilePicture')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);
    
    const total = await SYTEntry.countDocuments(query);
    
    res.status(200).json({
      success: true,
      data: entries,
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

// @desc    Toggle SYT entry
// @route   PUT /api/admin/syt/:id/toggle
// @access  Private (Admin only)
exports.toggleSYTEntry = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'SYT entry not found'
      });
    }
    
    entry.isActive = !entry.isActive;
    await entry.save();
    
    res.status(200).json({
      success: true,
      message: `SYT entry ${entry.isActive ? 'activated' : 'deactivated'} successfully`,
      data: entry
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Declare SYT winner
// @route   PUT /api/admin/syt/:id/winner
// @access  Private (Admin only)
exports.declareSYTWinner = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'SYT entry not found'
      });
    }
    
    entry.isWinner = true;
    entry.winnerDeclaredAt = new Date();
    await entry.save();
    
    // Award coins to winner
    const user = await User.findById(entry.user);
    const winnerReward = 500; // 500 coins for winning
    user.coinBalance += winnerReward;
    user.totalCoinsEarned += winnerReward;
    await user.save();
    
    // Create transaction
    await Transaction.create({
      user: entry.user,
      type: 'syt_winner_reward',
      amount: winnerReward,
      description: 'SYT Competition Winner Reward',
      status: 'completed'
    });
    
    res.status(200).json({
      success: true,
      message: 'SYT winner declared and rewarded successfully',
      data: entry
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete SYT entry
// @route   DELETE /api/admin/syt/:id
// @access  Private (Admin only)
exports.deleteSYTEntry = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'SYT entry not found'
      });
    }
    
    // Delete media files if local
    if (entry.mediaUrl && !entry.mediaUrl.includes('http')) {
      const fs = require('fs');
      const path = require('path');
      const mediaPath = path.join(__dirname, '..', entry.mediaUrl.replace('/uploads/', 'uploads/'));
      if (fs.existsSync(mediaPath)) {
        try {
          fs.unlinkSync(mediaPath);
        } catch (err) {
          console.error('Error deleting media file:', err);
        }
      }
    }
    
    await SYTEntry.findByIdAndDelete(req.params.id);
    
    res.status(200).json({
      success: true,
      message: 'SYT entry deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
