# Watch Ads & Earn - Display Fix

## Problem
The "Watch Ads & Earn" screen was showing "No ads available" because it was waiting for the server to return ads, but the database was empty (seed script hadn't been run).

## Root Cause
The `_loadAds()` method was:
1. Trying to fetch ads from server
2. If server returned empty or failed, showing "No ads available"
3. Never falling back to default ads immediately

## Solution
Changed the loading strategy to:
1. **Immediately load default ads** (always available)
2. **Show ads to user right away**
3. **Try to refresh from server in background** (non-blocking)
4. **Update UI if server returns different ads**

## Code Changes

### Before
```dart
Future<void> _loadAds() async {
  try {
    // Wait for server response
    final ads = await RewardedAdService.refreshAds();
    if (mounted) {
      setState(() {
        _adOptions = ads;
        _adsLoaded = true;
      });
    }
  } catch (e) {
    // Only fallback on error
    setState(() {
      _adOptions = RewardedAdService.getDefaultAds();
      _adsLoaded = true;
    });
  }
}
```

### After
```dart
Future<void> _loadAds() async {
  try {
    // Load defaults immediately
    _adOptions = RewardedAdService.getDefaultAds();
    
    if (mounted) {
      setState(() {
        _adsLoaded = true;  // Show ads now!
      });
    }
    
    // Try to refresh from server in background
    try {
      final ads = await RewardedAdService.refreshAds();
      if (ads.isNotEmpty && mounted) {
        setState(() {
          _adOptions = ads;  // Update if server has different ads
        });
      }
    } catch (e) {
      debugPrint('Background refresh failed, using defaults: $e');
    }
  } catch (e) {
    debugPrint('Error loading ads: $e');
    if (mounted) {
      setState(() {
        _adOptions = RewardedAdService.getDefaultAds();
        _adsLoaded = true;
      });
    }
  }
}
```

## Benefits

✅ **Instant Display** - Ads show immediately (no waiting)
✅ **Always Works** - Default ads always available
✅ **Server Sync** - Updates from server if available
✅ **Non-Blocking** - Server fetch doesn't block UI
✅ **Better UX** - Users see ads right away
✅ **Fallback Ready** - Works offline or if server is down

## User Experience

### Before
1. User opens "Watch Ads & Earn"
2. Screen waits for server response
3. If server is slow or empty → "No ads available"
4. User sees nothing

### After
1. User opens "Watch Ads & Earn"
2. **5 ads appear immediately** (from defaults)
3. Server updates in background (if available)
4. User can start watching ads right away

## Default Ads

The 5 default ads are always available:

1. **Quick Video Ad** (5 coins)
2. **Product Demo** (10 coins)
3. **Interactive Quiz** (15 coins)
4. **Survey Rewards** (20 coins)
5. **Premium Offer** (25 coins)

## Server Integration

When the database is seeded with ads:
1. Ads load from defaults immediately
2. Server ads are fetched in background
3. If server has ads, they replace defaults
4. If server fails, defaults remain

## Files Modified

- `apps/lib/ad_selection_screen.dart` - Updated `_loadAds()` method

## Testing

1. Open "Watch Ads & Earn" screen
2. **Should see 5 ads immediately** (no loading delay)
3. Each ad shows:
   - Title
   - Description
   - Coin reward
   - Icon and color
4. Can click any ad to watch

## Next Steps

### Optional: Seed Database
To use server ads instead of defaults:

```bash
cd server
node scripts/seed-rewarded-ads.js
```

Then restart server:
```bash
npm start
```

### Production
- Default ads work offline
- Server ads can override defaults
- System is resilient to server failures
- Users always see ads

## Notes

- Default ads are hardcoded in `rewarded_ad_service.dart`
- Server ads are fetched from `/api/rewarded-ads`
- Background refresh doesn't block UI
- Works with or without database
- Supports both online and offline modes
