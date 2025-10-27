const User = require('../models/User');
const Transaction = require('../models/Transaction');

// @desc    Check if user can spin today
// @route   GET /api/spin-wheel/status
// @access  Private
exports.getSpinStatus = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastSpin = user.lastSpinDate ? new Date(user.lastSpinDate) : null;
    const canSpin = !lastSpin || lastSpin < today;

    res.status(200).json({
      success: true,
      data: {
        canSpin,
        lastSpinDate: user.lastSpinDate,
        spinsRemaining: canSpin ? 1 : 0,
      },
    });
  } catch (error) {
    console.error('Get spin status error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Spin the wheel and get reward
// @route   POST /api/spin-wheel/spin
// @access  Private
exports.spinWheel = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    if (!user) {
      return res.status(404).json({
        success: false,
        message: 'User not found',
      });
    }

    // Check if user can spin today
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const lastSpin = user.lastSpinDate ? new Date(user.lastSpinDate) : null;
    
    if (lastSpin && lastSpin >= today) {
      return res.status(400).json({
        success: false,
        message: 'You have already spun the wheel today. Come back tomorrow!',
      });
    }

    // Possible rewards (weighted)
    const rewards = [
      { coins: 5, weight: 30 },
      { coins: 10, weight: 25 },
      { coins: 20, weight: 20 },
      { coins: 50, weight: 15 },
      { coins: 100, weight: 8 },
      { coins: 200, weight: 2 },
    ];

    // Calculate total weight
    const totalWeight = rewards.reduce((sum, r) => sum + r.weight, 0);

    // Random selection based on weight
    let random = Math.random() * totalWeight;
    let selectedReward = rewards[0];

    for (const reward of rewards) {
      random -= reward.weight;
      if (random <= 0) {
        selectedReward = reward;
        break;
      }
    }

    const coinsWon = selectedReward.coins;

    // Update user coins and last spin date
    user.coinBalance += coinsWon;
    user.totalCoinsEarned += coinsWon;
    user.lastSpinDate = new Date();
    await user.save();

    // Create transaction record
    await Transaction.create({
      user: user._id,
      type: 'spin_wheel',
      amount: coinsWon,
      description: `Won ${coinsWon} coins from spin wheel`,
      balanceAfter: user.coinBalance,
    });

    res.status(200).json({
      success: true,
      data: {
        coinsWon,
        newBalance: user.coinBalance,
        nextSpinAvailable: new Date(today.getTime() + 24 * 60 * 60 * 1000),
      },
    });
  } catch (error) {
    console.error('Spin wheel error:', error);
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};
