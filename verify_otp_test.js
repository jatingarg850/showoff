/**
 * Verify OTP Test - Simple Node.js Script
 * Verifies OTP for a phone number
 */

const http = require('http');

// Configuration
const SERVER_HOST = 'localhost';
const SERVER_PORT = 3000;
const PHONE = '9811226924';
const COUNTRY_CODE = '91';
const OTP = '566653';

console.log('\n╔════════════════════════════════════════╗');
console.log('║  🔍 Verifying OTP Test                 ║');
console.log('╚════════════════════════════════════════╝\n');

console.log('📍 Server:', `${SERVER_HOST}:${SERVER_PORT}`);
console.log('📱 Phone:', `+${COUNTRY_CODE} ${PHONE}`);
console.log('🔐 OTP:', OTP);
console.log('🔒 Protocol: HTTP\n');

// Prepare request data
const postData = JSON.stringify({
  phone: PHONE,
  countryCode: COUNTRY_CODE,
  otp: OTP
});

// Request options
const options = {
  hostname: SERVER_HOST,
  port: SERVER_PORT,
  path: '/api/auth/verify-otp',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('📤 Sending verification request...\n');

// Make request
const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    try {
      const response = JSON.parse(data);
      
      console.log('✅ Response Status:', res.statusCode);
      console.log('📋 Response Data:\n');
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success) {
        console.log('\n✅ OTP verified successfully!');
        console.log('🎉 User account created/authenticated!');
      } else {
        console.log('\n❌ OTP verification failed');
        console.log('Error:', response.message);
        if (response.attemptsLeft !== undefined) {
          console.log('Attempts left:', response.attemptsLeft);
        }
      }
    } catch (error) {
      console.log('❌ Error parsing response:', error.message);
      console.log('Raw response:', data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error.message);
  console.log('\n⚠️  Make sure the server is running on localhost:3000');
  console.log('Run: npm start (in server directory)');
});

// Send request
req.write(postData);
req.end();
