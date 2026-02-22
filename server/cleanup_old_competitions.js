require('dotenv').config();
const mongoose = require('mongoose');
const CompetitionSettings = require('./models/CompetitionSettings');

(async () => {
  try {
    console.log('🔗 Connecting...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected\n');

    const now = new Date();

    // Find all ended competitions that are still marked as active
    const endedButActive = await CompetitionSettings.find({
      isActive: true,
      endDate: { $lt: now },
    });

    console.log(`📋 Found ${endedButActive.length} ended competitions marked as active:\n`);

    for (const comp of endedButActive) {
      console.log(`   - ${comp.title}`);
      console.log(`     Ended: ${comp.endDate.toISOString()}`);
      
      // Mark as inactive
      await CompetitionSettings.findByIdAndUpdate(comp._id, { isActive: false });
      console.log(`     ✅ Marked as inactive\n`);
    }

    // Verify the current active competition
    const activeComp = await CompetitionSettings.findOne({
      type: 'weekly',
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
    });

    if (activeComp) {
      console.log('✅ Current active competition:');
      console.log(`   ${activeComp.title}`);
      console.log(`   Start: ${activeComp.startDate.toISOString()}`);
      console.log(`   End: ${activeComp.endDate.toISOString()}\n`);
    } else {
      console.log('⚠️  No active competition found\n');
    }

    await mongoose.connection.close();
    console.log('✅ Cleanup complete');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();
