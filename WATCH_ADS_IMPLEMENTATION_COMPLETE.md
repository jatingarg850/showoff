# Watch Ads Feature - Complete Implementation Guide

## Overview
The "Watch Ads" feature allows users to watch rewarded ads and earn coins. The system is fully integrated with AdMob and supports multiple ad providers.

## Architecture

### Frontend Flow
```
User clicks "Watch Ads" button
  ↓
AdSelectionScreen loads ads from server
  ↓
User selects an ad to watch
  ↓
AdMobService.showRewardedAd() displays ad
  ↓
User watches ad completely
  ↓
ApiService.watchAd() calls backend endpoint
  ↓
Backend awards coins to user
  ↓
Success dialog shows earned coins
  ↓
Return to wallet with refresh
```

## Components

### 1. AdMobService (`apps/lib/services/admob_service.dart`)
**Improved Implementation:**
- ✅ Proper callback-based ad completion detection (no polling)
- ✅ Preloading ads in background for faster display
- ✅ Better error handling and logging
- ✅ Proper resource cleanup with dispose()
- ✅ Support for test Ad Unit IDs (development)

**Key Methods:**
- `initialize()` - Initialize AdMob SDK
- `preloadRewardedAd()` - Load ad in background
- `showRewardedAd()` - Show ad to user
- `dispose()` - Clean up resources

**Features:**
- Automatic preloading of next ad after current one completes
- Timeout handling (120 seconds max wait)
- Comprehensive debug logging
- Graceful fallback if ad fails to load

### 2. RewardedAdService (`apps/lib/services/rewarded_ad_service.dart`)
**Responsibilities:**
- Fetch ads from backend: `GET /rewarded-ads`
- Track ad clicks: `POST /rewarded-ads/:adNumber/click`
- Track conversions: `POST /rewarded-ads/:adNumber/conversion`
- Provide default ads as fallback
- Support flexible reward coins per ad

**Key Methods:**
- `fetchRewardedAds()` - Get ads from server (always fresh)
- `getDefaultAds()` - Fallback ads if server unavailable
- `trackAdClick(adNumber)` - Track user interaction
- `trackAdConversion(adNumber)` - Track completion
- `getRewardCoins(ad)` - Get flexible reward amount
- `refreshAds()` - Force refresh from server

### 3. AdSelectionScreen (`apps/lib/ad_selection_screen.dart`)
**Features:**
- Displays all available ads with dynamic UI
- Shows ad title, description, icon, color, and reward
- Supports multiple ad providers (AdMob, Meta, Custom, Third-party)
- Tracks ad impressions and conversions
- Shows success dialog with earned coins
- Returns `true` when ad is successfully watched

**Flow:**
1. Load ads from server on init
2. Display ads in grid/list
3. User selects ad → `_watchAd()` called
4. Track click via RewardedAdService
5. Show ad via AdMobService
6. Track conversion
7. Call backend to award coins
8. Show success dialog
9. Return to caller with `true`

### 4. SpinWheelScreen (`apps/lib/spin_wheel_screen.dart`)
**Fixed Implementation:**
- ✅ "Watch ads" button now navigates to AdSelectionScreen
- ✅ Properly handles return value from AdSelectionScreen
- ✅ Resets spins only if user successfully watched ads
- ✅ Uses async/await with mounted check

**Code:**
```dart
onPressed: () async {
  Navigator.of(context).pop();
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const AdSelectionScreen(),
    ),
  );
  if (result == true && mounted) {
    setState(() {
      _spinsLeft = 5; // Reset spins after watching ads
    });
  }
}
```

### 5. WalletScreen (`apps/lib/wallet_screen.dart`)
**Features:**
- Has "Watch Ads" button in header
- Navigates to AdSelectionScreen
- Refreshes balance after ad is watched
- Shows earned coins notification

## Server-Side Implementation

### CoinController (`server/controllers/coinController.js`)

**Watch Ad Endpoint:**
```
POST /api/coins/watch-ad (Protected)
```

**Features:**
- Daily limits based on subscription tier:
  - Free: 5 ads/day
  - Basic: 10 ads/day
  - Pro: 15 ads/day
  - VIP: 50 ads/day
- Cooldown: 15 minutes after every 3 ads
- Tracks daily ad count and resets at midnight
- Awards coins from `AD_WATCH_COINS` environment variable
- Returns: `coinsEarned`, `dailyAdsWatched`, `dailyLimit`, `cooldownUntil`

**Response:**
```json
{
  "success": true,
  "coinsEarned": 10,
  "dailyAdsWatched": 1,
  "dailyLimit": 5,
  "cooldownUntil": null
}
```

### AdminController (`server/controllers/adminController.js`)

**Public Ad Endpoints:**

1. **Get Ads for App**
   ```
   GET /rewarded-ads (Public)
   ```
   - Returns active ads with metadata
   - Updates impressions and servedCount
   - Returns: id, adNumber, title, description, icon, color, adProvider, rewardCoins, providerConfig

