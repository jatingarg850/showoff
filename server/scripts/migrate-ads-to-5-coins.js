/**
 * Migration script to update all rewarded ads to have 5 coins reward
 * Run: node server/scripts/migrate-ads-to-5-coins.js
 */

const mongoose = require('mongoose');
const path = require('path');

// Load environment variables from the correct path
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const RewardedAd = require('../models/RewardedAd');

const migrateAds = async () => {
  try {
    console.log('📝 MongoDB URI:', process.env.MONGODB_URI ? '✅ Found' : '❌ Not found');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all ads
    const allAds = await RewardedAd.find();
    console.log(`📊 Found ${allAds.length} ads in database`);

    if (allAds.length === 0) {
      console.log('⚠️  No ads found in database');
      await mongoose.connection.close();
      return;
    }

    // Display current state
    console.log('\n📋 Current ad rewards:');
    allAds.forEach(ad => {
      console.log(`   - Ad ${ad.adNumber}: ${ad.title} (${ad.rewardCoins} coins)`);
    });

    // Update all ads to 5 coins
    console.log('\n🔄 Updating all ads to 5 coins...');
    const result = await RewardedAd.updateMany(
      {},
      { $set: { rewardCoins: 5 } }
    );

    console.log(`✅ Updated ${result.modifiedCount} ads`);

    // Display updated state
    const updatedAds = await RewardedAd.find();
    console.log('\n📋 Updated ad rewards:');
    updatedAds.forEach(ad => {
      console.log(`   - Ad ${ad.adNumber}: ${ad.title} (${ad.rewardCoins} coins)`);
    });

    await mongoose.connection.close();
    console.log('\n✅ Database connection closed');
    console.log('✅ Migration completed successfully!');
  } catch (error) {
    console.error('❌ Error during migration:', error.message);
    process.exit(1);
  }
};

migrateAds();
