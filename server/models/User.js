const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  // Authentication
  email: {
    type: String,
    sparse: true,
    lowercase: true,
    trim: true,
    unique: true,
  },
  phone: {
    type: String,
    sparse: true,
    trim: true,
    unique: true,
  },
  countryCode: {
    type: String,
    sparse: true,
    trim: true,
  },
  password: {
    type: String,
    minlength: 6,
    select: false,
  },
  googleId: {
    type: String,
    sparse: true,
    unique: true,
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
  profileCompletionBonusAwarded: {
    type: Boolean,
    default: false,
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
    sparse: true,
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
  
  // Share Rewards
  dailySharesCount: {
    type: Number,
    default: 0,
  },
  lastShareDate: {
    type: Date,
  },
  
  // Upload Rewards
  dailyUploadsCount: {
    type: Number,
    default: 0,
  },
  lastUploadDate: {
    type: Date,
  },
  
  // Spin Wheel
  lastSpinDate: {
    type: Date,
  },
  bonusSpins: {
    type: Number,
    default: 0,
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
    submittedAt: Date,
    verifiedAt: Date,
  },
  
  // Withdrawal Tracking
  hasCompletedFirstWithdrawal: {
    type: Boolean,
    default: false,
  },
  lastWithdrawalMonth: {
    type: String, // Format: "YYYY-MM"
    default: null,
  },
  totalWithdrawals: {
    type: Number,
    default: 0,
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
    email: { type: Boolean, default: false },
    sms: { type: Boolean, default: false },
    referral: { type: Boolean, default: true },
    transaction: { type: Boolean, default: true },
    community: { type: Boolean, default: false },
    marketing: { type: Boolean, default: false },
  },
  privacySettings: {
    profileVisibility: { type: String, enum: ['public', 'private'], default: 'public' },
    showEmail: { type: Boolean, default: false },
    showPhone: { type: Boolean, default: false },
  },
  
  // Privacy & Security (New fields for Privacy and Safety screen)
  profileVisibility: {
    type: Boolean,
    default: true,
  },
  dataSharing: {
    type: Boolean,
    default: false,
  },
  locationTracking: {
    type: Boolean,
    default: false,
  },
  twoFactorAuth: {
    type: Boolean,
    default: false,
  },
  
  // Location
  country: String,
  currency: {
    type: String,
    default: 'INR',
  },
  
  // Billing Information
  billingInfo: {
    fullName: String,
    email: String,
    phone: String,
    address: String,
    city: String,
    state: String,
    zipCode: String,
    country: String,
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
  accountStatus: {
    type: String,
    enum: ['active', 'suspended', 'banned'],
    default: 'active'
  },
  
  // Fraud Detection
  riskScore: {
    type: Number,
    default: 0,
    min: 0,
    max: 100
  },
  coinsFrozen: {
    type: Boolean,
    default: false
  },
  freezeReason: String,
  
  // Admin tracking
  statusUpdatedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  statusUpdatedAt: Date,
  statusReason: String,
  
  // Firebase Cloud Messaging
  fcmToken: {
    type: String,
    default: null,
  },
  
  // Terms & Conditions
  termsAndConditionsAccepted: {
    type: Boolean,
    default: false,
  },
  termsAndConditionsVersion: {
    type: Number,
    default: 1,
  },
  termsAndConditionsAcceptedAt: {
    type: Date,
  },
  
}, {
  timestamps: true,
});

// Hash password before saving
userSchema.pre('save', async function(next) {
  // Skip if password is not modified or not set (Google OAuth users)
  if (!this.isModified('password') || !this.password) {
    return next();
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
