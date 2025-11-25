// Node.js script to test Phone.email OTP Integration
// Run with: node test_phone_otp.js

const https = require('https');

const clientId = '16687983578815655151';
const apiKey = 'I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf';
const phoneNumber = '+919811226924';

console.log('🚀 Testing Phone.email OTP Integration\n');
console.log('📱 Sending OTP to:', phoneNumber);
console.log('🔑 Using Client ID:', clientId);
console.log('');

const data = JSON.stringify({
  phone_number: phoneNumber
});

const options = {
  hostname: 'api.phone.email',
  port: 443,
  path: '/auth/v1/otp',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length,
    'X-Client-Id': clientId,
    'X-API-Key': apiKey
  }
};

const req = https.request(options, (res) => {
  console.log('📡 Response Status:', res.statusCode);
  console.log('');

  let responseBody = '';

  res.on('data', (chunk) => {
    responseBody += chunk;
  });

  res.on('end', () => {
    console.log('📄 Response Body:', responseBody);
    console.log('');

    if (res.statusCode === 200 || res.statusCode === 201) {
      try {
        const response = JSON.parse(responseBody);
        console.log('✅ SUCCESS! OTP sent successfully');
        console.log('📨 Session ID:', response.session_id || 'N/A');
        console.log('⏰ Expires in:', response.expires_in || 'N/A', 'seconds');
        console.log('');
        console.log('💡 Check your phone for the OTP code!');
      } catch (e) {
        console.log('✅ OTP sent (response parsing failed)');
      }
    } else {
      console.log('❌ FAILED to send OTP');
      console.log('Error:', responseBody);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ ERROR:', error.message);
});

req.write(data);
req.end();
