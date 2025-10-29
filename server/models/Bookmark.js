const mongoose = require('mongoose');

const bookmarkSchema = new mongoose.Schema({
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
}, {
  timestamps: true,
});

// Ensure one bookmark per user per post
bookmarkSchema.index(
  { user: 1, post: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { post: { $exists: true, $ne: null } }
  }
);

// Ensure one bookmark per user per SYT entry
bookmarkSchema.index(
  { user: 1, sytEntry: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { sytEntry: { $exists: true, $ne: null } }
  }
);

module.exports = mongoose.model('Bookmark', bookmarkSchema);