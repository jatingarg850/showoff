# Fix: Spin Wheel Watch Ads - Show Admin-Uploaded Ads Directly

## Problem
When clicking "Watch ads" in the Spin Wheel screen, it was showing a rewards screen with default ads instead of directly showing admin-uploaded ads.

## Root Cause
The `AdSelectionScreen` was only fetching rewarded ads for spin-wheel type but **completely ignoring video ads**. When no ads were found, it fell back to default ads, which appeared as a rewards screen.

**Missing Code:**
```dart
// Video ads were NOT being fetched for spin-wheel type
final videoAds = await RewardedAdService.fetchVideoAds(
  usage: 'spin-wheel',
);
```

## Solution Applied

### File: `apps/lib/ad_selection_screen.dart`

**Before:**
```dart
} else if (widget.adType == 'spin-wheel') {
  // For spin wheel, fetch ONLY admin panel ads (type=spin-wheel)
  final adminAds = await RewardedAdService.fetchRewardedAds(
    type: 'spin-wheel',
  );
  ads = adminAds;  // ❌ ONLY REWARDED ADS, NO VIDEO ADS
}
```

**After:**
```dart
} else if (widget.adType == 'spin-wheel') {
  // For spin wheel, fetch BOTH rewarded ads AND video ads with spin-wheel type
  final rewardedAds = await RewardedAdService.fetchRewardedAds(
    type: 'spin-wheel',
  );
  final videoAds = await RewardedAdService.fetchVideoAds(
    usage: 'spin-wheel',
  );
  ads = [...rewardedAds, ...videoAds];  // ✅ BOTH TYPES
}
```

## How It Works Now

### Spin Wheel Watch Ads Flow
1. User runs out of spins
2. Clicks "Watch ads" button
3. Modal closes and navigates to `AdSelectionScreen(adType: 'spin-wheel')`
4. AdSelectionScreen fetches:
   - Rewarded ads with `type='spin-wheel'` from `/api/rewarded-ads?type=spin-wheel`
   - Video ads with `usage='spin-wheel'` from `/api/video-ads?usage=spin-wheel`
5. **Shows admin-uploaded ads directly** ✅
6. User watches an ad
7. Returns to Spin Wheel with spins refilled

### Watch Ads & Earn Flow (Unchanged)
1. User clicks "Watch Ads" in Wallet
2. Opens `AdSelectionScreen(adType='watch-ads')`
3. Fetches ONLY rewarded ads with `type='watch-ads'` (5 AdMob ads)
4. Shows success dialog after watching
5. Returns to Wallet with updated balance

## Backend Endpoints

### Rewarded Ads Endpoint
```
GET /api/rewarded-ads?type=spin-wheel
```
Returns ads with `adType: 'spin-wheel'`

### Video Ads Endpoint
```
GET /api/video-ads?usage=spin-wheel
```
Returns ads with `usage: 'spin-wheel'`

## Testing

### Test 1: Verify Spin Wheel Ads Load
1. Open Spin Wheel
2. Use daily spin
3. When out of spins, click "Watch ads"
4. **Should see admin-uploaded ads directly** ✅
5. No rewards screen should appear

### Test 2: Verify Ad Types
1. Check that ads shown are:
   - Rewarded ads with `adType='spin-wheel'`
   - Video ads with `usage='spin-wheel'`
2. Should NOT show:
   - Default ads
   - Watch ads (type='watch-ads')
   - AdMob ads

### Test 3: Verify Spins Refill
1. Watch an ad
2. Ad screen closes immediately
3. Return to Spin Wheel
4. Spins should be refilled

## Files Modified

1. **apps/lib/ad_selection_screen.dart**
   - Updated spin-wheel branch to fetch both rewarded and video ads
   - Now combines both types into single ads list

## Verification Checklist

- [ ] Spin Wheel shows admin ads when clicking "Watch ads"
- [ ] No rewards screen appears
- [ ] Both rewarded and video ads are shown
- [ ] Spins are refilled after watching ad
- [ ] Watch Ads & Earn still shows 5 AdMob ads
- [ ] No errors in console logs

## Summary

✅ Fixed Spin Wheel to fetch and display admin-uploaded ads directly
✅ Now shows both rewarded ads (type='spin-wheel') and video ads (usage='spin-wheel')
✅ No more rewards screen - goes directly to ad selection
✅ Spins refill correctly after watching ads
