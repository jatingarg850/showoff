const DailySelfie = require('../models/DailySelfie');
const Vote = require('../models/Vote');
const User = require('../models/User');
const { awardCoins } = require('../utils/coinSystem');

// Helper to get today's date string
const getTodayDateString = () => {
  const today = new Date();
  return today.toISOString().split('T')[0]; // YYYY-MM-DD format
};

// Helper to get current challenge theme
const getTodayTheme = () => {
  const themes = [
    'Golden Hour Glow',
    'Mirror Selfie',
    'Nature Background',
    'Black & White',
    'Smile Challenge',
    'Creative Angle',
    'Outfit of the Day',
    'Morning Vibes',
    'Sunset Mood',
    'Artistic Shadow',
    'Cozy Corner',
    'Street Style',
    'Minimalist',
    'Color Pop',
    'Vintage Filter'
  ];
  
  const today = new Date();
  const dayOfYear = Math.floor((today - new Date(today.getFullYear(), 0, 0)) / 1000 / 60 / 60 / 24);
  return themes[dayOfYear % themes.length];
};

// @desc    Submit daily selfie
// @route   POST /api/dailyselfie/submit
// @access  Private
exports.submitDailySelfie = async (req, res) => {
  try {
    if (!req.file) {
      return res.status(400).json({
        success: false,
        message: 'Please upload a selfie image',
      });
    }

    const todayDate = getTodayDateString();
    const theme = getTodayTheme();

    // Check if user already submitted today
    const existingSelfie = await DailySelfie.findOne({
      user: req.user.id,
      challengeDate: todayDate,
    });

    if (existingSelfie) {
      return res.status(400).json({
        success: false,
        message: 'You have already submitted a selfie for today',
      });
    }

    // Handle both S3 (location/key) and local storage (path)
    let imageUrl;
    if (req.file.key) {
      // S3/Wasabi - construct correct public URL
      const region = process.env.WASABI_REGION || 'ap-southeast-1';
      const bucketName = process.env.WASABI_BUCKET_NAME;
      // Use path-style URL that matches SSL certificate
      imageUrl = `https://s3.${region}.wasabisys.com/${bucketName}/${req.file.key}`;
    } else if (req.file.location) {
      // Fallback to location if provided
      imageUrl = req.file.location;
    } else {
      // Local storage - construct relative path
      imageUrl = `/uploads/images/${req.file.filename}`;
    }

    const selfie = await DailySelfie.create({
      user: req.user.id,
      imageUrl: imageUrl,
      challengeDate: todayDate,
      theme,
    });

    await selfie.populate('user', 'username displayName profilePicture isVerified');

    // Award 5 coins for daily participation
    await awardCoins(
      req.user.id,
      5,
      'daily_selfie',
      'Daily selfie challenge participation',
      { relatedDailySelfie: selfie._id }
    );

    res.status(201).json({
      success: true,
      data: selfie,
      message: 'Daily selfie submitted successfully! +5 coins earned',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get daily selfies
// @route   GET /api/dailyselfie/entries
// @access  Public
exports.getDailySelfies = async (req, res) => {
  try {
    const { date, limit = 20 } = req.query;
    
    let query = { isActive: true };
    
    if (date) {
      query.challengeDate = date;
    } else {
      // Get today's selfies by default
      query.challengeDate = getTodayDateString();
    }

    const selfies = await DailySelfie.find(query)
      .sort({ votesCount: -1, createdAt: -1 })
      .limit(parseInt(limit))
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: selfies,
      theme: getTodayTheme(),
      date: date || getTodayDateString(),
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Vote for daily selfie
// @route   POST /api/dailyselfie/:id/vote
// @access  Private
exports.voteDailySelfie = async (req, res) => {
  try {
    const selfie = await DailySelfie.findById(req.params.id);
    
    if (!selfie) {
      return res.status(404).json({
        success: false,
        message: 'Selfie not found',
      });
    }

    // Check if user already voted for this selfie
    const existingVote = await Vote.findOne({
      user: req.user.id,
      dailySelfie: selfie._id,
    });

    if (existingVote) {
      return res.status(400).json({
        success: false,
        message: 'You have already voted for this selfie',
      });
    }

    // Check daily vote limit (max 5 votes per day for daily selfies)
    const today = new Date().setHours(0, 0, 0, 0);
    const todayVotes = await Vote.countDocuments({
      user: req.user.id,
      dailySelfie: { $exists: true },
      createdAt: { $gte: today },
    });

    if (todayVotes >= 5) {
      return res.status(400).json({
        success: false,
        message: 'You have reached your daily voting limit (5 votes)',
      });
    }

    // Create vote
    await Vote.create({
      user: req.user.id,
      dailySelfie: selfie._id,
    });

    // Update selfie
    selfie.votesCount += 1;
    await selfie.save();

    // Award 1 coin to selfie creator
    await awardCoins(
      selfie.user,
      1,
      'selfie_vote_received',
      'Vote received on daily selfie',
      { relatedDailySelfie: selfie._id }
    );

    res.status(200).json({
      success: true,
      message: 'Vote recorded successfully',
      votesCount: selfie.votesCount,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get daily selfie leaderboard
// @route   GET /api/dailyselfie/leaderboard
// @access  Public
exports.getDailySelfieLeaderboard = async (req, res) => {
  try {
    const { type = 'daily', limit = 10 } = req.query;
    
    let dateFilter = {};
    const now = new Date();
    
    if (type === 'daily') {
      dateFilter.challengeDate = getTodayDateString();
    } else if (type === 'weekly') {
      const weekStart = new Date(now.setDate(now.getDate() - now.getDay()));
      weekStart.setHours(0, 0, 0, 0);
      dateFilter.createdAt = { $gte: weekStart };
    } else if (type === 'monthly') {
      const monthStart = new Date(now.getFullYear(), now.getMonth(), 1);
      dateFilter.createdAt = { $gte: monthStart };
    }

    const leaderboard = await DailySelfie.find({
      isActive: true,
      ...dateFilter,
    })
      .sort({ votesCount: -1, createdAt: -1 })
      .limit(parseInt(limit))
      .populate('user', 'username displayName profilePicture isVerified');

    // Calculate user streaks for leaderboard
    const leaderboardWithStreaks = await Promise.all(
      leaderboard.map(async (entry) => {
        const userStreak = await calculateUserStreak(entry.user._id);
        return {
          ...entry.toObject(),
          streak: userStreak,
        };
      })
    );

    res.status(200).json({
      success: true,
      data: leaderboardWithStreaks,
      type,
      theme: type === 'daily' ? getTodayTheme() : null,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get user's selfie streak
// @route   GET /api/dailyselfie/streak
// @access  Private
exports.getUserStreak = async (req, res) => {
  try {
    const streak = await calculateUserStreak(req.user.id);
    const todaySubmitted = await DailySelfie.findOne({
      user: req.user.id,
      challengeDate: getTodayDateString(),
    });

    res.status(200).json({
      success: true,
      data: {
        currentStreak: streak,
        todayCompleted: !!todaySubmitted,
        todayTheme: getTodayTheme(),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Helper function to calculate user's current streak
const calculateUserStreak = async (userId) => {
  try {
    const userSelfies = await DailySelfie.find({
      user: userId,
      isActive: true,
    }).sort({ challengeDate: -1 });

    if (userSelfies.length === 0) return 0;

    let streak = 0;
    const today = new Date();
    let checkDate = new Date(today);

    // Check if today is completed
    const todayString = getTodayDateString();
    const todaySubmitted = userSelfies.find(s => s.challengeDate === todayString);
    
    if (!todaySubmitted) {
      // If today is not completed, start checking from yesterday
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // Count consecutive days
    for (let i = 0; i < userSelfies.length; i++) {
      const dateString = checkDate.toISOString().split('T')[0];
      const selfieForDate = userSelfies.find(s => s.challengeDate === dateString);
      
      if (selfieForDate) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else {
        break;
      }
    }

    return streak;
  } catch (error) {
    console.error('Error calculating streak:', error);
    return 0;
  }
};

// @desc    Get today's challenge info
// @route   GET /api/dailyselfie/today
// @access  Public
exports.getTodayChallenge = async (req, res) => {
  try {
    const theme = getTodayTheme();
    const date = getTodayDateString();
    
    // Get today's submissions count
    const submissionsCount = await DailySelfie.countDocuments({
      challengeDate: date,
      isActive: true,
    });

    // Get top 3 for today
    const topSelfies = await DailySelfie.find({
      challengeDate: date,
      isActive: true,
    })
      .sort({ votesCount: -1 })
      .limit(3)
      .populate('user', 'username displayName profilePicture isVerified');

    res.status(200).json({
      success: true,
      data: {
        theme,
        date,
        submissionsCount,
        topSelfies,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};