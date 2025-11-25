/**
 * Direct endpoint test to diagnose 405 error
 */

const http = require('http');

console.log('Testing POST /api/auth/phone-email-verify\n');

const data = JSON.stringify({
  user_json_url: 'https://user.phone.email/test.json'
});

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/auth/phone-email-verify',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': data.length
  }
};

const req = http.request(options, (res) => {
  console.log('Status Code:', res.statusCode);
  console.log('Status Message:', res.statusMessage);
  console.log('Headers:', JSON.stringify(res.headers, null, 2));
  console.log('\nResponse:');
  
  let body = '';
  res.on('data', (chunk) => {
    body += chunk;
  });
  
  res.on('end', () => {
    console.log(body);
    
    if (res.statusCode === 405) {
      console.log('\n❌ 405 Method Not Allowed');
      console.log('This means the route exists but POST is not allowed.');
      console.log('\nPossible causes:');
      console.log('1. Route is defined as GET instead of POST');
      console.log('2. Middleware is blocking POST requests');
      console.log('3. CORS preflight issue');
      console.log('4. Route definition error');
    } else if (res.statusCode === 400) {
      console.log('\n✅ Endpoint is working! (400 = missing data, which is expected)');
    } else if (res.statusCode === 404) {
      console.log('\n❌ 404 Not Found - Route does not exist');
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Error:', error.message);
  console.log('\nServer is not running. Start it with: cd server && npm start');
});

req.write(data);
req.end();
