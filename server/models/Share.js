const mongoose = require('mongoose');

const shareSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  post: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Post',
    required: true,
  },
  shareType: {
    type: String,
    enum: ['link', 'direct', 'story', 'message'],
    default: 'link',
  },
}, {
  timestamps: true,
});

// Index for faster queries
shareSchema.index({ user: 1, post: 1 });
shareSchema.index({ post: 1, createdAt: -1 });

module.exports = mongoose.model('Share', shareSchema);