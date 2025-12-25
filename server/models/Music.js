const mongoose = require('mongoose');

const musicSchema = new mongoose.Schema({
  // Music Details
  title: {
    type: String,
    required: true,
    trim: true,
  },
  
  artist: {
    type: String,
    required: true,
    trim: true,
  },
  
  // File Information
  audioUrl: {
    type: String,
    required: true,
  },
  
  duration: {
    type: Number, // in seconds
    default: 0,
  },
  
  // Metadata
  genre: {
    type: String,
    default: 'other',
    trim: true,
  },
  
  mood: {
    type: String,
    enum: ['happy', 'sad', 'energetic', 'calm', 'romantic', 'other'],
    default: 'other',
  },
  
  // Thumbnail/Cover
  coverUrl: {
    type: String,
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  
  isApproved: {
    type: Boolean,
    default: false,
  },
  
  // Uploaded by
  uploadedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  
  // Usage tracking
  usageCount: {
    type: Number,
    default: 0,
  },
  
  likes: {
    type: Number,
    default: 0,
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
musicSchema.index({ isActive: 1, isApproved: 1 });
musicSchema.index({ genre: 1 });
musicSchema.index({ mood: 1 });
musicSchema.index({ createdAt: -1 });

module.exports = mongoose.model('Music', musicSchema);
