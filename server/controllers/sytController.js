const SYTEntry = require('../models/SYTEntry');
const Vote = require('../models/Vote');
const Like = require('../models/Like');
const User = require('../models/User');
const CompetitionSettings = require('../models/CompetitionSettings');
const { awardCoins, deductCoins } = require('../utils/coinSystem');

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

// Helper to get current active competition
const getCurrentCompetition = async (type) => {
  return await CompetitionSettings.getCurrentCompetition(type);
};

// @desc    Submit SYT entry
// @route   POST /api/syt/submit
// @access  Private
exports.submitEntry = async (req, res) => {
  try {
    const { title, description, category, competitionType, backgroundMusicId } = req.body;

    // Handle both single file and multiple files (video + thumbnail)
    const videoFile = req.files?.video?.[0] || req.file;
    const thumbnailFile = req.files?.thumbnail?.[0];

    if (!videoFile) {
      return res.status(400).json({
        success: false,
        message: 'Please upload a video',
      });
    }

    // Get current active competition
    const competition = await getCurrentCompetition(competitionType);
    
    if (!competition) {
      // Provide helpful error message with available competitions
      const allCompetitions = await CompetitionSettings.find({ isActive: true });
      return res.status(400).json({
        success: false,
        message: `No active ${competitionType} competition at this time`,
        availableCompetitions: allCompetitions.map(c => ({
          type: c.type,
          title: c.title,
          startDate: c.startDate,
          endDate: c.endDate,
          isActive: c.isCurrentlyActive(),
        })),
        hint: 'Please ask admin to create an active competition or try a different competition type',
      });
    }

    // Check if competition is currently active
    if (!competition.isCurrentlyActive()) {
      return res.status(400).json({
        success: false,
        message: 'Competition is not currently active',
        competition: {
          title: competition.title,
          startDate: competition.startDate,
          endDate: competition.endDate,
        },
      });
    }

    // Check if user already submitted for this competition period
    const existingEntry = await SYTEntry.findOne({
      user: req.user.id,
      competitionType,
      competitionPeriod: competition.periodId,
      isActive: true,
    });

    if (existingEntry) {
      return res.status(400).json({
        success: false,
        message: `You have already submitted an entry for this ${competitionType} competition`,
        existingEntry: {
          id: existingEntry._id,
          title: existingEntry.title,
          submittedAt: existingEntry.createdAt,
        },
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

    // Convert video to HLS format for better streaming
    let hlsUrl = null;
    try {
      console.log('🎬 Converting SYT video to HLS format...');
      const { convertVideoToHLS } = require('../utils/hlsConverter');
      const videoId = `syt_${Date.now()}_${Math.random().toString(36).substr(2, 9)}`;
      hlsUrl = await convertVideoToHLS(videoUrl, videoId);
      console.log('✅ HLS conversion completed:', hlsUrl);
    } catch (hlsError) {
      console.warn('⚠️ HLS conversion failed, using original video:', hlsError.message);
      // Continue with original video if HLS conversion fails
      hlsUrl = null;
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
    } else {
      // Auto-generate thumbnail if not provided
      try {
        const { generateAndUploadThumbnail } = require('../utils/thumbnailGenerator');
        console.log('🎬 Auto-generating thumbnail for SYT entry:', videoUrl);
        thumbnailUrl = await generateAndUploadThumbnail(videoUrl, `syt_${Date.now()}`);
        console.log('✅ SYT thumbnail auto-generated:', thumbnailUrl);
      } catch (error) {
        console.warn('⚠️ Failed to auto-generate SYT thumbnail:', error.message);
        // Continue without thumbnail if generation fails
      }
    }

    const entry = await SYTEntry.create({
      user: req.user.id,
      videoUrl: hlsUrl || videoUrl,  // Use HLS URL if available, otherwise original
      thumbnailUrl: thumbnailUrl,
      title,
      description,
      category,
      competitionType,
      competitionPeriod: competition.periodId,
      backgroundMusic: backgroundMusicId || null,
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
    } else if (filter === 'weekly' || filter === 'monthly' || filter === 'quarterly') {
      // Get current active competition for this type
      const competition = await getCurrentCompetition(filter);
      if (competition) {
        query.competitionType = filter;
        query.competitionPeriod = competition.periodId;
      } else {
        // No active competition - return entries from any recent period for this type
        // This allows viewing entries even if competition isn't active
        query.competitionType = filter;
        // Don't filter by period - show all entries for this type
      }
    }

    const entries = await SYTEntry.find(query)
      .sort({ votesCount: -1, createdAt: -1 })
      .populate('user', 'username displayName profilePicture isVerified')
      .populate('backgroundMusic', 'title artist audioUrl duration genre mood');

    res.status(200).json({
      success: true,
      data: entries,
      message: entries.length === 0 ? `No entries found for ${filter || 'this'} competition` : undefined,
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

    // Check if voter has enough coins (1 coin required to vote)
    const voter = await User.findById(req.user.id);
    if (!voter || voter.coinBalance < 1) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient coins to vote. You need at least 1 coin to vote.',
        requiredCoins: 1,
        currentCoins: voter ? voter.coinBalance : 0,
      });
    }

    // Deduct 1 coin from voter
    try {
      await deductCoins(
        req.user.id,
        1,
        'vote_cast',
        'Voted for SYT entry',
        { relatedSYTEntry: entry._id }
      );
    } catch (coinError) {
      console.error('❌ Error deducting coins:', coinError);
      return res.status(400).json({
        success: false,
        message: 'Failed to deduct voting cost. Please try again.',
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

    // Create vote notification
    try {
      const { createVoteNotification } = require('../utils/notificationHelper');
      await createVoteNotification(entry._id, req.user.id, entry.user);
    } catch (notificationError) {
      console.error('❌ Error creating vote notification:', notificationError);
    }

    res.status(200).json({
      success: true,
      message: 'Vote recorded successfully',
      votesCount: entry.votesCount,
      coinsDeducted: 1,
      coinsAwarded: 1,
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
    const competitionType = type || 'weekly';
    
    // Get current active competition
    const competition = await getCurrentCompetition(competitionType);
    
    if (!competition) {
      return res.status(200).json({
        success: true,
        data: [],
        message: `No active ${competitionType} competition`,
      });
    }

    const entries = await SYTEntry.find({
      competitionType,
      competitionPeriod: competition.periodId,
      isActive: true,
      isApproved: true,
    })
      .sort({ votesCount: -1 })
      .limit(10)
      .populate('user', 'username displayName profilePicture isVerified')
      .populate('backgroundMusic', 'title artist audioUrl duration genre mood');

    res.status(200).json({
      success: true,
      data: entries,
      period: competition.periodId,
      competition: {
        title: competition.title,
        startDate: competition.startDate,
        endDate: competition.endDate,
      },
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

      // Create like notification (only when liking, not unliking)
      if (entry.user.toString() !== req.user.id) {
        try {
          const { createLikeNotification } = require('../utils/notificationHelper');
          await createLikeNotification(entry._id, req.user.id, entry.user);
        } catch (notificationError) {
          console.error('❌ Error creating SYT like notification:', notificationError);
        }
      }
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

// @desc    Check if user has submitted for current competition
// @route   GET /api/syt/check-submission
// @access  Private
exports.checkUserSubmission = async (req, res) => {
  try {
    const { type } = req.query; // weekly, monthly, quarterly
    const competitionType = type || 'weekly';

    // Get current active competition
    const competition = await getCurrentCompetition(competitionType);
    
    if (!competition) {
      return res.status(200).json({
        success: true,
        data: {
          hasCompetition: false,
          hasSubmitted: false,
          message: `No active ${competitionType} competition at this time`,
        },
      });
    }

    // Check if user has submitted for this competition
    const submission = await SYTEntry.findOne({
      user: req.user.id,
      competitionType,
      competitionPeriod: competition.periodId,
      isActive: true,
    });

    res.status(200).json({
      success: true,
      data: {
        hasCompetition: true,
        hasSubmitted: !!submission,
        competition: {
          id: competition._id,
          title: competition.title,
          type: competition.type,
          startDate: competition.startDate,
          endDate: competition.endDate,
          isActive: competition.isCurrentlyActive(),
        },
        submission: submission ? {
          id: submission._id,
          title: submission.title,
          category: submission.category,
          submittedAt: submission.createdAt,
          votesCount: submission.votesCount,
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

// Legacy endpoint for backward compatibility
exports.checkUserWeeklySubmission = exports.checkUserSubmission;


// ==================== ADMIN ENDPOINTS ====================

// @desc    Get all competitions
// @route   GET /api/syt/admin/competitions
// @access  Admin
exports.getCompetitions = async (req, res) => {
  try {
    const competitions = await CompetitionSettings.find()
      .sort({ startDate: -1 });

    res.status(200).json({
      success: true,
      data: competitions,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Create new competition
// @route   POST /api/syt/admin/competitions
// @access  Admin
exports.createCompetition = async (req, res) => {
  try {
    const { type, title, description, startDate, endDate, prizes } = req.body;

    if (!type || !title || !startDate || !endDate) {
      return res.status(400).json({
        success: false,
        message: 'Please provide type, title, startDate, and endDate',
      });
    }

    // Validate dates
    const start = new Date(startDate);
    const end = new Date(endDate);

    if (start >= end) {
      return res.status(400).json({
        success: false,
        message: 'End date must be after start date',
      });
    }

    // Generate period ID
    const periodId = `${type}-${start.getFullYear()}-${start.getMonth() + 1}-${start.getDate()}`;

    // Check for overlapping competitions of same type
    const overlapping = await CompetitionSettings.findOne({
      type,
      isActive: true,
      $or: [
        { startDate: { $lte: end }, endDate: { $gte: start } },
      ],
    });

    if (overlapping) {
      return res.status(400).json({
        success: false,
        message: 'There is already an active competition overlapping with these dates',
      });
    }

    const competition = await CompetitionSettings.create({
      type,
      title,
      description,
      startDate: start,
      endDate: end,
      periodId,
      prizes: prizes || [
        { position: 1, coins: 1000, badge: 'Gold' },
        { position: 2, coins: 500, badge: 'Silver' },
        { position: 3, coins: 250, badge: 'Bronze' },
      ],
    });

    res.status(201).json({
      success: true,
      message: 'Competition created successfully',
      data: competition,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Update competition
// @route   PUT /api/syt/admin/competitions/:id
// @access  Admin
exports.updateCompetition = async (req, res) => {
  try {
    const { title, description, startDate, endDate, prizes, isActive } = req.body;

    const competition = await CompetitionSettings.findById(req.params.id);

    if (!competition) {
      return res.status(404).json({
        success: false,
        message: 'Competition not found',
      });
    }

    // Update fields
    if (title) competition.title = title;
    if (description !== undefined) competition.description = description;
    if (startDate) competition.startDate = new Date(startDate);
    if (endDate) competition.endDate = new Date(endDate);
    if (prizes) competition.prizes = prizes;
    if (isActive !== undefined) competition.isActive = isActive;

    // Validate dates if changed
    if (competition.startDate >= competition.endDate) {
      return res.status(400).json({
        success: false,
        message: 'End date must be after start date',
      });
    }

    await competition.save();

    res.status(200).json({
      success: true,
      message: 'Competition updated successfully',
      data: competition,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Delete competition
// @route   DELETE /api/syt/admin/competitions/:id
// @access  Admin
exports.deleteCompetition = async (req, res) => {
  try {
    const competition = await CompetitionSettings.findById(req.params.id);

    if (!competition) {
      return res.status(404).json({
        success: false,
        message: 'Competition not found',
      });
    }

    await competition.deleteOne();

    res.status(200).json({
      success: true,
      message: 'Competition deleted successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get current active competition info
// @route   GET /api/syt/current-competition
// @access  Public
exports.getCurrentCompetitionInfo = async (req, res) => {
  try {
    const { type } = req.query;
    const competitionType = type || 'weekly';

    const competition = await getCurrentCompetition(competitionType);

    if (!competition) {
      return res.status(200).json({
        success: true,
        data: {
          hasActiveCompetition: false,
          message: `No active ${competitionType} competition at this time`,
        },
      });
    }

    // If user is authenticated, check if they've submitted
    let hasSubmitted = false;
    let userSubmission = null;

    if (req.user) {
      const submission = await SYTEntry.findOne({
        user: req.user.id,
        competitionType,
        competitionPeriod: competition.periodId,
        isActive: true,
      });

      hasSubmitted = !!submission;
      if (submission) {
        userSubmission = {
          id: submission._id,
          title: submission.title,
          category: submission.category,
          submittedAt: submission.createdAt,
          votesCount: submission.votesCount,
        };
      }
    }

    res.status(200).json({
      success: true,
      data: {
        hasActiveCompetition: true,
        competition: {
          id: competition._id,
          title: competition.title,
          description: competition.description,
          type: competition.type,
          startDate: competition.startDate,
          endDate: competition.endDate,
          prizes: competition.prizes,
          isActive: competition.isCurrentlyActive(),
        },
        hasSubmitted,
        userSubmission,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
