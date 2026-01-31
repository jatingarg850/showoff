# Subscription Coin Fix - Quick Action Guide

## The Issue
❌ Subscription requires 249,900 coins instead of 2,499 coins

## The Fix (3 Steps)

### Step 1: Reset Database
```bash
cd server
node scripts/resetAndSeedSubscriptions.js
```

Wait for output:
```
✅ Subscription plans reset and seeded successfully!
```

### Step 2: Restart Server
```bash
npm start
```

### Step 3: Reload App
In Flutter terminal, press `R` to hot reload

## Done! ✅

Now test:
1. Open subscription screen
2. Select Pro plan
3. Click "Subscribe with 2499 Coins"
4. Should show: "You need 2,499 coins" (not 249,900)

## What Was Fixed

| Issue | Before | After |
|-------|--------|-------|
| Price format | `{ monthly: 2499 }` | `2499` |
| Coins required | 249,900 | 2,499 |
| User can subscribe | ❌ No (4,560 < 249,900) | ✅ Yes (4,560 > 2,499) |

## Files Changed
- `server/scripts/seedSubscriptionPlans.js` - Fixed price format
- `server/controllers/subscriptionController.js` - Simplified logic
- `server/scripts/resetAndSeedSubscriptions.js` - New reset script

That's it! The subscription coin system is now fixed.
