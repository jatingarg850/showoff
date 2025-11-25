const AdminNotification = require('../models/AdminNotification');
const Notification = require('../models/Notification');
const User = require('../models/User');

// @desc    Send custom notification (Admin)
// @route   POST /api/admin/notifications/send
// @access  Admin
exports.sendCustomNotification = async (req, res) => {
  try {
    const { 
      title, 
      message, 
      targetType, 
      targetUserIds, 
      imageUrl, 
      actionType, 
      actionData, 
      scheduledFor,
      customCriteria 
    } = req.body;

    if (!title || !message) {
      return res.status(400).json({
        success: false,
        message: 'Title and message are required',
      });
    }

    // Get target users based on type
    let targetUsers = [];
    let query = { isActive: true };
    
    if (targetType === 'all') {
      targetUsers = await User.find(query).select('_id');
    } else if (targetType === 'selected') {
      if (!targetUserIds || targetUserIds.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Please select at least one user',
        });
      }
      targetUsers = await User.find({ _id: { $in: targetUserIds }, ...query }).select('_id');
    } else if (targetType === 'verified') {
      targetUsers = await User.find({ isVerified: true, ...query }).select('_id');
    } else if (targetType === 'active') {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      targetUsers = await User.find({ 
        lastActive: { $gte: sevenDaysAgo },
        ...query 
      }).select('_id');
    } else if (targetType === 'new') {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      targetUsers = await User.find({ 
        createdAt: { $gte: thirtyDaysAgo },
        ...query 
      }).select('_id');
    } else if (targetType === 'custom' && customCriteria) {
      // Advanced targeting with custom criteria
      if (customCriteria.isVerified !== undefined) {
        query.isVerified = customCriteria.isVerified;
      }
      if (customCriteria.minBalance !== undefined) {
        query['wallet.balance'] = { ...query['wallet.balance'], $gte: customCriteria.minBalance };
      }
      if (customCriteria.maxBalance !== undefined) {
        query['wallet.balance'] = { ...query['wallet.balance'], $lte: customCriteria.maxBalance };
      }
      if (customCriteria.registeredAfter) {
        query.createdAt = { ...query.createdAt, $gte: new Date(customCriteria.registeredAfter) };
      }
      if (customCriteria.registeredBefore) {
        query.createdAt = { ...query.createdAt, $lte: new Date(customCriteria.registeredBefore) };
      }
      if (customCriteria.lastActiveAfter) {
        query.lastActive = { $gte: new Date(customCriteria.lastActiveAfter) };
      }
      if (customCriteria.minFollowers !== undefined) {
        query.followersCount = { $gte: customCriteria.minFollowers };
      }
      if (customCriteria.excludeUserIds && customCriteria.excludeUserIds.length > 0) {
        query._id = { $nin: customCriteria.excludeUserIds };
      }
      
      targetUsers = await User.find(query).select('_id');
    }

    const totalRecipients = targetUsers.length;

    if (totalRecipients === 0) {
      return res.status(400).json({
        success: false,
        message: 'No users match the selected criteria',
      });
    }

    // Create admin notification record
    const adminNotification = await AdminNotification.create({
      title,
      message,
      imageUrl,
      targetType,
      targetUsers: targetType === 'selected' ? targetUserIds : [],
      actionType: actionType || 'none',
      actionData,
      scheduledFor: scheduledFor ? new Date(scheduledFor) : null,
      status: scheduledFor ? 'scheduled' : 'sent',
      sentAt: scheduledFor ? null : new Date(),
      totalRecipients,
      createdBy: req.user?.id || null,
    });

    // If not scheduled, send immediately
    if (!scheduledFor) {
      let deliveredCount = 0;
      const { sendWebSocketNotification } = require('../utils/pushNotifications');

      // Send in batches for better performance
      const batchSize = 100;
      const { sendFCMNotification } = require('../utils/fcmService');
      
      for (let i = 0; i < targetUsers.length; i += batchSize) {
        const batch = targetUsers.slice(i, i + batchSize);
        const notifications = batch.map(user => ({
          recipient: user._id, // Use recipient field as per model
          user: user._id, // Also set user for compatibility
          sender: req.user?.id || null, // Admin who sent it
          type: 'admin_announcement',
          title,
          message,
          imageUrl,
          actionType: actionType || 'none',
          actionData,
          data: {
            metadata: {
              actionType: actionType || 'none',
              actionData: actionData || null,
            },
          },
        }));

        try {
          const createdNotifications = await Notification.insertMany(notifications, { ordered: false });
          deliveredCount += batch.length;
          console.log(`✅ Batch ${Math.floor(i / batchSize) + 1}: Created ${createdNotifications.length} notifications in database`);

          // Send real-time WebSocket notifications and FCM
          let wsCount = 0;
          let fcmCount = 0;
          
          for (const notification of createdNotifications) {
            const userId = notification.recipient || notification.user;
            
            // Try WebSocket first (for foreground users)
            const wsSent = sendWebSocketNotification(userId, notification);
            if (wsSent) wsCount++;
            
            // Also send via FCM (for background/closed app)
            const fcmSent = await sendFCMNotification(userId, notification);
            if (fcmSent) fcmCount++;
          }
          
          console.log(`📡 Batch ${Math.floor(i / batchSize) + 1}: WebSocket: ${wsCount}, FCM: ${fcmCount}`);
        } catch (error) {
          const successCount = batch.length - (error.writeErrors?.length || 0);
          deliveredCount += successCount;
          console.error(`❌ Batch ${Math.floor(i / batchSize) + 1} partial failure:`, error.writeErrors?.length || 0);
          if (error.writeErrors && error.writeErrors.length > 0) {
            console.error('   First error:', error.writeErrors[0].err.errmsg);
          }
        }
      }

      adminNotification.deliveredCount = deliveredCount;
      await adminNotification.save();

      console.log(`✅ Admin notification sent to ${deliveredCount} users (${targetUsers.length} total)`);

      return res.status(201).json({
        success: true,
        message: `Notification sent to ${deliveredCount} users successfully`,
        data: {
          notificationId: adminNotification._id,
          totalRecipients,
          deliveredCount,
        },
      });
    } else {
      // Scheduled for later
      return res.status(201).json({
        success: true,
        message: `Notification scheduled for ${new Date(scheduledFor).toLocaleString()}`,
        data: {
          notificationId: adminNotification._id,
          totalRecipients,
          scheduledFor,
        },
      });
    }
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get all admin notifications
// @route   GET /api/admin/notifications
// @access  Admin
exports.getAdminNotifications = async (req, res) => {
  try {
    const { page = 1, limit = 20, status } = req.query;
    
    let query = {};
    if (status) {
      query.status = status;
    }

    const notifications = await AdminNotification.find(query)
      .populate('createdBy', 'username displayName')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await AdminNotification.countDocuments(query);

    res.status(200).json({
      success: true,
      data: notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get notification statistics
// @route   GET /api/admin/notifications/:id/stats
// @access  Admin
exports.getNotificationStats = async (req, res) => {
  try {
    const notification = await AdminNotification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        totalRecipients: notification.totalRecipients,
        deliveredCount: notification.deliveredCount,
        readCount: notification.readCount,
        clickCount: notification.clickCount,
        deliveryRate: ((notification.deliveredCount / notification.totalRecipients) * 100).toFixed(2),
        readRate: ((notification.readCount / notification.deliveredCount) * 100).toFixed(2),
        clickRate: ((notification.clickCount / notification.deliveredCount) * 100).toFixed(2),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete notification
// @route   DELETE /api/admin/notifications/:id
// @access  Admin
exports.deleteNotification = async (req, res) => {
  try {
    const notification = await AdminNotification.findById(req.params.id);

    if (!notification) {
      return res.status(404).json({
        success: false,
        message: 'Notification not found',
      });
    }

    await notification.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user notifications
// @route   GET /api/notifications
// @access  Private
exports.getUserNotifications = async (req, res) => {
  try {
    const { page = 1, limit = 50 } = req.query;
    
    const notifications = await Notification.find({ 
      recipient: req.user.id 
    })
      .populate('sender', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 })
      .limit(limit * 1)
      .skip((page - 1) * limit);

    const total = await Notification.countDocuments({ recipient: req.user.id });
    const unread = await Notification.countDocuments({ 
      recipient: req.user.id, 
      isRead: false 
    });

    res.status(200).json({
      success: true,
      data: notifications,
      pagination: {
        page: parseInt(page),
        limit: parseInt(limit),
        total,
        pages: Math.ceil(total / limit),
      },
      unreadCount: unread,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get unread notification count
// @route   GET /api/notifications/unread-count
// @access  Private
exports.getUnreadCount = async (req, res) => {
  try {
    const count = await Notification.countDocuments({ 
      recipient: req.user.id, 
      isRead: false 
    });

    res.status(200).json({
      success: true,
      unreadCount: count,
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
exports.markNotificationAsRead = async (req, res) => {
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

    notification.isRead = true;
    notification.readAt = new Date();
    await notification.save();

    // Send updated unread count via WebSocket
    const unreadCount = await Notification.countDocuments({ 
      recipient: req.user.id, 
      isRead: false 
    });

    const io = require('../server').io;
    if (io) {
      io.to(`user_${req.user.id}`).emit('unreadCountUpdate', { unreadCount });
    }

    res.status(200).json({
      success: true,
      data: notification,
      unreadCount,
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

    // Send updated unread count via WebSocket
    const io = require('../server').io;
    if (io) {
      io.to(`user_${req.user.id}`).emit('unreadCountUpdate', { unreadCount: 0 });
    }

    res.status(200).json({
      success: true,
      message: 'All notifications marked as read',
      unreadCount: 0,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete user notification
// @route   DELETE /api/notifications/:id
// @access  Private
exports.deleteUserNotification = async (req, res) => {
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

    await notification.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Notification deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get recipient count for targeting criteria
// @route   POST /api/admin/notifications/preview-count
// @access  Admin
exports.getRecipientCount = async (req, res) => {
  try {
    const { targetType, targetUserIds, customCriteria } = req.body;

    let query = { isActive: true };
    let count = 0;

    if (targetType === 'all') {
      count = await User.countDocuments(query);
    } else if (targetType === 'selected') {
      if (!targetUserIds || targetUserIds.length === 0) {
        return res.status(400).json({
          success: false,
          message: 'Please select at least one user',
        });
      }
      count = await User.countDocuments({ _id: { $in: targetUserIds }, ...query });
    } else if (targetType === 'verified') {
      count = await User.countDocuments({ isVerified: true, ...query });
    } else if (targetType === 'active') {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      count = await User.countDocuments({ 
        lastActive: { $gte: sevenDaysAgo },
        ...query 
      });
    } else if (targetType === 'new') {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      count = await User.countDocuments({ 
        createdAt: { $gte: thirtyDaysAgo },
        ...query 
      });
    } else if (targetType === 'custom' && customCriteria) {
      if (customCriteria.isVerified !== undefined) {
        query.isVerified = customCriteria.isVerified;
      }
      if (customCriteria.minBalance !== undefined) {
        query['wallet.balance'] = { ...query['wallet.balance'], $gte: customCriteria.minBalance };
      }
      if (customCriteria.maxBalance !== undefined) {
        query['wallet.balance'] = { ...query['wallet.balance'], $lte: customCriteria.maxBalance };
      }
      if (customCriteria.registeredAfter) {
        query.createdAt = { ...query.createdAt, $gte: new Date(customCriteria.registeredAfter) };
      }
      if (customCriteria.registeredBefore) {
        query.createdAt = { ...query.createdAt, $lte: new Date(customCriteria.registeredBefore) };
      }
      if (customCriteria.lastActiveAfter) {
        query.lastActive = { $gte: new Date(customCriteria.lastActiveAfter) };
      }
      if (customCriteria.minFollowers !== undefined) {
        query.followersCount = { $gte: customCriteria.minFollowers };
      }
      if (customCriteria.excludeUserIds && customCriteria.excludeUserIds.length > 0) {
        query._id = { $nin: customCriteria.excludeUserIds };
      }
      
      count = await User.countDocuments(query);
    }

    res.status(200).json({
      success: true,
      data: {
        targetType,
        recipientCount: count,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
