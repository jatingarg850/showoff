/**
 * Test Resend Email OTP Service
 * Tests email OTP sending via Resend API
 */

const https = require('https');

// Configuration
const RESEND_API_KEY = 're_your_resend_api_key_here'; // Replace with actual key
const FROM_EMAIL = 'noreply@showoff.life';
const TEST_EMAIL = 'test@example.com'; // Replace with test email

// Generate OTP
function generateOTP() {
  return Math.floor(100000 + Math.random() * 900000).toString();
}

// Send Email OTP via Resend
function sendEmailOTP(email) {
  return new Promise((resolve, reject) => {
    if (!RESEND_API_KEY || RESEND_API_KEY === 're_your_resend_api_key_here') {
      return reject(new Error('Resend API key not configured. Please set RESEND_API_KEY in .env'));
    }

    const otp = generateOTP();

    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  TEST: Send Email OTP via Resend       ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Email: ${email.padEnd(30)} ║`);
    console.log(`║  OTP: ${otp.padEnd(32)} ║`);
    console.log('╚════════════════════════════════════════╝');

    const emailSubject = 'Your ShowOff.life OTP';
    const emailHtml = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 20px; border-radius: 8px 8px 0 0; text-align: center;">
          <h1 style="color: white; margin: 0;">ShowOff.life</h1>
        </div>
        <div style="background: #f9f9f9; padding: 30px; border-radius: 0 0 8px 8px;">
          <p style="color: #333; font-size: 16px; margin-bottom: 20px;">
            Hello,
          </p>
          <p style="color: #333; font-size: 16px; margin-bottom: 30px;">
            Your ShowOff.life OTP is:
          </p>
          <div style="background: white; border: 2px solid #667eea; border-radius: 8px; padding: 20px; text-align: center; margin-bottom: 30px;">
            <p style="font-size: 32px; font-weight: bold; color: #667eea; margin: 0; letter-spacing: 5px;">
              ${otp}
            </p>
          </div>
          <p style="color: #666; font-size: 14px; margin-bottom: 10px;">
            This OTP is valid for 10 minutes.
          </p>
          <p style="color: #666; font-size: 14px; margin-bottom: 20px;">
            Do not share this code with anyone.
          </p>
          <hr style="border: none; border-top: 1px solid #ddd; margin: 30px 0;">
          <p style="color: #999; font-size: 12px; text-align: center;">
            If you didn't request this OTP, please ignore this email.
          </p>
        </div>
      </div>
    `;

    const emailText = `Your ShowOff.life OTP is ${otp}. Do not share this code with anyone. Valid for 10 minutes.`;

    const requestBody = JSON.stringify({
      from: FROM_EMAIL,
      to: email,
      subject: emailSubject,
      html: emailHtml,
      text: emailText
    });

    const options = {
      hostname: 'api.resend.com',
      port: 443,
      path: '/emails',
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(requestBody),
        'Authorization': `Bearer ${RESEND_API_KEY}`
      }
    };

    console.log('\n📤 Sending request to Resend API...');
    console.log('   Endpoint: api.resend.com/emails');
    console.log('   Method: POST');
    console.log('   From:', FROM_EMAIL);
    console.log('   To:', email);
    console.log('   Subject:', emailSubject);

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

          if (res.statusCode === 200 && response.id) {
            console.log('\n✅ SUCCESS: Email OTP sent via Resend!');
            console.log('   Message ID:', response.id);
            console.log('   OTP Code:', otp);
            resolve({
              success: true,
              messageId: response.id,
              otp: otp
            });
          } else {
            console.log('\n❌ FAILED: Unexpected response');
            reject(new Error(response.message || 'Failed to send email'));
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

    req.write(requestBody);
    req.end();
  });
}

// Run test
async function runTest() {
  try {
    console.log('\n🚀 Starting Resend Email OTP Test\n');
    
    // Check if API key is configured
    if (RESEND_API_KEY === 're_your_resend_api_key_here') {
      console.log('⚠️  WARNING: Resend API key not configured!');
      console.log('\n📝 To test Resend email OTP:');
      console.log('   1. Get your API key from https://resend.com');
      console.log('   2. Update RESEND_API_KEY in this file or .env');
      console.log('   3. Update TEST_EMAIL with your test email');
      console.log('   4. Run this test again\n');
      process.exit(0);
    }

    const result = await sendEmailOTP(TEST_EMAIL);
    
    console.log('\n╔════════════════════════════════════════╗');
    console.log('║  ✅ TEST COMPLETED SUCCESSFULLY       ║');
    console.log('╠════════════════════════════════════════╣');
    console.log(`║  Message ID: ${result.messageId.padEnd(22)} ║`);
    console.log(`║  OTP Code: ${result.otp.padEnd(26)} ║`);
    console.log('║  Status: Email sent to inbox           ║');
    console.log('╚════════════════════════════════════════╝\n');
    
  } catch (error) {
    console.error('\n❌ TEST FAILED:', error.message);
    process.exit(1);
  }
}

// Run the test
runTest();
