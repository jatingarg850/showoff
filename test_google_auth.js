/**
 * Test Google OAuth Integration
 * 
 * This script helps test the Google Sign-In endpoint
 * You'll need a valid Google ID token to test
 */

const http = require('http');

console.log('╔════════════════════════════════════════════════════════╗');
console.log('║     Google OAuth Integration Test                     ║');
console.log('╚════════════════════════════════════════════════════════╝\n');

console.log('📝 Instructions:');
console.log('   1. Get a Google ID token from your Flutter app');
console.log('   2. Run: node test_google_auth.js <ID_TOKEN>');
console.log('   3. Or test the web flow at: http://localhost:3000/api/auth/google/redirect\n');

const idToken = process.argv[2];

if (!idToken) {
  console.log('⚠️  No ID token provided');
  console.log('\n📱 To test with Flutter app:');
  console.log('   1. Implement Google Sign-In in Flutter');
  console.log('   2. Get the ID token after sign-in');
  console.log('   3. Run: node test_google_auth.js <token>\n');
  
  console.log('🌐 To test web flow:');
  console.log('   1. Start server: cd server && npm start');
  console.log('   2. Open: http://localhost:3000/api/auth/google/redirect');
  console.log('   3. Sign in with Google');
  console.log('   4. Check server logs\n');
  
  console.log('🧪 To test with mock data:');
  console.log('   Run: node test_google_auth.js mock\n');
  process.exit(0);
}

if (idToken === 'mock') {
  console.log('🧪 Testing with mock data (will fail verification but tests endpoint)\n');
}

const testData = JSON.stringify({
  idToken: idToken === 'mock' ? 'mock_token_for_testing' : idToken
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/google',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': testData.length
  }
};

console.log('📡 Sending request to:', `http://localhost:3000${options.path}`);
console.log('🔑 ID Token:', idToken.substring(0, 30) + '...\n');

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('📊 Response Status:', res.statusCode);
    console.log('📄 Response Body:\n');
    
    try {
      const response = JSON.parse(data);
      console.log(JSON.stringify(response, null, 2));
      
      if (response.success) {
        console.log('\n✅ GOOGLE AUTHENTICATION SUCCESSFUL!');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('\n👤 User Details:');
        console.log('   Username:', response.data.user.username);
        console.log('   Email:', response.data.user.email);
        console.log('   Display Name:', response.data.user.displayName);
        console.log('   Profile Picture:', response.data.user.profilePicture);
        console.log('   Coin Balance:', response.data.user.coinBalance);
        console.log('\n🔑 JWT Token:', response.data.token.substring(0, 30) + '...');
        console.log('\n🎉 User is now logged in!');
        console.log('\n' + '='.repeat(60) + '\n');
      } else {
        console.log('\n❌ AUTHENTICATION FAILED');
        console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        console.log('Error:', response.message);
        console.log('\n💡 Troubleshooting:');
        console.log('   1. Check if server is running');
        console.log('   2. Verify Google credentials in .env');
        console.log('   3. Ensure ID token is valid and not expired');
        console.log('   4. Check server logs for detailed errors\n');
      }
    } catch (error) {
      console.log(data);
      console.log('\n❌ Failed to parse JSON response');
    }
  });
});

req.on('error', (error) => {
  console.log('❌ CONNECTION ERROR!');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log('Error:', error.message);
  console.log('\n💡 Make sure server is running: cd server && npm start\n');
});

req.write(testData);
req.end();
