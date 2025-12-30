# Subscription Testing Guide

## Issue: "You already have an active subscription"

This error occurs when testing with the same user account multiple times. The user already has an active subscription from a previous test.

## Solution 1: Clear Existing Subscription (For Testing)

Run this command to clear the subscription for a specific user:

```bash
node server/scripts/clear-user-subscription.js <userId>
```

**Example:**
```bash
node server/scripts/clear-user-subscription.js 6953e0b4090bf87f536021d0
```

This will:
- Delete all active subscriptions for the user
- Reset subscription tier to 'free'
- Remove verified badge
- Clear subscription expiry date

## Solution 2: Create a New Test User

1. Sign up with a new email/phone in the app
2. Complete the profile
3. Try subscription payment with the new account

## Testing Subscription Payment

### Step 1: Navigate to Subscription Screen
- Open the app
- Go to Settings or Account menu
- Click "Get Premium" or "Subscribe"

### Step 2: Click "Subscribe Now"
- The Razorpay payment dialog will open
- Order is created via `/api/subscriptions/create-order`

### Step 3: Complete Payment
- Use test card: `4111 1111 1111 1111`
- Any future expiry date
- Any CVV (e.g., 123)
- Click Pay

### Step 4: Verify Subscription
After successful payment, you should see:

1. **Success Message**: "Subscription activated! You now have premium benefits."
2. **Blue Tick (Verified Badge)**: Should appear on your profile
3. **Active Subscription Button**: "Subscribe Now" changes to "Active Subscription"
4. **Expiry Date**: Shows when subscription expires

## Verifying Benefits

### 1. Verified Badge (Blue Tick)
- Go to your profile
- Look for the purple verified icon next to your name
- Should show `Icons.verified` in purple color

### 2. Ad-Free Access
- Navigate to reel screen or other content areas
- Ads should NOT be shown
- Check `AdService.shouldShowAds()` returns false

### 3. Coin Payment Option
- Go to store or payment screen
- Should be able to pay with coins
- Check `SubscriptionService.canPayWithCoins()` returns true

## Database Verification

### Check User Subscription
```javascript
// In MongoDB
db.usersubscriptions.findOne({ user: ObjectId("userId") })
```

Should show:
```json
{
  "user": ObjectId("userId"),
  "plan": ObjectId("planId"),
  "status": "active",
  "billingCycle": "monthly",
  "startDate": ISODate("2025-12-30T..."),
  "endDate": ISODate("2026-01-29T..."),
  "amountPaid": 2499,
  "currency": "INR",
  "paymentMethod": "razorpay",
  "transactionId": "pay_RxrZpxqAMzrA5i",
  "autoRenew": true
}
```

### Check User Verified Flag
```javascript
// In MongoDB
db.users.findOne({ _id: ObjectId("userId") })
```

Should show:
```json
{
  "isVerified": true,
  "subscriptionTier": "pro",
  "subscriptionExpiry": ISODate("2026-01-29T...")
}
```

### Check Transaction Record
```javascript
// In MongoDB
db.transactions.findOne({ 
  user: ObjectId("userId"),
  type: "subscription"
})
```

Should show:
```json
{
  "user": ObjectId("userId"),
  "type": "subscription",
  "amount": -2499,
  "balanceAfter": 1000,
  "description": "Subscription to ShowOff Premium (monthly)",
  "status": "completed",
  "metadata": {
    "subscriptionId": ObjectId("subscriptionId"),
    "planId": ObjectId("planId"),
    "razorpayPaymentId": "pay_RxrZpxqAMzrA5i"
  }
}
```

## Troubleshooting

### Blue Tick Not Showing
1. **Refresh Profile**: Pull down to refresh or navigate away and back
2. **Check isVerified Flag**: Verify in database that `isVerified: true`
3. **Check Profile Screen Code**: Ensure it reads `user['isVerified']`
4. **Restart App**: Sometimes UI cache needs clearing

### Ads Still Showing
1. **Check AdService**: Verify `shouldShowAds()` checks subscription
2. **Check Subscription Status**: Verify subscription is active in database
3. **Check Expiry Date**: Ensure subscription hasn't expired
4. **Clear App Cache**: May need to restart app

### Coin Payment Not Available
1. **Check SubscriptionService**: Verify `canPayWithCoins()` checks subscription
2. **Verify Subscription Tier**: Check `subscriptionTier: 'pro'` in database
3. **Refresh User Data**: Navigate away and back to refresh

## API Endpoints

### Create Subscription Order
```
POST /api/subscriptions/create-order
Authorization: Bearer <token>
Content-Type: application/json

{
  "amount": 2499
}

Response:
{
  "success": true,
  "data": {
    "id": "order_RxrZkEo03uQICH",
  