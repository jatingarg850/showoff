# Watch Ads - 5 Coins Only - Quick Action

## What Was Fixed
❌ Ads were rewarding 5, 10, 15, 20, 25 coins
✅ Now all ads reward exactly 5 coins only

## Changes Made

### Frontend (Flutter)
- File: `apps/lib/services/rewarded_ad_service.dart`
- Changed: All 5 default ads now reward 5 coins each
- Result: UI shows "+5" for all ads

### Backend (Node.js)
- File: `server/controllers/coinController.js`
- Added: `adCoins = Math.min(adCoins, 5);`
- Result: Backend caps rewards at 5 coins maximum

## How to Apply

### Step 1: Restart Backend
```bash
npm start
```

### Step 2: Hot Reload Flutter App
Press `R` in terminal to hot reload

## Verification

1. Open "Watch Ads & Earn" screen
2. All ads should show "+5" coins badge
3. Watch any ad
4. User receives exactly 5 coins
5. Check backend logs: `✅ Final reward (capped at 5): 5 coins`

## Daily Limits (Unchanged)
- Free: 5 ads/day = 25 coins max
- Basic: 10 ads/day = 50 coins max
- Pro: 15 ads/day = 75 coins max
- VIP: 50 ads/day = 250 coins max

## Done! ✅

All ads now reward only 5 coins maximum, with backend enforcement to prevent any higher rewards.
