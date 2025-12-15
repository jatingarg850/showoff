/**
 * Test AuthKey.io 2FA endpoint
 * Maybe the successful format was using the 2FA API
 */

const https = require('https');

const API_KEY = '4e51b96379db3b83';
const SENDER_ID = 'ShowOff';
const TEMPLATE_ID = '29663';
const PE_ID = '1101735621000123456';

const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║  AuthKey.io 2FA Endpoint Test                          ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

// Test 1: 2FA endpoint with GET
async function test2FAGet() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 1: 2FA GET endpoint');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      mobile: TEST_PHONE,
      country_code: TEST_COUNTRY_CODE,
      sid: TEMPLATE_ID
    });

    const path = `/restapi/request.php?${params.toString()}`;

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: path,
      method: 'GET'
    };

    console.log('Endpoint: console.authkey.io/restapi/request.php');
    console.log('Method: GET');
    console.log('Parameters:', Object.fromEntries(params));

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

// Test 2: Try POST to 2FA endpoint
async function test2FAPost() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 2: 2FA POST endpoint');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const postData = JSON.stringify({
      authkey: API_KEY,
      country_code: TEST_COUNTRY_CODE,
      mobile: TEST_PHONE,
      sid: TEMPLATE_ID
    });

    const options = {
      hostname: 'console.authkey.io',
      port: 443,
      path: '/restapi/request.php',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': postData.length
      }
    };

    console.log('Endpoint: console.authkey.io/restapi/request.php');
    console.log('Method: POST');
    console.log('Body:', JSON.parse(postData));

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

async function runTests() {
  try {
    await test2FAGet();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await test2FAPost();

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ Tests Complete                                     ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runTests();
