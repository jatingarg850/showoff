/**
 * Comprehensive notification system diagnostic
 */

require('dotenv').config({ path: './server/.env' });
const mongoose = require('mongoose');

async function diagnose() {
  try {
    console.log('🔍 Notification System Diagnostic\n');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Connect to MongoDB
    console.log('1️⃣ Connecting to MongoDB...');
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB\n');

    const Notification = require('./server/models/Notification');
    const User = require('./server/models/User');
    const AdminNotification = require('./server/models/AdminNotification');

    // Check Notification model schema
    console.log('2️⃣ Checking Notification Model Schema...');
    const schema = Notification.schema.obj;
    console.log('   Fields:', Object.keys(schema));
    console.log('   Type enum:', schema.type?.enum || 'Not found');
    console.log('   Has "user" field:', !!schema.user);
    console.log('   Has "recipient" field:', !!schema.recipient);
    console.log('   Has "sender" field:', !!schema.sender);
    console.log();

    // Check if admin_announcement is in enum
    const hasAdminAnnouncement = schema.type?.enum?.includes('admin_announcement');
    console.log(`   ❌ PROBLEM: "admin_announcement" ${hasAdminAnnouncement ? 'IS' : 'IS NOT'} in type enum`);
    console.log();

    // Check users
    console.log('3️⃣ Checking Users...');
    const totalUsers = await User.countDocuments();
    const activeUsers = await User.countDocuments({ isActive: true });
    console.log(`   Total users: ${totalUsers}`);
    console.log(`   Active users: ${activeUsers}`);
    
    if (activeUsers > 0) {
      const sampleUser = await User.findOne({ isActive: true }).select('_id username');
      console.log(`   Sample user: ${sampleUser.username} (${sampleUser._id})`);
    }
    console.log();

    // Check recent notifications
    console.log('4️⃣ Checking Recent Notifications...');
    const recentNotifications = await Notification.find()
      .sort({ createdAt: -1 })
      .limit(5)
      .select('type title message recipient user createdAt');
    
    console.log(`   Total notifications: ${await Notification.countDocuments()}`);
    console.log(`   Recent notifications (last 5):`);
    
    if (recentNotifications.length === 0) {
      console.log('   ❌ No notifications found in database');
    } else {
      recentNotifications.forEach((notif, index) => {
        console.log(`   ${index + 1}. Type: ${notif.type}, Title: ${notif.title}`);
        console.log(`      Recipient: ${notif.recipient || 'N/A'}, User: ${notif.user || 'N/A'}`);
        console.log(`      Created: ${notif.createdAt}`);
      });
    }
    console.log();

    // Check admin notifications
    console.log('5️⃣ Checking Admin Notifications...');
    const adminNotifs = await AdminNotification.find()
      .sort({ createdAt: -1 })
      .limit(3)
      .select('title status totalRecipients deliveredCount createdAt');
    
    console.log(`   Total admin notifications: ${await AdminNotification.countDocuments()}`);
    if (adminNotifs.length > 0) {
      console.log(`   Recent admin notifications:`);
      adminNotifs.forEach((notif, index) => {
        console.log(`   ${index + 1}. ${notif.title}`);
        console.log(`      Status: ${notif.status}, Delivered: ${notif.deliveredCount}/${notif.totalRecipients}`);
        console.log(`      Created: ${notif.createdAt}`);
      });
    } else {
      console.log('   No admin notifications found');
    }
    console.log();

    // Check WebSocket setup
    console.log('6️⃣ Checking Server Configuration...');
    console.log(`   MongoDB URI: ${process.env.MONGO_URI ? '✅ Set' : '❌ Not set'}`);
    console.log(`   JWT Secret: ${process.env.JWT_SECRET ? '✅ Set' : '❌ Not set'}`);
    console.log(`   Port: ${process.env.PORT || 3000}`);
    console.log();

    // Summary of problems
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('🐛 PROBLEMS FOUND:\n');
    
    let problemCount = 0;

    if (!hasAdminAnnouncement) {
      problemCount++;
      console.log(`${problemCount}. ❌ Notification model missing "admin_announcement" in type enum`);
      console.log('   Fix: Update server/models/Notification.js to include "admin_announcement"');
    }

    if (schema.recipient && !schema.user) {
      problemCount++;
      console.log(`${problemCount}. ❌ Notification model uses "recipient" but controller uses "user"`);
      console.log('   Fix: Controller should use "recipient" instead of "user"');
    }

    if (!schema.sender) {
      problemCount++;
      console.log(`${problemCount}. ⚠️  Notification model requires "sender" field`);
      console.log('   Fix: Admin notifications need a sender (can be null or admin user)');
    }

    if (activeUsers === 0) {
      problemCount++;
      console.log(`${problemCount}. ❌ No active users in database`);
      console.log('   Fix: Create test users or activate existing users');
    }

    if (problemCount === 0) {
      console.log('✅ No problems found!');
    }

    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  } catch (error) {
    console.error('❌ Diagnostic failed:', error.message);
    console.error(error.stack);
  } finally {
    await mongoose.connection.close();
    console.log('🔌 MongoDB connection closed');
    process.exit(0);
  }
}

diagnose();
