/**
 * Send OTP Test - Simple Node.js Script
 * Sends OTP to a phone number via local server
 */

const http = require('http');

// Configuration
const SERVER_HOST = 'localhost';
const SERVER_PORT = 3000;
const PHONE = '9336444245';
const COUNTRY_CODE = '91';

console.log('\n╔════════════════════════════════════════╗');
console.log('║  📱 Sending OTP Test                   ║');
console.log('╚════════════════════════════════════════╝\n');

console.log('📍 Server:', `${SERVER_HOST}:${SERVER_PORT}`);
console.log('📱 Phone:', `+${COUNTRY_CODE} ${PHONE}`);
console.log('🔒 Protocol: HTTP\n');

// Prepare request data
const postData = JSON.stringify({
  phone: PHONE,
  countryCode: COUNTRY_CODE
});

// Request options
const options = {
  hostname: SERVER_HOST,
  port: SERVER_PORT,
  path: '/api/auth/send-otp',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData)
  }
};

console.log('📤 Sending request...\n');

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
        console.log('\n✅ OTP sent successfully!');
        console.log('📌 LogID:', response.data.logId);
        console.log('⏱️  Expires in:', response.data.expiresIn, 'seconds');
        console.log('📱 Phone:', response.data.identifier);
        console.log('\n💡 Check your phone for the OTP message!\n');
      } else {
        console.log('\n❌ Failed to send OTP');
        console.log('Error:', response.message);
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
