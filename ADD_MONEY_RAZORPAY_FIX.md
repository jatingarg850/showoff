# Add Money Screen - Razorpay INR Fix

## Issue Fixed
The withdrawal screen was failing with error: `Withdrawal validation failed: usdAmount: Path 'usdAmount' is required`

This was happening because the Withdrawal model requires a `usdAmount` field, but the withdrawal controller wasn't calculating and providing it.

## Changes Made

### Backend - Withdrawal Controller
Added USD amount calculation in `server/controllers/withdrawalController.js`:

```javascript
// Convert INR to USD (1 USD ≈ 83 INR)
const inrToUsdRate = 1 / 83;
const usdAmount = inrAmount * inrToUsdRate;
```

Updated withdrawal data to include usdAmount field.

## Add Money Screen - Currency Handling

### Frontend - Already Correct ✓

**Razorpay (INR):**
- Quick amounts: ₹10, ₹20, ₹50, ₹100, ₹200, ₹500
- Currency display: INR
- Conversion: 1 INR = 1 Coin

**Stripe (USD):**
- Quick amounts: $1, $5, $10, $20, $50, $100
- Currency display: USD
- Conversion: 1 USD = 83 Coins

### Backend - Coin Purchase Order

**For Razorpay (add_money):**
- Receives amount in INR
- Converts to paise: `amount * 100`
- Coins calculation: `amount * 1` (1 INR = 1 coin)

**For Stripe:**
- Receives amount in USD
- Converts to cents: `amount * 100`
- Coins calculation: `amount * 83` (1 USD = 83 coins)

## Summary

✅ Add Money screen correctly shows INR for Razorpay
✅ Withdrawal validation error fixed by adding usdAmount calculation
✅ Currency conversion properly handled throughout the app
