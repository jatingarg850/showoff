const mongoose = require('mongoose');

const postSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // Content
  type: {
    type: String,
    enum: ['image', 'video', 'reel'],
    required: true,
  },
  mediaUrl: {
    type: String,
    required: true,
  },
  thumbnailUrl: {
    type: String,
  },
  caption: {
    type: String,
    maxlength: 2000,
  },
  hashtags: [{
    type: String,
  }],
  
  // Engagement
  likesCount: {
    type: Number,
    default: 0,
  },
  commentsCount: {
    type: Number,
    default: 0,
  },
  sharesCount: {
    type: Number,
    default: 0,
  },
  viewsCount: {
    type: Number,
    default: 0,
  },
  
  // Monetization
  coinsEarned: {
    type: Number,
    default: 0,
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  isReported: {
    type: Boolean,
    default: false,
  },
  reportCount: {
    type: Number,
    default: 0,
  },
  
  // Visibility
  visibility: {
    type: String,
    enum: ['public', 'private', 'followers'],
    default: 'public',
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
postSchema.index({ user: 1, createdAt: -1 });
postSchema.index({ createdAt: -1 });
postSchema.index({ hashtags: 1 });

module.exports = mongoose.model('Post', postSchema);
