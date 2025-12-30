require('dotenv').config({ path: require('path').join(__dirname, '../.env') });
const mongoose = require('mongoose');
const { SubscriptionPlan } = require('../models/Subscription');

const verifyPlan = async () => {
  try {
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    const plan = await SubscriptionPlan.findOne({ tier: 'pro' });
    
    if (plan) {
      console.log('✅ Premium plan exists!');
      console.log('Plan ID:', plan._id);
      console.log('Plan Name:', plan.name);
      console.log('Plan Tier:', plan.tier);
      console.log('Price (Monthly):', plan.price.monthly);
      console.log('Is Active:', plan.isActive);
    } else {
      console.log('❌ Premium plan NOT found');
      console.log('Creating premium plan now...');
      
      const newPlan = await SubscriptionPlan.create({
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
      
      console.log('✅ Premium plan created!');
      console.log('Plan ID:', newPlan._id);
    }

    await mongoose.connection.close();
    console.log('✅ Done');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

verifyPlan();
