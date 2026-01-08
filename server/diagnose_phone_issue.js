const mongoose = require('mongoose');
const User = require('./models/User');

async function diagnosePhoneIssue() {
  try {
    const mongoUri = process.env.MONGODB_URI || 'mongodb://localhost:27017/showofftest';
    
    console.log('🔄 Connecting to MongoDB...');
    await mongoose.connect(mongoUri, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB\n');

    // Check total users
    const totalUsers = await User.countDocuments();
    console.log(`📊 Total users in database: ${totalUsers}`);

    if (totalUsers > 0) {
      console.log('\n📋 All users in database:');
      const users = await User.find({}, { phone: 1, email: 1, username: 1, displayName: 1 });
      users.forEach((user, index) => {
        console.log(`   ${index + 1}. Phone: ${user.phone}, Email: ${user.email}, Username: ${user.username}`);
      });
    } else {
      console.log('✅ Database is empty - no users found');
    }

    // Check for any phone field with specific values
    console.log('\n🔍 Checking for phone field patterns...');
    const phoneCounts = await User.aggregate([
      { $group: { _id: '$phone', count: { $sum: 1 } } },
      { $sort: { count: -1 } }
    ]);

    if (phoneCounts.length > 0) {
      console.log('   Found phone numbers:');
      phoneCounts.forEach(item => {
        console.log(`   - "${item._id}": ${item.count} user(s)`);
      });
    } else {
      console.log('   ✅ No phone numbers found in database');
    }

    // Check for sparse index issues
    console.log('\n🔧 Checking indexes...');
    const indexes = await User.collection.getIndexes();
    console.log('   Indexes on User collection:');
    Object.keys(indexes).forEach(indexName => {
      console.log(`   - ${indexName}:`, indexes[indexName]);
    });

    await mongoose.connection.close();
    console.log('\n🔌 Connection closed');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

diagnosePhoneIssue();
