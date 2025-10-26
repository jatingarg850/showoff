const User = require('../models/User');
const Transaction = require('../models/Transaction');
const { awardCoins } = require('../utils/coinSystem');

// @desc    Watch ad and earn coins
// @route   POST /api/coins/watch-ad
// @access  Private
exports.watchAd = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // Check daily limit based on subscription
    const dailyLimits = {
      free: 5,
      basic: 10,
      pro: 15,
      vip: 50,
    };

    const limit = dailyLimits[user.subscriptionTier];

    // Reset daily count if new day
    const today = new Date().setHours(0, 0, 0, 0);
    const lastAdDate = user.lastAdWatchTime ? new Date(user.lastAdWatchTime).setHours(0, 0, 0, 0) : 0;

    if (today > lastAdDate) {
      user.dailyAdsWatched = 0;
    }

    // Check if limit reached
    if (user.dailyAdsWatched >= limit) {
      return res.status(400).json({
        success: false,
        message: 'Daily ad watch limit reached',
      });
    }

    // Check cooldown (15 minutes after every 3 ads)
    if (user.adCooldownUntil && Date.now() < user.adCooldownUntil) {
      const remainingTime = Math.ceil((user.adCooldownUntil - Date.now()) / 60000);
      return res.status(400).json({
        success: false,
        message: `Please wait ${remainingTime} minutes before watching another ad`,
      });
    }

    // Award coins
    const adCoins = parseInt(process.env.AD_WATCH_COINS);
    await awardCoins(user._id, adCoins, 'ad_watch', 'Watched rewarded ad');

    // Update user
    user.dailyAdsWatched += 1;
    user.lastAdWatchTime = Date.now();

    // Set cooldown after every 3 ads
    if (user.dailyAdsWatched % 3 === 0) {
      user.adCooldownUntil = Date.now() + (15 * 60 * 1000); // 15 minutes
    }

    await user.save();

    res.status(200).json({
      success: true,
      coinsEarned: adCoins,
      dailyAdsWatched: user.dailyAdsWatched,
      dailyLimit: limit,
      cooldownUntil: user.adCooldownUntil,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Spin wheel
// @route   POST /api/coins/spin-wheel
// @access  Private
exports.spinWheel = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // Check if already spun today
    if (user.lastSpinDate) {
      const lastSpin = new Date(user.lastSpinDate).setHours(0, 0, 0, 0);
      const today = new Date().setHours(0, 0, 0, 0);

      if (lastSpin === today) {
        return res.status(400).json({
          success: false,
          message: 'You have already spun the wheel today',
        });
      }
    }

    // Random coins between 5 and 50
    const coinsWon = Math.floor(Math.random() * 46) + 5;

    await awardCoins(user._id, coinsWon, 'spin_wheel', 'Daily spin wheel reward');

    user.lastSpinDate = Date.now();
    await user.save();

    res.status(200).json({
      success: true,
      coinsWon,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get transaction history
// @route   GET /api/coins/transactions
// @access  Private
exports.getTransactions = async (req, res) => {
  try {
    const page = parseInt(req.query.page) || 1;
    const limit = parseInt(req.query.limit) || 20;
    const skip = (page - 1) * limit;

    const transactions = await Transaction.find({ user: req.user.id })
      .sort({ createdAt: -1 })
      .skip(skip)
      .limit(limit)
      .populate('relatedUser', 'username displayName');

    const total = await Transaction.countDocuments({ user: req.user.id });

    res.status(200).json({
      success: true,
      data: transactions,
      pagination: {
        page,
        limit,
        total,
        pages: Math.ceil(total / limit),
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Send gift coins
// @route   POST /api/coins/gift
// @access  Private
exports.sendGift = async (req, res) => {
  try {
    const { recipientId, amount, message } = req.body;

    if (amount <= 0) {
      return res.status(400).json({
        success: false,
        message: 'Invalid amount',
      });
    }

    const sender = await User.findById(req.user.id);
    const recipient = await User.findById(recipientId);

    if (!recipient) {
      return res.status(404).json({
        success: false,
        message: 'Recipient not found',
      });
    }

    if (sender.coinBalance < amount) {
      return res.status(400).json({
        success: false,
        message: 'Insufficient coin balance',
      });
    }

    // Deduct from sender
    sender.coinBalance -= amount;
    await sender.save();

    await Transaction.create({
      user: sender._id,
      type: 'gift_sent',
      amount: -amount,
      balanceAfter: sender.coinBalance,
      description: `Gift sent to ${recipient.username}`,
      relatedUser: recipient._id,
    });

    // Add to recipient
    recipient.coinBalance += amount;
    recipient.withdrawableBalance += amount;
    await recipient.save();

    await Transaction.create({
      user: recipient._id,
      type: 'gift_received',
      amount: amount,
      balanceAfter: recipient.coinBalance,
      description: `Gift received from ${sender.username}${message ? ': ' + message : ''}`,
      relatedUser: sender._id,
    });

    res.status(200).json({
      success: true,
      message: 'Gift sent successfully',
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Get coin balance
// @route   GET /api/coins/balance
// @access  Private
exports.getBalance = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    res.status(200).json({
      success: true,
      data: {
        coinBalance: user.coinBalance,
        withdrawableBalance: user.withdrawableBalance,
        totalCoinsEarned: user.totalCoinsEarned,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
