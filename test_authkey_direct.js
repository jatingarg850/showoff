/**
 * Direct AuthKey.io API Test
 * Tests the AuthKey.io API with different request formats
 */

const https = require('https');

const API_KEY = '4e51b96379db3b83';
const SENDER_ID = 'ShowOff';
const TEMPLATE_ID = '29663';
const PE_ID = '1101735621000123456';

// Test phone number (use a test number or your own)
const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║  AuthKey.io API Direct Test                            ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('Configuration:');
console.log('  API Key:', API_KEY);
console.log('  Sender ID:', SENDER_ID);
console.log('  Template ID:', TEMPLATE_ID);
console.log('  PE ID:', PE_ID);
console.log('  Test Phone:', `+${TEST_COUNTRY_CODE} ${TEST_PHONE}\n`);

// Test 1: POST with JSON body (current implementation)
async function testPostJSON() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 1: POST with JSON body (authkey in body)');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      authkey: API_KEY,
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sender: SENDER_ID,
      pe_id: PE_ID,
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

    console.log('Request Details:');
    console.log('  Hostname:', options.hostname);
    console.log('  Path:', options.path);
    console.log('  Method:', options.method);
    console.log('  Headers:', options.headers);
    console.log('  Body:', JSON.parse(postData));

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log('\nResponse:');
        console.log('  Status Code:', res.statusCode);
        console.log('  Headers:', res.headers);
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

// Test 2: GET request with query parameters
async function testGetRequest() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 2: GET request with query parameters');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sender: SENDER_ID,
      pe_id: PE_ID,
      template_id: TEMPLATE_ID
    });

    const path = `/restapi/requestjson.php?${params.toString()}`;

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    console.log('Request Details:');
    console.log('  Hostname:', options.hostname);
    console.log('  Path:', path.substring(0, 100) + '...');
    console.log('  Method:', options.method);

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

    req.end();
  });
}

// Test 3: POST with Basic Auth header
async function testPostWithBasicAuth() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 3: POST with Basic Auth header');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sender: SENDER_ID,
      pe_id: PE_ID,
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

    console.log('Request Details:');
    console.log('  Hostname:', options.hostname);
    console.log('  Path:', options.path);
    console.log('  Method:', options.method);
    console.log('  Auth:', `Basic ${basicAuth.substring(0, 20)}...`);

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

// Test 4: Check account balance/status
async function testAccountStatus() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 4: Check Account Status/Balance');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      action: 'balance'
    });

    const path = `/restapi/requestjson.php?${params.toString()}`;

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: path,
      method: 'GET'
    };

    console.log('Request Details:');
    console.log('  Checking account balance...');

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

    req.end();
  });
}

async function runAllTests() {
  try {
    await testPostJSON();
    await new Promise(resolve => setTimeout(resolve, 1000)); // Wait 1 second between tests
    
    await testGetRequest();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testPostWithBasicAuth();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testAccountStatus();

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ All Tests Complete                                 ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

    console.log('📝 Analysis:');
    console.log('  - Check which test format returns a successful response');
    console.log('  - If all fail with "Invalid authkey", the API key may be invalid');
    console.log('  - If balance check fails, the account may have no SMS credits');
    console.log('  - Use the successful format in authkeyService.js\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runAllTests();
