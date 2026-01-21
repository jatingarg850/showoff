const http = require('http');
const fs = require('fs');

// Configuration
const BASE_URL = 'http://localhost:5000';
let authToken = '';
let userId = '';
let videoAdId = '';

// Helper function to make HTTP requests
function makeRequest(method, path, body = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, BASE_URL);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (authToken) {
      options.headers['Authorization'] = `Bearer ${authToken}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve({
            status: res.statusCode,
            data: JSON.parse(data),
          });
        } catch (e) {
          resolve({
            status: res.statusCode,
            data: data,
          });
        }
      });
    });

    req.on('error', reject);

    if (body) {
      req.write(JSON.stringify(body));
    }
    req.end();
  });
}

async function testVideoAdsFlow() {
  console.log('🎬 Testing Video Ads Complete Flow\n');

  try {
    // Step 1: Login
    console.log('📝 Step 1: Logging in...');
    const loginRes = await makeRequest('POST', '/api/auth/login', {
      email: 'testuser@example.com',
      password: 'password123',
    });

    if (loginRes.status !== 200) {
      console.log('❌ Login failed:', loginRes.data);
      return;
    }

    authToken = loginRes.data.token;
    userId = loginRes.data.user._id;
    console.log('✅ Login successful');
    console.log('   Token:', authToken.substring(0, 20) + '...');
    console.log('   User ID:', userId);

    // Step 2: Get initial balance
    console.log('\n💰 Step 2: Getting initial balance...');
    const balanceRes = await makeRequest('GET', '/api/coins/balance');
    console.log('✅ Initial balance:', balanceRes.data.data.coinBalance, 'coins');

    // Step 3: Fetch video ads
    console.log('\n📺 Step 3: Fetching video ads...');
    const adsRes = await makeRequest('GET', '/api/video-ads');
    if (adsRes.status !== 200 || !adsRes.data.data || adsRes.data.data.length === 0) {
      console.log('❌ No video ads available');
      console.log('   Response:', adsRes.data);
      return;
    }

    videoAdId = adsRes.data.data[0].id;
    const videoAd = adsRes.data.data[0];
    console.log('✅ Video ads fetched');
    console.log('   Ad ID:', videoAdId);
    console.log('   Title:', videoAd.title);
    console.log('   Reward:', videoAd.rewardCoins, 'coins');

    // Step 4: Track video ad view
    console.log('\n👁️  Step 4: Tracking video ad view...');
    const viewRes = await makeRequest('POST', `/api/video-ads/${videoAdId}/view`);
    if (viewRes.status === 200) {
      console.log('✅ View tracked successfully');
    } else {
      console.log('⚠️  View tracking response:', viewRes.status, viewRes.data);
    }

    // Step 5: Simulate watching video (wait 2 seconds)
    console.log('\n⏳ Step 5: Simulating video watch (2 seconds)...');
    await new Promise((resolve) => setTimeout(resolve, 2000));
    console.log('✅ Video watched');

    // Step 6: Track video ad completion (this should award coins)
    console.log('\n🎉 Step 6: Tracking video ad completion...');
    const completeRes = await makeRequest('POST', `/api/video-ads/${videoAdId}/complete`);
    console.log('   Status:', completeRes.status);
    console.log('   Response:', JSON.stringify(completeRes.data, null, 2));

    if (completeRes.status === 200 && completeRes.data.success) {
      console.log('✅ Video ad completed successfully');
      console.log('   Coins earned:', completeRes.data.coinsEarned);
      console.log('   New balance:', completeRes.data.newBalance);
    } else {
      console.log('❌ Video ad completion failed');
      return;
    }

    // Step 7: Verify new balance
    console.log('\n💰 Step 7: Verifying new balance...');
    const newBalanceRes = await makeRequest('GET', '/api/coins/balance');
    const newBalance = newBalanceRes.data.data.coinBalance;
    console.log('✅ New balance:', newBalance, 'coins');

    // Step 8: Check transaction history
    console.log('\n📋 Step 8: Checking transaction history...');
    const transRes = await makeRequest('GET', '/api/coins/transactions?limit=5');
    if (transRes.data.data && transRes.data.data.length > 0) {
      const latestTrans = transRes.data.data[0];
      console.log('✅ Latest transaction:');
      console.log('   Type:', latestTrans.type);
      console.log('   Amount:', latestTrans.amount);
      console.log('   Description:', latestTrans.description);
      console.log('   Balance after:', latestTrans.balanceAfter);
    }

    console.log('\n✅ Video ads flow test completed successfully!');
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Run the test
testVideoAdsFlow();
