const mongoose = require('mongoose');

const sytEntrySchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // Content
  videoUrl: {
    type: String,
    required: true,
  },
  thumbnailUrl: {
    type: String,
  },
  title: {
    type: String,
    required: true,
    maxlength: 200,
  },
  description: {
    type: String,
    maxlength: 1000,
  },
  category: {
    type: String,
    enum: ['singing', 'dancing', 'comedy', 'acting', 'music', 'art', 'other'],
    required: true,
  },
  
  // Music
  backgroundMusic: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Music',
  },
  
  // Competition Details
  competitionType: {
    type: String,
    enum: ['weekly', 'monthly', 'quarterly'],
    required: true,
  },
  competitionPeriod: {
    type: String, // e.g., "2024-W01", "2024-01", "2024-Q1"
    required: true,
  },
  
  // Voting & Engagement
  votesCount: {
    type: Number,
    default: 0,
  },
  viewsCount: {
    type: Number,
    default: 0,
  },
  likesCount: {
    type: Number,
    default: 0,
  },
  commentsCount: {
    type: Number,
    default: 0,
  },
  
  // Coins from Votes
  coinsEarned: {
    type: Number,
    default: 0,
  },
  
  // Winner Status
  isWinner: {
    type: Boolean,
    default: false,
  },
  winnerPosition: {
    type: Number, // 1, 2, 3
  },
  prizeCoins: {
    type: Number,
    default: 0,
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  isApproved: {
    type: Boolean,
    default: true,
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
sytEntrySchema.index({ user: 1, competitionPeriod: 1 });
sytEntrySchema.index({ competitionPeriod: 1, votesCount: -1 });
sytEntrySchema.index({ competitionType: 1, competitionPeriod: 1 });

module.exports = mongoose.model('SYTEntry', sytEntrySchema);
