const mongoose = require('mongoose');

const subscriptionPlanSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
    unique: true
  },
  tier: {
    type: String,
    enum: ['free', 'basic', 'pro', 'vip'],
    required: true,
    unique: true
  },
  
  // Pricing
  price: {
    monthly: {
      type: Number,
      required: true
    },
    yearly: {
      type: Number
    }
  },
  currency: {
    type: String,
    default: 'USD'
  },
  
  // Features
  features: {
    maxUploadsPerDay: {
      type: Number,
      default: 10
    },
    maxStorageGB: {
      type: Number,
      default: 5
    },
    canParticipateInSYT: {
      type: Boolean,
      default: true
    },
    prioritySupport: {
      type: Boolean,
      default: false
    },
    verifiedBadge: {
      type: Boolean,
      default: false
    },
    adFree: {
      type: Boolean,
      default: false
    },
    customProfile: {
      type: Boolean,
      default: false
    },
    analyticsAccess: {
      type: Boolean,
      default: false
    },
    coinBonus: {
      type: Number,
      default: 0
    },
    uploadRewardMultiplier: {
      type: Number,
      default: 1
    }
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
    default: 'USD'
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
