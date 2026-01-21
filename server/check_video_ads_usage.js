/**
 * Check video ads and their usage field
 */

const mongoose = require('mongoose');
require('dotenv').config();

const VideoAd = require('./models/VideoAd');

async function checkVideoAds() {
  try {
    console.log('🔍 Checking video ads...\n');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff');
    console.log('✅ Connected to MongoDB\n');

    // Get all video ads
    const videoAds = await VideoAd.find();
    console.log(`📹 Total Video Ads: ${videoAds.length}\n`);

    if (videoAds.length > 0) {
      videoAds.forEach((ad, index) => {
        console.log(`Video Ad ${index + 1}:`);
        console.log(`  - ID: ${ad._id}`);
        console.log(`  - Title: ${ad.title}`);
        console.log(`  - Usage: ${ad.usage || 'NOT SET'}`);
        console.log(`  - Active: ${ad.isActive}`);
        console.log(`  - Reward: ${ad.rewardCoins} coins`);
        console.log(`  - Video URL: ${ad.videoUrl ? '✅' : '❌'}`);
        console.log('');
      });

      // Update all video ads to have usage='spin-wheel' if not set
      console.log('🔄 Updating video ads to usage="spin-wheel"...\n');
      
      const result = await VideoAd.updateMany(
        { usage: { $exists: false } },
        { $set: { usage: 'spin-wheel' } }
      );

      console.log(`✅ Updated ${result.modifiedCount} video ads`);
      console.log(`⚠️  Matched ${result.matchedCount} video ads\n`);

      // Show updated ads
      const updatedAds = await VideoAd.find();
      console.log('📹 Updated Video Ads:\n');
      updatedAds.forEach((ad, index) => {
        console.log(`Video Ad ${index + 1}:`);
        console.log(`  - Title: ${ad.title}`);
        console.log(`  - Usage: ${ad.usage}`);
        console.log(`  - Active: ${ad.isActive}`);
        console.log('');
      });
    } else {
      console.log('❌ No video ads found\n');
    }

    console.log('✅ Check completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkVideoAds();
