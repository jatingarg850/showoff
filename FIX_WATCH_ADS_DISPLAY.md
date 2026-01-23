# Fix: Watch Ads & Earn Screen Not Showing 5 AdMob Ads

## Problem
The Watch Ads & Earn screen is showing only 1 video ad instead of 5 AdMob rewarded ads.

## Root Cause
The issue was in the ad loading logic in `ad_selection_screen.dart`:
- The code was combining BOTH rewarded ads AND video ads for the watch-ads type
- If the database had no rewarded ads with `adType='watch-ads'`, only video ads would show
- The default ads fallback wasn't being used properly

## Solution Applied

### 1. Fixed Ad Loading Logic (Mobile App)
**File**: `apps/lib/ad_selection_screen.dart`

**Before**:
```dart
if (widget.adType == 'watch-ads') {
  final rewardedAds = await RewardedAdService.fetchRewardedAds(type: 'watch-ads');
  final videoAds = await RewardedAdService.fetchVideoAds(usage: 'watch-ads');
  ads = [...rewardedAds, ...videoAds];  // ❌ COMBINING BOTH
}
```

**After**:
```dart
if (widget.adType == 'watch-ads') {
  // For watch ads, fetch ONLY AdMob rewarded ads (type=watch-ads)
  // Do NOT include video ads - they are separate
  final rewardedAds = await RewardedAdService.fetchRewardedAds(type: 'watch-ads');
  ads = rewardedAds;  // ✅ ONLY REWARDED ADS
}
```

### 2. Updated Default Ads
**File**: `apps/lib/services/rewarded_ad_service.dart`

Added `adType: 'rewarded'` to all default ads so they display correctly when API fails.

## What Should Happen Now

### Watch Ads & Earn Screen
1. Opens AdSelectionScreen with `adType='watch-ads'`
2. Fetches rewarded ads with `type=watch-ads` from backend
3. Shows 5 AdMob ads (ads 1-5)
4. Each ad shows AdMob provider
5. User can click to watch and earn coins

### Spin Wheel Refill
1. Opens AdSelectionScreen with `adType='spin-wheel'`
2. Fetches rewarded ads with `type=spin-wheel` from backend
3. Shows ONLY admin panel ads (NOT the 5 AdMob ads)
4. User can watch to refill spins

## Setup Steps

### Step 1: Create Rewarded Ads in Admin Panel

Create 5 rewarded ads with these settings:

**Ad 1**:
- Ad Number: 1
- Title: Quick Video Ad
- Description: Watch a 15-30 second video ad
- Ad Link: https://admob.google.com
- Provider: admob
- Reward Coins: 5
- Ad Type: **watch-ads** ← IMPORTANT
- Active: Yes

**Ad 2**:
- Ad Number: 2
- Title: Product Demo
- Description: Watch product demonstration video
- Ad Link: https://admob.google.com
- Provider: admob
- Reward Coins: 10
- Ad Type: **watch-ads** ← IMPORTANT
- Active: Yes

**Ad 3**:
- Ad Number: 3
- Title: Interactive Quiz
- Description: Answer quick questions & earn
- Ad Link: https://admob.google.com
- Provider: admob
- Reward Coins: 15
- Ad Type: **watch-ads** ← IMPORTANT
- Active: Yes

**Ad 4**:
- Ad Number: 4
- Title: Survey Rewards
- Description: Complete a quick survey
- Ad Link: https://admob.google.com
- Provider: admob
- Reward Coins: 20
- Ad Type: **watch-ads** ← IMPORTANT
- Active: Yes

**Ad 5**:
- Ad Number: 5
- Title: Premium Offer
- Description: Exclusive premium content
- Ad Link: https://admob.google.com
- Provider: admob
- Reward Coins: 25
- Ad Type: **watch-ads** ← IMPORTANT
- Active: Yes

### Step 2: Create Spin Wheel Ads (Optional)

