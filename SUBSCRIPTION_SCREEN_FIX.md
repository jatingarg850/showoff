# Subscription Screen - NoSuchMethodError Fix

## Issue
**Error:** `NoSuchMethodError: Class 'int' has no instance method '[]'`
- **Receiver:** 249900
- **Tried calling:** `[]("monthly")`
- **Location:** `subscription_screen.dart:275`

The code was trying to access `proPlan['price']['monthly']` but `proPlan['price']` was an integer (249900) instead of a Map.

## Root Cause
The subscription plan data structure was inconsistent:
- **Expected:** `price: { monthly: 2499, yearly: 24990 }`
- **Received:** `price: 249900` (flattened to a single number)

This caused the bracket notation `[]` to fail on an integer type.

## Solution Implemented

### Before (Line 275):
```dart
final planPrice = (proPlan['price']?['monthly'] ?? 2499).toDouble();
```

### After (Lines 275-282):
```dart
final planId = proPlan['_id'] ?? 'pro';

// Handle price - it could be a Map or a direct number
double planPrice = 2499.0;
final priceData = proPlan['price'];
if (priceData is Map) {
  planPrice = (priceData['monthly'] ?? 2499).toDouble();
} else if (priceData is num) {
  planPrice = priceData.toDouble();
}
```

## How It Works

1. **Type Check:** First checks if `priceData` is a Map
   - If yes: Extracts the `monthly` price from the Map
   - If no: Checks if it's a number

2. **Fallback:** If `priceData` is a number, uses it directly
   - Converts to double for payment processing

3. **Default:** If neither, defaults to 2499.0

## Benefits

✅ **Handles both data formats:**
- Map structure: `{ monthly: 2499, yearly: 24990 }`
- Direct number: `2499`

✅ **Type-safe:** Uses `is` operator for proper type checking

✅ **Graceful fallback:** Defaults to 2499 if data is malformed

✅ **No more crashes:** Prevents NoSuchMethodError

## Testing

To verify the fix:
1. Open the subscription screen
2. Verify it loads without errors
3. Check that the Pro plan price displays correctly
4. Attempt to subscribe to verify payment flow works

## Files Modified
- `apps/lib/subscription_screen.dart` (lines 275-282)

## Related Code
The subscription plan structure from backend:
```javascript
{
  name: 'Pro',
  tier: 'pro',
  price: {
    monthly: 2499,
    yearly: 24990,
  },
  currency: 'INR',
  features: { ... }
}
```

## Prevention
To prevent similar issues in the future:
1. Always validate data types before accessing nested properties
2. Use type checking with `is` operator
3. Provide sensible defaults
4. Test with both expected and unexpected data formats
