#!/usr/bin/env node
/**
 * Bulk notification sender with advanced targeting
 * Allows sending notifications to users based on complex criteria
 * 
 * Usage:
 *   node server/scripts/bulkNotification.js --config notification-config.json
 */

require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');
const path = require('path');
const AdminNotification = require('../models/AdminNotification');
const Notification = require('../models/Notification');
const User = require('../models/User');

// Parse command line arguments
const args = process.argv.slice(2);
const configFile = args.indexOf('--config') !== -1 ? args[args.indexOf('--config') + 1] : null;

if (!configFile) {
  console.error('❌ Error: --config is required');
  console.log('\nUsage:');
  console.log('  node server/scripts/bulkNotification.js --config notification-config.json');
  console.log('\nConfig file format:');
  console.log(`{
  "title": "Notification Title",
  "message": "Notification message",
  "imageUrl": "https://example.com/image.jpg",
  "actionType": "open_url",
  "actionData": "https://example.com",
  "targeting": {
    "type": "custom",
    "criteria": {
      "isVerified": true,
      "minBalance": 100,
      "maxBalance": 1000,
      "registeredAfter": "2024-01-01",
      "registeredBefore": "2024-12-31",
      "lastActiveAfter": "2024-11-01",
      "hasSubmittedSYT": true,
      "minFollowers": 10,
      "excludeUserIds": ["id1", "id2"]
    }
  }
}`);
  process.exit(1);
}

async function loadConfig() {
  try {
    const configPath = path.resolve(configFile);
    const configData = fs.readFileSync(configPath, 'utf8');
    return JSON.parse(configData);
  } catch (error) {
    console.error('❌ Error loading config file:', error.message);
    process.exit(1);
  }
}

async function buildUserQuery(criteria) {
  const query = { isActive: true };

  if (criteria.isVerified !== undefined) {
    query.isVerified = criteria.isVerified;
  }

  if (criteria.minBalance !== undefined) {
    query['wallet.balance'] = { ...query['wallet.balance'], $gte: criteria.minBalance };
  }

  if (criteria.maxBalance !== undefined) {
    query['wallet.balance'] = { ...query['wallet.balance'], $lte: criteria.maxBalance };
  }

  if (criteria.registeredAfter) {
    query.createdAt = { ...query.createdAt, $gte: new Date(criteria.registeredAfter) };
  }

  if (criteria.registeredBefore) {
    query.createdAt = { ...query.createdAt, $lte: new Date(criteria.registeredBefore) };
  }

  if (criteria.lastActiveAfter) {
    query.lastActive = { $gte: new Date(criteria.lastActiveAfter) };
  }

  if (criteria.minFollowers !== undefined) {
    query.followersCount = { $gte: criteria.minFollowers };
  }

  if (criteria.excludeUserIds && criteria.excludeUserIds.length > 0) {
    query._id = { $nin: criteria.excludeUserIds };
  }

  return query;
}

async function sendBulkNotification() {
  try {
    // Load configuration
    console.log('📄 Loading configuration...');
    const config = await loadConfig();
    console.log('✅ Configuration loaded\n');

    // Connect to MongoDB
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB\n');

    // Build query based on targeting criteria
    console.log('🎯 Building target query...');
    let targetUsers = [];
    
    if (config.targeting.type === 'all') {
      targetUsers = await User.find({ isActive: true }).select('_id username displayName');
    } else if (config.targeting.type === 'custom') {
      const query = await buildUserQuery(config.targeting.criteria);
      console.log('Query:', JSON.stringify(query, null, 2));
      targetUsers = await User.find(query).select('_id username displayName wallet.balance followersCount');
    }

    const totalRecipients = targetUsers.length;

    if (totalRecipients === 0) {
      console.error('❌ No users match the selected criteria');
      process.exit(1);
    }

    console.log(`✅ Found ${totalRecipients} recipients\n`);

    // Show sample of recipients
    if (totalRecipients <= 10) {
      console.log('📋 Recipients:');
      targetUsers.forEach(user => {
        console.log(`   - ${user.username} (${user.displayName})`);
      });
    } else {
      console.log('📋 Sample recipients (first 10):');
      targetUsers.slice(0, 10).forEach(user => {
        console.log(`   - ${user.username} (${user.displayName})`);
      });
      console.log(`   ... and ${totalRecipients - 10} more`);
    }
    console.log();

    // Confirm before sending
    if (process.env.REQUIRE_CONFIRMATION !== 'false') {
      console.log('⚠️  This will send notifications to', totalRecipients, 'users');
      console.log('   Set REQUIRE_CONFIRMATION=false in .env to skip this prompt');
      console.log('   Press Ctrl+C to cancel, or wait 5 seconds to continue...\n');
      await new Promise(resolve => setTimeout(resolve, 5000));
    }

    // Create admin notification record
    console.log('📝 Creating notification record...');
    const adminNotification = await AdminNotification.create({
      title: config.title,
      message: config.message,
      imageUrl: config.imageUrl,
      targetType: 'custom',
      targetUsers: targetUsers.map(u => u._id),
      actionType: config.actionType || 'none',
      actionData: config.actionData,
      status: 'sent',
      sentAt: new Date(),
      totalRecipients,
      createdBy: config.adminId || null,
    });

    console.log(`✅ Notification record created (ID: ${adminNotification._id})\n`);

    // Send notifications in batches
    console.log('📤 Sending notifications in batches...');
    let deliveredCount = 0;
    let failedCount = 0;
    const batchSize = 100;
    const totalBatches = Math.ceil(targetUsers.length / batchSize);

    for (let i = 0; i < targetUsers.length; i += batchSize) {
      const batch = targetUsers.slice(i, i + batchSize);
      const batchNumber = Math.floor(i / batchSize) + 1;
      
      const notifications = batch.map(user => ({
        user: user._id,
        type: 'admin_announcement',
        title: config.title,
        message: config.message,
        imageUrl: config.imageUrl,
        actionType: config.actionType || 'none',
        actionData: config.actionData,
        relatedAdmin: config.adminId || null,
      }));

      try {
        await Notification.insertMany(notifications, { ordered: false });
        deliveredCount += batch.length;
        console.log(`  ✓ Batch ${batchNumber}/${totalBatches}: ${batch.length} notifications sent`);
      } catch (error) {
        const successCount = batch.length - (error.writeErrors?.length || 0);
        deliveredCount += successCount;
        failedCount += (error.writeErrors?.length || 0);
        console.log(`  ⚠ Batch ${batchNumber}/${totalBatches}: ${successCount} sent, ${error.writeErrors?.length || 0} failed`);
      }

      // Small delay between batches to avoid overwhelming the database
      if (i + batchSize < targetUsers.length) {
        await new Promise(resolve => setTimeout(resolve, 100));
      }
    }

    // Update admin notification with delivery stats
    adminNotification.deliveredCount = deliveredCount;
    await adminNotification.save();

    console.log('\n✅ Bulk notification sending complete!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 Summary:`);
    console.log(`   Title: ${config.title}`);
    console.log(`   Message: ${config.message}`);
    console.log(`   Target: ${config.targeting.type}`);
    console.log(`   Total Recipients: ${totalRecipients}`);
    console.log(`   Delivered: ${deliveredCount}`);
    console.log(`   Failed: ${failedCount}`);
    console.log(`   Success Rate: ${((deliveredCount / totalRecipients) * 100).toFixed(2)}%`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    console.error(error.stack);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed');
    process.exit(0);
  }
}

// Run the script
sendBulkNotification();
