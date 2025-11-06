const mongoose = require('mongoose');
const User = require('../models/User');
const bcrypt = require('bcryptjs');

async function createTestUsers() {
  try {
    // Connect to database
    await mongoose.connect('mongodb://localhost:27017/showoff-life');
    console.log('Connected to MongoDB');

    // Check if users already exist
    const existingUsers = await User.countDocuments();
    if (existingUsers > 0) {
      console.log(`Found ${existingUsers} existing users. Skipping user creation.`);
      const users = await User.find().limit(5);
      users.forEach(user => {
        console.log(`- ${user.displayName} (@${user.username})`);
      });
      return;
    }

    const testUsers = [
      {
        username: 'testuser1',
        displayName: 'Test User 1',
        email: 'test1@example.com',
        password: 'password123',
        bio: 'Test user for admin panel testing',
        profilePicture: '/uploads/images/profile1.jpg',
        referralCode: 'TEST001',
        isVerified: true,
        coinBalance: 150,
        totalCoinsEarned: 200,
        followersCount: 45,
        followingCount: 32,
        postsCount: 0
      },
      {
        username: 'testuser2',
        displayName: 'Test User 2',
        email: 'test2@example.com',
        password: 'password123',
        bio: 'Another test user for admin panel',
        profilePicture: '/uploads/images/profile2.jpg',
        referralCode: 'TEST002',
        isVerified: false,
        coinBalance: 75,
        totalCoinsEarned: 100,
        followersCount: 23,
        followingCount: 18,
        postsCount: 0
      },
      {
        username: 'testuser3',
        displayName: 'Test User 3',
        email: 'test3@example.com',
        password: 'password123',
        bio: 'Third test user for testing',
        referralCode: 'TEST003',
        isVerified: true,
        coinBalance: 300,
        totalCoinsEarned: 450,
        followersCount: 89,
        followingCount: 67,
        postsCount: 0
      },
      {
        username: 'testuser4',
        displayName: 'Test User 4',
        email: 'test4@example.com',
        password: 'password123',
        bio: 'Fourth test user',
        referralCode: 'TEST004',
        isVerified: false,
        coinBalance: 25,
        totalCoinsEarned: 50,
        followersCount: 12,
        followingCount: 8,
        postsCount: 0
      },
      {
        username: 'testuser5',
        displayName: 'Test User 5',
        email: 'test5@example.com',
        password: 'password123',
        bio: 'Fifth test user for comprehensive testing',
        referralCode: 'TEST005',
        isVerified: true,
        coinBalance: 500,
        totalCoinsEarned: 750,
        followersCount: 156,
        followingCount: 89,
        postsCount: 0
      }
    ];

    // Hash passwords
    for (let user of testUsers) {
      const salt = await bcrypt.genSalt(10);
      user.password = await bcrypt.hash(user.password, salt);
    }

    // Create users
    const createdUsers = await User.insertMany(testUsers);
    console.log(`✅ Created ${createdUsers.length} test users:`);
    
    createdUsers.forEach(user => {
      console.log(`- ${user.displayName} (@${user.username}) - ${user.isVerified ? 'Verified' : 'Unverified'}`);
    });

  } catch (error) {
    console.error('Error:', error);
  } finally {
    await mongoose.disconnect();
    console.log('Disconnected from MongoDB');
  }
}

createTestUsers();