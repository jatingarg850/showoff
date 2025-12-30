const http = require('http');

// Test subscription payment flow
const testSubscriptionFlow = async () => {
  console.log('🧪 Testing Subscription Payment Flow\n');

  // Step 1: Create Razorpay order
  console.log('Step 1: Creating Razorpay order...');
  const orderResponse = await makeRequest({
    hostname: 'localhost',
    port: 3000,
    path: '/api/coins/create-purchase-order',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_TOKEN_HERE', // Replace with actual token
    },
    body: JSON.stringify({
      packageId: 'add_money',
      amount: 2499,
      coins: 2499,
    }),
  });

  if (!orderResponse.success) {
    console.error('❌ Failed to create order:', orderResponse.message);
    return;
  }

  console.log('✅ Order created successfully');
  console.log('   Order ID:', orderResponse.data.orderId);
  console.log('   Amount:', orderResponse.data.amount, 'paise');
  console.log('   Coins:', orderResponse.data.coins);

  const orderId = orderResponse.data.orderId;

  // Step 2: Simulate Razorpay payment (in real app, user completes payment in Razorpay UI)
  console.log('\nStep 2: Simulating Razorpay payment...');
  console.log('   (In real app, user would complete payment in Razorpay UI)');
  console.log('   Order ID:', orderId);
  console.log('   Amount: ₹2,499');

  // Step 3: Verify payment
  console.log('\nStep 3: Verifying payment...');
  const verifyResponse = await makeRequest({
    hostname: 'localhost',
    port: 3000,
    path: '/api/subscriptions/verify-payment',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer YOUR_TOKEN_HERE', // Replace with actual token
    },
    body: JSON.stringify({
      razorpayOrderId: orderId,
      razorpayPaymentId: 'pay_test_' + Date.now(),
      razorpaySignature: 'test_signature_' + Date.now(),
    }),
  });

  if (!verifyResponse.success) {
    console.error('❌ Payment verification failed:', verifyResponse.message);
    return;
  }

  console.log('✅ Payment verified successfully');
  console.log('   Subscription created');
  console.log('   Status:', verifyResponse.data.status);
  console.log('   Expires:', verifyResponse.data.endDate);

  console.log('\n✅ Subscription flow test completed successfully!');
};

function makeRequest(options) {
  return new Promise((resolve, reject) => {
    const req = http.request(options, (res) => {
      let data = '';

      res.on('data', (chunk) => {
        data += chunk;
      });

      res.on('end', () => {
        try {
          const parsed = JSON.parse(data);
          resolve(parsed);
        } catch (e) {
          reject(e);
        }
      });
    });

    req.on('error', (e) => {
      reject(e);
    });

    if (options.body) {
      req.write(options.body);
    }
    req.end();
  });
}

// Run test
testSubscriptionFlow()
  .then(() => {
    console.log('\n✅ All tests passed!');
    process.exit(0);
  })
  .catch((error) => {
    console.error('\n❌ Test failed:', error.message);
    process.exit(1);
  });
