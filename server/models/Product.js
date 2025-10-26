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
  isActive: {
    type: Boolean,
    default: true,
  },
}, {
  timestamps: true,
});

module.exports = mongoose.model('Product', productSchema);
