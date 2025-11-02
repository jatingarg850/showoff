const Notification = require('../models/Notification');
const User = require('../models/User');
const { sendInAppNotification } = require('../utils/pushNotifications');

// @desc    Get user notifications
// @route   GET /api/notifications
// @access  Private
exports.getNotifications = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const notifications = await Notification.find({ recipient: req.user.id })
      .populate('sender', 'username displayName profilePicture isVerified')
      .populate('data.postId', 'thumbnailUrl')
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit);

    const total = await Notification.countDocuments({ recipient: req.user.id });
    const unreadCount = await Notification.countDocuments({ 
      recipient: req.user.id, 
      isRead: false 
    });

    res.status(200).json({
      success: true,
      data: notifications,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
      unreadCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get unread notifications count
// @route   GET /api/notifications/unread-count
// @access  Private
exports.getUnreadCount = async (req, res) => {
  try {
    const unreadCount = await Notification.countDocuments({
      recipient: req.user.id,
      isRead: false,
    });

    res.status(200).json({
      success: true,
      unreadCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Mark notification as read
// @route   PUT /api/notifications/:id/read
// @access  Private
exports.markAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOne({
      _id: req.params.id,
      recipient: req.user.id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    await notification.markAsRead();

    res.status(200).json({
      success: true,
      message: 'Notification marked as read',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Mark all notifications as read
// @route   PUT /api/notifications/mark-all-read
// @access  Private
exports.markAllAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { recipient: req.user.id, isRead: false },
      { isRead: true, readAt: new Date() }
    );

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete notification
// @route   DELETE /api/notifications/:id
// @access  Private
exports.deleteNotification = async (req, res) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      recipient: req.user.id,
    });

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    res.status(200).json({
      success: true,
      message: 'Notification deleted',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create notification (internal use)
exports.createNotification = async (notificationData) => {
  try {
    console.log('📝 Creating notification:', notificationData);
    
    const notification = await Notification.create(notificationData);
    console.log('✅ Notification created in database:', notification._id);
    
    // Populate sender data
    await notification.populate('sender', 'username displayName profilePicture isVerified');
    console.log('✅ Notification populated with sender data');
    
    // Send push notification if user has enabled notifications
    const recipient = await User.findById(notificationData.recipient);
    if (recipient && recipient.notificationSettings?.push !== false) {
      console.log('📱 Sending in-app notification to:', recipient.username);
      await sendInAppNotification(recipient, notification);
    } else {
      console.log('⚠️ Push notifications disabled for user or user not found');
    }

    // Emit real-time notification via WebSocket
    const io = require('../server').io;
    if (io) {
      const unreadCount = await Notification.countDocuments({
        recipient: notificationData.recipient,
        isRead: false,
      });
      
      console.log(`🔌 Emitting WebSocket notification to user_${notificationData.recipient}, unread count: ${unreadCount}`);
      
      io.to(`user_${notificationData.recipient}`).emit('newNotification', {
        notification: notification.toObject(),
        unreadCount: unreadCount,
      });
      
      console.log('✅ WebSocket notification emitted successfully');
    } else {
      console.log('❌ WebSocket server not available');
    }

    return notification;
  } catch (error) {
    console.error('❌ Error creating notification:', error);
    throw error;
  }
};

// @desc    Update notification settings
// @route   PUT /api/notifications/settings
// @access  Private
exports.updateNotificationSettings = async (req, res) => {
  try {
    const { push, email, sms, types } = req.body;

    const user = await User.findById(req.user.id);
    
    if (push !== undefined) user.notificationSettings.push = push;
    if (email !== undefined) user.notificationSettings.email = email;
    if (sms !== undefined) user.notificationSettings.sms = sms;
    if (types) user.notificationSettings.types = types;

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Notification settings updated',
      settings: user.notificationSettings,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Register device for push notifications
// @route   POST /api/notifications/register-device
// @access  Private
exports.registerDevice = async (req, res) => {
  try {
    const { deviceToken, platform } = req.body;

    if (!deviceToken) {
      return res.status(400).json({
        success: false,
        message: 'Device token is required',
      });
    }

    const user = await User.findById(req.user.id);
    
    // Add or update device token
    const existingDeviceIndex = user.deviceTokens?.findIndex(
      device => device.token === deviceToken
    );

    if (existingDeviceIndex >= 0) {
      user.deviceTokens[existingDeviceIndex].lastUsed = new Date();
    } else {
      if (!user.deviceTokens) user.deviceTokens = [];
      user.deviceTokens.push({
        token: deviceToken,
        platform: platform || 'unknown',
        lastUsed: new Date(),
      });
    }

    await user.save();

    res.status(200).json({
      success: true,
      message: 'Device registered for push notifications',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};