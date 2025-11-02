# Debug Payment Signature Issue

## Current Issue
Getting "Invalid payment signature" error after Razorpay payment completion.

## What This Means
1. ✅ **Razorpay order creation** - Working (fixed the receipt length issue)
2. ✅ **Payment UI** - User can complete payment in Razorpay
3. ❌ **Payment verification** - Signature verification failing

## Root Cause Analysis

The signature verification fails when:
1. **Wrong signature format** - Flutter app sends incorrect signature
2. **Missing data** - Required fields not sent to verification endpoint
3. **Encoding issues** - Signature encoding problems
4. **Wrong endpoint** - App calls wrong verification endpoint

## Debugging Steps

### 1. Check Server Logs
When payment fails, check server console for:
```
💳 Processing coin purchase...
Request body: { ... }
🔐 Verifying payment signature...
Expected signature: abc123...
Received signature: xyz789...
Signatures match: false
❌ Payment signature verification failed
```

### 2. Test Signature Verification
```bash
# Test signature verification endpoint
curl -X POST http://localhost:3000/api/coins/test-signature \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "razorpayOrderId": "order_test123",
    "razorpayPaymentId": "pay_test456", 
    "razorpaySignature": "test_signature"
  }'
```

### 3. Check Flutter App Integration

The Flutter app should call `/api/coins/purchase` with:
```json
{
  "razorpayOrderId": "order_xxxxx",
  "razorpayPaymentId": "pay_xxxxx", 
  "razorpaySignature": "generated_signature",
  "packageId": "add_money",
  "amount": 5000,
  "coins": 6000
}
```

## Common Issues & Solutions

### Issue 1: Wrong Endpoint
**Problem**: App calls wrong verification endpoint
**Solution**: Ensure Flutter app calls `/api/coins/purchase` (not `/api/coins/add-money`)

### Issue 2: Missing Fields
**Problem**: Required fields not sent in request
**Solution**: Include all required fields:
- `razorpayOrderId`
- `razorpayPaymentId` 
- `razorpaySignature`
- `packageId` (should be "add_money")
- `amount` (for add_money)

### Issue 3: Signature Generation
**Problem**: Flutter app generates wrong signature
**Solution**: Verify signature generation in Flutter:
```dart
String generateSignature(String orderId, String paymentId, String secret) {
  String data = orderId + "|" + paymentId;
  var key = utf8.encode(secret);
  var bytes = utf8.encode(data);
  var hmacSha256 = Hmac(sha256, key);
  var digest = hmacSha256.convert(bytes);
  return digest.toString();
}
```

### Issue 4: Environment Variables
**Problem**: Wrong Razorpay secret key
**Solution**: Verify `.env` has correct `RAZORPAY_KEY_SECRET`

## Expected Flow

### 1. Create Order (✅ Working)
```
POST /api/coins/create-purchase-order
→ Returns: { orderId: "order_xxx", amount: 500000, ... }
```

### 2. User Pays (✅ Working)
```
Razorpay UI → User completes payment
→ Returns: { paymentId: "pay_xxx", signature: "sig_xxx" }
```

### 3. Verify Payment (❌ Failing)
```
POST /api/coins/purchase
Body: { razorpayOrderId, razorpayPaymentId, razorpaySignature, packageId: "add_money", amount }
→ Should return: { success: true, coinsAdded: 6000 }
```

## Quick Fix Checklist

✅ **Server logs show detailed verification process**  
✅ **Add_money package supported in purchaseCoins**  
✅ **Enhanced error handling and logging**  
⚠️ **Check Flutter app sends correct data**  
⚠️ **Verify signature generation in Flutter**  
⚠️ **Ensure correct endpoint is called**  

## Next Steps

1. **Check Flutter payment integration** - Verify it calls `/api/coins/purchase`
2. **Test signature generation** - Use test endpoint to verify
3. **Check server logs** - See exact signature mismatch details
4. **Verify Razorpay keys** - Ensure test/live keys match

The enhanced logging will show exactly where the signature verification is failing! 🔍

## Flutter Integration Check

Make sure your Flutter app:
1. **Calls correct endpoint**: `/api/coins/purchase` (not `/api/coins/add-money`)
2. **Sends all required fields**: orderId, paymentId, signature, packageId, amount
3. **Generates signature correctly**: Using HMAC-SHA256 with correct format
4. **Uses correct Razorpay keys**: Test keys for development

The payment system should work once the signature verification is fixed! 💰