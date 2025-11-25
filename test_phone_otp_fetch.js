// Node.js script to test Phone.email OTP Integration using fetch
// Run with: node test_phone_otp_fetch.js

const clientId = '16687983578815655151';
const apiKey = 'I1WSXNX52SESBCdtjbXIV8TjKhlQ8Qrf';
const phoneNumber = '+919811226924';

console.log('🚀 Testing Phone.email OTP Integration\n');
console.log('📱 Sending OTP to:', phoneNumber);
console.log('🔑 Using Client ID:', clientId);
console.log('');

async function sendOTP() {
  try {
    console.log('📡 Sending request to Phone.email API...');
    console.log('');

    const response = await fetch('https://api.phone.email/auth/v1/otp', {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'X-Client-Id': clientId,
        'X-API-Key': apiKey
      },
      body: JSON.stringify({
        phone_number: phoneNumber
      })
    });

    console.log('📡 Response Status:', response.status);
    console.log('');

    const data = await response.json();
    console.log('📄 Response Body:', JSON.stringify(data, null, 2));
    console.log('');

    if (response.ok) {
      console.log('✅ SUCCESS! OTP sent successfully');
      console.log('📨 Session ID:', data.session_id || 'N/A');
      console.log('⏰ Expires in:', data.expires_in || 'N/A', 'seconds');
      console.log('');
      console.log('💡 Check your phone for the OTP code!');
    } else {
      console.log('❌ FAILED to send OTP');
      console.log('Error:', data.message || data.error || 'Unknown error');
    }
  } catch (error) {
    console.error('❌ ERROR:', error.message);
    console.error('');
    console.error('Troubleshooting:');
    console.error('1. Check your internet connection');
    console.error('2. Verify the API endpoint is accessible');
    console.error('3. Try testing via Postman or the Admin Dashboard');
    console.error('4. Check if your firewall is blocking the request');
  }
}

sendOTP();
