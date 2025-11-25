/**
 * Test script for admin notification system
 * Tests both API endpoints and CLI scripts
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function testNotificationSystem() {
  console.log('🧪 Testing Admin Notification System\n');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  try {
    // Test 1: Preview recipient count for "all users"
    console.log('📊 Test 1: Preview Recipient Count (All Users)');
    const previewAll = await axios.post(`${BASE_URL}/api/notifications/admin-web/preview-count`, {
      targetType: 'all'
    });
    console.log('✅ Result:', previewAll.data);
    console.log(`   Recipients: ${previewAll.data.data.recipientCount}\n`);

    // Test 2: Preview recipient count for "verified users"
    console.log('📊 Test 2: Preview Recipient Count (Verified Users)');
    const previewVerified = await axios.post(`${BASE_URL}/api/notifications/admin-web/preview-count`, {
      targetType: 'verified'
    });
    console.log('✅ Result:', previewVerified.data);
    console.log(`   Recipients: ${previewVerified.data.data.recipientCount}\n`);

    // Test 3: Preview recipient count for "active users"
    console.log('📊 Test 3: Preview Recipient Count (Active Users)');
    const previewActive = await axios.post(`${BASE_URL}/api/notifications/admin-web/preview-count`, {
      targetType: 'active'
    });
    console.log('✅ Result:', previewActive.data);
    console.log(`   Recipients: ${previewActive.data.data.recipientCount}\n`);

    // Test 4: Preview recipient count with custom criteria
    console.log('📊 Test 4: Preview Recipient Count (Custom Criteria)');
    const previewCustom = await axios.post(`${BASE_URL}/api/notifications/admin-web/preview-count`, {
      targetType: 'custom',
      customCriteria: {
        isVerified: true,
        minBalance: 0,
        maxBalance: 1000
      }
    });
    console.log('✅ Result:', previewCustom.data);
    console.log(`   Recipients: ${previewCustom.data.data.recipientCount}\n`);

    // Test 5: Send test notification (commented out to avoid spam)
    console.log('📤 Test 5: Send Test Notification');
    console.log('⚠️  Skipped (uncomment to test actual sending)');
    console.log('   To test sending, uncomment the code below\n');
    
    /*
    const sendResult = await axios.post(`${BASE_URL}/api/notifications/admin-web/send`, {
      title: '🧪 Test Notification',
      message: 'This is a test notification from the admin system',
      targetType: 'verified',
      actionType: 'none'
    });
    console.log('✅ Result:', sendResult.data);
    */

    // Test 6: Get notification list
    console.log('📋 Test 6: Get Notification List');
    const listResult = await axios.get(`${BASE_URL}/api/notifications/admin-web/list?limit=5`);
    console.log('✅ Result:', {
      success: listResult.data.success,
      count: listResult.data.data.length,
      pagination: listResult.data.pagination
    });
    
    if (listResult.data.data.length > 0) {
      console.log('   Recent notifications:');
      listResult.data.data.slice(0, 3).forEach((notif, index) => {
        console.log(`   ${index + 1}. ${notif.title} - ${notif.status} (${notif.totalRecipients} recipients)`);
      });
    }
    console.log();

    // Summary
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ All tests completed successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // CLI Script Examples
    console.log('📝 CLI Script Examples:\n');
    console.log('1. Send to all users:');
    console.log('   node server/scripts/sendNotification.js --title "Hello" --message "Welcome" --target all\n');
    
    console.log('2. Send to verified users:');
    console.log('   node server/scripts/sendNotification.js --title "Update" --message "New features" --target verified\n');
    
    console.log('3. Send with custom criteria:');
    console.log('   node server/scripts/bulkNotification.js --config notification-config.example.json\n');

    console.log('4. Access web admin panel:');
    console.log('   http://localhost:3000/admin/notifications\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    }
    console.log('\n⚠️  Make sure:');
    console.log('   1. Server is running (npm start)');
    console.log('   2. MongoDB is connected');
    console.log('   3. You are logged in as admin');
  }
}

// Run tests
testNotificationSystem();
