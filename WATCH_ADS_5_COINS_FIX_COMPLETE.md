# Watch Ads - 5 Coins Only Fix (Complete)

## Problem
The app was showing different reward values for ads (5, 10, 15, 20, 25 coins) even though the backend was capping rewards at 5 coins. The issue was:
1. Database had RewardedAd records with varying reward values (5, 10, 15, 20, 25)
2. The `getAdsForApp` endpoint returned these values as-is without capping
3. The app displayed these incorrect values to users
4. Even though `watchAd` endpoint capped at 5, the UI showed wrong values

## Solution Implemented

### 1. Backend Changes

#### Updated `getAdsForApp` Endpoint
**File**: `server/controllers/adminController.js` (line 1733-1785)

Added reward capping when returning ads to the app:
```javascript
rewardCoins: Math.min(ad.rewardCoins, 5), // Cap at 5 coins maximum
```

This ensures that even if database has higher values, the app always sees 5 coins max.

#### Existing `watchAd` Endpoint
**File**: `server/controllers/coinController.js` (line 26-100)

Already had the cap in place:
```javascript
// Cap reward at 5 coins maximum
adCoins = Math.min(adCoins, 5);
```

### 2. Database Updates

#### Updated Seed Script
**File**: `server/scripts/seed-rewarded-ads.js`

Changed all 5 ads to have 5 coins reward:
- Ad 1: Quick Video Ad → 5 coins (was 5)
- Ad 2: Product Demo → 5 coins (was 10)
- Ad 3: Interactive Quiz → 5 coins (was 15)
- Ad 4: Survey Rewards → 5 coins (was 20)
- Ad 5: Premium Offer → 5 coins (was 25)

#### Created Migration Script
**File**: `server/scripts/migrate-ads-to-5-coins.js`

For updating existing database records to 5 coins:
```bash
node server/scripts/migrate-ads-to-5-coins.js
```

### 3. Execution

Ran seed script to initialize database with correct values:
```
✅ Created 5 rewarded ads
   - Ad 1: Quick Video Ad (5 coins, admob)
   - Ad 2: Product Demo (5 coins, admob)
   - Ad 3: Interactive Quiz (5 coins, meta)
   - Ad 4: Survey Rewards (5 coins, custom)
   - Ad 5: Premium Offer (5 coins, third-party)
```

## How It Works Now

1. **App Fetches Ads**: Calls `GET /api/rewarded-ads`
2. **Backend Returns**: Ads with `rewardCoins: 5` (capped)
3. **App Displays**: Shows 5 coins to user
4. **User Watches Ad**: Calls `POST /api/coins/watch-ad`
5. **Backend Awards**: Caps at 5 coins and awards to user

## Testing

### Manual Test Steps
1. Restart the app (full restart, not hot reload)
2. Navigate to Watch Ads screen
3. Verify all ads show "5 coins" reward
4. Watch an ad
5. Verify user receives exactly 5 coins

### Expected Behavior
- All ads display 5 coins reward
- User receives exactly 5 coins per ad watched
- Daily limits still apply (free: 5, basic: 10, pro: 15, vip: 50)
- 15-minute cooldown after every 3 ads

## Files Modified
1. `server/controllers/adminController.js` - Added reward capping in `getAdsForApp`
2. `server/scripts/seed-rewarded-ads.js` - Updated all ads to 5 coins
3. `server/scripts/migrate-ads-to-5-coins.js` - Created migration script

## Notes
- The fix is now at TWO levels: database seed + backend capping
- Even if admin manually sets higher values in database, app will cap at 5
- This ensures consistency across all scenarios
- No app code changes needed - backend handles the capping
