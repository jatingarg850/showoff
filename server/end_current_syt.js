require('dotenv').config();
const mongoose = require('mongoose');
const CompetitionSettings = require('./models/CompetitionSettings');

(async () => {
  try {
    console.log('🔗 Connecting...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected\n');

    const now = new Date();
    const current = await CompetitionSettings.findOne({
      type: 'weekly',
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
    });

    if (current) {
      console.log('📋 Current competition:');
      console.log(`   ${current.title}`);
      console.log(`   Ends: ${current.endDate.toISOString()}\n`);

      // End it
      const endTime = new Date();
      await CompetitionSettings.findByIdAndUpdate(current._id, {
        endDate: endTime,
        isActive: false,
      });
      console.log('✅ Ended current competition\n');

      // Create new
      const newStart = new Date(endTime.getTime() + 1000);
      const newEnd = new Date(newStart.getTime() + 7 * 24 * 60 * 60 * 1000);

      const newComp = await CompetitionSettings.create({
        type: 'weekly',
        title: `Weekly Talent Show - ${newStart.toLocaleDateString()}`,
        startDate: newStart,
        endDate: newEnd,
        periodId: `weekly-${newStart.getFullYear()}-${newStart.getMonth() + 1}-${newStart.getDate()}`,
        isActive: true,
        prizes: [
          { position: 1, coins: 1000, badge: 'Gold' },
          { position: 2, coins: 500, badge: 'Silver' },
          { position: 3, coins: 250, badge: 'Bronze' },
        ],
      });

      console.log('✅ Created new competition:');
      console.log(`   ${newComp.title}`);
      console.log(`   Starts: ${newComp.startDate.toISOString()}`);
      console.log(`   Ends: ${newComp.endDate.toISOString()}\n`);
    } else {
      console.log('⚠️  No active weekly competition found');
    }

    await mongoose.connection.close();
    console.log('✅ Done');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();
