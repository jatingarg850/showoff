const Follow = require('../models/Follow');
const User = require('../models/User');

// @desc    Follow user
// @route   POST /api/follow/:userId
// @access  Private
exports.followUser = async (req, res) => {
  try {
    const userToFollow = req.params.userId;

    if (userToFollow === req.user.id) {
      return res.status(400).json({
        success: false,
        message: 'You cannot follow yourself',
      });
    }

    // Check if already following
    const existingFollow = await Follow.findOne({
      follower: req.user.id,
      following: userToFollow,
    });

    if (existingFollow) {
      return res.status(400).json({
        success: false,
        message: 'Already following this user',
      });
    }

    // Create follow
    await Follow.create({
      follower: req.user.id,
      following: userToFollow,
    });

    // Update counts
    await User.findByIdAndUpdate(req.user.id, {
      $inc: { followingCount: 1 },
    });

    await User.findByIdAndUpdate(userToFollow, {
      $inc: { followersCount: 1 },
    });

    // Create follow notification
    try {
      const { createFollowNotification } = require('../utils/notificationHelper');
      await createFollowNotification(req.user.id, userToFollow);
    } catch (notificationError) {
      console.error('❌ Error creating follow notification:', notificationError);
    }

    res.status(200).json({
      success: true,
      message: 'User followed successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Unfollow user
// @route   DELETE /api/follow/:userId
// @access  Private
exports.unfollowUser = async (req, res) => {
  try {
    const userToUnfollow = req.params.userId;

    const follow = await Follow.findOneAndDelete({
      follower: req.user.id,
      following: userToUnfollow,
    });

    if (!follow) {
      return res.status(400).json({
        success: false,
        message: 'You are not following this user',
      });
    }

    // Update counts
    await User.findByIdAndUpdate(req.user.id, {
      $inc: { followingCount: -1 },
    });

    await User.findByIdAndUpdate(userToUnfollow, {
      $inc: { followersCount: -1 },
    });

    res.status(200).json({
      success: true,
      message: 'User unfollowed successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get followers
// @route   GET /api/follow/followers/:userId
// @access  Public
exports.getFollowers = async (req, res) => {
  try {
    const follows = await Follow.find({ following: req.params.userId })
      .populate('follower', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 });

    const followers = follows.map(f => f.follower);

    res.status(200).json({
      success: true,
      data: followers,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get following
// @route   GET /api/follow/following/:userId
// @access  Public
exports.getFollowing = async (req, res) => {
  try {
    const follows = await Follow.find({ follower: req.params.userId })
      .populate('following', 'username displayName profilePicture isVerified')
      .sort({ createdAt: -1 });

    const following = follows.map(f => f.following);

    res.status(200).json({
      success: true,
      data: following,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check if following
// @route   GET /api/follow/check/:userId
// @access  Private
exports.checkFollowing = async (req, res) => {
  try {
    const follow = await Follow.findOne({
      follower: req.user.id,
      following: req.params.userId,
    });

    res.status(200).json({
      success: true,
      isFollowing: !!follow,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
