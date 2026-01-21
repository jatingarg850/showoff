# AdMob Multiple Ads - Quick Reference

## What Was Fixed

The "Watch Ads & Earn" screen now shows **5 different ads** instead of the same ad repeated.

## How It Works

Each of the 5 ad options has its own ad unit ID:

```
Ad 1: Quick Video Ad      → Ad Unit ID 1
Ad 2: Product Demo        → Ad Unit ID 2
Ad 3: Interactive Quiz    → Ad Unit ID 3
Ad 4: Survey Rewards      → Ad Unit ID 4
Ad 5: Premium Offer       → Ad Unit ID 5
```

## Key Changes

### AdMob Service
- Changed from single ad to **multiple ads** (one per slot)
- Each ad has its own loading state
- Each ad has its own cached instance
- Methods now accept `adNumber` parameter

### Ad Selection Screen
- Now passes `adNumber` when showing ads
- Each ad option shows different content

## Usage

### Show Ad for Specific Number
```dart
// Show ad #1
await AdMobService.showRewardedAd(adNumber: 1);

// Show ad #3
await AdMobService.showRewardedAd(adNumber: 3);
```

### Preload Ad
```dart
// Preload ad #2
await AdMobService.preloadRewardedAd(adNumber: 2);
```

## Production Setup

Replace test ad unit IDs with your production IDs in `admob_service.dart`:

```dart
static String getRewardedAdUnitId(int adNumber) {
  if (Platform.isAndroid) {
    switch (adNumber) {
      case 1:
        return 'ca-app-pub-YOUR-ID/UNIT-1'; // Your Ad Unit 1
      case 2:
        return 'ca-app-pub-YOUR-ID/UNIT-2'; // Your Ad Unit 2
      case 3:
        return 'ca-app-pub-YOUR-ID/UNIT-3'; // Your Ad Unit 3
      case 4:
        return 'ca-app-pub-YOUR-ID/UNIT-4'; // Your Ad Unit 4
      case 5:
        return 'ca-app-pub-YOUR-ID/UNIT-5'; // Your Ad Unit 5
    }
  }
  // Similar for iOS...
}
```

## Testing

1. Open "Watch Ads & Earn"
2. Click Ad 1 → Shows ad
3. Close and return
4. Click Ad 2 → Shows different ad
5. Repeat for all 5 ads

## Benefits

✅ Users see variety of ads
✅ Better ad performance
✅ Independent ad management
✅ Proper caching per slot
✅ Easy to extend

## Files Changed

- `apps/lib/services/admob_service.dart`
- `apps/lib/ad_selection_screen.dart`

## Debug Logs

Look for these in console:

```
✅ Rewarded ad 1 preloaded successfully
📺 Showing preloaded ad 2...
✅ Rewarded ad 3 loaded
👁️ Ad 4 impression
🎁 User earned reward from ad 5: 25 coins
```

## Troubleshooting

**All ads showing same content?**
- Check if ad unit IDs are different
- Verify AdMob account has multiple ad units

**Ad not loading?**
- Check internet connection
- Verify ad unit ID is correct
- Check AdMob account status

**Ad number not being passed?**
- Verify `adNumber` parameter is included
- Check ad selection screen is passing it correctly
