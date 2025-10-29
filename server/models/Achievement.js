const mongoose = require('mongoose');

const achievementSchema = new mongoose.Schema({
  // Achievement Details
  id: {
    type: String,
    required: true,
    unique: true,
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
  
  // Requirements
  requiredStreak: {
    type: Number,
    required: true,
  },
  category: {
    type: String,
    enum: ['selfie', 'post', 'social', 'special'],
    default: 'selfie',
  },
  
  // Rewards
  coinReward: {
    type: Number,
    default: 0,
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
achievementSchema.index({ category: 1, requiredStreak: 1 });
achievementSchema.index({ isActive: 1 });

module.exports = mongoose.model('Achievement', achievementSchema);