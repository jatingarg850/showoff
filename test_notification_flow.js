/**
 * Test notification flow from admin to user
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testNotificationFlow() {
  console.log('🧪 Testing Notification Flow\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  try {
    // Step 1: Check server health
    console.log('1️⃣ Checking server health...');
    const health = await axios.get(`${BASE_URL}/health`);
    console.log('✅ Server is running');
    console.log(`   WebSocket connections: ${health.data.websocket.activeConnections}\n`);

    // Step 2: Preview recipient count
    console.log('2️⃣ Previewing recipient count...');
    const preview = await axios.post(`${BASE_URL}/api/notifications/admin-web/preview-count`, {
      targetType: 'all'
    });
    console.log(`✅ Found ${preview.data.data.recipientCount} potential recipients\n`);

    if (preview.data.data.recipientCount === 0) {
      console.log('⚠️  No users found. Make sure you have users in the database.');
      return;
    }

    // Step 3: Send test notification
    console.log('3️⃣ Sending test notification...');
    console.log('   Title: 🧪 Test Notification');
    console.log('   Message: This is a test from the admin notification system');
    console.log('   Target: All users\n');

    const sendResult = await axios.post(`${BASE_URL}/api/notifications/admin-web/send`, {
      title: '🧪 Test Notification',
      message: 'This is a test from the admin notification system. If you see this, it works!',
      targetType: 'all',
      actionType: 'none'
    });

    if (sendResult.data.success) {
      console.log('✅ Notification sent successfully!');
      console.log(`   Notification ID: ${sendResult.data.data.notificationId}`);
      console.log(`   Total Recipients: ${sendResult.data.data.totalRecipients}`);
      console.log(`   Delivered: ${sendResult.data.data.deliveredCount}\n`);
    }

    // Step 4: Wait a moment for WebSocket delivery
    console.log('4️⃣ Waiting for WebSocket delivery...');
    await new Promise(resolve => setTimeout(resolve, 2000));
    console.log('✅ WebSocket delivery should be complete\n');

    // Step 5: Check notification in database
    console.log('5️⃣ Verifying notification in database...');
    const listResult = await axios.get(`${BASE_URL}/api/notifications/admin-web/list?limit=1`);
    
    if (listResult.data.data.length > 0) {
      const latestNotif = listResult.data.data[0];
      console.log('✅ Notification found in database:');
      console.log(`   Title: ${latestNotif.title}`);
      console.log(`   Status: ${latestNotif.status}`);
      console.log(`   Delivered: ${latestNotif.deliveredCount}/${latestNotif.totalRecipients}`);
      console.log(`   Created: ${new Date(latestNotif.createdAt).toLocaleString()}\n`);
    }

    // Summary
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ Test Complete!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
    console.log('📱 Check your Flutter app now!');
    console.log('   You should see a notification appear.\n');
    console.log('🔍 If you don\'t see it:');
    console.log('   1. Check Flutter console for WebSocket connection');
    console.log('   2. Make sure you\'re logged in with the same user');
    console.log('   3. Check server logs for WebSocket delivery');
    console.log('   4. Verify notification permissions are enabled\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    }
    console.log('\n⚠️  Make sure:');
    console.log('   1. Server is running (npm start)');
    console.log('   2. MongoDB is connected');
    console.log('   3. You are logged in as admin in browser');
  }
}

// Run test
testNotificationFlow();
