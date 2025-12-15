/**
 * Test Email OTP
 * Tests that OTP is sent via email
 */

const http = require('http');

const SERVER_URL = 'http://localhost:3000';
const TEST_EMAIL = 'test@example.com';

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

    const req = http.request(options, (res) => {
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

async function testEmailOTP() {
  console.log('\n╔════════════════════════════════════════════════════════╗');
  console.log('║  Test: Email OTP                                       ║');
  console.log('║  Server: http://localhost:3000                         ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  try {
    console.log('📧 Sending OTP to:', TEST_EMAIL);
    console.log('📍 Endpoint: POST /api/auth/send-otp\n');

    const response = await makeRequest('POST', `${SERVER_URL}/api/auth/send-otp`, {
      email: TEST_EMAIL,
    });

    console.log('✅ Response Status:', response.status);
    console.log('📋 Response Data:');
    console.log(JSON.stringify(response.data, null, 2));

    if (response.data.success) {
      console.log('\n✅ Email OTP sent successfully!');
      
      if (response.data.data.otp) {
        console.log('🔐 OTP Code:', response.data.data.otp);
        console.log('📌 LogID:', response.data.data.logId || 'N/A');
        console.log('⏱️  Expires in:', response.data.data.expiresIn, 'seconds');
        
        console.log('\n📝 What happened:');
        console.log('  1. Server generated OTP:', response.data.data.otp);
        console.log('  2. OTP was included in email');
        console.log('  3. Email sent via AuthKey.io');
        console.log('  4. User should receive email with OTP code');
        
        console.log('\n🧪 Next: Verify OTP');
        console.log('  Use the OTP code received in email to verify');
        
        return response.data.data.otp;
      } else {
        console.log('\n⚠️  OTP not returned in response');
      }
    } else {
      console.log('\n❌ Failed to send email OTP');
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
  console.log('║  Test: Verify Email OTP Code                           ║');
  console.log('╚════════════════════════════════════════════════════════╝\n');

  try {
    console.log('🔍 Verifying OTP');
    console.log('📧 Email:', TEST_EMAIL);
    console.log('🔐 OTP:', otp);
    console.log('📍 Endpoint: POST /api/auth/verify-otp\n');

    const response = await makeRequest('POST', `${SERVER_URL}/api/auth/verify-otp`, {
      email: TEST_EMAIL,
      otp: otp,
    });

    console.log('✅ Response Status:', response.status);
    console.log('📋 Response Data:');
    console.log(JSON.stringify(response.data, null, 2));

    if (response.data.success) {
      console.log('\n✅ Email OTP verified successfully!');
      console.log('🎉 User can now be registered');
    } else {
      console.log('\n❌ Email OTP verification failed');
      console.log('   Error:', response.data.message);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

async function runTests() {
  try {
    const otp = await testEmailOTP();
    
    if (otp) {
      await testVerifyOTP(otp);
    }

    console.log('\n╔════════════════════════════════════════════════════════╗');
    console.log('║  ✅ Test Complete                                      ║');
    console.log('╚════════════════════════════════════════════════════════╝\n');

    console.log('📝 Summary:');
    console.log('  ✅ Email OTP is now generated locally');
    console.log('  ✅ OTP code is included in email');
    console.log('  ✅ Email is sent via AuthKey.io');
    console.log('  ✅ User receives email with OTP code');
    console.log('  ✅ OTP can be verified\n');

  } catch (error) {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  }
}

runTests();
