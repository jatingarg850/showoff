// Automatic fix script for SYT entries not showing
// Run with: node auto_fix_syt.js

require('dotenv').config({ path: './server/.env' });
const mongoose = require('mongoose');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

function question(query) {
  return new Promise(resolve => rl.question(query, resolve));
}

async function autoFix() {
  try {
    console.log('🔧 SYT Auto-Fix Tool\n');
    console.log('This script will:');
    console.log('1. Check for active competitions');
    console.log('2. Create a competition if none exists');
    console.log('3. Fix entry period IDs to match active competition');
    console.log('4. Approve and activate all entries\n');

    const proceed = await question('Do you want to proceed? (yes/no): ');
    if (proceed.toLowerCase() !== 'yes') {
      console.log('Cancelled.');
      process.exit(0);
    }

    console.log('\n🔍 Connecting to database...');
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff_db');
    console.log('✅ Connected!\n');

    const CompetitionSettings = require('./server/models/CompetitionSettings');
    const SYTEntry = require('./server/models/SYTEntry');

    // Step 1: Check for active competition
    console.log('📋 Step 1: Checking for active competitions...');
    const now = new Date();
    let activeCompetition = await CompetitionSettings.findOne({
      type: 'weekly',
      isActive: true,
      startDate: { $lte: now },
      endDate: { $gte: now }
    });

    if (!activeCompetition) {
      console.log('❌ No active weekly competition found!');
      
      const create = await question('\nCreate a new weekly competition? (yes/no): ');
      if (create.toLowerCase() === 'yes') {
        console.log('\n📝 Creating competition...');
        
        const startDate = new Date();
        const endDate = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000);
        const periodId = `weekly-${startDate.getFullYear()}-${startDate.getMonth() + 1}-${startDate.getDate()}`;

        activeCompetition = await CompetitionSettings.create({
          type: 'weekly',
          title: 'Weekly Talent Show',
          description: 'Show off your talent to the world!',
          startDate,
          endDate,
          periodId,
          isActive: true,
          prizes: [
            { position: 1, coins: 1000, badge: 'Gold' },
            { position: 2, coins: 500, badge: 'Silver' },
            { position: 3, coins: 250, badge: 'Bronze' }
          ]
        });

        console.log('✅ Competition created!');
        console.log('   Title:', activeCompetition.title);
        console.log('   Period ID:', activeCompetition.periodId);
        console.log('   Start:', activeCompetition.startDate.toISOString());
        console.log('   End:', activeCompetition.endDate.toISOString());
      } else {
        console.log('\n⚠️  Cannot proceed without an active competition.');
        console.log('Please create one via admin panel or run this script again.');
        process.exit(0);
      }
    } else {
      console.log('✅ Active competition found!');
      console.log('   Title:', activeCompetition.title);
      console.log('   Period ID:', activeCompetition.periodId);
    }

    // Step 2: Check entries
    console.log('\n📹 Step 2: Checking SYT entries...');
    const entries = await SYTEntry.find({ competitionType: 'weekly' });
    console.log(`Found ${entries.length} weekly entries`);

    if (entries.length === 0) {
      console.log('\n⚠️  No entries found. Upload a reel from the Flutter app first.');
      process.exit(0);
    }

    // Step 3: Fix entries
    console.log('\n🔧 Step 3: Fixing entries...');
    
    const updates = {
      periodUpdates: 0,
      approvalUpdates: 0,
      activeUpdates: 0
    };

    for (const entry of entries) {
      let needsUpdate = false;
      const updateFields = {};

      if (entry.competitionPeriod !== activeCompetition.periodId) {
        updateFields.competitionPeriod = activeCompetition.periodId;
        updates.periodUpdates++;
        needsUpdate = true;
      }

      if (!entry.isApproved) {
        updateFields.isApproved = true;
        updates.approvalUpdates++;
        needsUpdate = true;
      }

      if (!entry.isActive) {
        updateFields.isActive = true;
        updates.activeUpdates++;
        needsUpdate = true;
      }

      if (needsUpdate) {
        await SYTEntry.updateOne({ _id: entry._id }, { $set: updateFields });
      }
    }

    console.log('✅ Entries fixed!');
    console.log(`   Period IDs updated: ${updates.periodUpdates}`);
    console.log(`   Entries approved: ${updates.approvalUpdates}`);
    console.log(`   Entries activated: ${updates.activeUpdates}`);

    // Step 4: Verify
    console.log('\n✅ Step 4: Verifying fix...');
    const matchingEntries = await SYTEntry.find({
      competitionType: 'weekly',
      competitionPeriod: activeCompetition.periodId,
      isActive: true,
      isApproved: true
    }).populate('user', 'username');

    console.log(`\n🎉 SUCCESS! ${matchingEntries.length} entries are now properly configured!`);
    
    if (matchingEntries.length > 0) {
      console.log('\nSample entries:');
      matchingEntries.slice(0, 3).forEach((entry, i) => {
        console.log(`${i + 1}. "${entry.title}" by @${entry.user?.username || 'unknown'}`);
      });
    }

    console.log('\n📱 Next steps:');
    console.log('1. Restart your Flutter app');
    console.log('2. Navigate to Talent screen');
    console.log('3. Entries should now be visible!');
    console.log('\n💡 Test the API: node test_syt_entries.js');

  } catch (error) {
    console.error('\n❌ Error:', error.message);
    console.error(error.stack);
  } finally {
    rl.close();
    await mongoose.disconnect();
    process.exit(0);
  }
}

autoFix();
