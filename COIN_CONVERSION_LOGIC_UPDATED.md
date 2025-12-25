# Coin Conversion Logic Updated - 1 Coin = 1 INR

## Summary
Updated the entire codebase to use the new coin conversion logic: **1 coin = 1 INR** (instead of the previous 100 coins = 1 INR).

## Changes Made

### App-Side Changes (Flutter)

#### 1. Currency Service (`apps/lib/services/currency_service.dart`)
- Updated `getCoinAmount()` method to return `localCurrencyAmount.ceil()` instead of `(localCurrencyAmount * 100).ceil()`
- Comment updated: "1 coin = 1 INR"

#### 2. Wallet Screen (`apps/lib/wallet_screen.dart`)
- Updated `_coinsToLocalCurrency()` method:
  - Old: `final usdAmount = coins / 100; return await CurrencyService.convertFromUSD(usdAmount);`
  - New: `final inrAmount = coins.toDouble(); return await CurrencyService.convertFromUSD(inrAmount / 83);`
  - This converts coins directly to INR (1 coin = 1 INR)

#### 3. Store Screen (`apps/lib/store_screen.dart`)
- Updated comment from "1 local currency unit = 100 coins" to "1 coin = 1 INR"
- Coin calculation now uses the updated `getCoinAmount()` method

#### 4. Product Detail Screen (`apps/lib/product_detail_screen.dart`)
- Updated comment from "1 local currency unit = 100 coins" to "1 coin = 1 INR"
- Coin calculation now uses the updated `getCoinAmount()` method

#### 5. Cart Screen (`apps/lib/cart_screen.dart`)
- Updated coin calculation from `((basePriceLocal * 0.5) * 100 * quantity)` to `((basePriceLocal * 0.5) * 1 * quantity)`
- Comment updated: "1 coin = 1 INR"

#### 6. API Service (`apps/lib/services/api_service.dart`)
- Already had correct logic: `'coins': (amount * 1).round()` with comment "1 INR = 1 coin"

### Server-Side Changes (Node.js)

#### 1. Admin Controller (`server/controllers/adminController.js`)
- **Product Creation**: Updated coin calculation from `(price / 2) * 100` to `(price / 2) * 1`
- **Product Update**: Updated coin calculation from `(price / 2) * 100` to `(price / 2) * 1`
- **Fallback coin price**: Updated from `price * 100` to `price * 1`
- Comment updated: "1 coin = 1 INR"

#### 2. Cart Controller (`server/controllers/cartController.js`)
- **Cart Total Calculation**: Updated from `Math.ceil((basePrice * 0.5) * 100)` to `Math.ceil((basePrice * 0.5) * 1)`
- **Checkout Calculation**: Updated from `Math.ceil((basePrice * 0.5) * 100)` to `Math.ceil((basePrice * 0.5) * 1)`
- Comment updated: "1 coin = 1 INR"

#### 3. Coin Controller (`server/controllers/coinController.js`)
- **Add Money**: Already correct - `selectedPackage.coins = Math.round(amount * 1)` with comment "1 INR = 1 coin"
- **Stripe Payment Intent**: Updated to check currency:
  - If currency is 'inr': `coinsToAdd = Math.floor(amountInUSD)` (1 INR = 1 coin)
  - If currency is 'usd': `coinsToAdd = Math.floor(amountInUSD * 83)` (1 USD ≈ 83 coins)
- **Stripe Webhook**: Updated with same currency check logic

#### 4. Withdrawal Controller (`server/controllers/withdrawalController.js`)
- Already has correct logic: `const coinToInrRate = parseInt(process.env.COIN_TO_INR_RATE) || 1;`
- Comment: "1 coin = 1 INR"

## Conversion Formula

### Old Logic (100 coins = 1 INR)
- 1 INR = 100 coins
- 1 coin = 0.01 INR
- Product price: ₹100 → 50% cash (₹50) + 50% coins (5000 coins)

### New Logic (1 coin = 1 INR)
- 1 INR = 1 coin
- 1 coin = 1 INR
- Product price: ₹100 → 50% cash (₹50) + 50% coins (50 coins)

## Impact on Features

### Store/Products
- Product prices now show correct coin amounts (1:1 with INR)
- 50/50 payment split now shows realistic coin amounts

### Wallet
- Coin balance now directly represents INR value
- Coin to currency conversion is now 1:1 for INR

### Payments
- Razorpay: 1 INR = 1 coin
- Stripe: Currency-aware (1 INR = 1 coin, 1 USD ≈ 83 coins)
- Add Money: 1 INR = 1 coin

### Withdrawals
- Withdrawal rate: 1 coin = 1 INR (configurable via COIN_TO_INR_RATE env var)

## Testing Checklist
- [ ] Store displays products with correct coin amounts (1:1 with INR)
- [ ] Cart shows correct coin calculations
- [ ] Wallet balance displays correctly
- [ ] Add money converts correctly (1 INR = 1 coin)
- [ ] Razorpay payments award correct coins
- [ ] Stripe payments award correct coins
- [ ] Withdrawals calculate correctly
- [ ] Admin panel creates products with correct coin prices
- [ ] 50/50 payment split shows realistic amounts

## Environment Variables
- `COIN_TO_INR_RATE`: Withdrawal rate (default: 1, meaning 1 coin = 1 INR)
- `STRIPE_SECRET_KEY`: For Stripe payments
- `RAZORPAY_KEY_ID` and `RAZORPAY_KEY_SECRET`: For Razorpay payments
