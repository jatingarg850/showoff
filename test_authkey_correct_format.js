/**
 * AuthKey.io API - Correct Format Test
 * Based on AuthKey.io official documentation
 */

const https = require('https');
const http = require('http');

const API_KEY = '4e51b96379db3b83';
const SENDER_ID = 'ShowOff';
const TEMPLATE_ID = '29663';
const PE_ID = '1101735621000123456';

const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║  AuthKey.io API - Correct Format Test                  ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

// Test 1: Using api.authkey.io (not console.authkey.io)
async function testApiAuthkeyIo() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 1: Using api.authkey.io endpoint');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      mobile: TEST_PHONE,
      country_code: TEST_COUNTRY_CODE,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sender: SENDER_ID,
      pe_id: PE_ID,
      template_id: TEMPLATE_ID
    });

    const path = `/request?${params.toString()}`;

    const options = {
      hostname: 'api.authkey.io',
      port: 443,
      path: path,
      method: 'GET'
    };

    console.log('Request Details:');
    console.log('  Hostname: api.authkey.io');
    console.log('  Path: /request?...');
    console.log('  Method: GET');

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

// Test 2: Using HTTP instead of HTTPS
async function testHttpEndpoint() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 2: Using HTTP endpoint');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      mobile: TEST_PHONE,
      country_code: TEST_COUNTRY_CODE,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`,
      sender: SENDER_ID,
      pe_id: PE_ID,
      template_id: TEMPLATE_ID
    });

    const path = `/request?${params.toString()}`;

    const options = {
      hostname: 'api.authkey.io',
      port: 80,
      path: path,
      method: 'GET'
    };

    console.log('Request Details:');
    console.log('  Hostname: api.authkey.io');
    console.log('  Port: 80 (HTTP)');
    console.log('  Path: /request?...');

    const req = http.request(options, (res) => {
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

// Test 3: Simple GET with minimal parameters
async function testMinimalParams() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 3: Minimal parameters (just authkey, mobile, sms)');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      mobile: `${TEST_COUNTRY_CODE}${TEST_PHONE}`,
      sms: `Your ShowOff.life OTP is 123456. Do not share this code with anyone. Valid for 10 minutes.`
    });

    const path = `/request?${params.toString()}`;

    const options = {
      hostname: 'api.authkey.io',
      port: 443,
      path: path,
      method: 'GET'
    };

    console.log('Request Details:');
    console.log('  Hostname: api.authkey.io');
    console.log('  Path: /request?authkey=...&mobile=91...&sms=...');
    console.log('  Method: GET');

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

// Test 4: Check if API key is valid by testing balance
async function testBalance() {
  console.log('\n═══════════════════════════════════════════════════════');
  console.log('Test 4: Check Account Balance');
  console.log('═══════════════════════════════════════════════════════\n');

  return new Promise((resolve) => {
    const params = new URLSearchParams({
      authkey: API_KEY,
      action: 'balance'
    });

    const path = `/request?${params.toString()}`;

    const options = {
      hostname: 'api.authkey.io',
      port: 443,
      path: path,
      method: 'GET'
    };

    console.log('Request Details:');
    console.log('  Checking balance with api.authkey.io...');

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
    await testApiAuthkeyIo();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testHttpEndpoint();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testMinimalParams();
    await new Promise(resolve => setTimeout(resolve, 1000));
    
    await testBalance();

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ All Tests Complete                                 ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

    console.log('📝 Next Steps:');
    console.log('  1. Check which endpoint/format returns success');
    console.log('  2. If balance is 0, the account needs SMS credits');
    console.log('  3. Update authkeyService.js with the correct format\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runAllTests();
