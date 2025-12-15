/**
 * Test AuthKey.io with EXACT format from user's logs
 * This matches the working format they showed
 */

const https = require('https');

const API_KEY = '4e51b96379db3b83';
const SENDER_ID = 'ShowOff';
const TEMPLATE_ID = '29663';
const PE_ID = '1101735621000123456';

const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║  AuthKey.io - EXACT Format Test                        ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

// Test 1: POST to console.authkey.io with exact format from logs
async function testExactFormat() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 1: POST to console.authkey.io (exact format)');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      authkey: API_KEY,
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      pe_id: PE_ID,
      sender: SENDER_ID,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      template_id: TEMPLATE_ID
    });

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

    console.log('Request Body:');
    console.log(JSON.parse(postData));

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

        resolve();
      });
    });

    req.on('error', (error) => {
      console.error('  Error:', error.message);
      resolve();
    });

    req.write(postData);
    req.end();
  });
}

// Test 2: Try with Authorization header
async function testWithAuthHeader() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 2: POST with Authorization header');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      pe_id: PE_ID,
      sender: SENDER_ID,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      template_id: TEMPLATE_ID
    });

    const basicAuth = Buffer.from(`${API_KEY}:`).toString('base64');

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: '/restapi/requestjson.php',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Basic ${basicAuth}`,
        'Content-Length': postData.length
      }
    };

    console.log('Request Body (without authkey):');
    console.log(JSON.parse(postData));
    console.log('Authorization: Basic [API_KEY]:');

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

        resolve();
      });
    });

    req.on('error', (error) => {
      console.error('  Error:', error.message);
      resolve();
    });

    req.write(postData);
    req.end();
  });
}

// Test 3: Try with sid (template ID) instead of template_id
async function testWithSid() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 3: POST with sid parameter');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      authkey: API_KEY,
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      pe_id: PE_ID,
      sender: SENDER_ID,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sid: TEMPLATE_ID
    });

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

    console.log('Request Body (with sid instead of template_id):');
    console.log(JSON.parse(postData));

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

        resolve();
      });
    });

    req.on('error', (error) => {
      console.error('  Error:', error.message);
      resolve();
    });

    req.write(postData);
    req.end();
  });
}

async function runAllTests() {
  try {
    await testExactFormat();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testWithAuthHeader();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testWithSid();

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ All Tests Complete                                 ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runAllTests();
