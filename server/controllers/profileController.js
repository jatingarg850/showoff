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
        'welcome_bonus',
        'Welcome Bonus'
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
        'welcome_bonus',
        'Welcome Bonus'
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

// @desc    Apply referral code
// @route   POST /api/profile/apply-referral
// @access  Private
exports.applyReferralCode = async (req, res) => {
  try {
    const { referralCode } = req.body;
    
    if (!referralCode) {
      return res.status(400).json({
        success: false,
        message: 'Referral code is required',
      });
    }

    const user = await User.findById(req.user.id);

    // Check if user already used a referral code
    if (user.referredBy) {
      return res.status(400).json({
        success: false,
        message: 'You have already used a referral code',
      });
    }

    // Find the referrer
    const referrer = await User.findOne({ referralCode: referralCode.toUpperCase() });

    if (!referrer) {
      return res.status(404).json({
        success: false,
        message: 'Invalid referral code',
      });
    }

    // Check if user is trying to use their own code
    if (referrer._id.toString() === user._id.toString()) {
      return res.status(400).json({
        success: false,
        message: 'You cannot use your own referral code',
      });
    }

    // Award coins to both users
    // Award 20 coins to the new user (referee)
    await awardCoins(
      user._id,
      20,
      'referral_bonus',
      'Referral Bonus - Used referral code'
    );
    user.coinBalance += 20;
    user.referredBy = referrer._id;
    await user.save();

    // Award 20 coins to the referrer
    await awardCoins(
      referrer._id,
      20,
      'referral_bonus',
      `Referral Bonus - ${user.username} joined using your code`
    );
    referrer.coinBalance += 20;
    referrer.referralCount = (referrer.referralCount || 0) + 1;
    await referrer.save();

    res.status(200).json({
      success: true,
      message: 'Referral code applied successfully! You both earned 20 coins.',
      data: {
        coinsEarned: 20,
        newBalance: user.coinBalance,
        referrerUsername: referrer.username,
      },
    });
  } catch (error) {
    console.error('Apply referral error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
