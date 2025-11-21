# Stripe Payment Integration

## Overview
ShowOff Life uses Stripe for international payments (USD) alongside Razorpay for Indian payments (INR).

## Stripe Test Credentials

### Test Keys (Sandbox)
```env
# Publishable Key (Client-Side)
STRIPE_PUBLISHABLE_KEY=pk_test_51RGe80Q23XtZsxOKsYZm2bBfxtmNhpFcOjAsorE0WuGnYGKFqrGECxFirSgdxlHpXfERcHOdvibiCN0yVBq3qyQI00oDSyyeuy

# Secret Key (Server-Side)
STRIPE_SECRET_KEY=sk_test_51RGe80Q23XtZsxOKfGhTV7113VCHV0Vol6aJPqYqLFrYDtXhbogV1etWZYKvtc5xeCybQBC4EmjSwvaoPNp3dZUL00pNAZBM0R

# Webhook Secret (for webhook verification)
STRIPE_WEBHOOK_SECRET=whsec_your_stripe_webhook_secret
```

### Key Types
- **Publishable Key** (`pk_test_*`): Used in client-side code (Flutter app)
- **Secret Key** (`sk_test_*`): Used for server-side API authentication
- **Webhook Secret** (`whsec_*`): Used to verify webhook events from Stripe

## Current Implementation Status

### ✅ Server-Side (Completed)
- Stripe SDK initialized in `server/controllers/coinController.js`
- Payment intent creation endpoint
- Payment confirmation endpoint
- Add money functionality

### ⚠️ Client-Side (Needs Full Integration)
- API calls implemented in `apps/lib/services/api_service.dart`
- UI implemented in `apps/lib/enhanced_add_money_screen.dart`
- **Missing**: Stripe Flutter SDK integration for actual payment processing

## Server-Side Implementation

### Location
`server/controllers/coinController.js`

### Endpoints

#### 1. Create Payment Intent
**Endpoint**: `POST /api/coins/create-stripe-intent`

**Request**:
```json
{
  "amount": 10.00,
  "currency": "usd"
}
```

**Response**:
```json
{
  "success": true,
  "data": {
    "paymentIntentId": "pi_xxxxx",
    "clientSecret": "pi_xxxxx_secret_xxxxx",
    "amount": 1000,
    "currency": "usd"
  }
}
```

#### 2. Confirm Payment
**Endpoint**: `POST /api/coins/confirm-stripe-payment`

**Request**:
```json
{
  "paymentIntentId": "pi_xxxxx"
}
```

**Response**:
```json
{
  "success": true,
  "message": "Payment confirmed and coins added",
  "data": {
    "coinsAdded": 1000,
    "newBalance": 5000,
    "transaction": { ... }
  }
}
```

#### 3. Add Money (Unified)
**Endpoint**: `POST /api/coins/add-money`

**Request**:
```json
{
  "amount": 10.00,
  "gateway": "stripe",
  "paymentData": {
    "paymentIntentId": "pi_xxxxx"
  }
}
```

## Client-Side Implementation

### Current Status
The Flutter app has:
- ✅ UI for selecting Stripe as payment gateway
- ✅ API service methods for Stripe
- ❌ Actual Stripe SDK integration (simulated)

### To Complete Full Integration

#### 1. Add Stripe Flutter Package
Add to `apps/pubspec.yaml`:
```yaml
dependencies:
  flutter_stripe: ^10.0.0
```

#### 2. Initialize Stripe in Flutter
In `apps/lib/main.dart`:
```dart
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Stripe
  Stripe.publishableKey = 'pk_test_51RGe80Q23XtZsxOKsYZm2bBfxtmNhpFcOjAsorE0WuGnYGKFqrGECxFirSgdxlHpXfERcHOdvibiCN0yVBq3qyQI00oDSyyeuy';
  
  runApp(MyApp());
}
```

#### 3. Update Payment Processing
In `apps/lib/enhanced_add_money_screen.dart`:

Replace the simulated payment with:
```dart
Future<void> _processStripePayment(double amount) async {
  try {
    // 1. Create payment intent on server
    final intentResponse = await ApiService.createStripePaymentIntent(
      amount: amount,
      currency: 'usd',
    );

    if (!intentResponse['success']) {
      throw Exception('Failed to create payment intent');
    }

    final clientSecret = intentResponse['data']['clientSecret'];

    // 2. Initialize payment sheet
    await Stripe.instance.initPaymentSheet(
      paymentSheetParameters: SetupPaymentSheetParameters(
        merchantDisplayName: 'ShowOff Life',
        paymentIntentClientSecret: clientSecret,
        style: ThemeMode.light,
      ),
    );

    // 3. Present payment sheet
    await Stripe.instance.presentPaymentSheet();

    // 4. Confirm payment on server
    final paymentIntentId = intentResponse['data']['paymentIntentId'];
    final confirmResponse = await ApiService.addMoney(
      amount: amount,
      gateway: 'stripe',
      paymentData: {'paymentIntentId': paymentIntentId},
    );

    if (confirmResponse['success']) {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment successful!')),
      );
    }
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Payment failed: $e')),
    );
  }
}
```

