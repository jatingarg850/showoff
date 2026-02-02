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
  },
  sytEntry: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SYTEntry',
  },
  shareType: {
    type: String,
    enum: ['link', 'direct', 'story', 'message'],
    default: 'link',
  },
}, {
  timestamps: true,
});

// Validation: Either post or sytEntry must be provided
shareSchema.pre('save', function(next) {
  if (!this.post && !this.sytEntry) {
    next(new Error('Either post or sytEntry must be provided'));
  } else if (this.post && this.sytEntry) {
    next(new Error('Cannot share both post and sytEntry at the same time'));
  } else {
    next();
  }
});

// Index for faster queries
shareSchema.index({ user: 1, post: 1 });
shareSchema.index({ user: 1, sytEntry: 1 });
shareSchema.index({ post: 1, createdAt: -1 });
shareSchema.index({ sytEntry: 1, createdAt: -1 });

module.exports = mongoose.model('Share', shareSchema);