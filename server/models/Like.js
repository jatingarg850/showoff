const mongoose = require('mongoose');

const likeSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  post: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Post',
  },
  comment: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Comment',
  },
  sytEntry: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SYTEntry',
  },
}, {
  timestamps: true,
});

// Compound indexes to prevent duplicate likes
// Use partialFilterExpression to only index when the field exists (not null)
likeSchema.index(
  { user: 1, post: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { post: { $exists: true, $ne: null } }
  }
);
likeSchema.index(
  { user: 1, comment: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { comment: { $exists: true, $ne: null } }
  }
);
likeSchema.index(
  { user: 1, sytEntry: 1 }, 
  { 
    unique: true, 
    partialFilterExpression: { sytEntry: { $exists: true, $ne: null } }
  }
);

module.exports = mongoose.model('Like', likeSchema);
