const mongoose = require('mongoose');

const withdrawalSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
  },
  
  // Amount
  coinAmount: {
    type: Number,
    required: true,
  },
  usdAmount: {
    type: Number,
    required: true,
  },
  localAmount: {
    type: Number,
    required: true,
  },
  currency: {
    type: String,
    required: true,
  },
  
  // Payment Method
  method: {
    type: String,
    enum: ['bank_transfer', 'sofft_address', 'upi', 'paypal'],
    required: true,
  },
  
  // Bank Details (if bank_transfer)
  bankDetails: {
    accountName: String,
    accountNumber: String,
    bankName: String,
    ifscCode: String,
    swiftCode: String,
  },
  
  // Wallet Address (if sofft_address)
  sofftAddress: String,
  
  // UPI Details (if upi)
  upiId: String,
  
  // ID Documents (uploaded to Wasabi)
  idDocuments: [{
    url: String,
    type: String, // 'passport', 'driving_license', 'national_id', etc.
    uploadedAt: {
      type: Date,
      default: Date.now,
    },
  }],
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'processing', 'completed', 'rejected'],
    default: 'pending',
  },
  
  // Admin Notes
  adminNotes: String,
  processedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
  },
  processedAt: Date,
  
  // Transaction Reference
  transactionId: String,
  
}, {
  timestamps: true,
});

// Index for faster queries
withdrawalSchema.index({ user: 1, createdAt: -1 });
withdrawalSchema.index({ status: 1 });

module.exports = mongoose.model('Withdrawal', withdrawalSchema);