## Coin Conversion Rates

### Stripe (USD)
- **1 USD = 100 Coins**
- Example: $10 = 1,000 coins

### Razorpay (INR)
- **1 INR = 1.2 Coins**
- Example: ₹100 = 120 coins

## Testing

### Test Cards (Stripe)

#### Successful Payment
```
Card Number: 4242 4242 4242 4242
Expiry: Any future date
CVC: Any 3 digits
ZIP: Any 5 digits
```

#### Payment Requires Authentication
```
Card Number: 4000 0025 0000 3155
Expiry: Any future date
CVC: Any 3 digits
```

#### Card Declined
```
Card Number: 4000 0000 0000 0002
Expiry: Any future date
CVC: Any 3 digits
```

### Test Flow

1. **Select Stripe Gateway**
   ```bash
   # In the app, tap "Stripe" payment option
   ```

2. **Enter Amount**
   ```bash
   # Enter amount in USD (e.g., $10)
   ```

3. **Process Payment**
   ```bash
   # Use test card: 4242 4242 4242 4242
   ```

4. **Verify Coins Added**
   ```bash
   # Check wallet balance increased by (amount * 100) coins
   ```

## Webhooks (Optional but Recommended)

### Setup Webhook Endpoint
**Endpoint**: `POST /api/webhooks/stripe`

```javascript
// server/routes/webhookRoutes.js
const express = require('express');
const router = express.Router();
const stripe = require('stripe')(process.env.STRIPE_SECRET_KEY);

router.post('/stripe', express.raw({type: 'application/json'}), async (req, res) => {
  const sig = req.headers['stripe-signature'];
  
  try {
    const event = stripe.webhooks.constructEvent(
      req.body,
      sig,
      process.env.STRIPE_WEBHOOK_SECRET
    );
    
    // Handle event
    switch (event.type) {
      case 'payment_intent.succeeded':
        const paymentIntent = event.data.object;
        // Update transaction status
        break;
      case 'payment_intent.payment_failed':
        // Handle failed payment
        break;
    }
    
    res.json({received: true});
  } catch (err) {
    res.status(400).send(`Webhook Error: ${err.message}`);
  }
});

module.exports = router;
```

### Configure Webhook in Stripe Dashboard
1. Go to: https://dashboard.stripe.com/test/webhooks
2. Click "Add endpoint"
3. URL: `https://your-domain.com/api/webhooks/stripe`
4. Events: Select `payment_intent.succeeded` and `payment_intent.payment_failed`
5. Copy webhook secret to `.env`

## Security Best Practices

1. **Never expose secret key in client code**
   - Only use publishable key in Flutter app
   - Keep secret key on server only

2. **Validate amounts on server**
   - Don't trust client-sent amounts
   - Verify payment intent amounts match expected values

3. **Use webhooks for critical updates**
   - Don't rely solely on client confirmation
   - Use webhooks to update transaction status

4. **Implement idempotency**
   - Use idempotency keys for payment requests
   - Prevent duplicate charges

5. **Log all transactions**
   - Keep audit trail of all payment attempts
   - Monitor for suspicious activity

## Production Checklist

- [ ] Replace test keys with live keys
- [ ] Set up webhook endpoint
- [ ] Configure webhook secret
- [ ] Test with real cards (small amounts)
- [ ] Implement proper error handling
- [ ] Add transaction logging
- [ ] Set up monitoring/alerts
- [ ] Review Stripe dashboard regularly
- [ ] Implement refund functionality
- [ ] Add customer support contact

## Stripe Dashboard

### Test Mode
https://dashboard.stripe.com/test/dashboard

### Live Mode
https://dashboard.stripe.com/dashboard

### Useful Sections
- **Payments**: View all transactions
- **Customers**: Manage customer data
- **Webhooks**: Configure webhook endpoints
- **Logs**: Debug API requests
- **Settings**: API keys and configuration

## Support Resources

- **Stripe Docs**: https://stripe.com/docs
- **Flutter Stripe Package**: https://pub.dev/packages/flutter_stripe
- **API Reference**: https://stripe.com/docs/api
- **Test Cards**: https://stripe.com/docs/testing

---

**Status**: ✅ Server-Side Complete | ⚠️ Client-Side Needs Full SDK Integration
**Last Updated**: 2024
