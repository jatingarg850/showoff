# Subscription Payment - Plan ID Missing Fix

## Issue
**Error:** `Plan ID is required`
- **Location:** Backend endpoint `/api/subscriptions/create-order`
- **Cause:** The Flutter app was sending only the amount, not the planId

The backend requires both `planId` and `amount` to create a subscription order, but the app was only sending the amount.

## Root Cause
The API service method `createRazorpayOrderForSubscription()` was missing the `planId` parameter:

**Before:**
```dart
static Future<Map<String, dynamic>> createRazorpayOrderForSubscription({
  required double amount,
}) async {
  final requestBody = {
    'amount': amount,
  };
  // ...
}
```

The subscription screen was calling it with only the amount:
```dart
final orderResponse = await ApiService.createRazorpayOrderForSubscription(
  amount: amount,
);
```

## Solution Implemented

### 1. Updated API Service Method
**File:** `apps/lib/services/api_service.dart`

**Before:**
```dart
static Future<Map<String, dynamic>> createRazorpayOrderForSubscription({
  required double amount,
}) async {
  final requestBody = {
    'amount': amount,
  };
  // ...
}
```

**After:**
```dart
static Future<Map<String, dynamic>> createRazorpayOrderForSubscription({
  required String planId,
  required double amount,
}) async {
  final requestBody = {
    'planId': planId,
    'amount': amount,
  };
  // ...
}
```

### 2. Updated Subscription Screen
**File:** `apps/lib/subscription_screen.dart`

**Before:**
```dart
final orderResponse = await ApiService.createRazorpayOrderForSubscription(
  amount: amount,
);
```

**After:**
```dart
final orderResponse = await ApiService.createRazorpayOrderForSubscription(
  planId: planId,
  amount: amount,
);
```

## How It Works

1. **User selects a plan** (e.g., Pro plan with ID 'pro')
2. **User clicks Subscribe** → `_initiatePayment(planId, amount)` is called
3. **API call includes both:**
   - `planId`: The subscription plan ID (e.g., 'pro')
   - `amount`: The price in rupees (e.g., 2499)
4. **Backend validates** both parameters and creates the order
5. **Razorpay payment** is initiated with the order details

## Request Body Example

**Now sends:**
```json
{
  "planId": "pro",
  "amount": 2499
}
```

**Backend expects:**
```javascript
const { planId } = req.body;
const plan = await SubscriptionPlan.findById(planId);
if (!plan || !plan.isActive) {
  return res.status(400).json({
    success: false,
    message: 'Plan ID is required'
  });
}
```

## Testing

To verify the fix:
1. Open the subscription screen
2. Select a plan (e.g., Pro)
3. Click "Subscribe Now"
4. Verify the order is created successfully
5. Check the logs show: `Creating subscription order: {planId: pro, amount: 2499}`

## Files Modified
1. `apps/lib/services/api_service.dart` - Added `planId` parameter
2. `apps/lib/subscription_screen.dart` - Pass `planId` to API call

## Related Backend Code
The backend endpoint expects both parameters:
```javascript
exports.createSubscriptionOrder = async (req, res) => {
  const { planId } = req.body;
  
  if (!planId) {
    return res.status(400).json({
      success: false,
      message: 'Plan ID is required'
    });
  }
  
  const plan = await SubscriptionPlan.findById(planId);
  // ... rest of the logic
};
```

## Prevention
To prevent similar issues:
1. Always check backend endpoint requirements
2. Ensure all required parameters are passed from frontend
3. Add validation on both frontend and backend
4. Test the complete flow end-to-end
