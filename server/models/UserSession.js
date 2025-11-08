const mongoose = require('mongoose');

const userSessionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  
  // Device Information
  deviceId: {
    type: String,
    required: true
  },
  deviceName: String,
  deviceType: {
    type: String,
    enum: ['mobile', 'tablet', 'desktop', 'unknown']
  },
  os: String,
  osVersion: String,
  appVersion: String,
  
  // Network Information
  ipAddress: {
    type: String,
    required: true
  },
  ipType: {
    type: String,
    enum: ['residential', 'datacenter', 'vpn', 'proxy', 'tor', 'unknown'],
    default: 'unknown'
  },
  isp: String,
  asn: String,
  
  // Location
  location: {
    country: String,
    countryCode: String,
    region: String,
    city: String,
    timezone: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  
  // Session Details
  userAgent: String,
  sessionToken: String,
  fcmToken: String, // For push notifications
  
  // Activity
  lastActivity: {
    type: Date,
    default: Date.now
  },
  loginAt: {
    type: Date,
    default: Date.now
  },
  logoutAt: Date,
  
  // Status
  isActive: {
    type: Boolean,
    default: true
  },
  
  // Fraud Indicators
  isSuspicious: {
    type: Boolean,
    default: false
  },
  suspiciousReasons: [String],
  riskScore: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  
}, {
  timestamps: true
});

// Indexes
userSessionSchema.index({ user: 1, isActive: 1 });
userSessionSchema.index({ deviceId: 1 });
userSessionSchema.index({ ipAddress: 1 });
userSessionSchema.index({ lastActivity: -1 });
userSessionSchema.index({ isSuspicious: 1 });

// Compound index for fraud detection
userSessionSchema.index({ user: 1, deviceId: 1, ipAddress: 1 });

module.exports = mongoose.model('UserSession', userSessionSchema);
