#!/usr/bin/env node

/**
 * Fix SYT entry period mismatches
 * Run with: node fix_syt_period_mismatch.js (from server directory)
 */

require('dotenv').config({ path: './.env' });
const mongoose = require('mongoose');

async function fixPeriodMismatch() {
  try {
    console.log('🔍 Connecting to database...\n');
    
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff_db');
    
    console.log('✅ Connected!\n');

    const CompetitionSettings = require('./models/CompetitionSettings');
    const SYTEntry = require('./models/SYTEntry');

    // Get active competition
    const activeCompetition = await CompetitionSettings.findOne({
      isActive: true,
      startDate: { $lte: new Date() },
      endDate: { $gte: new Date() },
    });

    if (!activeCompetition) {
      console.log('❌ No active competition found!');
      console.log('Run setup_syt_competition.js first\n');
      process.exit(1);
    }

    console.log('📋 Active Competition:');
    console.log(`Title: ${activeCompetition.title}`);
    console.log(`Type: ${activeCompetition.type}`);
    console.log(`Period: ${activeCompetition.periodId}\n`);

    // Find mismatched entries
    const mismatchedEntries = await SYTEntry.find({
      competitionType: activeCompetition.type,
      competitionPeriod: { $ne: activeCompetition.periodId },
    });

    console.log(`📹 Found ${mismatchedEntries.length} entries with period mismatch\n`);

    if (mismatchedEntries.length > 0) {
      console.log('Entries to be updated:');
      mismatchedEntries.forEach((entry, index) => {
        console.log(`${index + 1}. ${entry.title}`);
        console.log(`   Current Period: ${entry.competitionPeriod}`);
        console.log(`   New Period: ${activeCompetition.periodId}\n`);
      });

      // Update entries
      console.log('🔄 Updating entries...\n');
      const result = await SYTEntry.updateMany(
        {
          competitionType: activeCompetition.type,
          competitionPeriod: { $ne: activeCompetition.periodId },
        },
        {
          $set: { competitionPeriod: activeCompetition.periodId },
        }
      );

      console.log(`✅ Updated ${result.modifiedCount} entries\n`);

      // Verify
      const verifyEntries = await SYTEntry.find({
        competitionType: activeCompetition.type,
        competitionPeriod: activeCompetition.periodId,
      });

      console.log(`📹 Verified: ${verifyEntries.length} entries now have correct period\n`);

      console.log('✅ Period mismatch fixed!\n');
      console.log('Next steps:');
      console.log('1. Refresh admin panel');
      console.log('2. You should now see all entries');
      console.log('3. Try uploading a new entry\n');
    } else {
      console.log('✅ No period mismatches found!\n');
      console.log('All entries are already using the correct period.\n');
    }

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

fixPeriodMismatch();
