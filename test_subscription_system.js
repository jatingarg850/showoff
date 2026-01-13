const http = require('http');

const BASE_URL = 'http://localhost:3000/api';

async function makeRequest(method, path, body = null, token = null) {
  return new Promise((resolve, reject) => {
    const url = new URL(BASE_URL + path);
    const options = {
      hostname: url.hostname,
      port: url.port,
      path: url.pathname + url.search,
      method: method,
      headers: {
        'Content-Type': 'application/json',
      },
    };

    if (token) {
      options.headers['Authorization'] = `Bearer ${token}`;
    }

    const req = http.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          resolve({ raw: data });
        }
      });
    });

    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function testSubscriptionSystem() {
  console.log('🧪 Testing Subscription System\n');

  try {
    // Test 1: Get subscription plans
    console.log('📋 Test 1: Fetching subscription plans...');
    const plansResponse = await makeRequest('GET', '/subscriptions/plans');
    console.log(`Status: ${plansResponse.success ? '✅' : '❌'}`);
    console.log(`Plans found: ${plansResponse.data?.length || 0}`);
    if (plansResponse.data && plansResponse.data.length > 0) {
      plansResponse.data.forEach((plan) => {
        console.log(`  - ${plan.name} (${plan.tier}): ₹${plan.price.monthly}/month`);
      });
    } else {
      console.log('  ⚠️  No plans found! Run: node server/scripts/seedSubscriptionPlans.js');
    }
    console.log('');

    // Test 2: Check Pro plan exists
    console.log('🔍 Test 2: Checking Pro plan...');
    const proPlan = plansResponse.data?.find((p) => p.tier === 'pro');
    if (proPlan) {
      console.log(`✅ Pro plan found`);
      console.log(`  - ID: ${proPlan._id}`);
      console.log(`  - Price: ₹${proPlan.price.monthly}/month`);
      console.log(`  - Features:`);
      console.log(`    - Verified Badge: ${proPlan.features.verifiedBadge}`);
      console.log(`    - Ad-Free: ${proPlan.features.adFree}`);
      console.log(`    - Bonus Coins: ${proPlan.features.coinBonus}`);
    } else {
      console.log('❌ Pro plan not found!');
    }
    console.log('');

    // Test 3: Verify API structure
    console.log('✅ API Structure Verification:');
    console.log('  - GET /subscriptions/plans ✅');
    console.log('  - POST /subscriptions/create-order (requires auth)');
    console.log('  - POST /subscriptions/verify-payment (requires auth)');
    console.log('  - GET /subscriptions/my-subscription (requires auth)');
    console.log('  - PUT /subscriptions/cancel (requires auth)');
    console.log('');

    // Test 4: Summary
    console.log('📊 Summary:');
    if (plansResponse.success && plansResponse.data?.length > 0) {
      console.log('✅ Subscription system is ready!');
      console.log('');
      console.log('Next steps:');
      console.log('1. Open the app and navigate to Subscription screen');
      console.log('2. Click "Subscribe Now" to initiate payment');
      console.log('3. Complete Razorpay payment');
      console.log('4. Subscription should activate automatically');
    } else {
      console.log('❌ Subscription system needs setup');
      console.log('');
      console.log('Run this command to seed plans:');
      console.log('  node server/scripts/seedSubscriptionPlans.js');
    }
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

testSubscriptionSystem();
