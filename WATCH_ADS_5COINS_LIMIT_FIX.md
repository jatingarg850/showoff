# Watch Ads & Earn - 5 Coins Maximum Limit

## Issue
The "Watch Ads & Earn" screen was showing different rewards for different ads:
- Quick Video Ad: +5 coins
- Product Demo: +10 coins
- Interactive Quiz: +15 coins
- Survey Rewards: +20 coins
- Premium Offer: +25 coins

**Requirement:** All ads should reward only 5 coins maximum.

## Solution Implemented

### 1. Frontend Fix (apps/lib/services/rewarded_ad_service.dart)
Updated `getDefaultAds()` method to set all rewards to 5 coins:

**Before:**
```dart
'rewardCoins': 5,   // Ad 1
'rewardCoins': 10,  // Ad 2
'rewardCoins': 15,  // Ad 3
'rewardCoins': 20,  // Ad 4
'rewardCoins': 25,  // Ad 5
```

**After:**
```dart
'rewardCoins': 5,   // All ads now reward 5 coins
'rewardCoins': 5,
'rewardCoins': 5,
'rewardCoins': 5,
'rewardCoins': 5,
```

### 2. Backend Fix (server/controllers/coinController.js)
Added a cap to ensure no more than 5 coins are awarded:

**Added:**
```javascript
// Cap reward at 5 coins maximum
adCoins = Math.min(adCoins, 5);
console.log(`✅ Final reward (capped at 5): ${adCoins} coins`);
```

This ensures that even if:
- Admin configures higher rewards in the database
- Backend returns higher values
- Frontend sends higher values

The system will never award more than 5 coins per ad watch.

## How It Works

1. **User watches an ad** on the "Watch Ads & Earn" screen
2. **Frontend shows** "+5 coins" badge for all ads
3. **Backend receives** the watch request
4. **Backend caps** the reward at 5 coins maximum
5. **User receives** exactly 5 coins (no more, no less)

## Files Modified

1. **apps/lib/services/rewarded_ad_service.dart**
   - Updated all 5 default ads to reward 5 coins each

2. **server/controllers/coinController.js**
   - Added `Math.min(adCoins, 5)` to cap rewards at 5 coins

## Testing

To verify the fix:

1. **Open the app**
2. **Navigate to "Watch Ads & Earn"**
3. **Verify all ads show "+5" coins badge**
4. **Watch any ad**
5. **Verify user receives exactly 5 coins**
6. **Check logs show:** `✅ Final reward (capped at 5): 5 coins`

## Daily Limits

Daily ad watch limits remain based on subscription tier:
- Free: 5 ads/day = 25 coins/day max
- Basic: 10 ads/day = 50 coins/day max
- Pro: 15 ads/day = 75 coins/day max
- VIP: 50 ads/day = 250 coins/day max

## Cooldown

After every 3 ads watched, user must wait 15 minutes before watching another ad.

## Security

The backend cap ensures that:
- ✅ No admin can configure higher rewards
- ✅ No database manipulation can increase rewards
- ✅ No frontend tampering can increase rewards
- ✅ Maximum 5 coins per ad, always

## Result

✅ All ads now reward exactly 5 coins
✅ No variation between different ad types
✅ Backend enforces the limit
✅ User experience is consistent
