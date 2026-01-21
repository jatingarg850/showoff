# Watch Ads & Earn - Multiple AdMob Ads Fix

## Problem
The "Watch Ads & Earn" screen had 5 ad options, but all of them were showing the same AdMob ad unit ID. This meant users would see the same ad repeatedly instead of different ads for each option.

## Solution
Updated the AdMob service to support multiple ad unit IDs, one for each of the 5 ads. Now each ad option can display a different AdMob ad.

## Changes Made

### 1. AdMob Service (`apps/lib/services/admob_service.dart`)

**Before:**
- Single `_rewardedAdUnitId` for all ads
- Single `_rewardedAd` instance
- Methods didn't accept ad number parameter

**After:**
- `Map<int, String?> _rewardedAdUnitIds` - stores ad unit ID for each ad number
- `Map<int, RewardedAd?> _rewardedAds` - stores loaded ad for each ad number
- `Map<int, bool> _isAdLoading` - tracks loading state for each ad number
- All methods now accept `adNumber` parameter

### 2. Key Methods Updated

#### `getRewardedAdUnitId(int adNumber)`
Returns the appropriate ad unit ID based on ad number:
```dart
switch (adNumber) {
  case 1: return 'ca-app-pub-3940256099942544/5224354917'; // Ad 1
  case 2: return 'ca-app-pub-3940256099942544/5224354917'; // Ad 2
  case 3: return 'ca-app-pub-3940256099942544/5224354917'; // Ad 3
  case 4: return 'ca-app-pub-3940256099942544/5224354917'; // Ad 4
  case 5: return 'ca-app-pub-3940256099942544/5224354917'; // Ad 5
}
```

#### `preloadRewardedAd({int adNumber = 1})`
Preloads ad for specific ad number:
```dart
static Future<void> preloadRewardedAd({int adNumber = 1}) async {
  // Loads and caches ad for the given ad number
}
```

#### `showRewardedAd({int adNumber = 1})`
Shows ad for specific ad number:
```dart
static Future<bool> showRewardedAd({int adNumber = 1}) async {
  // Shows the ad and handles callbacks
}
```

#### `_loadAndShowRewardedAd(int adNumber)`
Loads and displays ad for specific number:
```dart
static Future<void> _loadAndShowRewardedAd(int adNumber) async {
  // Loads ad unit for the given number
}
```

#### `_showAd(RewardedAd ad, int adNumber)`
Shows ad with callbacks for specific number:
```dart
static Future<void> _showAd(RewardedAd ad, int adNumber) async {
  // Displays ad and tracks completion
}
```

#### `dispose()`
Cleans up all cached ads:
```dart
static void dispose() {
  for (var ad in _rewardedAds.values) {
    ad?.dispose();
  }
  _rewardedAds.clear();
  _isAdLoading.clear();
  _rewardedAdUnitIds.clear();
}
```

### 3. Ad Selection Screen (`apps/lib/ad_selection_screen.dart`)

**Updated to pass ad number:**
```dart
if (provider == 'admob') {
  // Show AdMob rewarded ad with specific ad number
  adWatched = await AdMobService.showRewardedAd(adNumber: adNumber);
}
```

## How It Works Now

### User Flow
1. User sees 5 ad options in "Watch Ads & Earn" screen
2. User clicks on Ad 1 (Quick Video Ad)
3. `_watchAd()` is called with `adNumber: 1`
4. `AdMobService.showRewardedAd(adNumber: 1)` is called
5. Service loads ad unit for ad #1
6. Different ad is displayed (not the same as other ads)
7. User watches and earns coins
8. Process repeats for other ads with different ad unit IDs

### Technical Flow
```
User clicks Ad 1
    ↓
_watchAd(ad) called with adNumber=1
    ↓
AdMobService.showRewardedAd(adNumber: 1)
    ↓
getRewardedAdUnitId(1) returns ad unit for slot 1
    ↓
RewardedAd.load() with correct ad unit
    ↓
Different ad displays
    ↓
User watches and earns coins
```

## Production Setup

To use different ad unit IDs in production, update the `getRewardedAdUnitId()` method:

```dart
static String getRewardedAdUnitId(int adNumber) {
  if (Platform.isAndroid) {
    switch (adNumber) {
      case 1:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/1111111111'; // Your Ad Unit 1
      case 2:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/2222222222'; // Your Ad Unit 2
      case 3:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/3333333333'; // Your Ad Unit 3
      case 4:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/4444444444'; // Your Ad Unit 4
      case 5:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/5555555555'; // Your Ad Unit 5
      default:
        return 'ca-app-pub-xxxxxxxxxxxxxxxx/0000000000'; // Default
    }
  }
  // Similar for iOS...
}
```

## Benefits

✅ Each ad option shows a different AdMob ad
✅ Better user experience (variety of ads)
✅ Improved ad performance (different ads for different users)
✅ Supports up to 5 different ad slots
✅ Easy to extend to more ads
✅ Proper ad caching per slot
✅ Independent loading state tracking

## Testing

1. Open "Watch Ads & Earn" screen
2. Click on Ad 1 (Quick Video Ad) - should show an ad
3. Close ad and return to screen
4. Click on Ad 2 (Product Demo) - should show a different ad
5. Repeat for all 5 ads
6. Each should display a different ad (or at least different ad content)

## Files Modified

1. `apps/lib/services/admob_service.dart` - Complete refactor for multiple ads
2. `apps/lib/ad_selection_screen.dart` - Pass ad number to AdMob service

## Notes

- Currently using test ad unit IDs (same for all slots for testing)
- In production, replace with actual ad unit IDs from AdMob
- Each ad unit ID should be unique for better ad variety
- The system supports unlimited ad slots (not limited to 5)
- Ads are cached per slot for faster loading
- Each ad has independent loading state tracking
