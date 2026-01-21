const mongoose = require('mongoose');

const videoAdSchema = new mongoose.Schema({
  // Ad Details
  title: {
    type: String,
    required: true,
  },
  
  description: {
    type: String,
    default: 'Watch this video to earn coins',
  },
  
  // Video Content
  videoUrl: {
    type: String,
    required: true,
  },
  
  thumbnailUrl: {
    type: String,
  },
  
  duration: {
    type: Number, // in seconds
    default: 30,
  },
  
  // Reward Configuration
  rewardCoins: {
    type: Number,
    default: 10,
    min: 1,
    max: 10000,
  },
  
  // Usage Type - Determines where video ad is used
  usage: {
    type: String,
    enum: ['watch-ads', 'spin-wheel'],
    default: 'watch-ads',
  },
  
  // Display Configuration
  icon: {
    type: String,
    default: 'video',
  },
  
  color: {
    type: String,
    default: '#667eea',
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
  
  views: {
    type: Number,
    default: 0,
  },
  
  completions: {
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
  
  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    default: null,
  },
  
  fileSize: {
    type: Number, // in bytes
  },
  
  mimeType: {
    type: String,
    default: 'video/mp4',
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
videoAdSchema.index({ isActive: 1 });
videoAdSchema.index({ createdAt: -1 });
videoAdSchema.index({ rotationOrder: 1 });
videoAdSchema.index({ usage: 1 });
videoAdSchema.index({ usage: 1, isActive: 1 });

module.exports = mongoose.model('VideoAd', videoAdSchema);
