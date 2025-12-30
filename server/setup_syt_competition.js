#!/usr/bin/env node

/**
 * Quick setup script to create an active SYT competition
 * Run with: node setup_syt_competition.js (from server directory)
 */

require('dotenv').config({ path: './.env' });
const mongoose = require('mongoose');

async function setupCompetition() {
  try {
    console.log('🔍 Connecting to database...\n');
    
    await mongoose.connect(process.env.MONGODB_URI || 'mongodb://localhost:27017/showoff_db');
    
    console.log('✅ Connected!\n');

    const CompetitionSettings = require('./models/CompetitionSettings');
    const SYTEntry = require('./models/SYTEntry');

    // Check existing competitions
    const existingCompetitions = await CompetitionSettings.find();
    console.log('📋 Existing Competitions:');
    console.log(`Total: ${existingCompetitions.length}\n`);
    
    if (existingCompetitions.length > 0) {
      existingCompetitions.forEach((comp, index) => {
        const now = new Date();
        const isActive = comp.isActive && now >= comp.startDate && now <= comp.endDate;
        console.log(`${index + 1}. ${comp.title}`);
        console.log(`   Type: ${comp.type}`);
        console.log(`   Period: ${comp.periodId}`);
        console.log(`   Start: ${comp.startDate.toISOString()}`);
        console.log(`   End: ${comp.endDate.toISOString()}`);
        console.log(`   Active: ${comp.isActive ? '✅' : '❌'}`);
        console.log(`   Currently Active: ${isActive ? '✅ YES' : '❌ NO'}\n`);
      });
    }

    // Check for active competition
    const activeCompetition = await CompetitionSettings.findOne({
      isActive: true,
      startDate: { $lte: new Date() },
      endDate: { $gte: new Date() },
    });

    if (activeCompetition) {
      console.log('✅ Active competition already exists!\n');
      console.log(`Title: ${activeCompetition.title}`);
      console.log(`Type: ${activeCompetition.type}`);
      console.log(`Period: ${activeCompetition.periodId}\n`);
    } else {
      console.log('⚠️  No active competition found. Updating existing or creating new one...\n');

      // Try to update existing weekly competition with current dates
      const now = new Date();
      const startDate = new Date(now);
      startDate.setHours(0, 0, 0, 0);
      
      const endDate = new Date(now);
      endDate.setDate(endDate.getDate() + 7); // 7 days from now
      endDate.setHours(23, 59, 59, 999);

      const year = now.getFullYear();
      const week = Math.ceil((now - new Date(year, 0, 1)) / (7 * 24 * 60 * 60 * 1000));
      const periodId = `${year}-W${week.toString().padStart(2, '0')}`;

      // Try to update existing weekly competition
      let updatedCompetition = await CompetitionSettings.findOneAndUpdate(
        { type: 'weekly' },
        {
          title: `Weekly Talent Show - Week ${week}`,
          description: 'Show your talent to the world!',
          startDate,
          endDate,
          periodId,
          isActive: true,
          prizes: [
            { position: 1, coins: 1000, badge: 'Gold' },
            { position: 2, coins: 500, badge: 'Silver' },
            { position: 3, coins: 250, badge: 'Bronze' },
          ],
        },
        { new: true }
      );

      if (updatedCompetition) {
        console.log('✅ Existing competition updated successfully!\n');
        console.log(`Title: ${updatedCompetition.title}`);
        console.log(`Type: ${updatedCompetition.type}`);
        console.log(`Period: ${updatedCompetition.periodId}`);
        console.log(`Start: ${updatedCompetition.startDate.toISOString()}`);
        console.log(`End: ${updatedCompetition.endDate.toISOString()}\n`);
      } else {
        // Create new if update failed
        const newCompetition = await CompetitionSettings.create({
          type: 'weekly',
          title: `Weekly Talent Show - Week ${week}`,
          description: 'Show your talent to the world!',
          startDate,
          endDate,
          periodId,
          isActive: true,
          prizes: [
            { position: 1, coins: 1000, badge: 'Gold' },
            { position: 2, coins: 500, badge: 'Silver' },
            { position: 3, coins: 250, badge: 'Bronze' },
          ],
        });

        console.log('✅ New competition created successfully!\n');
        console.log(`Title: ${newCompetition.title}`);
        console.log(`Type: ${newCompetition.type}`);
        console.log(`Period: ${newCompetition.periodId}`);
        console.log(`Start: ${newCompetition.startDate.toISOString()}`);
        console.log(`End: ${newCompetition.endDate.toISOString()}\n`);
      }
    }

    // Check entries
    const entries = await SYTEntry.find().lean(); // Use lean() to avoid model registration issues
    console.log('📹 SYT Entries:');
    console.log(`Total: ${entries.length}\n`);
    
    if (entries.length > 0) {
      entries.forEach((entry, index) => {
        console.log(`${index + 1}. ${entry.title}`);
        console.log(`   User ID: ${entry.user}`);
        console.log(`   Category: ${entry.category}`);
        console.log(`   Type: ${entry.competitionType}`);
        console.log(`   Period: ${entry.competitionPeriod}`);
        console.log(`   Approved: ${entry.isApproved ? '✅' : '❌'}`);
        console.log(`   Active: ${entry.isActive ? '✅' : '❌'}\n`);
      });

      // Check for period mismatch
      const activeComp = await CompetitionSettings.findOne({
        isActive: true,
        startDate: { $lte: new Date() },
        endDate: { $gte: new Date() },
      });

      if (activeComp) {
        const mismatchedEntries = entries.filter(
          e => e.competitionType === activeComp.type && e.competitionPeriod !== activeComp.periodId
        );

        if (mismatchedEntries.length > 0) {
          console.log(`⚠️  Found ${mismatchedEntries.length} entries with period mismatch!\n`);
          console.log('These entries won\'t show up because their period doesn\'t match the active competition.\n');
          console.log('To fix this, you can:\n');
          console.log('1. Update entries to match active competition period:');
          console.log(`   db.sytentries.updateMany({competitionPeriod: {$ne: "${activeComp.periodId}"}}, {$set: {competitionPeriod: "${activeComp.periodId}"}})\n`);
          console.log('2. Or create a new competition matching the entries\' period\n');
        }
      }
    }

    console.log('✅ Setup complete!\n');
    console.log('Next steps:');
    console.log('1. If no active competition exists, one has been created');
    console.log('2. If entries don\'t show up, check for period mismatches above');
    console.log('3. Try uploading a new SYT entry now\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  }
}

setupCompetition();
