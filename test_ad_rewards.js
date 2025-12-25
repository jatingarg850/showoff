const http = require('http');

// Test the ad rewards endpoint
function makeRequest(path) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve({ status: res.statusCode, data: parsed });
        } catch (e) {
          resolve({ status: res.statusCode, data });
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

async function testAdRewards() {
  console.log('🧪 Testing Ad Rewards System\n');

  try {
    // Test 1: Get ads from API
    console.log('📝 Test 1: Fetching ads from API...');
    const response = await makeRequest('/api/rewarded-ads');

    if (!response.data.success) {
      throw new Error('Failed to fetch ads');
    }

    console.log(`✅ Fetched ${response.data.data.length} ads\n`);

    // Test 2: Verify each ad's reward
    console.log('📊 Ad Rewards:');
    response.data.data.forEach((ad) => {
      console.log(`  Ad ${ad.adNumber}: ${ad.title}`);
      console.log(`    Reward: ${ad.rewardCoins} coins`);
      console