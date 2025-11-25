/**
 * Test script for Phone.email Web Integration
 * 
 * This script simulates the Phone.email callback by sending a test
 * user_json_url to your backend verification endpoint.
 */

const http = require('http');

// Test configuration
const TEST_CONFIG = {
  host: 'localhost',
  port: 3000,
  path: '/api/auth/phone-email-verify',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
  }
};

// Simulated user_json_url (in real scenario, this comes from Phone.email)
const testData = {
  user_json_url: 'https://user.phone.email/user_test_simulation.json'
};

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║     Phone.email Web Integration Test                  ║');
console.log('╠════════════════════════════════════════════════════════╣');
console.log('║  Testing endpoint: POST /api/auth/phone-email-verify  ║');
console.log('║  Server: http://localhost:3000                         ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('📡 Sending test request...\n');

const req = http.request(TEST_CONFIG, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📊 Response Status:', res.statusCode);
    console.log('📄 Response Headers:', JSON.stringify(res.headers, null, 2));
    console.log('\n📦 Response Body:');
    
    try {
      const jsonData = JSON.parse(data);
      console.log(JSON.stringify(jsonData, null, 2));
      
      if (jsonData.success) {
        console.log('\n✅ TEST PASSED!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('🎉 Phone.email web integration is working correctly!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        if (jsonData.user) {
          console.log('👤 User Details:');
          console.log(`   Username: ${jsonData.user.username}`);
          console.log(`   Phone: ${jsonData.user.countryCode} ${jsonData.user.phoneNumber}`);
          console.log(`   Display Name: ${jsonData.user.displayName}`);
          console.log(`   Coins: ${jsonData.user.coinBalance}`);
        }
        
        if (jsonData.token) {
          console.log(`\n🔑 JWT Token: ${jsonData.token.substring(0, 30)}...`);
        }
        
        console.log('\n📝 Next Steps:');
        console.log('   1. Open: http://localhost:3000/phone-login-demo');
        console.log('   2. Click "Sign in with Phone" button');
        console.log('   3. Verify with your phone number');
        console.log('   4. See the magic happen! ✨\n');
      } else {
        console.log('\n⚠️  TEST COMPLETED WITH WARNINGS');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('Message:', jsonData.message);
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
      }
    } catch (error) {
      console.log(data);
      console.log('\n❌ Failed to parse JSON response');
    }
  });
});

req.on('error', (error) => {
  console.log('❌ TEST FAILED!');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Error:', error.message);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
  
  if (error.code === 'ECONNREFUSED') {
    console.log('💡 Troubleshooting:');
    console.log('   1. Make sure your server is running:');
    console.log('      cd server && npm start');
    console.log('   2. Verify server is on port 3000');
    console.log('   3. Check for any startup errors\n');
  }
});

// Send the request
req.write(JSON.stringify(testData));
req.end();

console.log('⏳ Waiting for response...\n');
