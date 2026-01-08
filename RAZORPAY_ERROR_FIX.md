# Razorpay Payment Error - Troubleshooting Guide

## Issue
Razorpay payment shows "Something went wrong" error when trying to process payment.

## Root Causes & Solutions

### 1. **Invalid or Mismatched Razorpay Key** (Most Common)
The test key in the Flutter app might not match your Razorpay account credentials.

**Fix:**
1. Go to your Razorpay Dashboard: https://dashboard.razorpay.com
2. Navigate to Settings → API Keys
3. Copy your **Test Key ID** (starts with `rzp_test_`)
4. Update the key in `apps/lib/services/razorpay_service.dart` line 65:
   ```dart
   'key': 'YOUR_ACTUAL_RAZORPAY_TEST_KEY_ID',
   ```

### 2. **Backend Razorpay Credentials Not Set**
The backend server might not have Razorpay credentials configured.

**Fix:**
1. Check `server/.env` file for:
   ```
   RAZORPAY_KEY_ID=rzp_test_xxxxx
   RAZORPAY_KEY_SECRET=xxxxx
   ```
2. If missing, add them from your Razorpay Dashboard
3. Restart the server

### 3. **Network/Connectivity Issue**
The device might not be able to reach Razorpay servers.

**Fix:**
- Ensure device has internet connection
- Try on a different network
- Check if Razorpay is accessible from your region

### 4. **Order Amount Validation**
The order amount might be invalid or too small.

**Fix:**
- Minimum amount for Razorpay: ₹1 (100 paise)
- Maximum amount: ₹15,00,000 (15 million paise)
- Ensure amount is being sent correctly in paise

### 5. **Razorpay SDK Not Properly Initialized**
The Flutter Razorpay plugin might not be initialized correctly.

**Fix:**
- Ensure `razorpay_flutter` is in `pubspec.yaml`
- Run `flutter pub get`
- Rebuild the app: `flutter clean && flutter pub get && flutter run`

## Debugging Steps

### Step 1: Check Backend Razorpay Configuration
```bash
# Test Razorpay configuration
curl -X GET http://localhost:5000/api/coins/test-razorpay \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Expected response:
```json
{
  "success": true,
  "message": "Razorpay is working correctly",
  "testOrderId": "order_xxxxx",
  "razorpayConfigured": true
}
```

### Step 2: Verify Order Creation
Check the server logs when creating an order. Look for:
- ✅ Razorpay order created: order_xxxxx
- If you see ❌ errors, check the error message

### Step 3: Test with Demo Payment
Use the demo payment endpoint to test the flow:
```bash
curl -X POST http://localhost:5000/api/coins/test-demo-payment \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"
```

### Step 4: Check Flutter Logs
Run the app with verbose logging:
```bash
flutter run -v
```

Look for Razorpay-related errors in the output.

## Quick Checklist

- [ ] Razorpay test key is correct and matches your account
- [ ] Backend `.env` has `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`
- [ ] Server is running and restarted after env changes
- [ ] Device has internet connection
- [ ] Amount is valid (₹1 minimum)
- [ ] `razorpay_flutter` package is installed
- [ ] App has been rebuilt after any changes

## Common Error Codes

| Error | Cause | Solution |
|-------|-------|----------|
| "Something went wrong" | Invalid key or network issue | Verify key and internet |
| "Payment cancelled" | User cancelled the payment | Normal, user can retry |
| "Network error" | No internet or Razorpay unreachable | Check connection |
| "Invalid order" | Order doesn't exist or expired | Create new order |

## Next Steps

1. Verify your Razorpay credentials are correct
2. Update the key in the Flutter app
3. Restart the backend server
4. Rebuild and test the app
5. Check the server logs for any errors

If the issue persists, check the detailed error logs in the Flutter console and server logs.
