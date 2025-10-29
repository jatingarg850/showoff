const mongoose = require('mongoose');

const userAchievementSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  achievement: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Achievement',
    required: true,
  },
  
  // Achievement Details (denormalized for performance)
  achievementId: {
    type: String,
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  icon: {
    type: String,
    required: true,
  },
  
  // Unlock Details
  unlockedAt: {
    type: Date,
    default: Date.now,
  },
  streakAtUnlock: {
    type: Number,
    required: true,
  },
  
  // Rewards
  coinReward: {
    type: Number,
    default: 0,
  },
  rewardClaimed: {
    type: Boolean,
    default: false,
  },
  
}, {
  timestamps: true,
});

// Compound index to prevent duplicate achievements per user
userAchievementSchema.index({ user: 1, achievementId: 1 }, { unique: true });

// Index for faster queries
userAchievementSchema.index({ user: 1, unlockedAt: -1 });
userAchievementSchema.index({ achievementId: 1 });

module.exports = mongoose.model('UserAchievement', userAchievementSchema);