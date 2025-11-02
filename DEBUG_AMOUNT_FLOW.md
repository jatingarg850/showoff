# Debug Amount Flow - Step by Step

## 🔍 **Current Flow Analysis**

When user enters **₹500**, here's what should happen:

### Step 1: Frontend (Enhanced Add Money Screen)
```dart
// User enters: 500
final amount = 500.0; // ₹500

// Send to API
await ApiService.createRazorpayOrderForAddMoney(amount: amount);
// This sends: { "amount": 500, "coins": 600 }
```

### Step 2: Backend (Coin Controller)
```javascript
// Receives: amount = 500
console.log('Backend receives amount:', amount); // Should be 500

// For add_money package:
selectedPackage.price = Math.round(amount * 100); // 500 * 100 = 50000 paise
selectedPackage.coins = Math.round(amount * 1.2);  // 500 * 1.2 = 600 coins

// Creates Razorpay order with:
const options = {
  amount: selectedPackage.price, // 50000 paise
  currency: 'INR',
  // ...
};

// Returns to frontend:
{
  success: true,
  data: {
    orderId: "order_xxx",
    amount: 50000,  // This is in paise
    currency: "INR",
    coins: 600
  }
}
```

### Step 3: Frontend (Enhanced Add Money Screen)
```dart
// Receives from backend
final orderAmountInPaise = orderResponse['data']['amount']; // 50000
final orderAmountInRupees = orderAmountInPaise / 100; // 500

// Sends to RazorpayService
await RazorpayService.instance.startPayment(
  amount: orderAmountInPaise.toDouble(), // 50000.0
);
```

### Step 4: RazorpayService
```dart
// Receives: amount = 50000.0 (paise)
var options = {
  'amount': amount.toInt(), // 50000 (paise)
  // ...
};

// Sends to Razorpay: 50000 paise = ₹500
```

## 🎯 **Expected Result**
Razorpay should show: **₹500**

## 🚨 **If Still Showing ₹50,000**

The issue might be:

1. **Backend not converting correctly** - Check server logs
2. **Frontend sending wrong amount** - Check debug logs
3. **RazorpayService receiving wrong amount** - Check debug logs

## 🧪 **Debug Steps**

1. **Run the app** with debug logging
2. **Enter ₹500**
3. **Check console logs** for:
   ```
   📊 DEBUG - User entered: ₹500
   📊 DEBUG - Backend returned amount in paise: 50000
   📊 DEBUG - Converted to rupees for display: ₹500
   📊 DEBUG - Sending to Razorpay: 50000 paise
   🔍 RazorpayService DEBUG - Received amount: 50000
   🔍 RazorpayService DEBUG - Converting to int: 50000
   ```

4. **If logs show wrong values**, we know where the issue is

## 🔧 **Potential Issues**

### Issue 1: Backend Still Multiplying
If backend logs show:
```
Backend receives amount: 50000  // Wrong! Should be 500
```

Then frontend is still sending paise instead of rupees.

### Issue 2: Frontend Calculation Wrong
If frontend logs show:
```
📊 DEBUG - Backend returned amount in paise: 5000000  // Wrong! Should be 50000
```

Then backend is doing double conversion.

### Issue 3: RazorpayService Wrong
If RazorpayService logs show:
```
🔍 RazorpayService DEBUG - Received amount: 5000000  // Wrong! Should be 50000
```

Then there's an issue in the frontend flow.

## ✅ **Expected Debug Output**
```
🚀 Starting Razorpay payment for amount: ₹500
📊 DEBUG - User entered: ₹500
📊 DEBUG - Backend returned amount in paise: 50000
📊 DEBUG - Converted to rupees for display: ₹500
📊 DEBUG - Sending to Razorpay: 50000 paise
🔍 RazorpayService DEBUG - Received amount: 50000.0
🔍 RazorpayService DEBUG - Converting to int: 50000
✅ Order created: order_xxx for ₹500
🚀 Starting Razorpay payment with options: {amount: 50000, ...}
```

**Test now and check the debug logs to see where the issue is!** 🔍