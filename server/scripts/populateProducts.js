require('dotenv').config();
const mongoose = require('mongoose');
const Product = require('../models/Product');

const products = [
  {
    name: 'Light Dress Bless',
    description: 'Its simple and elegant shape makes it perfect for those of you who like minimalist clothes',
    price: 162.99,
    originalPrice: 190.99,
    category: 'clothing',
    sizes: ['S', 'M', 'L', 'XL'],
    colors: [
      { name: 'Light Gray', hexCode: '#D3D3D3' },
      { name: 'Dark Gray', hexCode: '#696969' },
      { name: 'Black', hexCode: '#000000' },
    ],
    stock: 50,
    rating: 5.0,
    reviewCount: 7932,
    badge: 'new',
  },
  {
    name: 'Modern Light Clothes',
    description: 'Dress modern with comfortable fabric and stylish design',
    price: 212.99,
    originalPrice: 250.00,
    category: 'clothing',
    sizes: ['S', 'M', 'L', 'XL'],
    colors: [
      { name: 'White', hexCode: '#FFFFFF' },
      { name: 'Beige', hexCode: '#F5F5DC' },
      { name: 'Gray', hexCode: '#808080' },
    ],
    stock: 30,
    rating: 4.8,
    reviewCount: 5421,
    badge: 'sale',
  },
  {
    name: 'Casual Summer Dress',
    description: 'Perfect for summer days, lightweight and breathable',
    price: 89.99,
    originalPrice: 120.00,
    category: 'clothing',
    sizes: ['XS', 'S', 'M', 'L'],
    colors: [
      { name: 'Blue', hexCode: '#0000FF' },
      { name: 'Pink', hexCode: '#FFC0CB' },
      { name: 'Yellow', hexCode: '#FFFF00' },
    ],
    stock: 45,
    rating: 4.5,
    reviewCount: 3210,
    badge: 'hot',
  },
  {
    name: 'Elegant Evening Gown',
    description: 'Sophisticated design for special occasions',
    price: 299.99,
    originalPrice: 399.99,
    category: 'clothing',
    sizes: ['S', 'M', 'L'],
    colors: [
      { name: 'Black', hexCode: '#000000' },
      { name: 'Navy', hexCode: '#000080' },
      { name: 'Burgundy', hexCode: '#800020' },
    ],
    stock: 20,
    rating: 4.9,
    reviewCount: 1890,
    badge: 'new',
  },
  {
    name: 'Sporty Casual Outfit',
    description: 'Comfortable and stylish for everyday wear',
    price: 75.00,
    originalPrice: 95.00,
    category: 'clothing',
    sizes: ['S', 'M', 'L', 'XL', 'XXL'],
    colors: [
      { name: 'Black', hexCode: '#000000' },
      { name: 'White', hexCode: '#FFFFFF' },
      { name: 'Gray', hexCode: '#808080' },
    ],
    stock: 60,
    rating: 4.6,
    reviewCount: 4567,
    badge: '',
  },
  {
    name: 'Classic Running Shoes',
    description: 'Comfortable running shoes with excellent support',
    price: 129.99,
    originalPrice: 159.99,
    category: 'shoes',
    sizes: ['7', '8', '9', '10', '11'],
    colors: [
      { name: 'Black', hexCode: '#000000' },
      { name: 'White', hexCode: '#FFFFFF' },
      { name: 'Blue', hexCode: '#0000FF' },
    ],
    stock: 40,
    rating: 4.7,
    reviewCount: 6789,
    badge: 'hot',
  },
  {
    name: 'Leather Ankle Boots',
    description: 'Premium leather boots for all seasons',
    price: 189.99,
    originalPrice: 229.99,
    category: 'shoes',
    sizes: ['6', '7', '8', '9', '10'],
    colors: [
      { name: 'Brown', hexCode: '#8B4513' },
      { name: 'Black', hexCode: '#000000' },
    ],
    stock: 25,
    rating: 4.8,
    reviewCount: 3456,
    badge: 'sale',
  },
  {
    name: 'Summer Sandals',
    description: 'Lightweight and comfortable for hot days',
    price: 49.99,
    originalPrice: 69.99,
    category: 'shoes',
    sizes: ['6', '7', '8', '9', '10'],
    colors: [
      { name: 'Tan', hexCode: '#D2B48C' },
      { name: 'White', hexCode: '#FFFFFF' },
      { name: 'Black', hexCode: '#000000' },
    ],
    stock: 55,
    rating: 4.4,
    reviewCount: 2345,
    badge: '',
  },
  {
    name: 'Designer Handbag',
    description: 'Elegant handbag with premium materials',
    price: 249.99,
    originalPrice: 349.99,
    category: 'accessories',
    sizes: ['One Size'],
    colors: [
      { name: 'Black', hexCode: '#000000' },
      { name: 'Brown', hexCode: '#8B4513' },
      { name: 'Red', hexCode: '#FF0000' },
    ],
    stock: 15,
    rating: 4.9,
    reviewCount: 1234,
    badge: 'new',
  },
  {
    name: 'Stylish Sunglasses',
    description: 'UV protection with modern design',
    price: 79.99,
    originalPrice: 99.99,
    category: 'accessories',
    sizes: ['One Size'],
    colors: [
      { name: 'Black', hexCode: '#000000' },
      { name: 'Tortoise', hexCode: '#8B4513' },
    ],
    stock: 35,
    rating: 4.6,
    reviewCount: 5678,
    badge: 'hot',
  },
];

async function populateProducts() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Clear existing products
    await Product.deleteMany({});
    console.log('Cleared existing products');

    // Add payment types to products (50% coins, 50% UPI)
    const productsWithPayment = products.map((product, index) => {
      const paymentType = index % 2 === 0 ? 'coins' : 'upi';
      const coinPrice = paymentType === 'coins' ? Math.ceil(product.price * 10) : null; // 1 USD = 10 coins
      
      return {
        ...product,
        paymentType,
        coinPrice,
      };
    });

    // Insert new products
    const createdProducts = await Product.insertMany(productsWithPayment);
    console.log(`Created ${createdProducts.length} products`);

    console.log('\nSample products:');
    createdProducts.slice(0, 5).forEach(product => {
      const priceDisplay = product.paymentType === 'coins' 
        ? `${product.coinPrice} coins` 
        : `$${product.price}`;
      console.log(`- ${product.name}: ${priceDisplay} (${product.category}) - Payment: ${product.paymentType}`);
    });

    process.exit(0);
  } catch (error) {
    console.error('Error:', error);
    process.exit(1);
  }
}

populateProducts();
