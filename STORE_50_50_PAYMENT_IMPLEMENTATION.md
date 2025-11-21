# Store 50% Cash + 50% Coins Payment System

## Implementation Summary

### ✅ Backend Changes Completed

#### 1. Product Model Updated (`server/models/Product.js`)
- Added `'mixed'` to paymentType enum
- Changed default paymentType to `'mixed'`
- Added `mixedPayment` object with `cashAmount` and `coinAmount` fields

#### 2. Cart Controller Updated (`server/controllers/cartController.js`)

**Checkout Endpoint (`POST /api/cart/checkout`):**
- Now calculates 50% cash + 50% coins for ALL products
- Formula: 
  - Cash: `basePrice * 0.5 * quantity`
  - Coins: `Math.ceil((basePrice * 0.5) * 100) * quantity` (1 USD = 100 coins)
- Returns breakdown with:
  - `totalCash`: Total cash amount needed
  - `totalCoins`: Total coins needed
  - `userCoinBalance`: User's current coin balance
  - `canProceed`: Boolean if user has enough coins

**Process Payment Endpoint (`POST /api/cart/process-payment`):**
- Deducts coins from user balance
- Verifies Razorpay payment for cash portion
- Creates transaction record showing mixed payment
- Clears cart after successful payment

### ✅ Flutter Changes Completed

#### 1. Cart Screen (`apps/lib/cart_screen.dart`)

**Updated `_calculateTotals()` method:**
```dart
// Calculates 50% cash + 50% coins for ALL products
for (var item in items) {
  final product = item['product'] ?? {};
  final quantity = item['quantity'] ?? 1;
  final basePrice = (product['price'] ?? 0.0) as double;

  // 50% cash
  _totalUPI += (basePrice * 0.5) * quantity;
  
  // 50% coins (1 USD = 100 coins)
  _totalCoins += ((basePrice * 0.5) * 100 * quantity).ceil();
}
```

**Updated `_getItemPrice()` method:**
```dart
// Shows both cash and coin amounts
final cashAmount = (basePrice * 0.5) * quantity;
final coinAmount = ((basePrice * 0.5) * 100 * quantity).ceil();
return '\$${cashAmount.toStringAsFixed(2)} + $coinAmount coins';
```

**Updated Checkout Section:**
- Added banner: "50% Cash + 50% Coins Payment"
- Shows Cash (50%): $X.XX
- Shows Coins (50%): XXX coins
- Clear visual separation with gradient banner

**Updated Cart Items:**
- Each item shows: "$X.XX + XXX coins"
- Added "50/50" badge with gradient background

### 📋 How It Works

1. **User adds product to cart** ($10 product example):
   - Cash portion: $5.00 (50%)
   - Coin portion: 500 coins (50% = $5 × 100 coins/USD)

2. **Cart displays**:
   - Each item: "$5.00 + 500 coins"
   - Total Cash (50%): $5.00
   - Total Coins (50%): 500 coins
   - Banner: "50% Cash + 50% Coins Payment"

3. **Checkout process**:
   - System checks if user has enough coins
   - If yes: Proceeds to Razorpay for cash payment
   - After Razorpay success: Deducts coins from balance
   - Creates transaction record
   - Clears cart

4. **Transaction record shows**:
   - "Store purchase - X item(s) - Mixed payment: $X.XX + XXX coins"

### 🎨 Admin Panel Integration

The admin panel already shows withdrawal requests. For products, you can:

1. **View Products** (`/admin/store`):
   - Shows all products with their prices
   - Payment type now defaults to "mixed"

2. **Product Management**:
   - When creating/editing products, set price
   - System automatically calculates:
     - Cash amount: price × 0.5
     - Coin amount: (price × 0.5) × 100

### 🔧 Configuration

**Coin to USD Ratio:** 1 USD = 100 coins

To change this ratio, update the calculation in:
- `server/controllers/cartController.js` (line with `* 100`)
- `apps/lib/cart_screen.dart` (`_calculateTotals` and `_getItemPrice`)

### ✅ Testing Checklist

- [ ] Add product to cart - shows 50/50 split
- [ ] View cart - displays cash + coins correctly
- [ ] Checkout - verifies coin balance
- [ ] Payment - deducts coins after Razorpay success
- [ ] Transaction history - shows mixed payment record
- [ ] Admin panel - can view product prices

### 📝 Notes

- ALL products now use 50/50 payment by default
- Old `paymentType: 'coins'` or `'upi'` still supported for backward compatibility
- Coin calculation rounds up to nearest integer
- Cash amount uses 2 decimal places
- User must have sufficient coins to proceed with checkout

## Example Scenarios

### Scenario 1: Single Item
- Product: T-Shirt ($20)
- Cash: $10.00
- Coins: 1,000 coins
- User needs: 1,000 coins in balance

### Scenario 2: Multiple Items
- Item 1: Shoes ($50) × 1
- Item 2: Hat ($15) × 2
- Total: $80
- Cash: $40.00
- Coins: 4,000 coins
- User needs: 4,000 coins in balance

### Scenario 3: Insufficient Coins
- Cart total: $100
- Cash needed: $50.00
- Coins needed: 5,000
- User has: 3,000 coins
- Result: Cannot proceed, shows "Insufficient coins. You need 5,000 coins but have 3,000"
