/**
 * Test All Notification Types
 * Tests follow, message, like, comment, vote notifications
 */

const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// CONFIGURE THESE VALUES
const USER_A_TOKEN = 'your_user_a_token_here'; // User who performs actions
const USER_B_ID = 'your_user_b_id_here';       // User who receives notifications
const POST_ID = 'your_post_id_here';           // Optional: for testing post like/comment
const SYT_ENTRY_ID = 'your_syt_entry_id_here'; // Optional: for testing SYT vote/like

async function testNotifications() {
  console.log('🧪 Testing All Notification Types');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  if (USER_A_TOKEN === 'your_user_a_token_here' || USER_B_ID === 'your_user_b_id_here') {
    console.log('❌ Please configure USER_A_TOKEN and USER_B_ID in the script');
    console.log('\n📝 How to get these values:');
    console.log('1. Login as User A in the app');
    console.log('2. Check console logs for auth token');
    console.log('3. Get User B\'s ID from database or API\n');
    return;
  }

  const headers = { Authorization: `Bearer ${USER_A_TOKEN}` };

  try {
    // Test 1: Follow Notification
    console.log('1️⃣  Testing Follow Notification');
    try {
      const followRes = await axios.post(
        `${BASE_URL}/api/follow/${USER_B_ID}`,
        {},
        { headers }
      );
      console.log('✅ Follow notification sent');
      console.log(`   Response: ${followRes.data.message}\n`);
    } catch (error) {
      if (error.response?.status === 400 && error.response?.data?.message?.includes('Already following')) {
        console.log('⚠️  Already following this user (notification still sent on first follow)');
        console.log('   To test again: unfollow first, then follow\n');
      } else {
        throw error;
      }
    }

    // Test 2: Message Notification
    console.log('2️⃣  Testing Message Notification');
    const messageRes = await axios.post(
      `${BASE_URL}/api/chat/${USER_B_ID}`,
      { text: 'Test message for notification system! 📱' },
      { headers }
    );
    console.log('✅ Message notification sent');
    console.log(`   Message: "${messageRes.data.data.text}"\n`);

    // Test 3: Post Like Notification (if POST_ID provided)
    if (POST_ID && POST_ID !== 'your_post_id_here') {
      console.log('3️⃣  Testing Post Like Notification');
      const likeRes = await axios.post(
        `${BASE_URL}/api/posts/${POST_ID}/like`,
        {},
        { headers }
      );
      console.log('✅ Post like notification sent');
      console.log(`   Liked: ${likeRes.data.liked}, Count: ${likeRes.data.likesCount}\n`);
    } else {
      console.log('3️⃣  Skipping Post Like (no POST_ID configured)\n');
    }

    // Test 4: Post Comment Notification (if POST_ID provided)
    if (POST_ID && POST_ID !== 'your_post_id_here') {
      console.log('4️⃣  Testing Comment Notification');
      const commentRes = await axios.post(
        `${BASE_URL}/api/posts/${POST_ID}/comment`,
        { text: 'Great post! Testing notifications 🎉' },
        { headers }
      );
      console.log('✅ Comment notification sent');
      console.log(`   Comment: "${commentRes.data.data.text}"\n`);
    } else {
      console.log('4️⃣  Skipping Comment (no POST_ID configured)\n');
    }

    // Test 5: SYT Vote Notification (if SYT_ENTRY_ID provided)
    if (SYT_ENTRY_ID && SYT_ENTRY_ID !== 'your_syt_entry_id_here') {
      console.log('5️⃣  Testing SYT Vote Notification');
      try {
        const voteRes = await axios.post(
          `${BASE_URL}/api/syt/${SYT_ENTRY_ID}/vote`,
          {},
          { headers }
        );
        console.log('✅ SYT vote notification sent');
        console.log(`   Votes: ${voteRes.data.votesCount}\n`);
      } catch (error) {
        if (error.response?.status === 400 && error.response?.data?.message?.includes('vote again')) {
          console.log('⚠️  Already voted (can vote once per 24 hours)');
          console.log(`   ${error.response.data.message}\n`);
        } else {
          throw error;
        }
      }
    } else {
      console.log('5️⃣  Skipping SYT Vote (no SYT_ENTRY_ID configured)\n');
    }

    // Test 6: SYT Like Notification (if SYT_ENTRY_ID provided)
    if (SYT_ENTRY_ID && SYT_ENTRY_ID !== 'your_syt_entry_id_here') {
      console.log('6️⃣  Testing SYT Like Notification');
      const sytLikeRes = await axios.post(
        `${BASE_URL}/api/syt/${SYT_ENTRY_ID}/like`,
        {},
        { headers }
      );
      console.log('✅ SYT like notification sent');
      console.log(`   Liked: ${sytLikeRes.data.data.isLiked}, Count: ${sytLikeRes.data.data.likesCount}\n`);
    } else {
      console.log('6️⃣  Skipping SYT Like (no SYT_ENTRY_ID configured)\n');
    }

    // Summary
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log('✅ All configured tests completed successfully!');
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    console.log('📱 Check User B\'s device for notifications:');
    console.log('   - App open: In-app notification banner');
    console.log('   - App background: System notification tray');
    console.log('   - App closed: FCM push notification\n');

    console.log('💡 To test more notification types:');
    console.log('   1. Configure POST_ID for post like/comment tests');
    console.log('   2. Configure SYT_ENTRY_ID for SYT vote/like tests');
    console.log('   3. Run the script again\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.response?.data || error.message);
    console.error('\n⚠️  Make sure:');
    console.error('   1. Server is running (node server/server.js)');
    console.error('   2. USER_A_TOKEN is valid');
    console.error('   3. USER_B_ID exists');
    console.error('   4. User A is authenticated\n');
  }
}

// Run tests
testNotifications();
