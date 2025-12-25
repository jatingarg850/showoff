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
    enum: ['admob', 'meta', 'custom', 'third-party'],
    default: 'custom',
  },
  
  // Provider-specific API Keys and Configuration
  providerConfig: {
    type: mongoose.Schema.Types.Mixed,
    default: {},
  },
  
  // Ad Display Information
  title: {
    type: String,
    default: 'Rewarded Ad',
  },
  
  description: {
    type: String,
    default: 'Watch this ad to earn coins',
  },
  
  icon: {
    type: String,
    default: 'gift', // Font Awesome icon name
  },
  
  color: {
    type: String,
    default: '#667eea', // Hex color code
  },
  
  // Reward Configuration - NOW FLEXIBLE
  rewardCoins: {
    type: Number,
    default: 10,
    min: 1,
    max: 10000,
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

// Index for faster queries (adNumber already has unique index from field definition)
rewardedAdSchema.index({ isActive: 1 });

module.exports = mongoose.model('RewardedAd', rewardedAdSchema);
