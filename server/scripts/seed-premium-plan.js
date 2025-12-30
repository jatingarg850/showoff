require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const { SubscriptionPlan } = require('../models/Subscription');

const seedPremiumPlan = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });

    console.log('✅ Connected to MongoDB');

    // Check if premium plan already exists
    const existingPlan = await SubscriptionPlan.findOne({ tier: 'pro' });
    if (existingPlan) {
      console.log('⚠️ Premium plan already exists');
      console.log('Plan:', existingPlan);
      await mongoose.connection.close();
      return;
    }

    // Create premium plan
    const premiumPlan = await SubscriptionPlan.create({
      name: 'ShowOff Premium',
      tier: 'pro',
      price: {
        monthly: 2499,
        yearly: 24990
      },
      currency: 'INR',
      features: {
        maxUploadsPerDay: 100,
        maxStorageGB: 100,
        canParticipateInSYT: true,
        prioritySupport: true,
        verifiedBadge: true,
        adFree: true,
        customProfile: true,
        analyticsAccess: true,
        coinBonus: 500,
        uploadRewardMultiplier: 1.5
      },
      isActive: true,
      description: 'Single plan only',
      highlightedFeatures: [
        'Verified profile (Blue tick)',
        '100% ad-free',
        'Payment allowed via earned coins'
      ],
      displayOrder: 1
    });

    console.log('✅ Premium plan created successfully');
    console.log('Plan ID:', premiumPlan._id);
    console.log('Plan Details:', premiumPlan);

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error seeding premium plan:', error.message);
    process.exit(1);
  }
};

seedPremiumPlan();
