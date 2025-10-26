const SYTEntry = require('../models/SYTEntry');
const Vote = require('../models/Vote');
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

    if (!req.file) {
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

    // Handle both S3 (location/key) and local storage (path)
    let videoUrl;
    if (req.file.key) {
      // S3/Wasabi - construct correct public URL
      const region = process.env.WASABI_REGION || 'ap-southeast-1';
      const bucketName = process.env.WASABI_BUCKET_NAME;
      // Use path-style URL that matches SSL certificate
      videoUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${req.file.key}`;
    } else if (req.file.location) {
      // Fallback to location if provided
      videoUrl = req.file.location;
    } else {
      // Local storage - construct relative path
      videoUrl = `/uploads/videos/${req.file.filename}`;
    }

    const entry = await SYTEntry.create({
      user: req.user.id,
      videoUrl: videoUrl,
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

    // Check if user already voted today
    const today = new Date().setHours(0, 0, 0, 0);
    const existingVote = await Vote.findOne({
      user: req.user.id,
      sytEntry: entry._id,
      voteDate: { $gte: today },
    });

    if (existingVote) {
      return res.status(400).json({
        success: false,
        message: 'You have already voted for this entry today',
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
