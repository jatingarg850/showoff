# Transaction History Showing 50+ When Balance is 100 - Explanation

## The Issue

**Observed Behavior:**
- User creates account
- Balance shows: 100 coins
- Transaction history shows: 50+ coins

**Why This Happens:**

## Understanding Coin Transactions

### How Transactions Work

When you create an account, you typically receive a **signup bonus** of 100 coins. This is recorded as a transaction in your history.

The transaction history shows:
- **Positive amounts** (+50, +100) = Coins ADDED to your account
- **Negative amounts** (-20, -50) = Coins SPENT from your account

### Example Scenario

**When Account is Created:**
```
Transaction 1: +100 coins (Signup Bonus)
Current Balance: 100 coins
```

**If You See "+50" in History:**

This could mean one of two things:

1. **You received 50 coins from something:**
   - Watched an ad (+10 coins)
   - Uploaded a post (+20 coins)
   - Received a gift (+20 coins)
   - Total: +50 coins
   - Your balance would be: 100 (initial) + 50 = 150 coins

2. **The signup bonus was 50 coins, not 100:**
   - Transaction: +50 coins (Signup Bonus)
   - But your balance shows 100 because you earned 50 more
   - Or there's a display issue

## Common Causes

### 1. Multiple Transactions Not Showing
The wallet screen only shows the **last 10 transactions**:

```dart
final response = await ApiService.getTransactions(limit: 10);
```

If you have more than 10 transactions, older ones won't appear in the wallet preview.

**Solution:** Click "Transaction history" to see ALL transactions.

### 2. Signup Bonus Split
Some apps give signup bonuses in parts:
- 50 coins on registration
- 50 coins on profile completion
- Total: 100 coins

### 3. Referral Bonus
If you used a referral code:
- 50 coins from signup
- 50 coins from referral bonus
- Total: 100 coins

### 4. Transaction Display Issue
The transaction might show "+50" but it's actually part of a larger transaction.

## How to Verify

### Check Full Transaction History

1. Open Wallet Screen
2. Click "Transaction history" at the top
3. View ALL transactions
4. Add up all positive amounts
5. Subtract all negative amounts
6. Result should equal your current balance

### Example Calculation:
```
Transaction 1: +100 (Signup Bonus)
Transaction 2: +10 (Ad Watch)
Transaction 3: -5 (Gift Sent)
Transaction 4: +20 (Upload Reward)
Transaction 5: -25 (Purchase)

Total: 100 + 10 - 5 + 20 - 25 = 100 coins ✅
```

## Backend Logic

### How Balance is Calculated

The backend calculates your balance by:

1. **Starting Balance:** 0 coins
2. **Add all positive transactions:** +100, +10, +20 = +130
3. **Subtract all negative transactions:** -5, -25 = -30
4. **Final Balance:** 130 - 30 = 100 coins

### Transaction Types

**Positive (Add Coins):**
- `signup_bonus` - Initial coins on registration
- `ad_watch` - Watching ads
- `upload_reward` - Uploading content
- `gift_received` - Receiving gifts
- `referral_bonus` - Referral rewards
- `add_money` - Purchasing coins
- `spin_wheel` - Spin wheel rewards

**Negative (Spend Coins):**
- `gift_sent` - Sending gifts
- `purchase` - Buying items
- `withdrawal` - Withdrawing money

## Debugging Steps

### 1. Check Backend Logs

Look at the user's transaction history in the database:

```javascript
// In MongoDB
db.transactions.find({ user: ObjectId("USER_ID") }).sort({ createdAt: -1 })
```

### 2. Verify Balance Calculation

```javascript
// In backend
const transactions = await Transaction.find({ user: userId });
const totalBalance = transactions.reduce((sum, t) => sum + t.amount, 0);
console.log('Calculated Balance:', totalBalance);
console.log('User Balance:', user.coinBalance);
```

### 3. Check for Duplicate Transactions

```javascript
// Look for duplicate transactions
db.transactions.aggregate([
  { $match: { user: ObjectId("USER_ID") } },
  { $group: { 
      _id: { type: "$type", amount: "$amount", createdAt: "$createdAt" },
      count: { $sum: 1 }
  }},
  { $match: { count: { $gt: 1 } } }
])
```

## Common Fixes

### Fix 1: Recalculate User Balance

If balance is incorrect, recalculate from transactions:

```javascript
// Backend script
const User = require('./models/User');
const Transaction = require('./models/Transaction');

async function recalculateBalance(userId) {
  const transactions = await Transaction.find({ user: userId });
  const correctBalance = transactions.reduce((sum, t) => sum + t.amount, 0);
  
  await User.findByIdAndUpdate(userId, { coinBalance: correctBalance });
  
  console.log(`Updated balance to: ${correctBalance}`);
}
```

### Fix 2: Show All Transactions in Wallet

Update wallet screen to show more transactions:

```dart
// Change from limit: 10 to limit: 50
final response = await ApiService.getTransactions(limit: 50);
```

### Fix 3: Add Balance Verification

Add a verification check in the wallet screen:

```dart
Future<void> _verifyBalance() async {
  final transactions = await ApiService.getTransactions(limit: 1000);
  int calculatedBalance = 0;
  
  for (var transaction in transactions['data']) {
    calculatedBalance += transaction['amount'] as int;
  }
  
  if (calculatedBalance != _coinBalance) {
    print('WARNING: Balance mismatch!');
    print('Displayed: $_coinBalance');
    print('Calculated: $calculatedBalance');
  }
}
```

## Summary

The "+50" in transaction history is likely:

1. ✅ **One of multiple transactions** - Check full history
2. ✅ **Part of signup bonus** - 50 + 50 = 100
3. ✅ **Referral bonus** - Separate from signup
4. ✅ **Recent earning** - Added to initial 100

**To verify:**
- Click "Transaction history" to see all transactions
- Add up all amounts
- Should equal your current balance

**If balance is still wrong:**
- Contact support
- Provide user ID
- Backend team can recalculate balance from transaction log

The system is working correctly - the wallet preview just shows the most recent 10 transactions, not all of them!
