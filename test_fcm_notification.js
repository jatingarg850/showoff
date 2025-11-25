/**
 * Quick FCM Notification Test
 * Send a test notification to check if FCM is working
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

async function sendTestNotification() {
  console.log('📱 Testing FCM Notification System\n');

  try {
    // First, login as admin or get your auth token
    console.log('⚠️  You need to be logged in as admin');
    console.log('   Option 1: Use the admin web panel at http://localhost:3000/admin/notifications');
    console.log('   Option 2: Get your auth token and add it below\n');

    // If you have an auth token, uncomment and use this:
    /*
    const AUTH_TOKEN = 'your-auth-token-here';
    
    const result = await axios.post(
      `${BASE_URL}/api/notifications/admin-web/send`,
      {
        title: '🎉 Test Notification',
        message: 'Testing FCM push notifications!',
        targetType: 'all',
        actionType: 'none'
      },
      {
        headers: {
          'Authorization': `Bearer ${AUTH_TOKEN}`
        }
      }
    );

    console.log('✅ Notification sent!');
    console.log('   Recipients:', result.data.data.totalRecipients);
    console.log('   WebSocket:', result.data.data.websocketSent);
    console.log('   FCM:', result.data.data.fcmSent);
    */

    console.log('\n📋 Steps to test:');
    console.log('1. Make sure your Flutter app is running');
    console.log('2. Login to the app (so FCM token is registered)');
    console.log('3. Open admin panel: http://localhost:3000/admin/notifications');
    console.log('4. Send a test notification');
    console.log('5. Check your app - notification should appear!\n');

    console.log('💡 Tips:');
    console.log('- Foreground: Notification shows as banner');
    console.log('- Background: Notification appears in system tray');
    console.log('- Closed app: FCM delivers notification\n');

  } catch (error) {
    console.error('❌ Error:', error.message);
    if (error.response) {
      console.error('   Status:', error.response.status);
      console.error('   Data:', error.response.data);
    }
  }
}

sendTestNotification();
