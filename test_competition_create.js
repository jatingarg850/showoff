const mongoose = require('mongoose');
require('dotenv').config({ path: 'server/.env' });

const CompetitionSettings = require('./server/models/CompetitionSettings');

async function test() {
  try {
    console.log('📝 MongoDB URI:', process.env.MONGODB_URI ? '✅ Found' : '❌ Not found');
    
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected to MongoDB');

    // Get all competitions
    const comps = await CompetitionSettings.find();
    console.log('\n📊 Existing competitions:');
    comps.forEach(c => {
      console.log(`  - Type: ${c.type}, Title: ${c.title}, Active: ${c.isActive}`);
    });

    // Try to create a new one
    console.log('\n🔄 Attempting to create new competition...');
    const newComp = await CompetitionSettings.create({
      type: 'weekly',
      title: 'Test Competition',
      description: 'Test',
      startDate: new Date(),
      endDate: new Date(Date.now() + 7 * 24 * 60 * 60 * 1000),
      periodId: 'test-period',
      prizes: [
        { position: 1, coins: 1000, badge: 'Gold' },
      ],
    });

    console.log('✅ Competition created:', newComp._id);

    await mongoose.connection.close();
    console.log('✅ Connection closed');
  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.code === 11000) {
      console.error('🔴 Duplicate key error - a competition with this type already exists');
      console.error('Error details:', error.keyPattern);
    }
    process.exit(1);
  }
}

test();
