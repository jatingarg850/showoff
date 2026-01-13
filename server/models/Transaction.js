const mongoose = require('mongoose');

const transactionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // Transaction Details
  type: {
    type: String,
    enum: [
      'upload_reward',
      'view_reward',
      'ad_watch',
      'referral',
      'referral_bonus',
      'spin_wheel',
      'vote_cast',      // Deducted when user votes on SYT entry
      'vote_received',  // Awarded when user receives a vote
      'gift_received',
      'gift_sent',
      'competition_prize',
      'withdrawal',
      'purchase',
      'subscription',
      'profile_completion',
      'add_money',  // Added for Razorpay add money functionality
      'welcome_bonus'  // Welcome bonus for new users
    ],
    required: true,
  },
  
  amount: {
    type: Number,
    required: true,
  },
  
  // Balance After Transaction
  balanceAfter: {
    type: Number,
    required: true,
  },
  
  // Description
  description: {
    type: String,
    required: true,
  },
  
  // Related References
  relatedPost: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Post',
  },
  relatedUser: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  relatedSYTEntry: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SYTEntry',
  },
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'completed', 'failed', 'cancelled'],
    default: 'completed',
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
transactionSchema.index({ user: 1, createdAt: -1 });
transactionSchema.index({ type: 1 });

module.exports = mongoose.model('Transaction', transactionSchema);
