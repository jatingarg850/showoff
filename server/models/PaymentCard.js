const mongoose = require('mongoose');

const paymentCardSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  cardType: {
    type: String,
    enum: ['visa', 'mastercard', 'amex', 'discover'],
    required: true,
  },
  lastFourDigits: {
    type: String,
    required: true,
    length: 4,
  },
  expiryMonth: {
    type: String,
    required: true,
    length: 2,
  },
  expiryYear: {
    type: String,
    required: true,
    length: 4,
  },
  cardholderName: {
    type: String,
    required: true,
  },
  isDefault: {
    type: Boolean,
    default: false,
  },
  // For security, we don't store the full card number or CVV
  // In production, you'd use a payment processor's tokenization
  razorpayCustomerId: String,
  razorpayTokenId: String,
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

// Ensure only one default card per user
paymentCardSchema.pre('save', async function(next) {
  if (this.isDefault) {
    await this.constructor.updateMany(
      { user: this.user, _id: { $ne: this._id } },
      { isDefault: false }
    );
  }
  next();
});

module.exports = mongoose.model('PaymentCard', paymentCardSchema);