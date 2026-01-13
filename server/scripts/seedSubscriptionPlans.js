const mongoose = require('mongoose');
const { SubscriptionPlan } = require('../models/Subscription');
require('dotenv').config();

const seedPlans = async () => {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Clear existing plans
    await SubscriptionPlan.deleteMany({});
    console.log('🗑️  Cleared existing plans');

    // Create subscription plans
    const plans = [
      {
        name: 'Free',
        tier: 'free',
        price: {
          monthly: 0,
          yearly: 0,
        },
        currency: 'INR',
        features: {
          maxUploadsPerDay: 3,
          maxStorageGB: 1,
          canParticipateInSYT: true,
          prioritySupport: false,
          verifiedBadge: false,
          adFree: false,
          customProfile: false,
          analyticsAccess: false,
          coinBonus: 0,
          uploadRewardMultiplier: 1,
        },
        isActive: true,
        description: 'Get started with ShowOff Life',
        highlightedFeatures: ['3 uploads per day', '1GB storage', 'SYT participation'],
        displayOrder: 1,
      },
      {
        name: 'Basic',
        tier: 'basic',
        price: {
          monthly: 499,
          yearly: 4990,
        },
        currency: 'INR',
        features: {
          maxUploadsPerDay: 10,
          maxStorageGB: 10,
          canParticipateInSYT: true,
          prioritySupport: true,
          verifiedBadge: false,
          adFree: false,
          customProfile: false,
          analyticsAccess: false,
          coinBonus: 100,
          uploadRewardMultiplier: 1.2,
        },
        isActive: true,
        description: 'Perfect for growing creators',
        highlightedFeatures: ['10 uploads per day', '10GB storage', 'Priority support', '100 bonus coins'],
        displayOrder: 2,
      },
      {
        name: 'Pro',
        tier: 'pro',
        price: {
          monthly: 2499,
          yearly: 24990,
        },
        currency: 'INR',
        features: {
          maxUploadsPerDay: 50,
          maxStorageGB: 100,
          canParticipateInSYT: true,
          prioritySupport: true,
          verifiedBadge: true,
          adFree: true,
          customProfile: true,
          analyticsAccess: true,
          coinBonus: 500,
          uploadRewardMultiplier: 1.5,
        },
        isActive: true,
        description: 'For serious creators',
        highlightedFeatures: [
          '50 uploads per day',
          '100GB storage',
          'Verified badge',
          'Ad-free experience',
          'Custom profile',
          'Analytics',
          '500 bonus coins',
          '1.5x upload rewards',
        ],
        displayOrder: 3,
      },
      {
        name: 'VIP',
        tier: 'vip',
        price: {
          monthly: 4999,
          yearly: 49990,
        },
        currency: 'INR',
        features: {
          maxUploadsPerDay: 100,
          maxStorageGB: 500,
          canParticipateInSYT: true,
          prioritySupport: true,
          verifiedBadge: true,
          adFree: true,
          customProfile: true,
          analyticsAccess: true,
          coinBonus: 1000,
          uploadRewardMultiplier: 2,
        },
        isActive: true,
        description: 'Ultimate creator experience',
        highlightedFeatures: [
          '100 uploads per day',
          '500GB storage',
          'Verified badge',
          'Ad-free experience',
          'Custom profile',
          'Advanced analytics',
          '1000 bonus coins',
          '2x upload rewards',
          'VIP support',
        ],
        displayOrder: 4,
      },
    ];

    const createdPlans = await SubscriptionPlan.insertMany(plans);
    console.log(`✅ Created ${createdPlans.length} subscription plans`);

    createdPlans.forEach((plan) => {
      console.log(`  - ${plan.name} (${plan.tier}): ₹${plan.price.monthly}/month`);
    });

    console.log('\n✅ Subscription plans seeded successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error seeding plans:', error.message);
    process.exit(1);
  }
};

seedPlans();
