const mongoose = require('mongoose');

const subscriptionPlanSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  tier: {
    type: String,
    enum: ['free', 'basic', 'premium', 'pro', 'vip'],
    required: true,
    unique: true
  },
  
  // Pricing - Support both formats for backward compatibility
  price: {
    type: Number,
    required: true
  },
  // Legacy pricing format (kept for backward compatibility)
  legacyPrice: {
    monthly: Number,
    yearly: Number
  },
  currency: {
    type: String,
    default: 'INR'
  },
  
  // Duration in days
  duration: {
    type: Number,
    default: 30
  },
  
  // Features - Array of strings for admin panel
  features: {
    type: [String],
    default: []
  },
  // Legacy features object (kept for backward compatibility)
  legacyFeatures: {
    maxUploadsPerDay: Number,
    maxStorageGB: Number,
    canParticipateInSYT: Boolean,
    prioritySupport: Boolean,
    verifiedBadge: Boolean,
    adFree: Boolean,
    customProfile: Boolean,
    analyticsAccess: Boolean,
    coinBonus: Number,
    uploadRewardMultiplier: Number
  },
  
  // Status
  isActive: {
    type: Boolean,
    default: true
  },
  
  // Display
  description: String,
  highlightedFeatures: [String],
  displayOrder: {
    type: Number,
    default: 0
  },
  
}, {
  timestamps: true
});

const userSubscriptionSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true
  },
  plan: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'SubscriptionPlan',
    required: true
  },
  
  // Subscription Details
  status: {
    type: String,
    enum: ['active', 'cancelled', 'expired', 'paused'],
    default: 'active'
  },
  billingCycle: {
    type: String,
    enum: ['monthly', 'yearly'],
    required: true
  },
  
  // Dates
  startDate: {
    type: Date,
    default: Date.now
  },
  endDate: {
    type: Date,
    required: true
  },
  nextBillingDate: Date,
  cancelledAt: Date,
  
  // Payment
  amountPaid: {
    type: Number,
    required: true
  },
  currency: {
    type: String,
    default: 'INR'
  },
  paymentMethod: {
    type: String,
    enum: ['razorpay', 'stripe', 'coins', 'other']
  },
  transactionId: String,
  
  // Auto-renewal
  autoRenew: {
    type: Boolean,
    default: true
  },
  
}, {
  timestamps: true
});

// Indexes
subscriptionPlanSchema.index({ tier: 1 });
subscriptionPlanSchema.index({ isActive: 1 });

userSubscriptionSchema.index({ user: 1, status: 1 });
userSubscriptionSchema.index({ endDate: 1 });
userSubscriptionSchema.index({ status: 1 });

const SubscriptionPlan = mongoose.model('SubscriptionPlan', subscriptionPlanSchema);
const UserSubscription = mongoose.model('UserSubscription', userSubscriptionSchema);

module.exports = { SubscriptionPlan, UserSubscription };
