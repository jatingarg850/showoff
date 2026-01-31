# Subscription Coin Payment - Price Calculation Fix

## Issue
**Error:** `Insufficient coins. You need 249900 coins but have 4560 coins.`

The system was requiring 249900 coins instead of 2499 coins for the Pro subscription.

## Root Cause
The backend `subscribeWithCoins` endpoint was treating `plan.price` as a number, but it's actually an object:

**Plan structure:**
```javascript
{
  name: 'Pro',
  tier: 'pro',
  price: {
    monthly: 2499,
    yearly: 24990
  },
  currency: 'INR'
}
```

**Buggy code:**
```javascript
const coinsRequired = Math.round(plan.price);
```

When `Math.round()` is called on an object, it converts to NaN or an unexpected value (249900).

## Solution Implemented

**File:** `server/controllers/subscriptionController.js`

**Before:**
```javascript
// Convert price to coins (1 INR = 1 coin)
const coinsRequired = Math.round(plan.price);
```

**After:**
```javascript
// Convert price to coins (1 INR = 1 coin)
// Get monthly price from the price object
const monthlyPrice = plan.price.monthly || plan.price;
const coinsRequired = Math.round(monthlyPrice);
```

## How It Works

1. **Extracts monthly price** from the price object
2. **Fallback:** If `price.monthly` doesn't exist, uses `price` directly
3. **Rounds to integer:** Ensures whole number of coins
4. **Validates:** Checks if user has enough coins

## Coin Calculation

**Pro Plan:**
- Monthly price: ₹2,499
- Coins required: 2,499 coins (1 INR = 1 coin)
- User has: 4,560 coins
- Result: ✅ Sufficient coins

**Before fix:**
- Coins required: 249,900 coins (incorrect)
- User has: 4,560 coins
- Result: ❌ Insufficient coins

## Testing

To verify the fix:
1. User with 4,560 coins tries to subscribe to Pro plan
2. System should show: "You need 2,499 coins but have 4,560 coins"
3. Subscription should succeed
4. User's coin balance should be: 4,560 - 2,499 = 2,061 coins

## Files Modified
- `server/controllers/subscriptionController.js` (lines 475-479)

## Related Code

**Subscription Plan Model:**
```javascript
price: {
  monthly: 2499,
  yearly: 24990
}
```

**Coin Conversion Rate:**
- 1 INR = 1 coin
- Pro subscription: ₹2,499/month = 2,499 coins

## Prevention

To prevent similar issues:
1. Always check data structure before using
2. Use type checking: `typeof plan.price === 'object'`
3. Add validation in model schema
4. Test with actual data structures
5. Add unit tests for price calculations
