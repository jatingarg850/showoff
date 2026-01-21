const VideoAd = require('../models/VideoAd');
const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Get all video ads for app
// @route   GET /api/video-ads
// @access  Public
exports.getVideoAdsForApp = async (req, res) => {
  try {
    const videoAds = await VideoAd.find({ isActive: true })
      .sort({ rotationOrder: 1, createdAt: -1 });
    
    if (videoAds.length === 0) {
      return res.status(200).json({
        success: true,
        data: [],
        message: 'No active video ads available'
      });
    }
    
    // Update impressions for each ad
    await Promise.all(videoAds.map(ad => {
      ad.impressions += 1;
      ad.lastServedAt = new Date();
      ad.servedCount += 1;
      return ad.save();
    }));
    
    // Return ads with necessary info for app
    const adsForApp = videoAds.map(ad => ({
      id: ad._id,
      title: ad.title,
      description: ad.description,
      videoUrl: ad.videoUrl,
      thumbnailUrl: ad.thumbnailUrl,
      duration: ad.duration,
      rewardCoins: ad.rewardCoins,
      icon: ad.icon,
      color: ad.color,
      isActive: ad.isActive,
      adType: 'video',
    }));
    
    res.status(200).json({
      success: true,
      data: adsForApp,
      message: 'Video ads retrieved successfully'
    });
  } catch (error) {
    console.error('❌ Error getting video ads:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Get all video ads (Admin)
// @route   GET /api/admin/video-ads
// @access  Private (Admin)
exports.getAllVideoAds = async (req, res) => {
  try {
    const videoAds = await VideoAd.find()
      .populate('uploadedBy', 'username email')
      .sort({ createdAt: -1 });
    
    res.status(200).json({
      success: true,
      data: videoAds,
      count: videoAds.length
    });
  } catch (error) {
    console.error('❌ Error getting video ads:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Create video ad (Admin)
// @route   POST /api/admin/video-ads
// @access  Private (Admin)
exports.createVideoAd = async (req, res) => {
  try {
    const { title, description, videoUrl, thumbnailUrl, duration, rewardCoins, icon, color, rotationOrder } = req.body;
    
    if (!title || !videoUrl) {
      return res.status(400).json({
        success: false,
        message: 'Title and video URL are required'
      });
    }
    
    const videoAd = await VideoAd.create({
      title,
      description: description || 'Watch this video to earn coins',
      videoUrl,
      thumbnailUrl,
      duration: duration || 30,
      rewardCoins: rewardCoins || 10,
      icon: icon || 'video',
      color: color || '#667eea',
      rotationOrder: rotationOrder || 0,
      uploadedBy: req.user.id,
    });
    
    res.status(201).json({
      success: true,
      message: 'Video ad created successfully',
      data: videoAd
    });
  } catch (error) {
    console.error('❌ Error creating video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Update video ad (Admin)
// @route   PUT /api/admin/video-ads/:id
// @access  Private (Admin)
exports.updateVideoAd = async (req, res) => {
  try {
    const { title, description, videoUrl, thumbnailUrl, duration, rewardCoins, icon, color, isActive, rotationOrder } = req.body;
    
    let videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    // Update fields
    if (title) videoAd.title = title;
    if (description) videoAd.description = description;
    if (videoUrl) videoAd.videoUrl = videoUrl;
    if (thumbnailUrl) videoAd.thumbnailUrl = thumbnailUrl;
    if (duration) videoAd.duration = duration;
    if (rewardCoins) videoAd.rewardCoins = rewardCoins;
    if (icon) videoAd.icon = icon;
    if (color) videoAd.color = color;
    if (isActive !== undefined) videoAd.isActive = isActive;
    if (rotationOrder !== undefined) videoAd.rotationOrder = rotationOrder;
    
    await videoAd.save();
    
    res.status(200).json({
      success: true,
      message: 'Video ad updated successfully',
      data: videoAd
    });
  } catch (error) {
    console.error('❌ Error updating video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Delete video ad (Admin)
// @route   DELETE /api/admin/video-ads/:id
// @access  Private (Admin)
exports.deleteVideoAd = async (req, res) => {
  try {
    const videoAd = await VideoAd.findByIdAndDelete(req.params.id);
    
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    res.status(200).json({
      success: true,
      message: 'Video ad deleted successfully'
    });
  } catch (error) {
    console.error('❌ Error deleting video ad:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Track video ad view
// @route   POST /api/video-ads/:id/view
// @access  Private
exports.trackVideoAdView = async (req, res) => {
  try {
    const videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    videoAd.views += 1;
    await videoAd.save();
    
    res.status(200).json({
      success: true,
      message: 'View tracked'
    });
  } catch (error) {
    console.error('❌ Error tracking view:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Track video ad completion
// @route   POST /api/video-ads/:id/complete
// @access  Private
exports.trackVideoAdCompletion = async (req, res) => {
  try {
    const videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    videoAd.completions += 1;
    videoAd.clicks += 1;
    await videoAd.save();
    
    // Award coins to user
    const user = await User.findById(req.user.id);
    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found'
      });
    }
    
    const coinsToAward = videoAd.rewardCoins;
    user.coinBalance += coinsToAward;
    await user.save();
    
    // Create transaction record
    await Transaction.create({
      user: req.user.id,
      type: 'video_ad_reward',
      amount: coinsToAward,
      balanceAfter: user.coinBalance,
      description: `Watched video ad: ${videoAd.title}`,
      status: 'completed',
      metadata: {
        videoAdId: videoAd._id,
        videoAdTitle: videoAd.title
      }
    });
    
    videoAd.conversions += 1;
    await videoAd.save();
    
    res.status(200).json({
      success: true,
      message: 'Video ad completed and coins awarded',
      coinsEarned: coinsToAward,
      newBalance: user.coinBalance
    });
  } catch (error) {
    console.error('❌ Error tracking completion:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};

// @desc    Reset video ad statistics (Admin)
// @route   POST /api/admin/video-ads/:id/reset-stats
// @access  Private (Admin)
exports.resetVideoAdStats = async (req, res) => {
  try {
    const videoAd = await VideoAd.findById(req.params.id);
    if (!videoAd) {
      return res.status(404).json({
        success: false,
        message: 'Video ad not found'
      });
    }
    
    videoAd.impressions = 0;
    videoAd.clicks = 0;
    videoAd.conversions = 0;
    videoAd.views = 0;
    videoAd.completions = 0;
    videoAd.servedCount = 0;
    await videoAd.save();
    
    res.status(200).json({
      success: true,
      message: 'Video ad statistics reset',
      data: videoAd
    });
  } catch (error) {
    console.error('❌ Error resetting stats:', error);
    res.status(500).json({
      success: false,
      message: error.message
    });
  }
};
