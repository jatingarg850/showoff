#!/usr/bin/env node
/**
 * Server-side notification sender
 * Allows admins to send custom notifications directly from the server
 * 
 * Usage:
 *   node server/scripts/sendNotification.js --title "Title" --message "Message" --target all
 *   node server/scripts/sendNotification.js --title "Title" --message "Message" --target verified
 *   node server/scripts/sendNotification.js --title "Title" --message "Message" --target active
 *   node server/scripts/sendNotification.js --title "Title" --message "Message" --target userIds --ids "id1,id2,id3"
 */

require('dotenv').config();
const mongoose = require('mongoose');
const AdminNotification = require('../models/AdminNotification');
const Notification = require('../models/Notification');
const User = require('../models/User');

// Parse command line arguments
const args = process.argv.slice(2);
const getArg = (flag) => {
  const index = args.indexOf(flag);
  return index !== -1 ? args[index + 1] : null;
};

const title = getArg('--title');
const message = getArg('--message');
const targetType = getArg('--target') || 'all';
const userIds = getArg('--ids');
const imageUrl = getArg('--image');
const actionType = getArg('--action') || 'none';
const actionData = getArg('--actionData');
const adminId = getArg('--adminId');

// Validation
if (!title || !message) {
  console.error('❌ Error: --title and --message are required');
  console.log('\nUsage:');
  console.log('  node server/scripts/sendNotification.js --title "Title" --message "Message" --target all');
  console.log('\nOptions:');
  console.log('  --title         Notification title (required)');
  console.log('  --message       Notification message (required)');
  console.log('  --target        Target type: all, selected, verified, active, new (default: all)');
  console.log('  --ids           Comma-separated user IDs (required if target is "selected")');
  console.log('  --image         Image URL (optional)');
  console.log('  --action        Action type: none, open_url, open_screen, open_post (default: none)');
  console.log('  --actionData    Action data (URL, screen name, or post ID)');
  console.log('  --adminId       Admin user ID (optional)');
  process.exit(1);
}

if (targetType === 'selected' && !userIds) {
  console.error('❌ Error: --ids is required when target is "selected"');
  process.exit(1);
}

async function sendNotification() {
  try {
    // Connect to MongoDB
    console.log('🔌 Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB\n');

    // Get target users based on type
    let targetUsers = [];
    let query = { isActive: true };

    console.log(`🎯 Target Type: ${targetType}`);

    if (targetType === 'all') {
      targetUsers = await User.find(query).select('_id username displayName');
    } else if (targetType === 'selected') {
      const idArray = userIds.split(',').map(id => id.trim());
      targetUsers = await User.find({ 
        _id: { $in: idArray }, 
        ...query 
      }).select('_id username displayName');
    } else if (targetType === 'verified') {
      targetUsers = await User.find({ 
        isVerified: true, 
        ...query 
      }).select('_id username displayName');
    } else if (targetType === 'active') {
      const sevenDaysAgo = new Date(Date.now() - 7 * 24 * 60 * 60 * 1000);
      targetUsers = await User.find({ 
        lastActive: { $gte: sevenDaysAgo },
        ...query 
      }).select('_id username displayName');
    } else if (targetType === 'new') {
      const thirtyDaysAgo = new Date(Date.now() - 30 * 24 * 60 * 60 * 1000);
      targetUsers = await User.find({ 
        createdAt: { $gte: thirtyDaysAgo },
        ...query 
      }).select('_id username displayName');
    } else {
      console.error(`❌ Invalid target type: ${targetType}`);
      process.exit(1);
    }

    const totalRecipients = targetUsers.length;

    if (totalRecipients === 0) {
      console.error('❌ No users match the selected criteria');
      process.exit(1);
    }

    console.log(`📊 Found ${totalRecipients} recipients\n`);

    // Create admin notification record
    console.log('📝 Creating notification record...');
    const adminNotification = await AdminNotification.create({
      title,
      message,
      imageUrl,
      targetType,
      targetUsers: targetType === 'selected' ? targetUsers.map(u => u._id) : [],
      actionType,
      actionData,
      status: 'sent',
      sentAt: new Date(),
      totalRecipients,
      createdBy: adminId || null,
    });

    console.log(`✅ Notification record created (ID: ${adminNotification._id})\n`);

    // Send notifications
    console.log('📤 Sending notifications...');
    let deliveredCount = 0;
    let failedCount = 0;

    // Process in batches of 100 for better performance
    const batchSize = 100;
    for (let i = 0; i < targetUsers.length; i += batchSize) {
      const batch = targetUsers.slice(i, i + batchSize);
      const notifications = batch.map(user => ({
        user: user._id,
        type: 'admin_announcement',
        title,
        message,
        imageUrl,
        actionType,
        actionData,
        relatedAdmin: adminId || null,
      }));

      try {
        await Notification.insertMany(notifications, { ordered: false });
        deliveredCount += batch.length;
        console.log(`  ✓ Batch ${Math.floor(i / batchSize) + 1}: ${batch.length} notifications sent`);
      } catch (error) {
        // Some might fail, count successful ones
        const successCount = batch.length - (error.writeErrors?.length || 0);
        deliveredCount += successCount;
        failedCount += (error.writeErrors?.length || 0);
        console.log(`  ⚠ Batch ${Math.floor(i / batchSize) + 1}: ${successCount} sent, ${error.writeErrors?.length || 0} failed`);
      }
    }

    // Update admin notification with delivery stats
    adminNotification.deliveredCount = deliveredCount;
    await adminNotification.save();

    console.log('\n✅ Notification sending complete!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`📊 Summary:`);
    console.log(`   Title: ${title}`);
    console.log(`   Message: ${message}`);
    console.log(`   Target: ${targetType}`);
    console.log(`   Total Recipients: ${totalRecipients}`);
    console.log(`   Delivered: ${deliveredCount}`);
    console.log(`   Failed: ${failedCount}`);
    console.log(`   Success Rate: ${((deliveredCount / totalRecipients) * 100).toFixed(2)}%`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    process.exit(1);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed');
    process.exit(0);
  }
}

// Run the script
sendNotification();
