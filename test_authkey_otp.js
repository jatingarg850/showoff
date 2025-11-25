/**
 * Test AuthKey.io OTP Integration
 * Tests sending and verifying OTP via AuthKey.io API
 */

const http = require('http');

// Configuration
const API_BASE = 'http://localhost:3000';
const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║     AuthKey.io OTP Integration Test                   ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('📱 Test Phone:', `+${TEST_COUNTRY_CODE} ${TEST_PHONE}`);
console.log('🌐 API Base:', API_BASE);
console.log('\n' + '='.repeat(60) + '\n');

// Step 1: Send OTP
console.log('Step 1: Sending OTP...\n');

const sendOTPData = JSON.stringify({
  phone: TEST_PHONE,
  countryCode: TEST_COUNTRY_CODE
});

const sendOptions = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/send-otp',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': sendOTPData.length
  }
};

const sendReq = http.request(sendOptions, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📡 Response Status:', res.statusCode);
    console.log('📄 Response Body:\n');
    
    try {
      const response = JSON.parse(data);
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success) {
        console.log('\n✅ OTP SENT SUCCESSFULLY!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');
        
        if (response.data.logId) {
          console.log('📋 LogID:', response.data.logId);
          console.log('⏰ Expires in:', response.data.expiresIn, 'seconds');
        }
        
        if (response.data.otp) {
          console.log('🔐 OTP (Development):', response.data.otp);
          console.log('\n💡 Use this OTP to test verification');
          
          // Prompt for verification test
          console.log('\n' + '='.repeat(60));
          console.log('\nTo test OTP verification, run:');
          console.log(`node test_authkey_verify.js ${response.data.otp}`);
          console.log('\nOr manually test with:');
          console.log(`curl -X POST ${API_BASE}/api/auth/verify-otp \\`);
          console.log(`  -H "Content-Type: application/json" \\`);
          console.log(`  -d '{"phone":"${TEST_PHONE}","countryCode":"${TEST_COUNTRY_CODE}","otp":"${response.data.otp}"}'`);
        } else {
          console.log('\n📱 Check your phone for the OTP!');
          console.log('   Then run verification test with the received OTP');
        }
        
        console.log('\n' + '='.repeat(60) + '\n');
        
      } else {
        console.log('\n❌ FAILED TO SEND OTP');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('Error:', response.message);
        console.log('\n💡 Troubleshooting:');
        console.log('   1. Check if server is running');
        console.log('   2. Verify AuthKey.io credentials in .env');
        console.log('   3. Check server logs for errors');
        console.log('   4. Ensure phone number is not already registered\n');
      }
    } catch (error) {
      console.log(data);
      console.log('\n❌ Failed to parse JSON response');
    }
  });
});

sendReq.on('error', (error) => {
  console.log('❌ CONNECTION ERROR!');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Error:', error.message);
  console.log('\n💡 Troubleshooting:');
  console.log('   1. Make sure server is running:');
  console.log('      cd server && npm start');
  console.log('   2. Verify server is on port 3000');
  console.log('   3. Check for any startup errors\n');
});

sendReq.write(sendOTPData);
sendReq.end();
