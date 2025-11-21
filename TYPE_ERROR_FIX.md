# Type Error Fix - "type 'int' is not a subtype of type 'double'"

## Problem
The app was showing a runtime error: `type 'int' is not a subtype of type 'double'` when displaying product prices in the store.

## Root Cause
The `product['price']` field from the API could be returned as either an `int` or `double`, but the code was using `as double` which would fail if the value was an integer.

## Solution
Changed all type casting from `as double` to `.toDouble()` which safely converts both int and double to double.

## Files Fixed

### 1. `apps/lib/store_screen.dart`

**Fixed `_getProductPrice()` method:**
```dart
// Before:
final basePrice = (product['price'] ?? 0.0) as double;

// After:
final basePrice = (product['price'] ?? 0.0).toDouble();
```

**Fixed `_getCartTotal()` method:**
```dart
// Before:
final basePrice = (product['price'] ?? 0.0) as double;
final quantity = item['quantity'] ?? 1;

// After:
final basePrice = (product['price'] ?? 0.0).toDouble();
final quantity = (item['quantity'] ?? 1).toInt();
```

### 2. `apps/lib/product_detail_screen.dart`

**Fixed `_getProductPrice()` method:**
```dart
// Before:
final basePrice = (product['price'] ?? 0.0) as double;

// After:
final basePrice = (product['price'] ?? 0.0).toDouble();
```

### 3. `apps/lib/cart_screen.dart`

**Removed unused variable:**
```dart
// Removed:
final paymentType = item['paymentType'] ?? 'upi';
```

## Why `.toDouble()` is Better Than `as double`

1. **Safe Conversion**: `.toDouble()` converts both `int` and `double` to `double`
2. **No Runtime Errors**: Won't crash if the value is an integer
3. **Type Safety**: Ensures the result is always a double

## Example

```dart
// If API returns price as int: 100
int price = 100;

// This would crash:
double amount = (price as double); // ❌ Error!

// This works:
double amount = price.toDouble(); // ✅ Works! Returns 100.0
```

## Testing

✅ All diagnostics clear
✅ No type errors
✅ Store displays prices correctly
✅ Product detail shows prices correctly
✅ Cart calculates totals correctly

## Result

The store now displays all products with the 50/50 payment split without any type errors:
- "$X.XX + XXX coins" format
- Proper type handling for all numeric values
- No runtime crashes
