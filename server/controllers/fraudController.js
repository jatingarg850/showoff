const FraudLog = require('../models/FraudLog');
const UserSession = require('../models/UserSession');
const User = require('../models/User');
const {
  detectSuspiciousIP,
  detectMultipleAccounts,
  detectGeoHopping,
  detectSuspiciousActivity,
  calculateRiskScore,
  logFraudIncident,
  takeAutomatedAction
} = require('../utils/fraudDetection');

// @desc    Get fraud dashboard stats
// @route   GET /api/admin/fraud/dashboard
// @access  Private (Admin)
exports.getFraudDashboard = async (req, res) => {
  try {
    const { period = '7' } = req.query;
    const daysAgo = new Date(Date.now() - parseInt(period) * 24 * 60 * 60 * 1000);

    // Total fraud incidents
    const totalIncidents = await FraudLog.countDocuments({
      createdAt: { $gte: daysAgo }
    });

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

    // Pending reviews
    const pendingReviews = await FraudLog.countDocuments({
      status: 'pending'
    });

    // High-risk users
    const highRiskUsers = await User.find({
      riskScore: { $gte: 50 }
    })
      .select('username displayName profilePicture riskScore')
      .sort({ riskScore: -1 })
      .limit(10);

    // Recent incidents
    const recentIncidents = await FraudLog.find({
      createdAt: { $gte: daysAgo }
    })
      .populate('user', 'username displayName profilePicture')
      .sort({ createdAt: -1 })
      .limit(20);

    // Actions taken
    const actionsTaken = await FraudLog.aggregate([
      { $match: { createdAt: { $gte: daysAgo } } },
      { $group: { _id: '$actionTaken', count: { $sum: 1 } } }
    ]);

    // Suspicious IPs
    const suspiciousIPs = await UserSession.aggregate([
      {
        $match: {
          ipType: { $in: ['vpn', 'proxy', 'tor', 'datacenter'] },
          lastActivity: { $gte: daysAgo }
        }
      },
      {
        $group: {
          _id: '$ipAddress',
          count: { $sum: 1 },
          users: { $addToSet: '$user' }
        }
      },
      { $sort: { count: -1 } },
      { $limit: 10 }
    ]);

    res.status(200).json({
      success: true,
      data: {
        summary: {
          totalIncidents,
          pendingReviews,
          highRiskUsersCount: highRiskUsers.length
        },
        incidentsByType,
        incidentsBySeverity,
        actionsTaken,
        highRiskUsers,
        recentIncidents,
        suspiciousIPs
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all fraud logs
// @route   GET /api/admin/fraud/logs
// @access  Private (Admin)
exports.getFraudLogs = async (req, res) => {
  try {
    const {
      page = 1,
      limit = 20,
      fraudType,
      severity,
      status,
      userId
    } = req.query;

    let query = {};

    if (fraudType) query.fraudType = fraudType;
    if (severity) query.severity = severity;
    if (status) query.status = status;
    if (userId) query.user = userId;

    const logs = await FraudLog.find(query)
      .populate('user', 'username displayName profilePicture email')
      .populate('reviewedBy', 'username displayName')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await FraudLog.countDocuments(query);

    res.status(200).json({
      success: true,
      data: logs,
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

// @desc    Get user risk profile
// @route   GET /api/admin/fraud/user/:userId
// @access  Private (Admin)
exports.getUserRiskProfile = async (req, res) => {
  try {
    const { userId } = req.params;

    // Get user
    const user = await User.findById(userId).select('-password');
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // Calculate current risk score
    const riskScore = await calculateRiskScore(userId);

    // Get fraud history
    const fraudHistory = await FraudLog.find({ user: userId })
      .sort({ createdAt: -1 })
      .limit(50);

    // Get user sessions
    const sessions = await UserSession.find({ user: userId })
      .sort({ lastActivity: -1 })
      .limit(20);

    // Get unique IPs and devices
    const uniqueIPs = await UserSession.distinct('ipAddress', { user: userId });
    const uniqueDevices = await UserSession.distinct('deviceId', { user: userId });

    // Check for suspicious patterns
    const vpnUsage = await UserSession.countDocuments({
      user: userId,
      ipType: { $in: ['vpn', 'proxy', 'tor'] }
    });

    // Get related accounts (same IP/device)
    const relatedAccounts = await UserSession.aggregate([
      {
        $match: {
          $or: [
            { ipAddress: { $in: uniqueIPs } },
            { deviceId: { $in: uniqueDevices } }
          ],
          user: { $ne: mongoose.Types.ObjectId(userId) }
        }
      },
      {
        $group: {
          _id: '$user',
          sharedIPs: { $addToSet: '$ipAddress' },
          sharedDevices: { $addToSet: '$deviceId' }
        }
      },
      { $limit: 10 }
    ]);

    // Populate related accounts
    const relatedUsers = await User.find({
      _id: { $in: relatedAccounts.map(a => a._id) }
    }).select('username displayName profilePicture');

    res.status(200).json({
      success: true,
      data: {
        user,
        riskScore,
        fraudHistory,
        sessions,
        statistics: {
          uniqueIPs: uniqueIPs.length,
          uniqueDevices: uniqueDevices.length,
          vpnUsage,
          totalFraudIncidents: fraudHistory.length,
          relatedAccountsCount: relatedAccounts.length
        },
        relatedAccounts: relatedUsers.map((u, i) => ({
          user: u,
          sharedIPs: relatedAccounts[i].sharedIPs,
          sharedDevices: relatedAccounts[i].sharedDevices
        }))
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Review fraud incident
// @route   PUT /api/admin/fraud/:id/review
// @access  Private (Admin)
exports.reviewFraudIncident = async (req, res) => {
  try {
    const { status, reviewNotes, actionTaken } = req.body;

    const fraudLog = await FraudLog.findById(req.params.id);
    if (!fraudLog) {
      return res.status(404).json({
        success: false,
        message: 'Fraud log not found'
      });
    }

    fraudLog.status = status;
    fraudLog.reviewedBy = req.user.id;
    fraudLog.reviewedAt = new Date();
    fraudLog.reviewNotes = reviewNotes;

    if (actionTaken) {
      fraudLog.actionTaken = actionTaken;
    }

    await fraudLog.save();

    // If confirmed, take action
    if (status === 'confirmed' && actionTaken) {
      const action = await takeAutomatedAction(
        fraudLog.user,
        fraudLog.fraudType,
        fraudLog.severity
      );
      fraudLog.actionDetails = action.actionDetails;
      await fraudLog.save();
    }

    res.status(200).json({
      success: true,
      message: 'Fraud incident reviewed',
      data: fraudLog
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Manually log fraud incident
// @route   POST /api/admin/fraud/log
// @access  Private (Admin)
exports.manuallyLogFraud = async (req, res) => {
  try {
    const {
      userId,
      fraudType,
      severity,
      description,
      evidence,
      actionTaken
    } = req.body;

    const fraudLog = await logFraudIncident(userId, fraudType, {
      severity,
      description,
      evidence,
      actionTaken,
      detectionMethod: 'manual'
    });

    // Take action if specified
    if (actionTaken && actionTaken !== 'none') {
      await takeAutomatedAction(userId, fraudType, severity);
    }

    res.status(201).json({
      success: true,
      message: 'Fraud incident logged',
      data: fraudLog
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get suspicious IPs
// @route   GET /api/admin/fraud/suspicious-ips
// @access  Private (Admin)
exports.getSuspiciousIPs = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;

    const suspiciousIPs = await UserSession.aggregate([
      {
        $match: {
          $or: [
            { ipType: { $in: ['vpn', 'proxy', 'tor', 'datacenter'] } },
            { isSuspicious: true }
          ]
        }
      },
      {
        $group: {
          _id: '$ipAddress',
          ipType: { $first: '$ipType' },
          users: { $addToSet: '$user' },
          lastSeen: { $max: '$lastActivity' },
          location: { $first: '$location' },
          isp: { $first: '$isp' }
        }
      },
      { $sort: { lastSeen: -1 } },
      { $skip: (page - 1) * limit },
      { $limit: limit }
    ]);

    const total = await UserSession.distinct('ipAddress', {
      $or: [
        { ipType: { $in: ['vpn', 'proxy', 'tor', 'datacenter'] } },
        { isSuspicious: true }
      ]
    });

    res.status(200).json({
      success: true,
      data: suspiciousIPs,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total: total.length,
        pages: Math.ceil(total.length / limit)
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Block/Unblock IP
// @route   PUT /api/admin/fraud/ip/:ipAddress/block
// @access  Private (Admin)
exports.blockIP = async (req, res) => {
  try {
    const { ipAddress } = req.params;
    const { block, reason } = req.body;

    // Update all sessions with this IP
    await UserSession.updateMany(
      { ipAddress },
      {
        isSuspicious: block,
        suspiciousReasons: block ? [reason || 'Blocked by admin'] : []
      }
    );

    res.status(200).json({
      success: true,
      message: `IP ${block ? 'blocked' : 'unblocked'} successfully`
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

module.exports = exports;
