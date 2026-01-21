const mongoose = require('mongoose');
const { SubscriptionPlan } = require('../models/Subscription');
require('dotenv').config();

async function seedSubscriptionPlans() {
  try {
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Check if pro plan already exists
    const existingPlan = await SubscriptionPlan.findOne({ tier: 'pro' });
    if (existingPlan) {
      console.log('✅ Pro plan already exists:', existingPlan._id);
      console.log('Plan details:', {
        name: existingPlan.name,
        tier: existingPlan.tier,
        price: existingPlan.price,
        currency: existingPlan.currency,
        features: existingPlan.features
      });
      await mongoose.connection.close();
      return;
    }

    // Create premium plan
    const premiumPlan = await SubscriptionPlan.create({
      name: 'Premium',
      tier: 'pro',
      price: 249900, // 2499 in paise (₹2,499)
      currency: 'INR',
      duration: 30,
      features: [
        'Verified profile (Blue tick)',
        '100% ad-free',
        'Payment allowed via earned coins'
      ],
      isActive: true,
      description: 'Premium subscription with all features',
      highlightedFeatures: [
        'Verified profile (Blue tick)',
        '100% ad-free',
        'Payment allowed via earned coins'
      ],
      displayOrder: 1
    });

    console.log('✅ Premium plan created successfully');
    console.log('Plan ID:', premiumPlan._id);
    console.log('Plan details:', {
      name: premiumPlan.name,
      tier: premiumPlan.tier,
      price: premiumPlan.price,
      currency: premiumPlan.currency
    });

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error seeding subscription plans:', error);
    process.exit(1);
  }
}

seedSubscriptionPlans();
