const mongoose = require('mongoose');

const productSchema = new mongoose.Schema({
  name: {
    type: String,
    required: true,
  },
  description: {
    type: String,
    required: true,
  },
  price: {
    type: Number,
    required: true,
  },
  originalPrice: {
    type: Number,
  },
  category: {
    type: String,
    enum: ['clothing', 'shoes', 'accessories', 'other'],
    default: 'other',
  },
  images: [{
    type: String,
  }],
  thumbnailUrl: String,
  sizes: [{
    type: String,
  }],
  colors: [{
    name: String,
    hexCode: String,
  }],
  stock: {
    type: Number,
    default: 0,
  },
  rating: {
    type: Number,
    default: 0,
  },
  reviewCount: {
    type: Number,
    default: 0,
  },
  badge: {
    type: String,
    enum: ['new', 'sale', 'hot', ''],
    default: '',
  },
  paymentType: {
    type: String,
    enum: ['coins', 'upi', 'mixed'],
    required: true,
    default: 'mixed', // Default to 50% money + 50% coins
  },
  coinPrice: {
    type: Number,
    // Price in coins when paymentType is 'coins' or for mixed payment (50% of total)
  },
  // For mixed payment: 50% real money + 50% coins
  mixedPayment: {
    cashAmount: Number,    // 50% of price in USD
    coinAmount: Number,    // 50% of price in coins
  },
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Product', productSchema);
