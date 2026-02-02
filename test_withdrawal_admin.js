const http = require('http');

// Test the withdrawal admin endpoints
const tests = [
  {
    name: 'Get withdrawal details',
    method: 'GET',
    path: '/admin/withdrawals/697ef073b76afe0fd3512c59',
    body: null
  },
  {
    name: 'Approve withdrawal',
    method: 'POST',
    path: '/admin/withdrawals/697ef073b76afe0fd3512c59/approve',
    body: JSON.stringify({
      adminNotes: 'Test approval',
      transactionId: 'TXN123456',
      approvedAmount: 500
    })
  },
  {
    name: 'Reject withdrawal',
    method: 'POST',
    path: '/admin/withdrawals/697ef073b76afe0fd3512c59/reject',
    body: JSON.stringify({
      rejectionReason: 'Test rejection'
    })
  }
];

function runTest(test) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: test.path,
      method: test.method,
      headers: {
        'Content-Type': 'application/json',
        'Cookie': 'connect.sid=wNY2dfuK-7sNeRNoRckLgjBR3YnaDfhZ'
      }
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log(`\n✅ ${test.name}`);
        console.log(`   Status: ${res.statusCode}`);
        console.log(`   Response: ${data.substring(0, 100)}...`);
        resolve();
      });
    });

    req.on('error', (error) => {
      console.log(`\n❌ ${test.name}`);
      console.log(`   Error: ${error.message}`);
      resolve();
    });

    if (test.body) {
      req.write(test.body);
    }
    req.end();
  });
}

async function runAllTests() {
  console.log('🧪 Testing Withdrawal Admin Endpoints\n');
  for (const test of tests) {
    await runTest(test);
  }
  console.log('\n✅ All tests completed');
}

runAllTests();
