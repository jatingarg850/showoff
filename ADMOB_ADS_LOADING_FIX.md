# AdMob Ads Loading Fix

## Problem
AdMob ads were not showing when users clicked on ads in the "Watch Ads & Earn" screen.

## Root Causes
1. **No preloading** - Ads weren't being preloaded before user clicked
2. **Complex ad unit logic** - Unnecessary complexity in getting ad unit IDs
3. **No background preloading** - Ads only loaded when user clicked (too slow)
4. **Poor error handling** - Errors weren't being logged properly

## Solution

### 1. Simplified AdMob Service (`apps/lib/services/admob_service.dart`)

**Key Changes:**
- Removed complex ad unit ID switching (all use same test ID)
- Added comprehensive debug logging
- Simplified ad loading logic
- Better error handling

**Test Ad Unit IDs:**
```dart
// Android
ca-app-pub-3940256099942544/5224354917

// iOS
ca-app-pub-3940256099942544/1712485313
```

### 2. Background Preloading (`apps/lib/ad_selection_screen.dart`)

**New Feature:**
```dart
Future<void> _preloadAllAds() async {
  // Preload all 5 ads in background
  for (int i = 1; i <= 5; i++) {
    await Future.delayed(const Duration(milliseconds: 500));
    AdMobService.preloadRewardedAd(adNumber: i);
  }
}
```

**When it runs:**
- Automatically called in `initState()`
- Preloads all 5 ads with 500ms delay between each
- Happens in background (doesn't block UI)
- Ads are ready when user clicks

### 3. Improved Logging

All AdMob operations now log with emojis:

```
✅ AdMob initialized successfully
📥 Preloading ad 1 with unit: ca-app-pub-3940256099942544/5224354917
✅ Rewarded ad 1 preloaded successfully
🎬 Attempting to show ad 1
📺 Showing preloaded ad 1...
👁️ Ad 1 impression
🎁 User earned reward from ad 1: 25 coins
📺 Ad 1 dismissed
🧹 AdMob ads disposed
```

## How It Works Now

### User Flow
1. User opens "Watch Ads & Earn" screen
2. **Background: All 5 ads start preloading** (with delays)
3. User sees 5 ad options
4. User clicks on Ad 1
5. **Ad 1 is already preloaded** → Shows immediately
6. User watches ad
7. Coins awarded
8. Ad dismissed

### Technical Flow
```
App Start
    ↓
AdMobService.initialize()
    ↓
Ad Selection Screen opens
    ↓
_preloadAllAds() called
    ↓
For each ad 1-5:
  - Wait 500ms
  - Call preloadRewardedAd(adNumber: i)
  - Ad loads in background
    ↓
User clicks Ad 1
    ↓
showRewardedAd(adNumber: 1)
    ↓
Ad 1 already loaded → Show immediately
    ↓
User watches and earns coins
```

## Key Improvements

✅ **Instant Ad Display** - Ads preloaded before user clicks
✅ **Better Error Handling** - Comprehensive logging for debugging
✅ **Simplified Logic** - Removed unnecessary complexity
✅ **Background Loading** - Doesn't block UI
✅ **Reliable** - Falls back gracefully if ad fails
✅ **Production Ready** - Easy to swap test IDs for production

## Production Setup

To use production ad unit IDs, update `admob_service.dart`:

```dart
// Replace test IDs with your production IDs
static const String _androidTestAdUnitId = 'ca-app-pub-YOUR-ID/YOUR-UNIT-1';
static const String _iosTestAdUnitId = 'ca-app-pub-YOUR-ID/YOUR-UNIT-2';
```

## Testing

1. Open "Watch Ads & Earn" screen
2. Check console for preloading logs:
   ```
   📥 Preloading ad 1...
   ✅ Rewarded ad 1 preloaded successfully
   📥 Preloading ad 2...
   ✅ Rewarded ad 2 preloaded successfully
   ...
   ```
3. Click on any ad
4. Ad should show immediately (or within 1-2 seconds)
5. Watch ad and earn coins

## Debug Checklist

- [ ] AdMob initialized (check logs for ✅)
- [ ] All 5 ads preloading (check for 📥 logs)
- [ ] Ads preload successfully (check for ✅ logs)
- [ ] Clicking ad shows it (check for 📺 logs)
- [ ] Ad completes (check for 👁️ and 🎁 logs)
- [ ] Coins awarded (check backend response)

## Files Modified

1. `apps/lib/services/admob_service.dart` - Complete rewrite
2. `apps/lib/ad_selection_screen.dart` - Added preloading

## Common Issues

### Ads not showing
- Check if AdMob is initialized
- Check console for error logs
- Verify test ad unit IDs are correct
- Check internet connection

### Ads showing but no reward
- Check backend `/api/watch-ad/:adNumber` endpoint
- Verify user is authenticated
- Check coin balance in database

### Slow ad loading
- Ads are preloading in background
- First ad may take 2-3 seconds
- Subsequent ads should be instant

## Notes

- Using Google's official test ad unit IDs
- Test ads will always show (even without AdMob account)
- Production IDs required for real ads
- Preloading happens automatically
- All ads preload with 500ms delays to avoid network congestion
