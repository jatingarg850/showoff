/**
 * Check what ads are in the database and their types
 */

const mongoose = require('mongoose');
require('dotenv').config();

const RewardedAd = require('./server/models/RewardedAd');
const VideoAd = require('./server/models/VideoAd');

async function checkAds() {
  try {
    console.log('🔍 Checking ads in database...\n');

    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff');
    console.log('✅ Connected to MongoDB\n');

    // Check Rewarded Ads
    console.log('📝 REWARDED ADS:');
    const rewardedAds = await RewardedAd.find().sort({ adNumber: 1 });
    console.log(`Total: ${rewardedAds.length}\n`);

    if (rewardedAds.length > 0) {
      rewardedAds.forEach(ad => {
        console.log(`  Ad #${ad.adNumber}:`);
        console.log(`    - Title: ${ad.title}`);
        console.log(`    - Type: ${ad.adType || 'NOT SET'}`);
        console.log(`    - Provider: ${ad.adProvider}`);
        console.log(`    - Active: ${ad.isActive}`);
        console.log(`    - Reward: ${ad.rewardCoins} coins`);
        console.log('');
      });
    } else {
      console.log('  ❌ No rewarded ads found\n');
    }

    // Check Video Ads
    console.log('📹 VIDEO ADS:');
    const videoAds = await VideoAd.find().sort({ createdAt: -1 });
    console.log(`Total: ${videoAds.length}\n`);

    if (videoAds.length > 0) {
      videoAds.forEach((ad, index) => {
        console.log(`  Video Ad ${index + 1}:`);
        console.log(`    - Title: ${ad.title}`);
        console.log(`    - Usage: ${ad.usage || 'NOT SET'}`);
        console.log(`    - Active: ${ad.isActive}`);
        console.log(`    - Reward: ${ad.rewardCoins} coins`);
        console.log(`    - URL: ${ad.videoUrl ? '✅ Set' : '❌ Not set'}`);
        console.log('');
      });
    } else {
      console.log('  ❌ No video ads found\n');
    }

    // Summary
    console.log('📊 SUMMARY:');
    const watchAdsCount = await RewardedAd.countDocuments({ adType: 'watch-ads' });
    const spinWheelCount = await RewardedAd.countDocuments({ adType: 'spin-wheel' });
    const interstitialCount = await RewardedAd.countDocuments({ adType: 'interstitial' });

    console.log(`  Rewarded Ads by Type:`);
    console.log(`    - Watch Ads: ${watchAdsCount}`);
    console.log(`    - Spin Wheel: ${spinWheelCount}`);
    console.log(`    - Interstitial: ${interstitialCount}`);

    const watchVideoCount = await VideoAd.countDocuments({ usage: 'watch-ads' });
    const spinWheelVideoCount = await VideoAd.countDocuments({ usage: 'spin-wheel' });

    console.log(`\n  Video Ads by Usage:`);
    console.log(`    - Watch Ads: ${watchVideoCount}`);
    console.log(`    - Spin Wheel: ${spinWheelVideoCount}`);

    console.log('\n✅ Check completed!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

checkAds();
