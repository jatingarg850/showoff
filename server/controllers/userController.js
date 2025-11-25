const User = require('../models/User');
const bcrypt = require('bcryptjs');

// @desc    Search users
// @route   GET /api/users/search
// @access  Private
exports.searchUsers = async (req, res) => {
  try {
    const { q } = req.query;
    const currentUserId = req.user.id;

    let query = { _id: { $ne: currentUserId } }; // Exclude current user

    if (q && q.trim()) {
      query.$or = [
        { username: { $regex: q, $options: 'i' } },
        { displayName: { $regex: q, $options: 'i' } },
      ];
    }

    const users = await User.find(query)
      .select('username displayName profilePicture bio isVerified followersCount followingCount')
      .limit(50);

    res.status(200).json({
      success: true,
      data: users,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update privacy settings
// @route   PUT /api/users/privacy-settings
// @access  Private
exports.updatePrivacySettings = async (req, res) => {
  try {
    const { profileVisibility, dataSharing, locationTracking, twoFactorAuth } = req.body;
    const userId = req.user.id;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        profileVisibility,
        dataSharing,
        locationTracking,
        twoFactorAuth
      },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Privacy settings updated successfully',
      data: {
        profileVisibility: user.profileVisibility,
        dataSharing: user.dataSharing,
        locationTracking: user.locationTracking,
        twoFactorAuth: user.twoFactorAuth
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update notification settings
// @route   PUT /api/users/notification-settings
// @access  Private
exports.updateNotificationSettings = async (req, res) => {
  try {
    const { push, email, sms, referral, transaction, community, marketing } = req.body;
    const userId = req.user.id;

    const user = await User.findByIdAndUpdate(
      userId,
      {
        notificationSettings: {
          push,
          email,
          sms,
          referral,
          transaction,
          community,
          marketing
        }
      },
      { new: true, runValidators: true }
    );

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    res.status(200).json({
      success: true,
      message: 'Notification settings updated successfully',
      data: user.notificationSettings
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Download user data
// @route   GET /api/users/download-data
// @access  Private
exports.downloadUserData = async (req, res) => {
  try {
    const userId = req.user.id;

    const user = await User.findById(userId).select('-password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    // In a real implementation, you would:
    // 1. Generate a comprehensive data export (JSON/CSV)
    // 2. Include posts, comments, transactions, etc.
    // 3. Send download link via email
    // 4. Store the file temporarily for download

    // For now, we'll just return success
    res.status(200).json({
      success: true,
      message: 'Data export request received. Download link will be sent to your email.',
      data: {
        username: user.username,
        email: user.email,
        requestedAt: new Date()
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete account
// @route   DELETE /api/users/delete-account
// @access  Private
exports.deleteAccount = async (req, res) => {
  try {
    const { password } = req.body;
    const userId = req.user.id;

    // Verify password
    const user = await User.findById(userId).select('+password');
    
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }

    const isPasswordMatch = await bcrypt.compare(password, user.password);
    
    if (!isPasswordMatch) {
      return res.status(401).json({
        success: false,
        message: 'Incorrect password'
      });
    }

    // Delete user and all associated data
    // Note: You might want to add cascade delete for posts, comments, etc.
    await User.findByIdAndDelete(userId);

    res.status(200).json({
      success: true,
      message: 'Account deleted successfully'
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update FCM token
// @route   POST /api/users/fcm-token
// @access  Private
exports.updateFCMToken = async (req, res) => {
  try {
    const { fcmToken } = req.body;

    if (!fcmToken) {
      return res.status(400).json({
        success: false,
        message: 'FCM token is required',
      });
    }

    await User.findByIdAndUpdate(req.user.id, {
      fcmToken,
    });

    console.log(`✅ FCM token updated for user ${req.user.username}`);

    res.json({
      success: true,
      message: 'FCM token updated successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
