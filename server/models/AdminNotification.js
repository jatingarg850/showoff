const mongoose = require('mongoose');

const adminNotificationSchema = new mongoose.Schema({
  // Notification Content
  title: {
    type: String,
    required: true,
    maxlength: 100,
  },
  message: {
    type: String,
    required: true,
    maxlength: 500,
  },
  imageUrl: {
    type: String,
  },
  
  // Targeting
  targetType: {
    type: String,
    enum: ['all', 'selected', 'verified', 'active', 'new'],
    required: true,
    default: 'all',
  },
  targetUsers: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  
  // Action (optional)
  actionType: {
    type: String,
    enum: ['none', 'open_url', 'open_screen', 'open_post'],
  },
  actionData: {
    type: String, // URL, screen name, or post ID
  },
  
  // Scheduling
  scheduledFor: {
    type: Date,
  },
  sentAt: {
    type: Date,
  },
  
  // Status
  status: {
    type: String,
    enum: ['draft', 'scheduled', 'sent', 'failed'],
    default: 'draft',
  },
  
  // Statistics
  totalRecipients: {
    type: Number,
    default: 0,
  },
  deliveredCount: {
    type: Number,
    default: 0,
  },
  readCount: {
    type: Number,
    default: 0,
  },
  clickCount: {
    type: Number,
    default: 0,
  },
  
  // Admin Info
  createdBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  
}, {
  timestamps: true,
});

// Index for faster queries
adminNotificationSchema.index({ status: 1, scheduledFor: 1 });
adminNotificationSchema.index({ createdAt: -1 });

module.exports = mongoose.model('AdminNotification', adminNotificationSchema);
