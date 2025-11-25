const mongoose = require('mongoose');

const withdrawalSettingsSchema = new mongoose.Schema({
  minWithdrawalAmount: {
    type: Number,
    default: 100,
    required: true,
    min: 1,
  },
  withdrawalDay: {
    type: Number,
    default: 10,
    required: true,
    min: 1,
    max: 31,
  },
  coinToInrRate: {
    type: Number,
    default: 1,
    required: true,
  },
  withdrawalFeePercent: {
    type: Number,
    default: 20,
    min: 0,
    max: 100,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  processingTimeHours: {
    type: Number,
    default: 24,
  },
  supportedMethods: [{
    type: String,
    enum: ['bank_transfer', 'sofft_address', 'upi', 'paypal'],
  }],
  description: String,
}, {
  timestamps: true,
});

// Static method to get active settings
withdrawalSettingsSchema.statics.getActiveSettings = async function() {
  let settings = await this.findOne({ isActive: true });
  
  // Create default settings if none exist
  if (!settings) {
    settings = await this.create({
      minWithdrawalAmount: 100,
      withdrawalDay: 10,
      coinToInrRate: 1,
      withdrawalFeePercent: 20,
      isActive: true,
      supportedMethods: ['sofft_address', 'upi'],
    });
  }
  
  return settings;
};

module.exports = mongoose.model('WithdrawalSettings', withdrawalSettingsSchema);
