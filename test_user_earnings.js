const axios = require('axios');

const BASE_URL = 'http://localhost:3000';

// Test the user earnings endpoint
async function testUserEarnings() {
  try {
    console.log('🧪 Testing User Earnings Endpoint\n');
    
    // First, get a list of users to test with
    console.log('📋 Fetching users list...');
    const usersResponse = await axios.get(`${BASE_URL}/api/admin/users?limit=5`, {
      headers: {
        'Authorization': 'Bearer your_admin_token_here'
      }
    });
    
    if (usersResponse.data.success && usersResponse.data.data.length > 0) {
      const userId = usersResponse.data.data[0]._id;
      console.log(`✅ Found user: ${usersResponse.data.data[0].displayName} (${userId})\n`);
      
      // Test the earnings endpoint
      console.log(`📊 Fetching earnings for user ${userId}...`);
      const earningsResponse = await axios.get(`${BASE_URL}/api/admin/users/${userId}/earnings`, {
        headers: {
          'Authorization': 'Bearer your_admin_token_here'
        }
      });
      
      if (earningsResponse.data.success) {
        const data = earningsResponse.data.data;
        
        console.log('\n✅ Earnings Data Retrieved Successfully!\n');
        console.log('📈 User Information:');
        console.log(`   - Username: ${data.user.username}`);
        console.log(`   - Display Name: ${data.user.displayName}`);
        console.log(`   - Current Balance: ${data.user.coinBalance.toLocaleString()} coins`);
        console.log(`   - Total Earned: ${data.user.totalCoinsEarned.toLocaleString()} coins`);
        console.log(`   - Withdrawable: ${data.user.withdrawableBalance.toLocaleString()} coins\n`);
        
        console.log('💰 Earnings Breakdown:');
        console.log(`   - Video Uploads: ${data.earnings.videoUploadEarnings.toLocaleString()}`);
        console.log(`   - Content Sharing: ${data.earnings.contentSharingEarnings.toLocaleString()}`);
        console.log(`   - Wheel Spins: ${data.earnings.wheelSpinEarnings.toLocaleString()}`);
        console.log(`   - Rewarded Ads: ${data.earnings.rewardedAdEarnings.toLocaleString()}`);
        console.log(`   - Referrals: ${data.earnings.referralEarnings.toLocaleString()}`);
        console.log(`   - Competitions: ${data.earnings.competitionEarnings.toLocaleString()}`);
        console.log(`   - Gifts Received: ${data.earnings.giftEarnings.toLocaleString()}`);
        console.log(`   - Other: ${data.earnings.otherEarnings.toLocaleString()}`);
        console.log(`   - TOTAL: ${data.earnings.totalEarnings.toLocaleString()}\n`);
        
        console.log('📊 Statistics:');
        console.log(`   - Average Daily Earnings: ${Math.round(data.stats.averageDailyEarnings).toLocaleString()}`);
        console.log(`   - Total Withdrawn: ${data.stats.totalWithdrawn.toLocaleString()}`);
        console.log(`   - Withdrawal Count: ${data.stats.withdrawalCount}`);
        console.log(`   - Transaction Count: ${data.stats.transactionCount}\n`);
        
        console.log(`📅 Recent Transactions: ${data.recentTransactions.length}`);
        if (data.recentTransactions.length > 0) {
          console.log('   Last 5 transactions:');
          data.recentTransactions.slice(0, 5).forEach((tx, idx) => {
            console.log(`   ${idx + 1}. ${tx.type} - ${tx.amount > 0 ? '+' : ''}${tx.amount} coins (${new Date(tx.createdAt).toLocaleDateString()})`);
          });
        }
        
        console.log(`\n💳 Withdrawal History: ${data.withdrawalHistory.length}`);
        if (data.withdrawalHistory.length > 0) {
          console.log('   Last 3 withdrawals:');
          data.withdrawalHistory.slice(0, 3).forEach((w, idx) => {
            console.log(`   ${idx + 1}. ${w.coinAmount} coins via ${w.method} - Status: ${w.status}`);
          });
        }
        
        console.log('\n✅ All tests passed!');
      } else {
        console.log('❌ Error:', earningsResponse.data.message);
      }
    } else {
      console.log('❌ No users found');
    }
  } catch (error) {
    console.error('❌ Error:', error.response?.data || error.message);
  }
}

// Run the test
testUserEarnings();
