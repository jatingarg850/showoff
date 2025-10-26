const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Authentication
  email: {
    type: String,
    sparse: true,
    lowercase: true,
    trim: true,
  },
  phone: {
    type: String,
    sparse: true,
    trim: true,
  },
  password: {
    type: String,
    required: true,
    minlength: 6,
    select: false,
  },
  
  // Profile Information
  username: {
    type: String,
    required: true,
    unique: true,
    trim: true,
    lowercase: true,
  },
  displayName: {
    type: String,
    required: true,
    trim: true,
  },
  bio: {
    type: String,
    default: '',
    maxlength: 500,
  },
  profilePicture: {
    type: String,
    default: '',
  },
  interests: [{
    type: String,
  }],
  
  // Profile Completion
  profileCompletionPercentage: {
    type: Number,
    default: 0,
  },
  isProfileComplete: {
    type: Boolean,
    default: false,
  },
  
  // Verification & Status
  isVerified: {
    type: Boolean,
    default: false,
  },
  isEmailVerified: {
    type: Boolean,
    default: false,
  },
  isPhoneVerified: {
    type: Boolean,
    default: false,
  },
  
  // Subscription
  subscriptionTier: {
    type: String,
    enum: ['free', 'basic', 'pro', 'vip'],
    default: 'free',
  },
  subscriptionExpiry: {
    type: Date,
  },
  
  // Coins & Monetization
  coinBalance: {
    type: Number,
    default: 0,
  },
  totalCoinsEarned: {
    type: Number,
    default: 0,
  },
  withdrawableBalance: {
    type: Number,
    default: 0,
  },
  
  // Upload Rewards Tracking
  uploadRewardsEnabled: {
    type: Boolean,
    default: true,
  },
  uploadCount: {
    type: Number,
    default: 0,
  },
  uploadRewardsEarned: {
    type: Number,
    default: 0,
  },
  
  // View-Based Earnings
  totalViews: {
    type: Number,
    default: 0,
  },
  dailyViewCoins: {
    type: Number,
    default: 0,
  },
  monthlyViewCoins: {
    type: Number,
    default: 0,
  },
  lastViewCoinReset: {
    type: Date,
    default: Date.now,
  },
  
  // Referral System
  referralCode: {
    type: String,
    unique: true,
  },
  referredBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  referralCount: {
    type: Number,
    default: 0,
  },
  referralCoinsEarned: {
    type: Number,
    default: 0,
  },
  
  // Ad Watching
  dailyAdsWatched: {
    type: Number,
    default: 0,
  },
  lastAdWatchTime: {
    type: Date,
  },
  adCooldownUntil: {
    type: Date,
  },
  
  // Spin Wheel
  lastSpinDate: {
    type: Date,
  },
  
  // Social Stats
  followersCount: {
    type: Number,
    default: 0,
  },
  followingCount: {
    type: Number,
    default: 0,
  },
  postsCount: {
    type: Number,
    default: 0,
  },
  likesCount: {
    type: Number,
    default: 0,
  },
  
  // KYC
  kycStatus: {
    type: String,
    enum: ['pending', 'submitted', 'verified', 'rejected'],
    default: 'pending',
  },
  kycDetails: {
    fullName: String,
    dateOfBirth: Date,
    address: String,
    documentType: String,
    documentNumber: String,
    documentImages: [String],
  },
  
  // Badges & Achievements
  badges: [{
    name: String,
    icon: String,
    earnedAt: Date,
  }],
  
  // Settings
  notificationSettings: {
    push: { type: Boolean, default: true },
    email: { type: Boolean, default: true },
    sms: { type: Boolean, default: false },
  },
  privacySettings: {
    profileVisibility: { type: String, enum: ['public', 'private'], default: 'public' },
    showEmail: { type: Boolean, default: false },
    showPhone: { type: Boolean, default: false },
  },
  
  // Location
  country: String,
  currency: {
    type: String,
    default: 'USD',
  },
  
  // Timestamps
  lastLogin: {
    type: Date,
  },
  signupDate: {
    type: Date,
    default: Date.now,
  },
  
  // Account Status
  isActive: {
    type: Boolean,
    default: true,
  },
  isBanned: {
    type: Boolean,
    default: false,
  },
  banReason: String,
  
}, {
  timestamps: true,
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) {
    next();
  }
  const salt = await bcrypt.genSalt(10);
  this.password = await bcrypt.hash(this.password, salt);
});

// Compare password
userSchema.methods.comparePassword = async function(enteredPassword) {
  return await bcrypt.compare(enteredPassword, this.password);
};

// Calculate profile completion
userSchema.methods.calculateProfileCompletion = function() {
  let completion = 0;
  if (this.profilePicture) completion += 25;
  if (this.displayName) completion += 25;
  if (this.bio) completion += 25;
  if (this.interests && this.interests.length > 0) completion += 25;
  
  this.profileCompletionPercentage = completion;
  this.isProfileComplete = completion === 100;
  return completion;
};

module.exports = mongoose.model('User', userSchema);
