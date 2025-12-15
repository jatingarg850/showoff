/**
 * Test Check Email and Phone Availability Endpoints
 * Tests the new check-email and check-phone endpoints
 */

const http = require('http');

const BASE_URL = 'http://localhost:3000';

// Test 1: Check Email Availability
function testCheckEmail(email, shouldExist = false) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ email });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/check-email',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log(`\n📧 Testing Email: ${email}`);
    console.log('   Endpoint: POST /api/auth/check-email');

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('   Response:', JSON.stringify(response, null, 2));

          if (response.available) {
            console.log('   ✅ Email is available');
            resolve(true);
          } else {
            console.log('   ❌ Email already exists');
            resolve(false);
          }
        } catch (error) {
          console.error('   Error parsing response:', error.message);
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Test 2: Check Phone Availability
function testCheckPhone(phone, countryCode = '91', shouldExist = false) {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ phone, countryCode });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/check-phone',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log(`\n📱 Testing Phone: +${countryCode} ${phone}`);
    console.log('   Endpoint: POST /api/auth/check-phone');

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('   Response:', JSON.stringify(response, null, 2));

          if (response.available) {
            console.log('   ✅ Phone is available');
            resolve(true);
          } else {
            console.log('   ❌ Phone already exists');
            resolve(false);
          }
        } catch (error) {
          console.error('   Error parsing response:', error.message);
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Test 3: Invalid Email Format
function testInvalidEmail() {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ email: 'invalid-email' });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/check-email',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log(`\n📧 Testing Invalid Email: invalid-email`);
    console.log('   Endpoint: POST /api/auth/check-email');

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('   Response:', JSON.stringify(response, null, 2));

          if (!response.success) {
            console.log('   ✅ Invalid email rejected correctly');
            resolve(true);
          } else {
            console.log('   ❌ Invalid email should be rejected');
            resolve(false);
          }
        } catch (error) {
          console.error('   Error parsing response:', error.message);
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Test 4: Invalid Phone Format
function testInvalidPhone() {
  return new Promise((resolve, reject) => {
    const postData = JSON.stringify({ phone: '123', countryCode: '91' });

    const options = {
      hostname: 'localhost',
      port: 3000,
      path: '/api/auth/check-phone',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData)
      }
    };

    console.log(`\n📱 Testing Invalid Phone: 123`);
    console.log('   Endpoint: POST /api/auth/check-phone');

    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const response = JSON.parse(data);
          console.log('   Response:', JSON.stringify(response, null, 2));

          if (!response.success) {
            console.log('   ✅ Invalid phone rejected correctly');
            resolve(true);
          } else {
            console.log('   ❌ Invalid phone should be rejected');
            resolve(false);
          }
        } catch (error) {
          console.error('   Error parsing response:', error.message);
          reject(error);
        }
      });
    });

    req.on('error', reject);
    req.write(postData);
    req.end();
  });
}

// Run all tests
async function runTests() {
  try {
    console.log('\n╔════════════════════════════════════════════════════════════╗');
    console.log('║  Test: Check Email and Phone Availability Endpoints       ║');
    console.log('╚════════════════════════════════════════════════════════════╝');

    // Test 1: Check new email (should be available)
    console.log('\n\n--- Test 1: Check New Email (Should be Available) ---');
    const newEmailAvailable = await testCheckEmail('newuser@example.com');

    // Test 2: Check new phone (should be available)
    console.log('\n\n--- Test 2: Check New Phone (Should be Available) ---');
    const newPhoneAvailable = await testCheckPhone('9999999999');

    // Test 3: Invalid email format
    console.log('\n\n--- Test 3: Invalid Email Format ---');
    const invalidEmailRejected = await testInvalidEmail();

    // Test 4: Invalid phone format
    console.log('\n\n--- Test 4: Invalid Phone Format ---');
    const invalidPhoneRejected = await testInvalidPhone();

    // Summary
    console.log('\n\n╔════════════════════════════════════════════════════════════╗');
    console.log('║                    Test Summary                            ║');
    console.log('╠════════════════════════════════════════════════════════════╣');
    console.log(`║  New Email Available: ${newEmailAvailable ? '✅ PASS' : '❌ FAIL'}${' '.repeat(35)} ║`);
    console.log(`║  New Phone Available: ${newPhoneAvailable ? '✅ PASS' : '❌ FAIL'}${' '.repeat(35)} ║`);
    console.log(`║  Invalid Email Rejected: ${invalidEmailRejected ? '✅ PASS' : '❌ FAIL'}${' '.repeat(31)} ║`);
    console.log(`║  Invalid Phone Rejected: ${invalidPhoneRejected ? '✅ PASS' : '❌ FAIL'}${' '.repeat(31)} ║`);
    console.log('╚════════════════════════════════════════════════════════════╝\n');

    if (newEmailAvailable && newPhoneAvailable && invalidEmailRejected && invalidPhoneRejected) {
      console.log('✅ All tests passed!\n');
      process.exit(0);
    } else {
      console.log('❌ Some tests failed!\n');
      process.exit(1);
    }
  } catch (error) {
    console.error('\n❌ Test error:', error.message);
    process.exit(1);
  }
}

// Run tests
runTests();
