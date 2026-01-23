const http = require('http');

const baseUrl = 'http://localhost:3000';

// Test endpoints
const tests = [
  {
    name: 'Get Watch Ads (AdMob)',
    method: 'GET',
    path: '/api/rewarded-ads?type=watch-ads',
  },
  {
    name: 'Get Spin Wheel Ads (Admin)',
    method: 'GET',
    path: '/api/rewarded-ads?type=spin-wheel',
  },
  {
    name: 'Get Video Ads for Watch',
    method: 'GET',
    path: '/api/video-ads?usage=watch-ads',
  },
  {
    name: 'Get Video Ads for Spin Wheel',
    method: 'GET',
    path: '/api/video-ads?usage=spin-wheel',
  },
];

async function runTest(test) {
  return new Promise((resolve) => {
    const url = new URL(baseUrl + test.path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: test.method,
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
          const json = JSON.parse(data);
          console.log(`\n✅ ${test.name}`);
          console.log(`   Status: ${res.statusCode}`);
          console.log(`   Success: ${json.success}`);
          console.log(`   Data count: ${json.data ? json.data.length : 0}`);
          if (json.data && json.data.length > 0) {
            console.log(`   First ad:`, {
              title: json.data[0].title,
              adType: json.data[0].adType || json.data[0].usage,
              rewardCoins: json.data[0].rewardCoins,
            });
          }
        } catch (e) {
          console.log(`\n❌ ${test.name}`);
          console.log(`   Error parsing response: ${e.message}`);
        }
        resolve();
      });
    });

    req.on('error', (e) => {
      console.log(`\n❌ ${test.name}`);
      console.log(`   Error: ${e.message}`);
      resolve();
    });

    req.end();
  });
}

async function runAllTests() {
  console.log('🧪 Testing Ad System Endpoints\n');
  console.log('Waiting for server to be ready...');
  
  // Wait for server to be ready
  await new Promise(resolve => setTimeout(resolve, 2000));

  for (const test of tests) {
    await runTest(test);
  }

  console.log('\n✅ All tests completed!');
  process.exit(0);
}

runAllTests().catch(err => {
  console.error('Test error:', err);
  process.exit(1);
});
