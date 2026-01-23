const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config({ path: './server/.env' });

const User = require('./server/models/User');

async function createAdminUser() {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Check if admin user already exists
    console.log('\n🔍 Checking for existing admin user...');
    let adminUser = await User.findOne({ email: 'admin@showofflife.com' });

    if (adminUser) {
      console.log('✅ Admin user already exists');
      console.log('   Email:', adminUser.email);
      console.log('   Username:', adminUser.username);
      console.log('   ID:', adminUser._id);
    } else {
      console.log('❌ Admin user not found, creating new one...');
      
      // Hash password
      const hashedPassword = await bcrypt.hash('admin123', 10);
      
      // Create admin user
      adminUser = await User.create({
        username: 'admin',
        email: 'admin@showofflife.com',
        password: hashedPassword,
        displayName: 'Admin',
        isVerified: true,
        isEmailVerified: true,
        coinBalance: 0,
        withdrawableBalance: 0,
      });
      
      console.log('✅ Admin user created successfully');
      console.log('   Email:', adminUser.email);
      console.log('   Username:', adminUser.username);
      console.log('   ID:', adminUser._id);
      console.log('\n📝 Login credentials:');
      console.log('   Email: admin@showofflife.com');
      console.log('   Password: admin123');
    }

    // Verify admin user can be found
    console.log('\n🔍 Verifying admin user...');
    const verifyAdmin = await User.findOne({ email: 'admin@showofflife.com' });
    if (verifyAdmin) {
      console.log('✅ Admin user verified in database');
      console.log('   ID:', verifyAdmin._id);
      console.log('   Email:', verifyAdmin.email);
      console.log('   Username:', verifyAdmin.username);
    } else {
      console.log('❌ Admin user verification failed');
    }

    // Check total users
    console.log('\n🔍 Checking total users...');
    const totalUsers = await User.countDocuments();
    console.log('✅ Total users in database:', totalUsers);

    console.log('\n✅ Admin user setup complete!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

createAdminUser();
