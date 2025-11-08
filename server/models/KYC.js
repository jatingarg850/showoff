const mongoose = require('mongoose');

const kycSchema = new mongoose.Schema({
  user: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User',
    required: true,
    unique: true
  },
  
  // Personal Information
  fullName: {
    type: String,
    required: true
  },
  dateOfBirth: {
    type: Date,
    required: true
  },
  gender: {
    type: String,
    enum: ['male', 'female', 'other'],
    required: true
  },
  
  // Address
  address: {
    street: String,
    city: String,
    state: String,
    country: String,
    zipCode: String
  },
  
  // Identity Documents
  documentType: {
    type: String,
    enum: ['passport', 'driving_license', 'national_id', 'aadhaar'],
    required: true
  },
  documentNumber: {
    type: String,
    required: true
  },
  documentFrontImage: {
    type: String,
    required: true
  },
  documentBackImage: {
    type: String
  },
  selfieImage: {
    type: String,
    required: true
  },
  
  // Bank Details (for withdrawals)
  bankDetails: {
    accountHolderName: String,
    accountNumber: String,
    ifscCode: String,
    bankName: String,
    branch: String,
    accountType: {
      type: String,
      enum: ['savings', 'current']
    }
  },
  
  // Web3 Wallet (optional)
  web3Wallet: {
    address: String,
    network: String
  },
  
  // Status
  status: {
    type: String,
    enum: ['pending', 'under_review', 'approved', 'rejected', 'resubmit_required'],
    default: 'pending'
  },
  
  // Review Details
  reviewedBy: {
    type: mongoose.Schema.Types.ObjectId,
    ref: 'User'
  },
  reviewedAt: Date,
  rejectionReason: String,
  adminNotes: String,
  
  // Verification Flags
  isDocumentVerified: {
    type: Boolean,
    default: false
  },
  isSelfieVerified: {
    type: Boolean,
    default: false
  },
  isBankVerified: {
    type: Boolean,
    default: false
  },
  
  // Metadata
  submittedAt: {
    type: Date,
    default: Date.now
  },
  ipAddress: String,
  deviceInfo: String,
  
}, {
  timestamps: true
});

// Indexes
kycSchema.index({ user: 1 });
kycSchema.index({ status: 1 });
kycSchema.index({ submittedAt: -1 });

module.exports = mongoose.model('KYC', kycSchema);
