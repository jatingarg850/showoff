const https = require('https');

// Test scenario: Sign up on one phone, sign in from another
const testPhone = '9876543210';
const countryCode1 = '+1'; // US
const countryCode2 = '+1'; // Same country code (should work)

async function makeRequest(method, path, body) {
  return new Promise((resolve, reject) => {
    const options = {
      hostname: 'localhost',
      port: 3000,
      path: `/api${path}`,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    const req = require('http').request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve({ raw: data });
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function testCrossPhoneSignIn() {
  console.log('🧪 Testing Cross-Phone Sign-In Flow\n');

  try {
    // Step 1: Send OTP for signup
    console.log('📱 Step 1: Sending OTP for signup (Phone 1)...');
    const sendOtpRes = await makeRequest('POST', '/auth/send-otp', {
      phone: testPhone,
      countryCode: countryCode1,
    });
    console.log('Response:', sendOtpRes);
    console.log('');

    // Step 2: Verify OTP (using development OTP)
    console.log('✅ Step 2: Verifying OTP...');
    const verifyOtpRes = await makeRequest('POST', '/auth/verify-otp', {
      phone: testPhone,
      countryCode: countryCode1,
      otp: sendOtpRes.otp || '123456', // Use returned OTP or fallback
    });
    console.log('Response:', verifyOtpRes);
    console.log('');

    // Step 3: Register account
    console.log('📝 Step 3: Registering account...');
    const registerRes = await makeRequest('POST', '/auth/register', {
      username: `testuser_${Date.now()}`,
      displayName: 'Test User',
      password: 'TestPassword123!',
      phone: `${countryCode1}${testPhone}`,
      termsAccepted: true,
    });
    console.log('Response:', registerRes);
    console.log('');

    if (!registerRes.success) {
      console.log('❌ Registration failed:', registerRes.message);
      return;
    }

    console.log('✅ Account created successfully!');
    console.log('');

    // Step 4: Try to sign in from another phone (same country code)
    console.log('📱 Step 4: Sending OTP for sign-in (Phone 2 - same country)...');
    const signInOtpRes = await makeRequest('POST', '/auth/send-otp', {
      phone: testPhone,
      countryCode: countryCode2,
    });
    console.log('Response:', signInOtpRes);
    console.log('');

    // Step 5: Verify OTP for sign-in
    console.log('✅ Step 5: Verifying OTP for sign-in...');
    const signInVerifyRes = await makeRequest('POST', '/auth/verify-otp', {
      phone: testPhone,
      countryCode: countryCode2,
      otp: signInOtpRes.otp || '123456',
    });
    console.log('Response:', signInVerifyRes);
    console.log('');

    // Step 6: Sign in with phone OTP
    console.log('🔐 Step 6: Signing in with phone OTP...');
    const signInRes = await makeRequest('POST', '/auth/signin-phone-otp', {
      phone: testPhone,
      countryCode: countryCode2,
    });
    console.log('Response:', signInRes);
    console.log('');

    if (signInRes.success) {
      console.log('✅ SUCCESS! Account found and signed in from different phone!');
      console.log('User:', signInRes.data.user.username);
    } else {
      console.log('❌ FAILED! Account not found:', signInRes.message);
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testCrossPhoneSignIn();