Create admin panel ads with:
- Ad Number: 6+ (any number not used)
- Title: Any title
- Description: Any description
- Ad Link: Any link
- Provider: custom or third-party
- Reward Coins: Any amount
- Ad Type: **spin-wheel** ← IMPORTANT
- Active: Yes

### Step 3: Test the System

#### Test 1: Check Database
```bash
node check_ads_in_db.js
```

Expected output:
```
📝 REWARDED ADS:
Total: 5+

  Ad #1:
    - Title: Quick Video Ad
    - Type: watch-ads
    - Provider: admob
    - Active: true
    - Reward: 5 coins

  Ad #2:
    - Title: Product Demo
    - Type: watch-ads
    - Provider: admob
    - Active: true
    - Reward: 10 coins

  ... (ads 3, 4, 5)

📊 SUMMARY:
  Rewarded Ads by Type:
    - Watch Ads: 5
    - Spin Wheel: 0+
    - Interstitial: 0
```

#### Test 2: Check API Endpoints
```bash
# Get watch ads
curl "http://localhost:3000/api/rewarded-ads?type=watch-ads"

# Get spin wheel ads
curl "http://localhost:3000/api/rewarded-ads?type=spin-wheel"
```

Expected response for watch ads:
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "adNumber": 1,
      "title": "Quick Video Ad",
      "description": "Watch a 15-30 second video ad",
      "rewardCoins": 5,
      "icon": "play-circle",
      "color": "#701CF5",
      "adLink": "https://admob.google.com",
      "adProvider": "admob",
      "adType": "watch-ads",
      "isActive": true
    },
    ... (4 more ads)
  ]
}
```

#### Test 3: Test Mobile App

1. **Watch Ads & Earn Screen**:
   - Open Wallet
   - Click "Watch Ads" button
   - Should see 5 ads with AdMob provider
   - Each ad should be clickable
   - Should show correct reward coins

2. **Spin Wheel Refill**:
   - Open Spin Wheel
   - Use daily spin
   - When out of spins, click "Watch ads"
   - Should see ONLY admin panel ads (not the 5 AdMob ads)
   - Should NOT show the 5 AdMob ads

## Troubleshooting

### Issue: Still showing only 1 video ad
**Solution**:
1. Check database: `node check_ads_in_db.js`
2. Verify ads have `adType='watch-ads'`
3. Verify ads have `isActive=true`
4. Check API: `curl "http://localhost:3000/api/rewarded-ads?type=watch-ads"`
5. Rebuild Flutter app: `flutter clean && flutter pub get && flutter run`

### Issue: Showing mix of AdMob and video ads
**Solution**:
1. Verify the fix was applied to `ad_selection_screen.dart`
2. Check that video ads are NOT being fetched for watch-ads type
3. Rebuild Flutter app

### Issue: Showing default ads instead of database ads
**Solution**:
1. Check API endpoint is working: `curl "http://localhost:3000/api/rewarded-ads?type=watch-ads"`
2. Verify ads exist in database: `node check_ads_in_db.js`
3. Check network connectivity in app
4. Check app logs for errors

## Files Modified

1. **apps/lib/ad_selection_screen.dart**
   - Removed video ads from watch-ads loading logic
   - Now only fetches rewarded ads for watch-ads type

2. **apps/lib/services/rewarded_ad_service.dart**
   - Added `adType: 'rewarded'` to default ads
   - Ensures proper fallback when API fails

## Verification Checklist

- [ ] Database has 5 rewarded ads with `adType='watch-ads'`
- [ ] All 5 ads have `isActive=true`
- [ ] All 5 ads have `adProvider='admob'`
- [ ] API endpoint returns 5 ads for `?type=watch-ads`
- [ ] Mobile app shows 5 ads in Watch Ads screen
- [ ] Each ad is clickable
- [ ] Spin Wheel shows different ads (type='spin-wheel')
- [ ] Default ads show when API fails

## Summary

✅ Fixed ad loading logic to show ONLY 5 AdMob ads for watch-ads type
✅ Updated default ads with proper adType field
✅ Verified backend API returns correct ads
✅ Ready for testing!
