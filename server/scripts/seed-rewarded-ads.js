/**
 * Seed script to initialize rewarded ads in the database
 * Run: node server/scripts/seed-rewarded-ads.js
 */

const mongoose = require('mongoose');
const path = require('path');

// Load environment variables from the correct path
require('dotenv').config({ path: path.join(__dirname, '../.env') });

const RewardedAd = require('../models/RewardedAd');

const seedAds = async () => {
  try {
    console.log('📝 MongoDB URI:', process.env.MONGODB_URI ? '✅ Found' : '❌ Not found');
    
    // Connect to MongoDB
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Check if ads already exist
    const existingAds = await RewardedAd.find();
    if (existingAds.length > 0) {
      console.log(`⚠️  ${existingAds.length} ads already exist in database`);
      console.log('Skipping seed...');
      await mongoose.connection.close();
      return;
    }

    // Create initial ads
    const initialAds = [
      {
        adNumber: 1,
        title: 'Watch & Earn',
        description: 'Watch video ad to earn coins',
        icon: 'play-circle',
        color: '#667eea',
        adLink: 'https://example.com/ad1',
        adProvider: 'admob',
        rewardCoins: 10,
        isActive: true,
        rotationOrder: 1,
        providerConfig: {
          admob: {
            adUnitId: 'ca-app-pub-3940256099942544/5224354917',
            appId: 'ca-app-pub-3940256099942544~3347511713'
          }
        }
      },
      {
        adNumber: 2,
        title: 'Sponsored Content',
        description: 'Watch sponsored content',
        icon: 'video',
        color: '#FF6B35',
        adLink: 'https://example.com/ad2',
        adProvider: 'admob',
        rewardCoins: 10,
        isActive: true,
        rotationOrder: 2,
        providerConfig: {
          admob: {
            adUnitId: 'ca-app-pub-3940256099942544/5224354917',
            appId: 'ca-app-pub-3940256099942544~3347511713'
          }
        }
      },
      {
        adNumber: 3,
        title: 'Interactive Ad',
        description: 'Interactive ad experience',
        icon: 'hand-pointer',
        color: '#4FACFE',
        adLink: 'https://example.com/ad3',
        adProvider: 'meta',
        rewardCoins: 15,
        isActive: true,
        rotationOrder: 3,
        providerConfig: {
          meta: {
            placementId: 'YOUR_PLACEMENT_ID',
            appId: 'YOUR_APP_ID',
            accessToken: 'YOUR_ACCESS_TOKEN'
          }
        }
      },
      {
        adNumber: 4,
        title: 'Quick Survey',
        description: 'Complete a quick survey',
        icon: 'clipboard',
        color: '#43E97B',
        adLink: 'https://example.com/ad4',
        adProvider: 'custom',
        rewardCoins: 20,
        isActive: true,
        rotationOrder: 4,
        providerConfig: {
          custom: {
            apiKey: 'YOUR_API_KEY',
            apiSecret: 'YOUR_API_SECRET',
            endpoint: 'https://api.example.com'
          }
        }
      },
      {
        adNumber: 5,
        title: 'Premium Offer',
        description: 'Exclusive premium offer',
        icon: 'star',
        color: '#FBBF24',
        adLink: 'https://example.com/ad5',
        adProvider: 'third-party',
        rewardCoins: 25,
        isActive: true,
        rotationOrder: 5,
        providerConfig: {
          thirdParty: {
            apiKey: 'YOUR_API_KEY',
            apiSecret: 'YOUR_API_SECRET',
            endpoint: 'https://api.thirdparty.com',
            customField1: 'value1',
            customField2: 'value2'
          }
        }
      }
    ];

    // Insert ads
    const createdAds = await RewardedAd.insertMany(initialAds);
    console.log(`✅ Created ${createdAds.length} rewarded ads`);

    // Display created ads
    createdAds.forEach(ad => {
      console.log(`   - Ad ${ad.adNumber}: ${ad.title} (${ad.rewardCoins} coins, ${ad.adProvider})`);
    });

    await mongoose.connection.close();
    console.log('✅ Database connection closed');
  } catch (error) {
    console.error('❌ Error seeding ads:', error.message);
    process.exit(1);
  }
};

seedAds();
