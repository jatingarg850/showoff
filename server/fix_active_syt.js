require('dotenv').config();
const mongoose = require('mongoose');
const CompetitionSettings = require('./models/CompetitionSettings');

(async () => {
  try {
    console.log('🔗 Connecting...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected\n');

    const now = new Date();
    console.log('📅 Current time:', now.toISOString());
    console.log('📅 Current time (local):', now.toString(), '\n');

    // Get all weekly competitions
    const allWeekly = await CompetitionSettings.find({ type: 'weekly' }).sort({ startDate: -1 });
    
    console.log('📋 All weekly competitions:');
    allWeekly.forEach((comp, idx) => {
      const isActive = comp.isActive && now >= comp.startDate && now <= comp.endDate;
      console.log(`\n   ${idx + 1}. ${comp.title}`);
      console.log(`      Start: ${comp.startDate.toISOString()}`);
      console.log(`      End: ${comp.endDate.toISOString()}`);
      console.log(`      isActive flag: ${comp.isActive}`);
      console.log(`      Currently active: ${isActive}`);
    });

    // Find or create an active competition
    let activeComp = await CompetitionSettings.findOne({
      type: 'weekly',
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
    });

    if (!activeComp) {
      console.log('\n⚠️  No active competition found. Creating one...\n');

      // Create a new active competition
      const startDate = new Date(now);
      startDate.setHours(0, 0, 0, 0); // Start at midnight today
      
      const endDate = new Date(startDate);
      endDate.setDate(endDate.getDate() + 7); // 7 days from start

      const newComp = await CompetitionSettings.create({
        type: 'weekly',
        title: `Weekly Talent Show - ${startDate.toLocaleDateString()}`,
        description: 'Active weekly talent competition',
        startDate: startDate,
        endDate: endDate,
        periodId: `weekly-${startDate.getFullYear()}-${startDate.getMonth() + 1}-${startDate.getDate()}`,
        isActive: true,
        prizes: [
          { position: 1, coins: 1000, badge: 'Gold' },
          { position: 2, coins: 500, badge: 'Silver' },
          { position: 3, coins: 250, badge: 'Bronze' },
        ],
      });

      console.log('✅ Created new active competition:');
      console.log(`   Title: ${newComp.title}`);
      console.log(`   Start: ${newComp.startDate.toISOString()}`);
      console.log(`   End: ${newComp.endDate.toISOString()}`);
      console.log(`   Active: ${newComp.isActive}\n`);
    } else {
      console.log('\n✅ Active competition found:');
      console.log(`   Title: ${activeComp.title}`);
      console.log(`   Start: ${activeComp.startDate.toISOString()}`);
      console.log(`   End: ${activeComp.endDate.toISOString()}\n`);
    }

    await mongoose.connection.close();
    console.log('✅ Done');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
})();
