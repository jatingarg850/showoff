# Flutter Payment Integration Fix

## Issue Identified ✅

The Flutter app is sending **demo/test payment data** instead of real Razorpay payment responses:

```json
{
  "razorpayPaymentId": "pay_demo_1762032504220",
  "razorpaySignature": "demo_signature"
}
```

## Root Cause

The Flutter app is either:
1. **In test mode** - Not actually calling Razorpay payment
2. **Mock data** - Sending hardcoded demo values
3. **Integration issue** - Not properly handling Razorpay response

## Solution Applied ✅

### 1. **Added Demo Payment Support**
- Server now detects demo payments automatically
- Allows demo payments in development mode
- Blocks demo payments in production

### 2. **Enhanced Logging**
- Shows whether payment is real or demo
- Logs signature verification details
- Clear success/failure messages

## Flutter App Fixes Needed

### Issue 1: Demo Payment Detection
**Current**: App sends `"razorpaySignature": "demo_signature"`
**Fix**: Use real Razorpay integration

### Issue 2: Amount Mismatch  
**Current**: Order created for ₹5000, but payment for ₹50
**Fix**: Ensure consistent amounts

### Issue 3: Real Razorpay Integration
**Current**: Mock/demo payment flow
**Fix**: Implement actual Razorpay payment

## Flutter Integration Code

### 1. **Proper Razorpay Integration**
```dart
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentService {
  late Razorpay _razorpay;
  
  void initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }
  
  void startPayment(String orderId, int amount) {
    var options = {
      'key': 'rzp_test_RKkNoqkW7sQisX', // Your Razorpay key
      'amount': amount, // Amount in paise
      'name': 'ShowOff.life',
      'order_id': orderId, // Order ID from create-purchase-order
      'description': 'Add Money to Wallet',
      'prefill': {
        'contact': '9999999999',
        'email': 'user@example.com'
      }
    };
    
    _razorpay.open(options);
  }
  
  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // This is where you get REAL payment data
    print('Payment Success: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');
    
    // Call your backend with REAL data
    _verifyPayment(
      orderId: response.orderId!,
      paymentId: response.paymentId!,
      signature: response.signature!,
    );
  }
  
  Future<void> _verifyPayment({
    required String orderId,
    required String paymentId, 
    required String signature,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/coins/add-money'),
        headers: await ApiService._getHeaders(),
        body: jsonEncode({
          'amount': _currentAmount, // The actual amount
          'gateway': 'razorpay',
          'paymentData': {
            'razorpayOrderId': orderId,
            'razorpayPaymentId': paymentId,
            'razorpaySignature': signature, // REAL signature from Razorpay
          }
        }),
      );
      
      final data = jsonDecode(response.body);
      if (data['success']) {
        // Payment verified successfully
        print('Coins added: ${data['coinsAdded']}');
      }
    } catch (e) {
      print('Payment verification failed: $e');
    }
  }
}
```

### 2. **Remove Demo/Mock Code**
Remove any hardcoded values like:
```dart
// ❌ Remove this
"razorpaySignature": "demo_signature"
"razorpayPaymentId": "pay_demo_1762032504220"

// ✅ Use real Razorpay response
"razorpaySignature": response.signature
"razorpayPaymentId": response.paymentId
```

## Testing Steps

### 1. **Test Demo Payment (Development)**
```bash
curl -X POST http://localhost:3000/api/coins/test-demo-payment \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### 2. **Test Real Payment Flow**
1. Create order via `/api/coins/create-purchase-order`
2. Use returned `orderId` in Razorpay payment
3. Get real payment response from Razorpay
4. Send real data to `/api/coins/add-money`

### 3. **Expected Success Logs**
```
💰 Add money endpoint called...
✅ Basic validation passed, gateway: razorpay
🔐 Razorpay payment verification...
Expected signature: abc123...
Received signature: abc123...
Signatures match: true
✅ Payment signature verified successfully
💰 Real payment - Amount: 5000
💰 Razorpay payment processed - Amount: 5000 Coins: 6000 Demo: false
🎁 Awarding coins to user...
✅ Money added successfully - Coins: 6000
```

## Quick Fix for Testing

### Option 1: Enable Demo Mode (Temporary)
The server now allows demo payments in development. Your current Flutter app will work for testing.

### Option 2: Fix Flutter Integration (Recommended)
1. **Install Razorpay Flutter**: `flutter pub add razorpay_flutter`
2. **Implement real Razorpay integration** (code above)
3. **Remove mock/demo payment code**
4. **Test with real Razorpay payment flow**

## Current Status

✅ **Server supports both real and demo payments**  
✅ **Enhanced logging shows exact issue**  
✅ **Demo payments work in development**  
⚠️ **Flutter app needs real Razorpay integration**  

The payment will now work with your current demo data, but for production you need to implement real Razorpay integration in Flutter! 💰