const User = require('../models/User');
const { awardCoins } = require('../utils/coinSystem');

// @desc    Update profile
// @route   PUT /api/profile
// @access  Private
exports.updateProfile = async (req, res) => {
  try {
    const { username, displayName, bio, interests } = req.body;
    
    const user = await User.findById(req.user.id);
    
    const oldCompletion = user.profileCompletionPercentage;
    
    // Update username if provided and different
    if (username && username !== user.username) {
      // Check if new username is available
      const existingUser = await User.findOne({ 
        username: username.toLowerCase(),
        _id: { $ne: user._id }
      });
      
      if (existingUser) {
        return res.status(400).json({
          success: false,
          message: 'Username already taken',
        });
      }
      
      user.username = username.toLowerCase();
    }
    
    if (displayName) user.displayName = displayName;
    if (bio !== undefined) user.bio = bio;
    if (interests) user.interests = interests;
    
    // Recalculate profile completion
    const newCompletion = user.calculateProfileCompletion();
    await user.save();
    
    // Award coins if profile just became complete and bonus not yet awarded
    if (oldCompletion < 100 && newCompletion === 100 && !user.profileCompletionBonusAwarded) {
      await awardCoins(
        user._id,
        50,
        'profile_completion',
        'Profile completion bonus'
      );
      user.coinBalance += 50;
      user.profileCompletionBonusAwarded = true;
      await user.save();
    }

    res.status(200).json({
      success: true,
      data: user,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Upload profile picture
// @route   POST /api/profile/picture
// @access  Private
exports.uploadProfilePicture = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload an image',
      });
    }

    const user = await User.findById(req.user.id);
    const oldCompletion = user.profileCompletionPercentage;
    
    // Handle both S3 (location/key) and local storage (path)
    let fileUrl;
    if (req.file.key) {
      // S3/Wasabi - construct public URL
      const region = process.env.WASABI_REGION || 'ap-southeast-1';
      const bucketName = process.env.WASABI_BUCKET_NAME;
      
      // Use Cloudflare CDN URL if configured, otherwise use Wasabi direct URL
      if (process.env.CLOUDFLARE_CDN_URL) {
        fileUrl = `${process.env.CLOUDFLARE_CDN_URL}/${bucketName}/${req.file.key}`;
      } else {
        // Use path-style URL that matches SSL certificate
        fileUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${req.file.key}`;
      }
    } else if (req.file.location) {
      // Fallback to location if provided
      fileUrl = req.file.location;
    } else {
      // Local storage - construct relative path
      const folder = req.file.mimetype.startsWith('image/') ? 'images' : 'videos';
      fileUrl = `/uploads/${folder}/${req.file.filename}`;
    }
    user.profilePicture = fileUrl;
    
    console.log('Saving profile picture URL:', fileUrl);
    
    // Recalculate profile completion
    const newCompletion = user.calculateProfileCompletion();
    await user.save();
    
    console.log('Profile picture saved successfully:', user.profilePicture);
    
    // Award coins if profile just became complete and bonus not yet awarded
    if (oldCompletion < 100 && newCompletion === 100 && !user.profileCompletionBonusAwarded) {
      await awardCoins(
        user._id,
        50,
        'profile_completion',
        'Profile completion bonus'
      );
      user.coinBalance += 50;
      user.profileCompletionBonusAwarded = true;
      await user.save();
    }

    res.status(200).json({
      success: true,
      data: {
        profilePicture: user.profilePicture,
        profileCompletionPercentage: user.profileCompletionPercentage,
        isProfileComplete: user.isProfileComplete,
      },
    });
  } catch (error) {
    console.error('Upload profile picture error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user profile
// @route   GET /api/profile/:username
// @access  Public
exports.getUserProfile = async (req, res) => {
  try {
    const user = await User.findOne({ username: req.params.username });

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    res.status(200).json({
      success: true,
      data: {
        id: user._id,
        username: user.username,
        displayName: user.displayName,
        bio: user.bio,
        profilePicture: user.profilePicture,
        interests: user.interests,
        isVerified: user.isVerified,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postsCount: user.postsCount,
        badges: user.badges,
        subscriptionTier: user.subscriptionTier,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get my profile stats
// @route   GET /api/profile/stats
// @access  Private
exports.getMyStats = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        coinBalance: user.coinBalance,
        totalCoinsEarned: user.totalCoinsEarned,
        withdrawableBalance: user.withdrawableBalance,
        followersCount: user.followersCount,
        followingCount: user.followingCount,
        postsCount: user.postsCount,
        likesCount: user.likesCount,
        totalViews: user.totalViews,
        subscriptionTier: user.subscriptionTier,
        uploadCount: user.uploadCount,
        referralCount: user.referralCount,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
