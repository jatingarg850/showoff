/**
 * Diagnose 405 Error
 * Tests different HTTP methods on the endpoint
 */

const http = require('http');

const testMethods = ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS', 'PATCH'];

console.log('╔════════════════════════════════════════╗');
console.log('║   Diagnosing 405 Error                 ║');
console.log('╚════════════════════════════════════════╝\n');

console.log('Testing endpoint: /api/auth/phone-email-verify\n');

let testsCompleted = 0;

testMethods.forEach((method) => {
  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/auth/phone-email-verify',
    method: method,
    headers: {
      'Content-Type': 'application/json'
    }
  };

  const req = http.request(options, (res) => {
    console.log(`${method.padEnd(8)} → Status: ${res.statusCode} ${res.statusMessage}`);
    
    testsCompleted++;
    if (testsCompleted === testMethods.length) {
      console.log('\n╔════════════════════════════════════════╗');
      console.log('║   Analysis                             ║');
      console.log('╚════════════════════════════════════════╝');
      console.log('\nExpected results:');
      console.log('  POST    → 400 (Bad Request - missing data)');
      console.log('  OPTIONS → 200 or 204 (CORS preflight)');
      console.log('  Others  → 404 or 405\n');
      console.log('If POST returns 405, the route is not');
      console.log('properly configured for POST requests.\n');
    }
  });

  req.on('error', (error) => {
    console.log(`${method.padEnd(8)} → Error: ${error.message}`);
    testsCompleted++;
  });

  if (method === 'POST' || method === 'PUT' || method === 'PATCH') {
    req.write(JSON.stringify({ test: 'data' }));
  }
  
  req.end();
});
