/**
 * Test AuthKey.io - trying with space in country_code
 */

const https = require('https');

const API_KEY = '4e51b96379db3b83';
const SENDER_ID = 'ShowOff';
const TEMPLATE_ID = '29663';
const PE_ID = '1101735621000123456';

const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = ' 91'; // WITH SPACE

console.log('Testing with country_code: " 91" (with space)\n');

const postData = JSON.stringify({
  authkey: API_KEY,
  country_code: TEST_COUNTRY_CODE,
  mobile: TEST_PHONE,
  pe_id: PE_ID,
  sender: SENDER_ID,
  sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
  template_id: TEMPLATE_ID
});

console.log('Request Body:');
console.log(JSON.parse(postData));

const options = {
  hostname: 'console.authkey.io',
  port: 443,
  path: '/restapi/requestjson.php',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': postData.length
  }
};

const req = https.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('\nResponse:');
    console.log('  Status Code:', res.statusCode);
    console.log('  Body:', data);
    
    try {
      const parsed = JSON.parse(data);
      console.log('  Parsed:', JSON.stringify(parsed, null, 2));
    } catch (e) {
      console.log('  (Could not parse as JSON)');
    }
  });
});

req.on('error', (error) => {
  console.error('  Error:', error.message);
});

req.write(postData);
req.end();
