const mongoose = require('mongoose');

const dailySelfieSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // Content
  imageUrl: {
    type: String,
    required: true,
  },
  
  // Challenge Details
  challengeDate: {
    type: Date,
    required: true,
  },
  theme: {
    type: String,
    required: true,
  },
  
  // Voting
  votesCount: {
    type: Number,
    default: 0,
  },
  
  // Winner Status
  isWinner: {
    type: Boolean,
    default: false,
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
  
}, {
  timestamps: true,
});

// Index for faster queries
dailySelfieSchema.index({ challengeDate: 1, votesCount: -1 });
dailySelfieSchema.index({ user: 1, challengeDate: 1 }, { unique: true });

module.exports = mongoose.model('DailySelfie', dailySelfieSchema);
