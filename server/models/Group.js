const mongoose = require('mongoose');

const groupSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    trim: true,
  },
  description: {
    type: String,
    required: true,
  },
  category: {
    type: String,
    required: true,
    enum: ['Arts', 'Dance', 'Drama', 'Music', 'Sports', 'Technology', 'Fashion', 'Food', 'Travel', 'Other'],
  },
  coverImage: {
    type: String,
  },
  creator: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  members: [{
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  }],
  membersCount: {
    type: Number,
    default: 0,
  },
  isPublic: {
    type: Boolean,
    default: true,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Update members count before saving
groupSchema.pre('save', function(next) {
  this.membersCount = this.members.length;
  next();
});

module.exports = mongoose.model('Group', groupSchema);
