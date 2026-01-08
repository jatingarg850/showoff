const mongoose = require('mongoose');
const RewardedAd = require('./models/RewardedAd');

const MONGODB_URI = process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff';

mongoose.connect(MONGODB_URI).then(async () => {
  console.log('Connected to MongoDB Atlas');
  
  // Get all ads
  const ads = await RewardedAd.find({});
  console.log('\n📊 All Ads in Database:');
  ads.forEach(ad => {
    console.log(`\nAd ${ad.adNumber}:`);
    console.log(`  Title: ${ad.title}`);
    console.log(`  Reward Coins: ${ad.rewardCoins}`);
    console.log(`  Provider: ${ad.adProvider}`);
    console.log(`  Active: ${ad.isActive}`);
  });
  
  process.exit(0);
}).catch(err => {
  console.error('Connection error:', err.message);
  process.exit(1);
});
