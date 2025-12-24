const mongoose = require('mongoose');

const termsAndConditionsSchema = new mongoose.Schema({
  version: {
    type: Number,
    required: true,
    unique: true,
    default: 1,
  },
  title: {
    type: String,
    default: 'SHOWOFF.LIFE – TERMS & CONDITIONS',
  },
  lastUpdated: {
    type: Date,
    default: Date.now,
  },
  content: {
    type: String,
    required: true,
  },
  isActive: {
    type: Boolean,
    default: true,
  },
  createdAt: {
    type: Date,
    default: Date.now,
  },
  updatedAt: {
    type: Date,
    default: Date.now,
  },
});

module.exports = mongoose.model('TermsAndConditions', termsAndConditionsSchema);
