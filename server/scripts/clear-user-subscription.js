require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const { UserSubscription } = require('../models/Subscription');
const User = require('../models/User');

const clearSubscription = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get the user ID from command line or use a default
    const userId = process.argv[2];
    if (!userId) {
      console.log('❌ Please provide user ID as argument');
      console.log('Usage: node clear-user-subscription.js <userId>');
      await mongoose.connection.close();
      return;
    }

    // Find and delete active subscriptions
    const result = await UserSubscription.deleteMany({
      user: userId,
      status: 'active'
    });

    console.log(`✅ Deleted ${result.deletedCount} active subscription(s)`);

    // Reset user subscription tier
    await User.findByIdAndUpdate(userId, {
      subscriptionTier: 'free',
      isVerified: false,
      subscriptionExpiry: null
    });

    console.log('✅ User subscription tier reset to free');
    console.log('✅ Verified badge removed');

    await mongoose.connection.close();
    console.log('✅ Done');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

clearSubscription();
