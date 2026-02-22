/**
 * Script to manage SYT competitions - end current and create new
 * Usage: node manage_syt_competition.js
 */

require('dotenv').config({ path: 'server/.env' });
const mongoose = require('mongoose');
const CompetitionSettings = require('./server/models/CompetitionSettings');

const manageCompetitions = async () => {
  try {
    console.log('🔗 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGODB_URI);
    console.log('✅ Connected!\n');

    // Get current active weekly competition
    const now = new Date();
    const currentComp = await CompetitionSettings.findOne({
      type: 'weekly',
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now },
    });

    if (currentComp) {
      console.log('📋 Current Active Weekly Competition:');
      console.log(`   Title: ${currentComp.title}`);
      console.log(`   Start: ${currentComp.startDate.toISOString()}`);
      console.log(`   End: ${currentComp.endDate.toISOString()}`);
      console.log(`   Status: Active\n`);

      // Option 1: End the current competition
      console.log('🔄 Option 1: End current competition and create new one');
      console.log('   This will set the current competition end date to now\n');

      // End current competition
      const endTime = new Date();
      await CompetitionSettings.findByIdAndUpdate(currentComp._id, {
        endDate: endTime,
        isActive: false,
      });
      console.log('✅ Current competition ended\n');

      // Create new competition
      const newStart = new Date(endTime.getTime() + 1000); // 1 second after current ends
      const newEnd = new Date(newStart.getTime() + 7 * 24 * 60 * 60 * 1000); // 7 days later

      const newComp = await CompetitionSettings.create({
        type: 'weekly',
        title: `Weekly Talent Show - ${newStart.toLocaleDateString()}`,
        description: 'New weekly talent competition',
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

      console.log('✅ New competition created:');
      console.log(`   Title: ${newComp.title}`);
      console.log(`   Start: ${newComp.startDate.toISOString()}`);
      console.log(`   End: ${newComp.endDate.toISOString()}`);
      console.log(`   Status: Active\n`);
    } else {
      console.log('⚠️  No active weekly competition found\n');
      console.log('📋 All weekly competitions:');
      const allWeekly = await CompetitionSettings.find({ type: 'weekly' }).sort({ startDate: -1 });
      allWeekly.forEach((comp, idx) => {
        console.log(`\n   ${idx + 1}. ${comp.title}`);
        console.log(`      Start: ${comp.startDate.toISOString()}`);
        console.log(`      End: ${comp.endDate.toISOString()}`);
        console.log(`      Active: ${comp.isActive}`);
      });
    }

    await mongoose.connection.close();
    console.log('\n✅ Done!');
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
};

manageCompetitions();
