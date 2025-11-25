/**
 * Quick server health check
 * Tests if the server is running and endpoints are accessible
 */

const http = require('http');

console.log('╔════════════════════════════════════════╗');
console.log('║     Server Health Check                ║');
console.log('╚════════════════════════════════════════╝\n');

// Test 1: Health endpoint
console.log('1️⃣  Testing health endpoint...');
http.get('http://localhost:3000/health', (res) => {
  let data = '';
  res.on('data', chunk => data += chunk);
  res.on('end', () => {
    if (res.statusCode === 200) {
      console.log('   ✅ Health endpoint: OK');
      console.log('   Response:', data.substring(0, 100) + '...\n');
      
      // Test 2: Check if auth routes are loaded
      console.log('2️⃣  Testing auth endpoint availability...');
      const testReq = http.request({
        hostname: 'localhost',
        port: 3000,
        path: '/api/auth/phone-email-verify',
        method: 'POST',
        headers: {
          'Content-Type': 'application/json'
        }
      }, (res) => {
        let data = '';
        res.on('data', chunk => data += chunk);
        res.on('end', () => {
          console.log('   Status Code:', res.statusCode);
          console.log('   Content-Type:', res.headers['content-type']);
          
          if (res.statusCode === 400) {
            console.log('   ✅ Endpoint exists (400 = missing data, which is expected)');
            console.log('\n╔════════════════════════════════════════╗');
            console.log('║  ✅ SERVER IS HEALTHY!                ║');
            console.log('║                                        ║');
            console.log('║  You can now test:                     ║');
            console.log('║  http://localhost:3000/phone-login-demo║');
            console.log('╚════════════════════════════════════════╝\n');
          } else if (res.statusCode === 404) {
            console.log('   ❌ Endpoint not found!');
            console.log('   Response:', data);
            console.log('\n⚠️  The route may not be registered correctly.');
          } else {
            console.log('   Response:', data.substring(0, 200));
          }
        });
      });
      
      testReq.on('error', (error) => {
        console.log('   ❌ Error:', error.message);
      });
      
      testReq.write(JSON.stringify({}));
      testReq.end();
      
    } else {
      console.log('   ❌ Health endpoint failed:', res.statusCode);
    }
  });
}).on('error', (error) => {
  console.log('   ❌ Cannot connect to server!');
  console.log('   Error:', error.message);
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║  ❌ SERVER NOT RUNNING                 ║');
  console.log('║                                        ║');
  console.log('║  Please start the server:              ║');
  console.log('║  cd server && npm start                ║');
  console.log('╚════════════════════════════════════════╝\n');
});
