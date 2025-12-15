/**
 * Complete OTP Flow Test
 * Simulates the entire OTP process: Send -> Receive -> Verify
 */

const https = require('https');

// Configuration
const API_BASE = 'http://localhost:3000';
const AUTHKEY_API_KEY = '4e51b96379db3b83';
const TEMPLATE_SID = '29663';
const TEST_MOBILE = '9811226924';
const TEST_COUNTRY_CODE = '91';

// In-memory OTP store (simulating server storage)
const otpStore = new Map();

// Generate OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Step 1: Send OTP
async function stepSendOTP() {
  return new Promise((resolve, reject) => {
    const otp = generateOTP();
    const identifier = `${TEST_COUNTRY_CODE}${TEST_MOBILE}`;
    
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  STEP 1: Send OTP                      ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Mobile: +${TEST_COUNTRY_CODE} ${TEST_MOBILE}${' '.repeat(15)} ║`);
    console.log(`║  OTP Generated: ${otp}${' '.repeat(20)} ║`);
    console.log('╚════════════════════════════════════════╝');

    // Store OTP in memory (simulating server)
    otpStore.set(identifier, {
      otp: otp,
      expiresAt: Date.now() + 10 * 60 * 1000, // 10 minutes
      attempts: 0,
      createdAt: Date.now()
    });

    // Send via AuthKey.io
    const params = new URLSearchParams({
      authkey: AUTHKEY_API_KEY,
      mobile: TEST_MOBILE,
      country_code: TEST_COUNTRY_CODE,
      sid: TEMPLATE_SID,
      otp: otp,
      company: 'ShowOff'
    });

    const path = `/request?${params.toString()}`;

    console.log('\n📤 Sending to AuthKey.io...');
    console.log('   Endpoint: api.authkey.io/request');
    console.log('   Parameters:');
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
          
          if (response.LogID && response.Message === 'Submitted Successfully') {
            console.log('\n✅ OTP Sent Successfully!');
            console.log('   LogID:', response.LogID);
            console.log('   Message:', response.Message);
            console.log(`   OTP Code: ${otp}`);
            console.log('   Status: Waiting for user input...');
            
            resolve({
              success: true,
              otp: otp,
              logId: response.LogID,
              identifier: identifier
            });
          } else {
            reject(new Error('Failed to send OTP'));
          }
        } catch (error) {
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.end();
  });
}

// Step 2: User Enters OTP (Simulated)
async function stepUserEntersOTP(correctOTP) {
  return new Promise((resolve) => {
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  STEP 2: User Enters OTP               ║');
    console.log('╠════════════════════════════════════════╣');
    
    // Simulate user entering correct OTP
    const enteredOTP = correctOTP;
    console.log(`║  Entered OTP: ${enteredOTP}${' '.repeat(20)} ║`);
    console.log('║  Status: Submitting for verification   ║');
    console.log('╚════════════════════════════════════════╝');
    
    resolve(enteredOTP);
  });
}

// Step 3: Verify OTP
async function stepVerifyOTP(enteredOTP, identifier) {
  return new Promise((resolve, reject) => {
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  STEP 3: Verify OTP                    ║');
    console.log('╠════════════════════════════════════════╣');
    
    const storedSession = otpStore.get(identifier);
    
    if (!storedSession) {
      console.log('║  ❌ OTP session not found              ║');
      console.log('╚════════════════════════════════════════╝');
      reject(new Error('OTP session expired'));
      return;
    }

    // Check expiry
    if (Date.now() > storedSession.expiresAt) {
      console.log('║  ❌ OTP expired                        ║');
      console.log('╚════════════════════════════════════════╝');
      otpStore.delete(identifier);
      reject(new Error('OTP expired'));
      return;
    }

    // Check attempts
    if (storedSession.attempts >= 3) {
      console.log('║  ❌ Too many failed attempts           ║');
      console.log('╚════════════════════════════════════════╝');
      otpStore.delete(identifier);
      reject(new Error('Too many attempts'));
      return;
    }

    console.log(`║  Stored OTP: ${storedSession.otp}${' '.repeat(20)} ║`);
    console.log(`║  Entered OTP: ${enteredOTP}${' '.repeat(20)} ║`);
    console.log(`║  Attempts: ${storedSession.attempts}/3${' '.repeat(24)} ║`);

    // Verify OTP
    if (storedSession.otp === enteredOTP) {
      console.log('║  ✅ OTP VERIFIED - MATCH!              ║');
      console.log('╚════════════════════════════════════════╝');
      
      otpStore.delete(identifier);
      
      resolve({
        success: true,
        message: 'OTP verified successfully'
      });
    } else {
      storedSession.attempts += 1;
      console.log(`║  ❌ Invalid OTP - Attempt ${storedSession.attempts}/3${' '.repeat(15)} ║`);
      console.log('╚════════════════════════════════════════╝');
      
      reject(new Error(`Invalid OTP (${3 - storedSession.attempts} attempts left)`));
    }
  });
}

// Test Scenario 1: Successful OTP Flow
async function testSuccessfulFlow() {
  try {
    console.log('\n\n🚀 TEST SCENARIO 1: Successful OTP Flow\n');
    
    // Step 1: Send OTP
    const sendResult = await stepSendOTP();
    
    // Step 2: User enters correct OTP
    const enteredOTP = await stepUserEntersOTP(sendResult.otp);
    
    // Step 3: Verify OTP
    const verifyResult = await stepVerifyOTP(enteredOTP, sendResult.identifier);
    
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  ✅ TEST PASSED: Complete Flow Works   ║');
    console.log('╠════════════════════════════════════════╣');
    console.log('║  1. OTP Generated ✅                   ║');
    console.log('║  2. OTP Sent via AuthKey.io ✅         ║');
    console.log('║  3. User Entered OTP ✅                ║');
    console.log('║  4. OTP Verified ✅                    ║');
    console.log('╚════════════════════════════════════════╝\n');
    
    return true;
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    return false;
  }
}

// Test Scenario 2: Wrong OTP
async function testWrongOTP() {
  try {
    console.log('\n\n🚀 TEST SCENARIO 2: Wrong OTP Entered\n');
    
    // Step 1: Send OTP
    const sendResult = await stepSendOTP();
    
    // Step 2: User enters WRONG OTP
    const wrongOTP = '000000';
    const enteredOTP = await stepUserEntersOTP(wrongOTP);
    
    // Step 3: Try to verify (should fail)
    try {
      await stepVerifyOTP(enteredOTP, sendResult.identifier);
      console.log('\n❌ TEST FAILED: Should have rejected wrong OTP');
      return false;
    } catch (error) {
      console.log('\n✅ TEST PASSED: Correctly rejected wrong OTP');
      console.log('   Error:', error.message);
      return true;
    }
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    return false;
  }
}

// Run all tests
async function runAllTests() {
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║  Complete OTP Flow Test Suite          ║');
  console.log('╚════════════════════════════════════════╝');
  
  const test1 = await testSuccessfulFlow();
  const test2 = await testWrongOTP();
  
  console.log('\n╔════════════════════════════════════════╗');
  console.log('║  Test Results Summary                  ║');
  console.log('╠════════════════════════════════════════╣');
  console.log(`║  Scenario 1 (Success): ${test1 ? '✅ PASS' : '❌ FAIL'}${' '.repeat(18)} ║`);
  console.log(`║  Scenario 2 (Wrong OTP): ${test2 ? '✅ PASS' : '❌ FAIL'}${' '.repeat(14)} ║`);
  console.log('╠════════════════════════════════════════╣');
  console.log(`║  Overall: ${test1 && test2 ? '✅ ALL TESTS PASSED' : '❌ SOME TESTS FAILED'}${' '.repeat(12)} ║`);
  console.log('╚════════════════════════════════════════╝\n');
}

// Run tests
runAllTests().catch(console.error);
