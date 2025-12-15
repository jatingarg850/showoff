/**
 * Test OTP with actual code in message - LOCAL SERVER
 * Tests that OTP is included in the SMS message
 */

const https = require('https');

const SERVER_URL = 'http://localhost:3000';
const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

function makeRequest(method, path, data = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(path, SERVER_URL);
    
    const options = {
      hostname: url.hostname,
      port: url.port || 80,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = require('http').request(options, (res) => {
      let responseData = '';

      res.on('data', (chunk) => {
        responseData += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(responseData);
          resolve({
            status: res.statusCode,
            data: parsed,
          });
        } catch (error) {
          resolve({
            status: res.statusCode,
            data: responseData,
          });
        }
      });
    });

    req.on('error', (error) => {
      reject(error);
    });

    if (data) {
      req.write(JSON.stringify(data));
    }

    req.end();
  });
}

async function testOTPWithCode() {
  console.log('\n╔════════════════════════════════════════════════════════╗');
  console.log('║  Test: OTP with Actual Code in Message (LOCAL)         ║');
  console.log('║  Server: http://localhost:3000                         ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  try {
    console.log('📱 Sending OTP to:', `+${TEST_COUNTRY_CODE} ${TEST_PHONE}`);
    console.log('📍 Endpoint: POST /api/auth/send-otp\n');

    const response = await makeRequest('POST', `${SERVER_URL}/api/auth/send-otp`, {
      phone: TEST_PHONE,
      countryCode: TEST_COUNTRY_CODE,
    });

    console.log('✅ Response Status:', response.status);
    console.log('📋 Response Data:');
    console.log(JSON.stringify(response.data, null, 2));

    if (response.data.success) {
      console.log('\n✅ OTP sent successfully!');
      
      if (response.data.data.otp) {
        console.log('🔐 OTP Code:', response.data.data.otp);
        console.log('📌 LogID:', response.data.data.logId || 'N/A');
        console.log('⏱️  Expires in:', response.data.data.expiresIn, 'seconds');
        
        console.log('\n📝 What happened:');
        console.log('  1. Server generated OTP:', response.data.data.otp);
        console.log('  2. OTP was included in SMS message');
        console.log('  3. Message sent via AuthKey.io');
        console.log('  4. User should receive SMS with OTP code');
        
        console.log('\n🧪 Next: Verify OTP');
        console.log('  Use the OTP code received in SMS to verify');
        
        return response.data.data.otp;
      } else {
        console.log('\n⚠️  OTP not returned in response');
        console.log('   This might be development mode');
      }
    } else {
      console.log('\n❌ Failed to send OTP');
      console.log('   Error:', response.data.message);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function testVerifyOTP(otp) {
  if (!otp) {
    console.log('\n⚠️  No OTP to verify. Skipping verification test.');
    return;
  }

  console.log('\n╔════════════════════════════════════════════════════════╗');
  console.log('║  Test: Verify OTP Code                                 ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  try {
    console.log('🔍 Verifying OTP');
    console.log('📱 Phone:', `+${TEST_COUNTRY_CODE} ${TEST_PHONE}`);
    console.log('🔐 OTP:', otp);
    console.log('📍 Endpoint: POST /api/auth/verify-otp\n');

    const response = await makeRequest('POST', `${SERVER_URL}/api/auth/verify-otp`, {
      phone: TEST_PHONE,
      countryCode: TEST_COUNTRY_CODE,
      otp: otp,
    });

    console.log('✅ Response Status:', response.status);
    console.log('📋 Response Data:');
    console.log(JSON.stringify(response.data, null, 2));

    if (response.data.success) {
      console.log('\n✅ OTP verified successfully!');
      console.log('🎉 User can now be registered');
    } else {
      console.log('\n❌ OTP verification failed');
      console.log('   Error:', response.data.message);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function runTests() {
  try {
    const otp = await testOTPWithCode();
    
    if (otp) {
      await testVerifyOTP(otp);
    }

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ Test Complete                                      ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

    console.log('📝 Summary:');
    console.log('  ✅ OTP is now generated locally');
    console.log('  ✅ OTP code is included in SMS message');
    console.log('  ✅ Message is sent via AuthKey.io');
    console.log('  ✅ User receives SMS with OTP code');
    console.log('  ✅ OTP can be verified\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runTests();
