const mongoose = require('mongoose');

const fraudLogSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Fraud Type
  fraudType: {
    type: String,
    enum: [
      'multiple_accounts',
      'vpn_detected',
      'suspicious_voting',
      'fake_engagement',
      'geo_hopping',
      'abnormal_referrals',
      'suspicious_payout',
      'bot_activity',
      'self_referral',
      'duplicate_device',
      'rapid_actions',
      'other'
    ],
    required: true
  },
  
  // Severity
  severity: {
    type: String,
    enum: ['low', 'medium', 'high', 'critical'],
    default: 'medium'
  },
  
  // Detection Details
  description: {
    type: String,
    required: true
  },
  evidence: {
    type: mongoose.Schema.Types.Mixed
  },
  
  // User Activity Context
  ipAddress: String,
  deviceId: String,
  userAgent: String,
  location: {
    country: String,
    region: String,
    city: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  
  // Action Taken
  actionTaken: {
    type: String,
    enum: ['none', 'warning', 'rate_limit', 'freeze_coins', 'shadow_ban', 'suspend', 'ban'],
    default: 'none'
  },
  actionDetails: String,
  
  // Review Status
  status: {
    type: String,
    enum: ['pending', 'reviewed', 'false_positive', 'confirmed'],
    default: 'pending'
  },
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  reviewedAt: Date,
  reviewNotes: String,
  
  // Risk Score
  riskScore: {
    type: Number,
    min: 0,
    max: 100,
    default: 0
  },
  
  // Auto-detected or Manual
  detectionMethod: {
    type: String,
    enum: ['automatic', 'manual', 'user_report'],
    default: 'automatic'
  },
  
}, {
  timestamps: true
});

// Indexes
fraudLogSchema.index({ user: 1, createdAt: -1 });
fraudLogSchema.index({ fraudType: 1 });
fraudLogSchema.index({ severity: 1 });
fraudLogSchema.index({ status: 1 });
fraudLogSchema.index({ riskScore: -1 });

module.exports = mongoose.model('FraudLog', fraudLogSchema);
