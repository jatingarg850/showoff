/**
 * Migration script to set default adType and usage values for existing ads
 * Run this once to initialize all existing ads with proper type values
 */

const mongoose = require('mongoose');
require('dotenv').config();

const RewardedAd = require('./server/models/RewardedAd');
const VideoAd = require('./server/models/VideoAd');

async function migrateAds() {
  try {
    console.log('🔄 Starting ad migration...\n');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff');
    console.log('✅ Connected to MongoDB\n');

    // Migrate Rewarded Ads
    console.log('📝 Migrating Rewarded Ads...');
    const rewardedAds = await RewardedAd.find({ adType: { $exists: false } });
    console.log(`   Found ${rewardedAds.length} rewarded ads without adType`);

    if (rewardedAds.length > 0) {
      // Set default adType based on ad number
      // Ads 1-5 are for watch-ads (AdMob)
      // Additional ads can be for spin-wheel
      const updateResult = await RewardedAd.updateMany(
        { adType: { $exists: false } },
        { $set: { adType: 'watch-ads' } }
      );
      console.log(`   ✅ Updated ${updateResult.modifiedCount} rewarded ads with adType='watch-ads'\n`);
    } else {
      console.log('   ✅ All rewarded ads already have adType\n');
    }

    // Migrate Video Ads
    console.log('📹 Migrating Video Ads...');
    const videoAds = await VideoAd.find({ usage: { $exists: false } });
    console.log(`   Found ${videoAds.length} video ads without usage`);

    if (videoAds.length > 0) {
      const updateResult = await VideoAd.updateMany(
        { usage: { $exists: false } },
        { $set: { usage: 'watch-ads' } }
      );
      console.log(`   ✅ Updated ${updateResult.modifiedCount} video ads with usage='watch-ads'\n`);
    } else {
      console.log('   ✅ All video ads already have usage\n');
    }

    // Show summary
    console.log('📊 Migration Summary:');
    const totalRewardedAds = await RewardedAd.countDocuments();
    const watchAdsCount = await RewardedAd.countDocuments({ adType: 'watch-ads' });
    const spinWheelAdsCount = await RewardedAd.countDocuments({ adType: 'spin-wheel' });
    const interstitialAdsCount = await RewardedAd.countDocuments({ adType: 'interstitial' });

    console.log(`   Total Rewarded Ads: ${totalRewardedAds}`);
    console.log(`   - Watch Ads: ${watchAdsCount}`);
    console.log(`   - Spin Wheel: ${spinWheelAdsCount}`);
    console.log(`   - Interstitial: ${interstitialAdsCount}`);

    const totalVideoAds = await VideoAd.countDocuments();
    const watchVideoAdsCount = await VideoAd.countDocuments({ usage: 'watch-ads' });
    const spinWheelVideoAdsCount = await VideoAd.countDocuments({ usage: 'spin-wheel' });

    console.log(`\n   Total Video Ads: ${totalVideoAds}`);
    console.log(`   - Watch Ads: ${watchVideoAdsCount}`);
    console.log(`   - Spin Wheel: ${spinWheelVideoAdsCount}`);

    console.log('\n✅ Migration completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Migration error:', error);
    process.exit(1);
  }
}

migrateAds();
