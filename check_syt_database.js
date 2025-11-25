// Quick script to check SYT database status
// Run with: node check_syt_database.js

require('dotenv').config({ path: './server/.env' });
const mongoose = require('mongoose');

async function checkDatabase() {
  try {
    console.log('🔍 Connecting to database...\n');
    
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff_db');
    
    console.log('✅ Connected!\n');

    // Check CompetitionSettings
    const CompetitionSettings = require('./server/models/CompetitionSettings');
    const competitions = await CompetitionSettings.find();
    
    console.log('📋 COMPETITIONS:');
    console.log('Total:', competitions.length);
    
    if (competitions.length > 0) {
      competitions.forEach((comp, index) => {
        const now = new Date();
        const isActive = comp.isActive && now >= comp.startDate && now <= comp.endDate;
        console.log(`\n${index + 1}. ${comp.title}`);
        console.log('   Type:', comp.type);
        console.log('   Period ID:', comp.periodId);
        console.log('   Start:', comp.startDate.toISOString());
        console.log('   End:', comp.endDate.toISOString());
        console.log('   Is Active:', comp.isActive);
        console.log('   Currently Active:', isActive ? '✅ YES' : '❌ NO');
      });
    } else {
      console.log('⚠️  No competitions found!');
      console.log('\n💡 Solution: Create a competition via admin panel');
      console.log('   1. Go to http://localhost:5000/admin/login');
      console.log('   2. Navigate to Talent/SYT section');
      console.log('   3. Click "Create Competition"');
    }

    // Check SYTEntries
    const SYTEntry = require('./server/models/SYTEntry');
    const entries = await SYTEntry.find().populate('user', 'username');
    
    console.log('\n\n📹 SYT ENTRIES:');
    console.log('Total:', entries.length);
    
    if (entries.length > 0) {
      entries.forEach((entry, index) => {
        console.log(`\n${index + 1}. ${entry.title}`);
        console.log('   User:', entry.user?.username || 'Unknown');
        console.log('   Type:', entry.competitionType);
        console.log('   Period:', entry.competitionPeriod);
        console.log('   Active:', entry.isActive);
        console.log('   Approved:', entry.isApproved);
        console.log('   Votes:', entry.votesCount);
        console.log('   Likes:', entry.likesCount);
      });

      // Check for mismatches
      console.log('\n\n🔍 CHECKING FOR ISSUES:');
      
      const activeCompetitions = competitions.filter(c => {
        const now = new Date();
        return c.isActive && now >= c.startDate && now <= c.endDate;
      });

      if (activeCompetitions.length === 0) {
        console.log('❌ No active competitions found!');
        console.log('   Entries exist but no competition is active.');
        console.log('   Solution: Create or activate a competition.');
      } else {
        const activePeriodIds = activeCompetitions.map(c => c.periodId);
        console.log('✅ Active competition period IDs:', activePeriodIds.join(', '));
        
        const matchingEntries = entries.filter(e => 
          activePeriodIds.includes(e.competitionPeriod) && e.isActive && e.isApproved
        );
        
        console.log(`✅ Entries matching active competitions: ${matchingEntries.length}`);
        
        if (matchingEntries.length === 0 && entries.length > 0) {
          console.log('\n⚠️  MISMATCH DETECTED!');
          console.log('   Entries exist but their competitionPeriod doesn\'t match active competitions.');
          console.log('\n   Entry periods:', [...new Set(entries.map(e => e.competitionPeriod))].join(', '));
          console.log('   Active periods:', activePeriodIds.join(', '));
          console.log('\n   Solution: Update entries to match active competition:');
          console.log(`   db.sytentries.updateMany({}, { $set: { competitionPeriod: "${activePeriodIds[0]}" } })`);
        }

        const unapprovedEntries = entries.filter(e => !e.isApproved);
        if (unapprovedEntries.length > 0) {
          console.log(`\n⚠️  ${unapprovedEntries.length} entries are not approved!`);
          console.log('   Solution: Approve them:');
          console.log('   db.sytentries.updateMany({ isApproved: false }, { $set: { isApproved: true } })');
        }

        const inactiveEntries = entries.filter(e => !e.isActive);
        if (inactiveEntries.length > 0) {
          console.log(`\n⚠️  ${inactiveEntries.length} entries are not active!`);
          console.log('   Solution: Activate them:');
          console.log('   db.sytentries.updateMany({ isActive: false }, { $set: { isActive: true } })');
        }
      }
    } else {
      console.log('⚠️  No entries found!');
      console.log('\n💡 This means no SYT reels have been uploaded yet.');
      console.log('   Try uploading a reel from the Flutter app.');
    }

    console.log('\n\n✅ Database check complete!');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  } finally {
    await mongoose.disconnect();
    process.exit(0);
  }
}

checkDatabase();
