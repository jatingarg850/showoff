const Achievement = require('../models/Achievement');
const UserAchievement = require('../models/UserAchievement');
const DailySelfie = require('../models/DailySelfie');
const { awardCoins } = require('../utils/coinSystem');

// @desc    Get all achievements with user progress
// @route   GET /api/achievements
// @access  Private
exports.getUserAchievements = async (req, res) => {
  try {
    // Get all achievements
    const allAchievements = await Achievement.find({ isActive: true })
      .sort({ requiredStreak: 1 });

    // Get user's unlocked achievements
    const userAchievements = await UserAchievement.find({ user: req.user.id })
      .populate('achievement');

    // Get user's current selfie streak
    const currentStreak = await getCurrentSelfieStreak(req.user.id);

    // Map achievements with unlock status
    const achievementsWithProgress = allAchievements.map(achievement => {
      const userAchievement = userAchievements.find(
        ua => ua.achievementId === achievement.id
      );

      return {
        _id: achievement._id,
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        requiredStreak: achievement.requiredStreak,
        coinReward: achievement.coinReward,
        category: achievement.category,
        isUnlocked: !!userAchievement,
        unlockedAt: userAchievement?.unlockedAt || null,
        progress: Math.min(currentStreak / achievement.requiredStreak, 1.0),
        currentStreak,
      };
    });

    // Find next achievement
    const nextAchievement = achievementsWithProgress.find(
      a => !a.isUnlocked && currentStreak < a.requiredStreak
    );

    res.json({
      success: true,
      data: {
        achievements: achievementsWithProgress,
        currentStreak,
        nextAchievement,
        unlockedCount: userAchievements.length,
        totalCount: allAchievements.length,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Check and unlock achievements for user
// @route   POST /api/achievements/check
// @access  Private
exports.checkAndUnlockAchievements = async (req, res) => {
  try {
    const userId = req.user.id;
    const currentStreak = await getCurrentSelfieStreak(userId);

    // Get all achievements that should be unlocked
    const eligibleAchievements = await Achievement.find({
      isActive: true,
      requiredStreak: { $lte: currentStreak },
    });

    // Get already unlocked achievements
    const unlockedAchievementIds = await UserAchievement.find({ user: userId })
      .distinct('achievementId');

    // Find new achievements to unlock
    const newAchievements = eligibleAchievements.filter(
      achievement => !unlockedAchievementIds.includes(achievement.id)
    );

    const unlockedAchievements = [];

    // Unlock new achievements
    for (const achievement of newAchievements) {
      const userAchievement = await UserAchievement.create({
        user: userId,
        achievement: achievement._id,
        achievementId: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        streakAtUnlock: currentStreak,
        coinReward: achievement.coinReward,
      });

      // Award coins if applicable
      if (achievement.coinReward > 0) {
        await awardCoins(
          userId,
          achievement.coinReward,
          'upload_reward',
          `Achievement unlocked: ${achievement.title}`,
          { relatedAchievement: achievement._id }
        );
      }

      unlockedAchievements.push({
        id: achievement.id,
        title: achievement.title,
        description: achievement.description,
        icon: achievement.icon,
        coinReward: achievement.coinReward,
      });
    }

    res.json({
      success: true,
      data: {
        newAchievements: unlockedAchievements,
        currentStreak,
      },
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// @desc    Initialize default achievements
// @route   POST /api/achievements/init
// @access  Private (Admin only)
exports.initializeAchievements = async (req, res) => {
  try {
    const defaultAchievements = [
      {
        id: 'first_selfie',
        title: 'First Steps',
        description: 'Take your first daily selfie',
        icon: '📸',
        requiredStreak: 1,
        coinReward: 10,
      },
      {
        id: 'week_warrior',
        title: 'Week Warrior',
        description: 'Maintain a 7-day selfie streak',
        icon: '🔥',
        requiredStreak: 7,
        coinReward: 50,
      },
      {
        id: 'month_master',
        title: 'Month Master',
        description: 'Complete 30 consecutive days',
        icon: '👑',
        requiredStreak: 30,
        coinReward: 200,
      },
      {
        id: 'century_club',
        title: 'Century Club',
        description: 'Reach 100 days streak',
        icon: '💎',
        requiredStreak: 100,
        coinReward: 1000,
      },
      {
        id: 'legend_status',
        title: 'Legend Status',
        description: 'Achieve 365 days streak',
        icon: '🏆',
        requiredStreak: 365,
        coinReward: 5000,
      },
    ];

    // Insert achievements if they don't exist
    for (const achievementData of defaultAchievements) {
      await Achievement.findOneAndUpdate(
        { id: achievementData.id },
        achievementData,
        { upsert: true, new: true }
      );
    }

    res.json({
      success: true,
      message: 'Default achievements initialized',
      data: defaultAchievements,
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: error.message,
    });
  }
};

// Helper function to get current selfie streak
async function getCurrentSelfieStreak(userId) {
  try {
    // Get all user's selfies sorted by date
    const selfies = await DailySelfie.find({ user: userId })
      .sort({ challengeDate: -1 });

    if (selfies.length === 0) return 0;

    let streak = 0;
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Check if user has a selfie today
    const todaySelfie = selfies.find(selfie => {
      const selfieDate = new Date(selfie.challengeDate);
      selfieDate.setHours(0, 0, 0, 0);
      return selfieDate.getTime() === today.getTime();
    });

    // Start from today or yesterday
    let checkDate = new Date(today);
    if (!todaySelfie) {
      checkDate.setDate(checkDate.getDate() - 1);
    }

    // Count consecutive days
    for (let i = 0; i < selfies.length; i++) {
      const selfieDate = new Date(selfies[i].challengeDate);
      selfieDate.setHours(0, 0, 0, 0);

      if (selfieDate.getTime() === checkDate.getTime()) {
        streak++;
        checkDate.setDate(checkDate.getDate() - 1);
      } else if (selfieDate.getTime() < checkDate.getTime()) {
        break;
      }
    }

    return streak;
  } catch (error) {
    console.error('Error calculating streak:', error);
    return 0;
  }
}

// Export the helper function for use in other controllers
exports.getCurrentSelfieStreak = getCurrentSelfieStreak;