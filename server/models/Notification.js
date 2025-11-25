const mongoose = require('mongoose');

const notificationSchema = new mongoose.Schema({
  recipient: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  sender: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: false, // Not required for system/admin notifications
  },
  type: {
    type: String,
    enum: [
      'like',
      'comment',
      'follow',
      'mention',
      'share',
      'achievement',
      'gift',
      'vote',
      'post_upload',
      'system',
      'admin_announcement',
      'message',
    ],
    required: true,
  },
  title: {
    type: String,
    required: true,
  },
  message: {
    type: String,
    required: true,
  },
  data: {
    postId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Post',
    },
    commentId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Comment',
    },
    sytEntryId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'SYTEntry',
    },
    amount: Number,
    metadata: mongoose.Schema.Types.Mixed,
  },
  isRead: {
    type: Boolean,
    default: false,
  },
  readAt: {
    type: Date,
  },
  priority: {
    type: String,
    enum: ['low', 'normal', 'high', 'urgent'],
    default: 'normal',
  },
  expiresAt: {
    type: Date,
  },
}, {
  timestamps: true,
});

// Indexes for better performance
notificationSchema.index({ recipient: 1, createdAt: -1 });
notificationSchema.index({ recipient: 1, isRead: 1 });
notificationSchema.index({ expiresAt: 1 }, { expireAfterSeconds: 0 });

// Virtual for time ago
notificationSchema.virtual('timeAgo').get(function() {
  const now = new Date();
  const diff = now - this.createdAt;
  const minutes = Math.floor(diff / 60000);
  const hours = Math.floor(diff / 3600000);
  const days = Math.floor(diff / 86400000);

  if (minutes < 1) return 'Just now';
  if (minutes < 60) return `${minutes} minute${minutes > 1 ? 's' : ''} ago`;
  if (hours < 24) return `${hours} hour${hours > 1 ? 's' : ''} ago`;
  if (days < 7) return `${days} day${days > 1 ? 's' : ''} ago`;
  return this.createdAt.toLocaleDateString();
});

// Mark as read
notificationSchema.methods.markAsRead = function() {
  this.isRead = true;
  this.readAt = new Date();
  return this.save();
};

module.exports = mongoose.model('Notification', notificationSchema);