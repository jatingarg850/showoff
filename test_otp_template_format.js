/**
 * Test AuthKey.io OTP with correct template format (SID 29663)
 * Tests the new implementation using template variables instead of custom SMS message
 */

const https = require('https');

// Configuration
const AUTHKEY_API_KEY = '4e51b96379db3b83';
const TEMPLATE_SID = '29663';
const MOBILE = '9811226924'; // Without country code
const COUNTRY_CODE = '91';

// Generate OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Test 1: Send OTP with template format
function testSendOTPWithTemplate() {
  return new Promise((resolve, reject) => {
    const otp = generateOTP();
    
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  TEST 1: Send OTP with Template SID    ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Mobile: +${COUNTRY_CODE} ${MOBILE}${' '.repeat(15)} ║`);
    console.log(`║  OTP: ${otp}${' '.repeat(28)} ║`);
    console.log(`║  Template SID: ${TEMPLATE_SID}${' '.repeat(22)} ║`);
    console.log('╚════════════════════════════════════════╝');

    // Build query parameters using template format
    const params = new URLSearchParams({
      authkey: AUTHKEY_API_KEY,
      mobile: MOBILE,
      country_code: COUNTRY_CODE,
      sid: TEMPLATE_SID,
      otp: otp,
      company: 'ShowOff'
    });

    const path = `/request?${params.toString()}`;

    console.log('\n📤 Sending request to api.authkey.io...');
    console.log('   Endpoint: api.authkey.io/request');
    console.log('   Method: GET');
    console.log('   Parameters:');
    console.log(`     - authkey: ${AUTHKEY_API_KEY}`);
    console.log(`     - mobile: ${MOBILE}`);
    console.log(`     - country_code: ${COUNTRY_CODE}`);
    console.log(`     - sid: ${TEMPLATE_SID}`);
    console.log(`     - otp: ${otp}`);
    console.log(`     - company: ShowOff`);

    const options = {
      hostname: 'api.authkey.io',
      port: 443,
      path: path,
      method: 'GET',
      headers: {
        'Content-Type': 'application/json'
      }
    };

    const req = https.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          
          console.log('\n📥 Response received:');
          console.log('   Status Code:', res.statusCode);
          console.log('   Response:', JSON.stringify(response, null, 2));

          if (response.success && response.success.sms) {
            console.log('\n✅ SUCCESS: OTP sent with template format!');
            console.log('   Message:', response.message?.sms);
            resolve({
              success: true,
              otp: otp,
              response: response
            });
          } else if (response.LogID) {
            console.log('\n✅ SUCCESS: OTP sent (alternative format)!');
            console.log('   LogID:', response.LogID);
            console.log('   Message:', response.Message);
            resolve({
              success: true,
              otp: otp,
              logId: response.LogID,
              response: response
            });
          } else {
            console.log('\n❌ FAILED: Unexpected response format');
            reject(new Error('Unexpected response format'));
          }
        } catch (error) {
          console.error('\n❌ ERROR: Failed to parse response');
          console.error('   Error:', error.message);
          console.error('   Raw data:', data);
          reject(error);
        }
      });
    });

    req.on('error', (error) => {
      console.error('\n❌ ERROR: Request failed');
      console.error('   Error:', error.message);
      reject(error);
    });

    req.end();
  });
}

// Test 2: Verify OTP format in response
function testVerifyOTPFormat(testResult) {
  return new Promise((resolve, reject) => {
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  TEST 2: Verify OTP Format             ║');
    console.log('╠════════════════════════════════════════╣');
    
    if (testResult.response.success && testResult.response.success.sms) {
      console.log('║  ✅ Response has correct format        ║');
      console.log('║     - success.sms: true                ║');
      console.log('║     - message.sms: present             ║');
      console.log('╚════════════════════════════════════════╝');
      resolve(true);
    } else {
      console.log('║  ⚠️  Response format differs           ║');
      console.log('║     Check if template is configured    ║');
      console.log('╚════════════════════════════════════════╝');
      resolve(false);
    }
  });
}

// Run tests
async function runTests() {
  try {
    console.log('\n🚀 Starting AuthKey.io OTP Template Format Tests\n');
    
    // Test 1: Send OTP
    const testResult = await testSendOTPWithTemplate();
    
    // Test 2: Verify format
    await testVerifyOTPFormat(testResult);
    
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  ✅ ALL TESTS COMPLETED               ║');
    console.log('╠════════════════════════════════════════╣');
    console.log('║  OTP Code: ' + testResult.otp.padEnd(24) + '║');
    console.log('║  Status: Ready for verification       ║');
    console.log('╚════════════════════════════════════════╝\n');
    
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    process.exit(1);
  }
}

// Run the tests
runTests();
