const http = require('http');

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/rewarded-ads',
  method: 'GET',
  headers: {
    'Content-Type': 'application/json',
  },
};

const req = http.request(options, (res) => {
  let data = '';
  res.on('data', (chunk) => {
    data += chunk;
  });
  res.on('end', () => {
    console.log('Status:', res.statusCode);
    console.log('Response:', data);
    try {
      const parsed = JSON.parse(data);
      console.log('\nParsed Response:');
      console.log(JSON.stringify(parsed, null, 2));
    } catch (e) {
      console.log('Parse error:', e.message);
    }
    process.exit(0);
  });
});

req.on('error', (error) => {
  console.error('Error:', error);
  process.exit(1);
});

req.end();