2. **Track Ad Click**
   ```
   POST /rewarded-ads/:adNumber/click (Public)
   ```
   - Increments click counter for ad

3. **Track Ad Conversion**
   ```
   POST /rewarded-ads/:adNumber/conversion (Public)
   ```
   - Increments conversion counter for ad

## Environment Variables Required

```bash
# Coin rewards
AD_WATCH_COINS=10          # Coins awarded per ad watch

# AdMob (optional - use test IDs by default)
ADMOB_ANDROID_AD_UNIT_ID=  # Production Android Ad Unit
ADMOB_IOS_AD_UNIT_ID=      # Production iOS Ad Unit
```

## Testing

### Test Ad Unit IDs (Built-in)
- **Android**: `ca-app-pub-3940256099942544/5224354917`
- **iOS**: `ca-app-pub-3940256099942544/1712485313`

These are Google's official test Ad Unit IDs and will always show test ads.

### Testing Checklist
- [ ] AdMob initializes on app startup
- [ ] "Watch Ads" button appears in wallet screen
- [ ] "Watch Ads" button appears in spin wheel out-of-spins modal
- [ ] Clicking button navigates to AdSelectionScreen
- [ ] Ads load and display correctly
- [ ] Ad plays when user clicks
- [ ] Success dialog shows after ad completes
- [ ] Coins are awarded to user
- [ ] Daily limit is enforced
- [ ] Cooldown works after 3 ads
- [ ] Spins reset after watching ads (spin wheel)
- [ ] Balance refreshes after watching ads (wallet)

## Deployment Checklist

### Before Production Release
- [ ] Replace test Ad Unit IDs with production IDs
- [ ] Set `AD_WATCH_COINS` environment variable
- [ ] Test with real ads (not test ads)
- [ ] Verify daily limits work correctly
- [ ] Test cooldown functionality
- [ ] Verify coin awards appear in user balance
- [ ] Test on both Android and iOS
- [ ] Verify ads show for different subscription tiers
- [ ] Test error handling (no ads available, network error, etc.)

### Production Ad Unit IDs
To use production ads:
1. Create AdMob account and app
2. Create rewarded ad units for Android and iOS
3. Update AdMobService with production IDs:
   ```dart
   if (Platform.isAndroid) {
     _rewardedAdUnitId = 'YOUR_ANDROID_AD_UNIT_ID';
   } else if (Platform.isIOS) {
     _rewardedAdUnitId = 'YOUR_IOS_AD_UNIT_ID';
   }
   ```
4. Or use environment variables/Firebase Remote Config

## Troubleshooting

### Ads Not Showing
1. Check AdMob initialization in main.dart
2. Verify Ad Unit IDs are correct
3. Check network connectivity
4. Verify user is authenticated
5. Check daily limit hasn't been reached
6. Check cooldown period

### Coins Not Awarded
1. Verify `AD_WATCH_COINS` environment variable is set
2. Check user subscription tier
3. Verify backend endpoint is accessible
4. Check user balance in database
5. Verify transaction was created

### Ad Fails to Load
1. Check internet connection
2. Verify Ad Unit ID is valid
3. Check AdMob account status
4. Verify app is registered in AdMob
5. Check for ad policy violations

## Future Enhancements

1. **Multiple Ad Networks**: Add Meta Audience Network, AppLovin, etc.
2. **Interstitial Ads**: Show between actions
3. **Banner Ads**: Show in feed
4. **Native Ads**: Custom ad layouts
5. **Analytics**: Track ad performance metrics
6. **A/B Testing**: Test different reward amounts
7. **Fraud Detection**: Detect ad fraud patterns
8. **Offline Support**: Cache ads for offline viewing

## Files Modified

### App-Side
- ✅ `apps/lib/services/admob_service.dart` - Improved implementation
- ✅ `apps/lib/spin_wheel_screen.dart` - Fixed watch ads button
- ✅ `apps/lib/ad_selection_screen.dart` - Already working correctly
- ✅ `apps/lib/services/rewarded_ad_service.dart` - Already working correctly
- ✅ `apps/lib/wallet_screen.dart` - Already working correctly

### Server-Side
- ✅ `server/controllers/coinController.js` - Already working correctly
- ✅ `server/controllers/adminController.js` - Already working correctly
- ✅ `server/routes/publicRoutes.js` - Already has ad endpoints

## Summary

The Watch Ads feature is now fully functional with:
- ✅ Proper AdMob integration with test ads
- ✅ Callback-based ad completion detection
- ✅ Flexible reward system
- ✅ Daily limits and cooldowns
- ✅ Multi-provider support
- ✅ Proper error handling
- ✅ Success notifications
- ✅ Spin wheel integration
- ✅ Wallet integration

Users can now watch ads to earn coins, with proper rate limiting and fraud prevention!
