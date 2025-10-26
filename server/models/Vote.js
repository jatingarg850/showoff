const mongoose = require('mongoose');

const voteSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  sytEntry: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SYTEntry',
  },
  dailySelfie: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'DailySelfie',
  },
  
  // Vote Details
  voteDate: {
    type: Date,
    default: Date.now,
  },
  
}, {
  timestamps: true,
});

// Compound indexes - one vote per user per day per entry
voteSchema.index({ user: 1, sytEntry: 1, voteDate: 1 }, { unique: true, sparse: true });
voteSchema.index({ user: 1, dailySelfie: 1, voteDate: 1 }, { unique: true, sparse: true });

module.exports = mongoose.model('Vote', voteSchema);
