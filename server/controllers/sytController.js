const SYTEntry = require('../models/SYTEntry');
const Vote = require('../models/Vote');
const Like = require('../models/Like');
const User = require('../models/User');
const { awardCoins } = require('../utils/coinSystem');

// Helper to get current competition period
const getCurrentPeriod = (type) => {
  const now = new Date();
  const year = now.getFullYear();
  
  if (type === 'weekly') {
    const week = Math.ceil((now - new Date(year, 0, 1)) / (7 * 24 * 60 * 60 * 1000));
    return `${year}-W${week.toString().padStart(2, '0')}`;
  } else if (type === 'monthly') {
    const month = (now.getMonth() + 1).toString().padStart(2, '0');
    return `${year}-${month}`;
  } else if (type === 'quarterly') {
    const quarter = Math.ceil((now.getMonth() + 1) / 3);
    return `${year}-Q${quarter}`;
  }
};

// @desc    Submit SYT entry
// @route   POST /api/syt/submit
// @access  Private
exports.submitEntry = async (req, res) => {
  try {
    const { title, description, category, competitionType } = req.body;

    // Handle both single file and multiple files (video + thumbnail)
    const videoFile = req.files?.video?.[0] || req.file;
    const thumbnailFile = req.files?.thumbnail?.[0];

    if (!videoFile) {
      return res.status(400).json({
        success: false,
        message: 'Please upload a video',
      });
    }

    // Check if user already submitted for this period
    const period = getCurrentPeriod(competitionType);
    const existingEntry = await SYTEntry.findOne({
      user: req.user.id,
      competitionType,
      competitionPeriod: period,
    });

    if (existingEntry) {
      return res.status(400).json({
        success: false,
        message: `You have already submitted an entry for this ${competitionType} competition`,
      });
    }

    // Handle video URL - both S3 (location/key) and local storage (path)
    let videoUrl;
    if (videoFile.key) {
      // S3/Wasabi - construct correct public URL
      const region = process.env.WASABI_REGION || 'ap-southeast-1';
      const bucketName = process.env.WASABI_BUCKET_NAME;
      videoUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${videoFile.key}`;
    } else if (videoFile.location) {
      videoUrl = videoFile.location;
    } else {
      videoUrl = `/uploads/videos/${videoFile.filename}`;
    }

    // Handle thumbnail URL if provided
    let thumbnailUrl = null;
    if (thumbnailFile) {
      if (thumbnailFile.key) {
        const region = process.env.WASABI_REGION || 'ap-southeast-1';
        const bucketName = process.env.WASABI_BUCKET_NAME;
        thumbnailUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${thumbnailFile.key}`;
      } else if (thumbnailFile.location) {
        thumbnailUrl = thumbnailFile.location;
      } else {
        thumbnailUrl = `/uploads/images/${thumbnailFile.filename}`;
      }
    }

    const entry = await SYTEntry.create({
      user: req.user.id,
      videoUrl: videoUrl,
      thumbnailUrl: thumbnailUrl,
      title,
      description,
      category,
      competitionType,
      competitionPeriod: period,
    });

    await entry.populate('user', 'username displayName profilePicture isVerified');

    res.status(201).json({
      success: true,
      data: entry,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get SYT entries
// @route   GET /api/syt/entries
// @access  Public
exports.getEntries = async (req, res) => {
  try {
    const { type, period, filter } = req.query;
    
    let query = { isActive: true, isApproved: true };
    
    if (type) query.competitionType = type;
    if (period) query.competitionPeriod = period;
    
    // Filter: weekly, monthly, all, winners
    if (filter === 'winners') {
      query.isWinner = true;
    } else if (filter === 'weekly') {
      query.competitionType = 'weekly';
      query.competitionPeriod = getCurrentPeriod('weekly');
    } else if (filter === 'monthly') {
      query.competitionType = 'monthly';
      query.competitionPeriod = getCurrentPeriod('monthly');
    }

    const entries = await SYTEntry.find(query)
      .sort({ votesCount: -1, createdAt: -1 })
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: entries,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Vote for SYT entry
// @route   POST /api/syt/:id/vote
// @access  Private
exports.voteEntry = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    // Check if user already voted in the last 24 hours
    const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
    const existingVote = await Vote.findOne({
      user: req.user.id,
      sytEntry: entry._id,
      voteDate: { $gte: twentyFourHoursAgo },
    });

    if (existingVote) {
      // Calculate time remaining until next vote
      const nextVoteTime = new Date(existingVote.voteDate.getTime() + 24 * 60 * 60 * 1000);
      const hoursRemaining = Math.ceil((nextVoteTime - Date.now()) / (60 * 60 * 1000));
      
      return res.status(400).json({
        success: false,
        message: `You can vote again in ${hoursRemaining} hour${hoursRemaining !== 1 ? 's' : ''}`,
        nextVoteTime: nextVoteTime.toISOString(),
      });
    }

    // Create vote
    await Vote.create({
      user: req.user.id,
      sytEntry: entry._id,
      voteDate: Date.now(),
    });

    // Update entry
    entry.votesCount += 1;
    entry.coinsEarned += 1;
    await entry.save();

    // Award 1 coin to creator
    await awardCoins(
      entry.user,
      1,
      'vote_received',
      'Vote received on SYT entry',
      { relatedSYTEntry: entry._id }
    );

    res.status(200).json({
      success: true,
      message: 'Vote recorded successfully',
      votesCount: entry.votesCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get leaderboard
// @route   GET /api/syt/leaderboard
// @access  Public
exports.getLeaderboard = async (req, res) => {
  try {
    const { type } = req.query; // weekly, monthly, quarterly
    const period = getCurrentPeriod(type || 'weekly');

    const entries = await SYTEntry.find({
      competitionType: type || 'weekly',
      competitionPeriod: period,
      isActive: true,
      isApproved: true,
    })
      .sort({ votesCount: -1 })
      .limit(10)
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: entries,
      period,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Toggle like on SYT entry
// @route   POST /api/syt/:id/like
// @access  Private
exports.toggleLike = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    // Check if user already liked this entry
    const existingLike = await Like.findOne({
      user: req.user.id,
      sytEntry: entry._id,
    });

    let isLiked;
    
    if (existingLike) {
      // Unlike
      await Like.deleteOne({ _id: existingLike._id });
      entry.likesCount = Math.max(0, entry.likesCount - 1);
      isLiked = false;
    } else {
      // Like
      await Like.create({
        user: req.user.id,
        sytEntry: entry._id,
      });
      entry.likesCount += 1;
      isLiked = true;
    }

    await entry.save();

    res.status(200).json({
      success: true,
      data: {
        isLiked,
        likesCount: entry.likesCount,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get SYT entry stats
// @route   GET /api/syt/:id/stats
// @access  Public (but returns user-specific data if authenticated)
exports.getEntryStats = async (req, res) => {
  try {
    const entry = await SYTEntry.findById(req.params.id);
    
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    const stats = {
      likesCount: entry.likesCount || 0,
      votesCount: entry.votesCount || 0,
      commentsCount: entry.commentsCount || 0,
      viewsCount: entry.viewsCount || 0,
    };

    // If user is authenticated, check their interactions
    if (req.user) {
      const Bookmark = require('../models/Bookmark');
      const twentyFourHoursAgo = new Date(Date.now() - 24 * 60 * 60 * 1000);
      
      const [isLiked, recentVote, isBookmarked] = await Promise.all([
        Like.exists({ user: req.user.id, sytEntry: entry._id }),
        Vote.findOne({ 
          user: req.user.id, 
          sytEntry: entry._id,
          voteDate: { $gte: twentyFourHoursAgo }
        }),
        Bookmark.exists({ user: req.user.id, sytEntry: entry._id }),
      ]);
      
      stats.isLiked = !!isLiked;
      stats.hasVoted = !!recentVote;
      stats.isBookmarked = !!isBookmarked;
      
      // If they voted recently, include when they can vote again
      if (recentVote) {
        const nextVoteTime = new Date(recentVote.voteDate.getTime() + 24 * 60 * 60 * 1000);
        stats.nextVoteTime = nextVoteTime.toISOString();
        stats.hoursUntilNextVote = Math.ceil((nextVoteTime - Date.now()) / (60 * 60 * 1000));
      }
    } else {
      stats.isLiked = false;
      stats.hasVoted = false;
      stats.isBookmarked = false;
    }

    res.status(200).json({
      success: true,
      data: stats,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Toggle bookmark on SYT entry
// @route   POST /api/syt/:id/bookmark
// @access  Private
exports.toggleBookmark = async (req, res) => {
  try {
    const Bookmark = require('../models/Bookmark');
    const entry = await SYTEntry.findById(req.params.id);
    
    if (!entry) {
      return res.status(404).json({
        success: false,
        message: 'Entry not found',
      });
    }

    // Check if user already bookmarked this entry
    const existingBookmark = await Bookmark.findOne({
      user: req.user.id,
      sytEntry: entry._id,
    });

    let isBookmarked;
    
    if (existingBookmark) {
      // Remove bookmark
      await Bookmark.deleteOne({ _id: existingBookmark._id });
      isBookmarked = false;
    } else {
      // Add bookmark
      await Bookmark.create({
        user: req.user.id,
        sytEntry: entry._id,
      });
      isBookmarked = true;
    }

    res.status(200).json({
      success: true,
      data: {
        isBookmarked,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check if user has submitted for current week
// @route   GET /api/syt/weekly-check
// @access  Private
exports.checkUserWeeklySubmission = async (req, res) => {
  try {
    // Get current week period (Monday to Sunday)
    const now = new Date();
    
    // Calculate the start of the current week (Monday)
    const dayOfWeek = now.getDay(); // 0 = Sunday, 1 = Monday, etc.
    const daysToMonday = dayOfWeek === 0 ? 6 : dayOfWeek - 1; // If Sunday, go back 6 days
    const startOfWeek = new Date(now);
    startOfWeek.setDate(now.getDate() - daysToMonday);
    startOfWeek.setHours(0, 0, 0, 0);
    
    // Calculate the end of the current week (Sunday)
    const endOfWeek = new Date(startOfWeek);
    endOfWeek.setDate(startOfWeek.getDate() + 6);
    endOfWeek.setHours(23, 59, 59, 999);

    // Check if user has submitted any SYT entry this week
    const weeklySubmission = await SYTEntry.findOne({
      user: req.user.id,
      createdAt: {
        $gte: startOfWeek,
        $lte: endOfWeek,
      },
      isActive: true,
    });

    res.status(200).json({
      success: true,
      data: {
        hasSubmitted: !!weeklySubmission,
        weekStart: startOfWeek,
        weekEnd: endOfWeek,
        submission: weeklySubmission ? {
          id: weeklySubmission._id,
          title: weeklySubmission.title,
          category: weeklySubmission.category,
          submittedAt: weeklySubmission.createdAt,
        } : null,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};