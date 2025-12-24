const mongoose = require('mongoose');

const userEarningsSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true,
  },
  
  // Earnings Breakdown
  videoUploadEarnings: {
    type: Number,
    default: 0,
  },
  
  contentSharingEarnings: {
    type: Number,
    default: 0,
  },
  
  wheelSpinEarnings: {
    type: Number,
    default: 0,
  },
  
  rewardedAdEarnings: {
    type: Number,
    default: 0,
  },
  
  referralEarnings: {
    type: Number,
    default: 0,
  },
  
  otherEarnings: {
    type: Number,
    default: 0,
  },
  
  // Total
  totalEarnings: {
    type: Number,
    default: 0,
  },
  
  // Breakdown by date
  earningsByDate: [{
    date: Date,
    amount: Number,
    source: String, // 'video', 'share', 'wheel', 'ad', 'referral', 'other'
  }],
  
}, {
  timestamps: true,
});

// Index for faster queries
userEarningsSchema.index({ user: 1 });
userEarningsSchema.index({ totalEarnings: -1 });

module.exports = mongoose.model('UserEarnings', userEarningsSchema);
