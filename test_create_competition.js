/**
 * Test script to verify competition creation works
 */

const http = require('http');

const testData = {
  type: 'weekly',
  title: 'Test Competition ' + new Date().getTime(),
  description: 'Test competition for verification',
  startDate: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(), // Tomorrow
  endDate: new Date(Date.now() + 8 * 24 * 60 * 60 * 1000).toISOString(), // 8 days from now
  prizes: [
    { position: 1, coins: 1000, badge: 'Gold' },
    { position: 2, coins: 500, badge: 'Silver' },
    { position: 3, coins: 250, badge: 'Bronze' }
  ]
};

console.log('📝 Test Data:');
console.log(JSON.stringify(testData, null, 2));

const postData = JSON.stringify(testData);

const options = {
  hostname: 'localhost',
  port: 3000,
  path: '/api/syt/admin-web/competitions',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Content-Length': Buffer.byteLength(postData),
    'Cookie': 'connect.sid=YOUR_SESSION_ID' // You may need to add a valid session
  }
};

console.log('\n🌐 Making request to:', options.hostname + ':' + options.port + options.path);

const req = http.request(options, (res) => {
  let data = '';

  res.on('data', (chunk) => {
    data += chunk;
  });

  res.on('end', () => {
    console.log('\n📊 Response Status:', res.statusCode);
    console.log('📊 Response Headers:', res.headers);
    console.log('\n📋 Response Body:');
    try {
      const parsed = JSON.parse(data);
      console.log(JSON.stringify(parsed, null, 2));
      
      if (parsed.success) {
        console.log('\n✅ Competition created successfully!');
        console.log('Competition ID:', parsed.data._id);
      } else {
        console.log('\n❌ Error:', parsed.message);
      }
    } catch (e) {
      console.log(data);
    }
  });
});

req.on('error', (error) => {
  console.error('❌ Request error:', error);
});

req.write(postData);
req.end();
