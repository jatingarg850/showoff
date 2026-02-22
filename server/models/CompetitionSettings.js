const mongoose = require('mongoose');

const competitionSettingsSchema = new mongoose.Schema({
  // Competition Type
  type: {
    type: String,
    enum: ['weekly', 'monthly', 'quarterly', 'custom'],
    required: true,
  },
  
  // Custom Date Range
  startDate: {
    type: Date,
    required: true,
  },
  endDate: {
    type: Date,
    required: true,
  },
  
  // Competition Details
  title: {
    type: String,
    required: true,
  },
  description: {
    type: String,
  },
  
  // Prize Configuration
  prizes: [{
    position: {
      type: Number, // 1, 2, 3
      required: true,
    },
    coins: {
      type: Number,
      required: true,
    },
    badge: {
      type: String,
    },
  }],
  
  // Status
  isActive: {
    type: Boolean,
    default: true,
  },
  
  // Auto-generated period identifier
  periodId: {
    type: String,
    required: true,
  },
  
}, {
  timestamps: true,
});

// Index for faster queries (removed unique constraint on type+isActive to allow multiple competitions)
competitionSettingsSchema.index({ type: 1, isActive: 1 });
competitionSettingsSchema.index({ startDate: 1, endDate: 1 });
competitionSettingsSchema.index({ periodId: 1 });
competitionSettingsSchema.index({ type: 1, startDate: 1, endDate: 1 });

// Method to check if competition is currently active
competitionSettingsSchema.methods.isCurrentlyActive = function() {
  const now = new Date();
  return this.isActive && now >= this.startDate && now <= this.endDate;
};

// Static method to get current active competition
competitionSettingsSchema.statics.getCurrentCompetition = async function(type) {
  const now = new Date();
  return await this.findOne({
    type,
    isActive: true,
    startDate: { $lte: now },
    endDate: { $gte: now },
  });
};

// Static method to get previous/last completed competition
competitionSettingsSchema.statics.getPreviousCompetition = async function(type) {
  const now = new Date();
  return await this.findOne({
    type,
    endDate: { $lt: now }, // Competition has ended
  }).sort({ endDate: -1 }); // Get the most recent one
};

module.exports = mongoose.model('CompetitionSettings', competitionSettingsSchema);
