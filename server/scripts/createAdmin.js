require('dotenv').config();
const mongoose = require('mongoose');
const User = require('../models/User');

async function createAdmin() {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('Connected to MongoDB');

    // Check if admin already exists
    const existingAdmin = await User.findOne({ email: 'admin@showofflife.com' });
    
    if (existingAdmin) {
      console.log('Admin user already exists');
      // Update to admin role if not already
      if (existingAdmin.role !== 'admin') {
        existingAdmin.role = 'admin';
        await existingAdmin.save();
        console.log('Updated existing user to admin role');
      }
    } else {
      // Create new admin user
      const adminUser = await User.create({
        username: 'admin',
        displayName: 'Admin User',
        email: 'admin@showofflife.com',
        password: 'admin123',
        role: 'admin',
        isVerified: true,
        isEmailVerified: true,
        accountStatus: 'active'
      });
      
      console.log('Admin user created successfully');
      console.log('Email: admin@showofflife.com');
      console.log('Password: admin123');
    }

    process.exit(0);
  } catch (error) {
    console.error('Error creating admin user:', error);
    process.exit(1);
  }
}

createAdmin();