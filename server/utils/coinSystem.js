const User = require('../models/User');
const Transaction = require('../models/Transaction');

// Award coins to user
exports.awardCoins = async (userId, amount, type, description, relatedData = {}) => {
  try {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    user.coinBalance += amount;
    user.totalCoinsEarned += amount;
    await user.save();

    // Create transaction record
    const transaction = await Transaction.create({
      user: userId,
      type,
      amount,
      balanceAfter: user.coinBalance,
      description,
      ...relatedData,
    });

    return { user, transaction };
  } catch (error) {
    throw error;
  }
};

// Deduct coins from user
exports.deductCoins = async (userId, amount, type, description, relatedData = {}) => {
  try {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    if (user.coinBalance < amount) {
      throw new Error('Insufficient coin balance');
    }

    user.coinBalance -= amount;
    await user.save();

    // Create transaction record
    const transaction = await Transaction.create({
      user: userId,
      type,
      amount: -amount,
      balanceAfter: user.coinBalance,
      description,
      ...relatedData,
    });

    return { user, transaction };
  } catch (error) {
    throw error;
  }
};

// Check and award upload rewards
exports.checkUploadReward = async (userId) => {
  try {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    // Check if upload rewards are still enabled
    if (!user.uploadRewardsEnabled) {
      return { awarded: false, reason: 'Upload rewards disabled' };
    }

    // Check if user has reached 5000 total coins from uploads/views
    if (user.totalCoinsEarned >= 5000) {
      user.uploadRewardsEnabled = false;
      await user.save();
      return { awarded: false, reason: 'Upload rewards limit reached' };
    }

    // Check if user has uploaded max posts
    if (user.uploadCount >= parseInt(process.env.MAX_UPLOAD_POSTS)) {
      return { awarded: false, reason: 'Max upload limit reached' };
    }

    // Award upload coins
    const uploadCoins = parseInt(process.env.UPLOAD_REWARD_COINS);
    user.uploadCount += 1;
    user.uploadRewardsEarned += uploadCoins;

    // Check for bonus (10 uploads within 7 days of signup)
    const daysSinceSignup = (Date.now() - user.signupDate) / (1000 * 60 * 60 * 24);
    let bonusCoins = 0;

    if (user.uploadCount === parseInt(process.env.MAX_UPLOAD_POSTS) && daysSinceSignup <= 7) {
      bonusCoins = parseInt(process.env.UPLOAD_BONUS_COINS);
    }

    const totalCoins = uploadCoins + bonusCoins;
    user.coinBalance += totalCoins;
    user.totalCoinsEarned += totalCoins;
    await user.save();

    // Create transaction
    await Transaction.create({
      user: userId,
      type: 'upload_reward',
      amount: totalCoins,
      balanceAfter: user.coinBalance,
      description: bonusCoins > 0
        ? `Upload reward (${uploadCoins} coins) + Bonus (${bonusCoins} coins)`
        : `Upload reward`,
    });

    return {
      awarded: true,
      coins: totalCoins,
      uploadCount: user.uploadCount,
      bonusAwarded: bonusCoins > 0,
    };
  } catch (error) {
    throw error;
  }
};

// Award view-based earnings
exports.awardViewCoins = async (userId, views) => {
  try {
    const user = await User.findById(userId);
    if (!user) throw new Error('User not found');

    // Calculate coins (10 coins per 1000 views)
    const coinsPerThousand = parseInt(process.env.VIEW_REWARD_PER_1000);
    const coinsToAward = Math.floor(views / 1000) * coinsPerThousand;

    if (coinsToAward === 0) return { awarded: false };

    // Check daily cap
    const today = new Date().setHours(0, 0, 0, 0);
    const lastReset = new Date(user.lastViewCoinReset).setHours(0, 0, 0, 0);

    if (today > lastReset) {
      user.dailyViewCoins = 0;
      user.lastViewCoinReset = Date.now();
    }

    const dailyCap = parseInt(process.env.DAILY_COIN_CAP);
    if (user.dailyViewCoins >= dailyCap) {
      return { awarded: false, reason: 'Daily cap reached' };
    }

    // Check monthly cap
    const monthlyCap = parseInt(process.env.MONTHLY_COIN_CAP);
    if (user.monthlyViewCoins >= monthlyCap) {
      return { awarded: false, reason: 'Monthly cap reached' };
    }

    // Award coins within limits
    let finalCoins = Math.min(coinsToAward, dailyCap - user.dailyViewCoins);
    finalCoins = Math.min(finalCoins, monthlyCap - user.monthlyViewCoins);

    user.coinBalance += finalCoins;
    user.totalCoinsEarned += finalCoins;
    user.dailyViewCoins += finalCoins;
    user.monthlyViewCoins += finalCoins;
    await user.save();

    await Transaction.create({
      user: userId,
      type: 'view_reward',
      amount: finalCoins,
      balanceAfter: user.coinBalance,
      description: `View-based earnings (${views} views)`,
    });

    return { awarded: true, coins: finalCoins };
  } catch (error) {
    throw error;
  }
};

// Generate unique referral code
exports.generateReferralCode = (username) => {
  const random = Math.random().toString(36).substring(2, 8).toUpperCase();
  return `${username.substring(0, 4).toUpperCase()}${random}`;
};
