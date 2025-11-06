const User = require('../models/User');

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
