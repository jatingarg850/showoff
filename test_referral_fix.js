// Test script to verify referral code fix
// This tests that the referral_bonus transaction type is now valid

const mongoose = require('mongoose');
require('dotenv').config();

const Transaction = require('./server/models/Transaction');
const User = require('./server/models/User');

async function testReferralFix() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB');

    // Get a test user
    const testUser = await User.findOne();
    if (!testUser) {
      console.log('❌ No users found in database');
      await mongoose.connection.close();
      return;
    }

    console.log(`\n📝 Testing with user: ${testUser.username}`);

    // Try to create a referral_bonus transaction
    const transaction = await Transaction.create({
      user: testUser._id,
      type: 'referral_bonus',
      amount: 20,
      balanceAfter: testUser.coinBalance + 20,
      description: 'Test referral bonus transaction',
      status: 'completed',
    });

    console.log('\n✅ SUCCESS! referral_bonus transaction created:');
    console.log('Transaction ID:', transaction._id);
    console.log('Type:', transaction.type);
    console.log('Amount:', transaction.amount);
    console.log('Description:', transaction.description);

    // Verify we can query it back
    const retrieved = await Transaction.findById(transaction._id);
    console.log('\n✅ Transaction retrieved successfully');
    console.log('Retrieved type:', retrieved.type);

    // Clean up - delete the test transaction
    await Transaction.findByIdAndDelete(transaction._id);
    console.log('\n✅ Test transaction cleaned up');

    console.log('\n🎉 All tests passed! Referral code fix is working.');

    await mongoose.connection.close();
  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.errors) {
      console.error('Validation errors:', error.errors);
    }
    process.exit(1);
  }
}

testReferralFix();
