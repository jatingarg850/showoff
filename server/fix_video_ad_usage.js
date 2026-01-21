/**
 * Fix video ad usage to spin-wheel
 */

const mongoose = require('mongoose');
require('dotenv').config();

const VideoAd = require('./models/VideoAd');

async function fixVideoAdUsage() {
  try {
    console.log('🔄 Fixing video ad usage...\n');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff');
    console.log('✅ Connected to MongoDB\n');

    // Update the video ad to spin-wheel usage
    const result = await VideoAd.updateOne(
      { title: 'jhvgf' },
      { $set: { usage: 'spin-wheel' } }
    );

    console.log(`✅ Updated ${result.modifiedCount} video ad(s)`);
    console.log(`⚠️  Matched ${result.matchedCount} video ad(s)\n`);

    // Show updated ad
    const updatedAd = await VideoAd.findOne({ title: 'jhvgf' });
    if (updatedAd) {
      console.log('📹 Updated Video Ad:');
      console.log(`  - Title: ${updatedAd.title}`);
      console.log(`  - Usage: ${updatedAd.usage}`);
      console.log(`  - Active: ${updatedAd.isActive}`);
      console.log(`  - Reward: ${updatedAd.rewardCoins} coins`);
    }

    console.log('\n✅ Fix completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

fixVideoAdUsage();
