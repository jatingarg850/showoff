/**
 * Test AuthKey.io OTP Verification
 * Usage: node test_authkey_verify.js <OTP>
 */

const http = require('http');

// Get OTP from command line argument
const otp = process.argv[2];

if (!otp) {
  console.log('❌ Error: OTP not provided');
  console.log('\nUsage: node test_authkey_verify.js <OTP>');
  console.log('Example: node test_authkey_verify.js 123456\n');
  process.exit(1);
}

// Configuration
const API_BASE = 'http://localhost:3000';
const TEST_PHONE = '9811226924';
const TEST_COUNTRY_CODE = '91';

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║     AuthKey.io OTP Verification Test                  ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('📱 Test Phone:', `+${TEST_COUNTRY_CODE} ${TEST_PHONE}`);
console.log('🔐 OTP:', otp);
console.log('🌐 API Base:', API_BASE);
console.log('\n' + '='.repeat(60) + '\n');

console.log('Verifying OTP...\n');

const verifyData = JSON.stringify({
  phone: TEST_PHONE,
  countryCode: TEST_COUNTRY_CODE,
  otp: otp
});

const verifyOptions = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/verify-otp',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': verifyData.length
  }
};

const verifyReq = http.request(verifyOptions, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📡 Response Status:', res.statusCode);
    console.log('📄 Response Body:\n');
    
    try {
      const response = JSON.parse(data);
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success) {
        console.log('\n✅ OTP VERIFIED SUCCESSFULLY!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('\n🎉 Phone number verification complete!');
        console.log('   User can now proceed with registration.');
        console.log('\n' + '='.repeat(60) + '\n');
        
      } else {
        console.log('\n❌ OTP VERIFICATION FAILED');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('Error:', response.message);
        
        if (response.attemptsLeft !== undefined) {
          console.log('Attempts Left:', response.attemptsLeft);
        }
        
        console.log('\n💡 Troubleshooting:');
        console.log('   1. Check if OTP is correct');
        console.log('   2. Verify OTP has not expired (10 minutes)');
        console.log('   3. Check if too many attempts (max 3)');
        console.log('   4. Request a new OTP if needed\n');
      }
    } catch (error) {
      console.log(data);
      console.log('\n❌ Failed to parse JSON response');
    }
  });
});

verifyReq.on('error', (error) => {
  console.log('❌ CONNECTION ERROR!');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Error:', error.message);
  console.log('\n💡 Make sure server is running: cd server && npm start\n');
});

verifyReq.write(verifyData);
verifyReq.end();
