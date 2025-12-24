const http = require('http');

// Test the admin T&C endpoints
const tests = [
  {
    name: 'Get all T&C versions',
    method: 'GET',
    path: '/api/admin/terms',
    headers: {
      'Authorization': 'Bearer invalid-token'
    }
  },
  {
    name: 'Create new T&C version',
    method: 'POST',
    path: '/api/admin/terms',
    headers: {
      'Authorization': 'Bearer invalid-token',
      'Content-Type': 'application/json'
    },
    body: JSON.stringify({
      title: 'Test T&C',
      content: 'Test content'
    })
  },
  {
    name: 'Get current T&C (public)',
    method: 'GET',
    path: '/api/terms/current',
    headers: {
      'Content-Type': 'application/json'
    }
  }
];

function makeRequest(test) {
  return new Promise((resolve) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: test.path,
      method: test.method,
      headers: test.headers
    };

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        console.log(`\n✅ ${test.name}`);
        console.log(`   Status: ${res.statusCode}`);
        try {
          const json = JSON.parse(data);
          console.log(`   Response: ${JSON.stringify(json, null, 2).split('\n').slice(0, 3).join('\n')}`);
        } catch (e) {
          console.log(`   Response: ${data.substring(0, 100)}`);
        }
        resolve();
      });
    });

    req.on('error', (e) => {
      console.log(`\n❌ ${test.name}`);
      console.log(`   Error: ${e.message}`);
      resolve();
    });

    if (test.body) {
      req.write(test.body);
    }
    req.end();
  });
}

async function runTests() {
  console.log('🧪 Testing Terms & Conditions Endpoints\n');
  console.log('=' .repeat(50));

  for (const test of tests) {
    await makeRequest(test);
  }

  console.log('\n' + '='.repeat(50));
  console.log('\n✅ All endpoint tests completed!');
  console.log('\n📝 Admin Panel: http://localhost:3000/admin/terms-and-conditions');
  console.log('📱 Public API: http://localhost:3000/api/terms/current');
}

runTests();
