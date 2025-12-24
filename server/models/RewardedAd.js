const mongoose = require('mongoose');

const rewardedAdSchema = new mongoose.Schema({
  // Ad Details
  adNumber: {
    type: Number,
    enum: [1, 2, 3, 4, 5],
    required: true,
    unique: true,
  },
  
  // Ad Configuration
  adLink: {
    type: String,
    required: true,
  },
  
  adProvider: {
    type: String,
    enum: ['admob', 'custom', 'third-party'],
    default: 'custom',
  },
  
  // Reward Configuration
  rewardCoins: {
    type: Number,
    default: 10,
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  
  // Tracking
  impressions: {
    type: Number,
    default: 0,
  },
  
  clicks: {
    type: Number,
    default: 0,
  },
  
  conversions: {
    type: Number,
    default: 0,
  },
  
  // Rotation
  rotationOrder: {
    type: Number,
    default: 0,
  },
  
  lastServedAt: {
    type: Date,
  },
  
  servedCount: {
    type: Number,
    default: 0,
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
rewardedAdSchema.index({ adNumber: 1 });
rewardedAdSchema.index({ isActive: 1 });

module.exports = mongoose.model('RewardedAd', rewardedAdSchema);
