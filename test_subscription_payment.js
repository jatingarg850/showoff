const http = require('http');

// Test creating Razorpay order for subscription
const testSubscriptionPayment = async () => {
  const token = 'YOUR_AUTH_TOKEN_HERE'; // Replace with actual token
  const amount = 2499; // ₹2,499

  const postData = JSON.stringify({
    packageId: 'premium_plan',
    amount: amount,
    coins: amount, // 1 INR = 1 coin
  });

  const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/api/coins/create-purchase-order',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Content-Length': Buffer.byteLength(postData),
      'Authorization': `Bearer ${token}`,
    },
  };

  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        console.log('Status Code:', res.statusCode);
        console.log('Response:', data);
        try {
          const parsed = JSON.parse(data);
          resolve(parsed);
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      console.error('Request error:', e);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
};

// Run test
testSubscriptionPayment()
  .then((response) => {
    console.log('\n✅ Test completed');
    if (response.success) {
      console.log('Order ID:', response.data?.id);
      console.log('Amount:', response.data?.amount);
    } else {
      console.log('Error:', response.message);
    }
  })
  .catch((error) => {
    console.error('❌ Test failed:', error.message);
  });
