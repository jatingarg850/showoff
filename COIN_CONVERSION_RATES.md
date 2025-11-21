# Coin Conversion Rates - Updated

## New Conversion Rate: 1 Coin = 1 Rupee (INR)

### Overview
The coin system has been updated to use a simple 1:1 conversion rate with Indian Rupees (INR).

## Conversion Rates

### Indian Rupees (INR) - Razorpay
```
1 INR = 1 Coin
```

**Examples:**
- ₹10 = 10 coins
- ₹100 = 100 coins
- ₹1,000 = 1,000 coins

### US Dollars (USD) - Stripe
```
1 USD ≈ 83 Coins
```

**Note**: Based on approximate exchange rate (1 USD ≈ 83 INR)

**Examples:**
- $1 = 83 coins
- $10 = 830 coins
- $100 = 8,300 coins

## Updated Files

### Server-Side
1. **server/.env**
   - Changed `COIN_TO_USD_RATE=100` to `COIN_TO_INR_RATE=1`

2. **server/controllers/coinController.js**
   - Razorpay: `1 INR = 1 coin` (was 1.2 coins)
   - Stripe: `1 USD = 83 coins` (was 100 coins)

3. **server/controllers/withdrawalController.js**
   - Updated to use `COIN_TO_INR_RATE`
   - Withdrawal calculation: `coins / 1 = INR amount`

### Client-Side (Flutter)
1. **apps/lib/enhanced_add_money_screen.dart**
   - Display: "1 INR = 1 Coin" (was 1.2 Coins)
   - Display: "1 USD = 83 Coins" (was 100 Coins)

2. **apps/lib/services/api_service.dart**
   - Coin calculation: `amount * 1` (was amount * 1.2)

## Earning Coins

### Ways to Earn
| Method | Coins Earned | Notes |
|--------|--------------|-------|
| Upload Post | 5 coins | Per post upload |
| Upload Bonus | 10 coins | After 10 posts |
| Views (per 1000) | 10 coins | Per 1000 views |
| Ad Watch | 10 coins | Per ad watched |
| Referral (First 100) | 50 coins | Per referral |
| Referral (After 100) | 20 coins | Per referral |
| Gifts Received | Variable | Based on gift value |
| Competition Prizes | Variable | Based on ranking |

### Daily/Monthly Caps
- **Daily Coin Cap**: 5,000 coins
- **Monthly Coin Cap**: 100,000 coins

## Spending Coins

### What You Can Buy
| Item | Cost | INR Equivalent |
|------|------|----------------|
| Virtual Gifts | 10-1000 coins | ₹10-₹1,000 |
| Premium Features | Variable | Based on feature |
| Store Items | Variable | Based on item |

## Withdrawal

### Minimum Withdrawal
- **Minimum**: 100 coins = ₹100

### Withdrawal Methods
1. **Bank Transfer** (INR)
   - Direct conversion: 100 coins = ₹100
   
2. **Web3 Wallet** (Crypto)
   - Converted to crypto equivalent

### Withdrawal Fees
- Bank Transfer: 2% or ₹10 (whichever is higher)
- Web3 Wallet: Network gas fees apply

## Payment Methods

### Razorpay (INR)
- **Currency**: Indian Rupees (₹)
- **Conversion**: 1 INR = 1 coin
- **Example**: Pay ₹500 → Get 500 coins

### Stripe (USD)
- **Currency**: US Dollars ($)
- **Conversion**: 1 USD = 83 coins
- **Example**: Pay $10 → Get 830 coins

## Examples

### Adding Money
```
Razorpay (INR):
₹10 → 10 coins
₹50 → 50 coins
₹100 → 100 coins
₹500 → 500 coins
₹1,000 → 1,000 coins

Stripe (USD):
$1 → 83 coins
$5 → 415 coins
$10 → 830 coins
$50 → 4,150 coins
$100 → 8,300 coins
```

### Withdrawing Money
```
100 coins → ₹100
500 coins → ₹500
1,000 coins → ₹1,000
5,000 coins → ₹5,000
10,000 coins → ₹10,000
```

### Earning Through Activities
```
Upload 10 posts:
- 10 posts × 5 coins = 50 coins
- Bonus = 10 coins
- Total = 60 coins = ₹60

Watch 5 ads:
- 5 ads × 10 coins = 50 coins = ₹50

Refer 10 friends:
- 10 referrals × 50 coins = 500 coins = ₹500

Get 10,000 views:
- 10,000 views / 1000 × 10 = 100 coins = ₹100
```

## Benefits of 1:1 Rate

### For Users
- ✅ **Simple to understand**: 1 coin = 1 rupee
- ✅ **Easy calculations**: No complex math
- ✅ **Transparent**: Clear value of coins
- ✅ **Fair**: Direct conversion to real money

### For Business
- ✅ **Clear pricing**: Easy to set prices
- ✅ **Better trust**: Users understand value
- ✅ **Simplified accounting**: 1:1 mapping
- ✅ **Reduced confusion**: No conversion errors

## Migration Notes

### Previous Rates
- **INR**: 1 INR = 1.2 coins
- **USD**: 1 USD = 100 coins

### New Rates
- **INR**: 1 INR = 1 coin
- **USD**: 1 USD = 83 coins

### Impact on Existing Users
- Existing coin balances remain unchanged
- New purchases use new rates
- Withdrawals use new rates
- All earning rates remain the same

## Configuration

### Environment Variables
```env
# server/.env
COIN_TO_INR_RATE=1
```

### Code Constants
```javascript
// Razorpay (INR)
coinsToAdd = Math.floor(amountInINR * 1); // 1 INR = 1 coin

// Stripe (USD)
coinsToAdd = Math.floor(amountInUSD * 83); // 1 USD ≈ 83 coins
```

## Testing

### Test Scenarios
1. **Add ₹100 via Razorpay**
   - Expected: 100 coins added
   
2. **Add $10 via Stripe**
   - Expected: 830 coins added
   
3. **Withdraw 500 coins**
   - Expected: ₹500 transferred
   
4. **Watch 5 ads**
   - Expected: 50 coins earned (10 per ad)

---

**Status**: ✅ Updated to 1 Coin = 1 Rupee
**Last Updated**: 2024
**Primary Currency**: Indian Rupees (INR)
**Exchange Rate**: 1 USD ≈ 83 INR (approximate)
