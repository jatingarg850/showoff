const mongoose = require('mongoose');

const settingsSchema = new mongoose.Schema({
  // Coin Rewards Configuration
  coins: {
    // Share Rewards
    shareRewardCoins: {
      type: Number,
      default: 5,
      min: 1,
      max: 1000,
      description: 'Coins awarded per share (post or SYT)',
    },
    maxSharesPerDay: {
      type: Number,
      default: 50,
      min: 1,
      max: 1000,
      description: 'Maximum shares per day to earn coins',
    },
    
    // Upload Rewards
    uploadRewardCoins: {
      type: Number,
      default: 5,
      min: 1,
      max: 1000,
      description: 'Coins awarded per upload',
    },
    maxUploadsPerDay: {
      type: Number,
      default: 10,
      min: 1,
      max: 100,
      description: 'Maximum uploads per day to earn coins',
    },
    
    // Ad Watch Rewards
    adWatchCoins: {
      type: Number,
      default: 10,
      min: 1,
      max: 1000,
      description: 'Coins awarded per ad watch',
    },
    
    // Referral Rewards
    referralCoinsFirstHundred: {
      type: Number,
      default: 5,
      min: 1,
      max: 1000,
      description: 'Coins for first 100 referrals',
    },
    referralCoinsAfter: {
      type: Number,
      default: 5,
      min: 1,
      max: 1000,
      description: 'Coins for referrals after 100',
    },
    
    // Withdrawal Settings
    minWithdrawalAmount: {
      type: Number,
      default: 100,
      min: 1,
      max: 100000,
      description: 'Minimum coins required for withdrawal',
    },
    coinToInrRate: {
      type: Number,
      default: 1,
      min: 0.01,
      max: 100,
      description: 'Conversion rate: 1 coin = X INR',
    },
    
    // Daily & Monthly Caps
    dailyCoinCap: {
      type: Number,
      default: 5000,
      min: 100,
      max: 1000000,
      description: 'Maximum coins per day from all sources',
    },
    monthlyCoinCap: {
      type: Number,
      default: 100000,
      min: 1000,
      max: 10000000,
      description: 'Maximum coins per month from all sources',
    },
  },

  // Platform Settings
  platform: {
    maintenanceMode: {
      type: Boolean,
      default: false,
    },
    registrationEnabled: {
      type: Boolean,
      default: true,
    },
    sharingEnabled: {
      type: Boolean,
      default: true,
    },
  },

  // Ad Settings
  ads: {
    enabled: {
      type: Boolean,
      default: true,
    },
    adFrequency: {
      type: Number,
      default: 6,
      min: 1,
      max: 50,
      description: 'Show ad after every N reels',
    },
    interstitialEnabled: {
      type: Boolean,
      default: true,
    },
    rewardedEnabled: {
      type: Boolean,
      default: true,
    },
    bannerEnabled: {
      type: Boolean,
      default: true,
    },
  },

  // Content Settings
  content: {
    maxFileSize: {
      type: Number,
      default: 100,
      description: 'Max file size in MB',
    },
    allowedImageTypes: {
      type: [String],
      default: ['jpg', 'jpeg', 'png', 'gif', 'webp'],
    },
    allowedVideoTypes: {
      type: [String],
      default: ['mp4', 'mov', 'avi', 'mkv'],
    },
    autoModeration: {
      type: Boolean,
      default: true,
    },
    requireApproval: {
      type: Boolean,
      default: false,
    },
  },

  // User Settings
  users: {
    emailVerificationRequired: {
      type: Boolean,
      default: false,
    },
    phoneVerificationRequired: {
      type: Boolean,
      default: false,
    },
    kycRequired: {
      type: Boolean,
      default: false,
    },
    defaultSubscription: {
      type: String,
      enum: ['free', 'basic', 'pro', 'vip'],
      default: 'free',
    },
  },

  // Last Updated
  lastUpdatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },

}, {
  timestamps: true,
});

// Ensure only one settings document exists
settingsSchema.statics.getSettings = async function() {
  let settings = await this.findOne();
  if (!settings) {
    settings = await this.create({});
  }
  return settings;
};

settingsSchema.statics.updateSettings = async function(updates, adminId) {
  let settings = await this.findOne();
  if (!settings) {
    settings = await this.create({});
  }
  
  // Deep merge updates
  Object.keys(updates).forEach(key => {
    if (typeof updates[key] === 'object' && !Array.isArray(updates[key])) {
      settings[key] = { ...settings[key], ...updates[key] };
    } else {
      settings[key] = updates[key];
    }
  });
  
  settings.lastUpdatedBy = adminId;
  await settings.save();
  return settings;
};

module.exports = mongoose.model('Settings', settingsSchema);
