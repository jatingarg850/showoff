# Spin Wheel Video Ads - Coins Fix Complete

## Problem
When users watched video ads on the Spin Wheel screen, they were receiving **BOTH coins AND spin refills**. The desired behavior is to give them **ONLY spin refills** (no coins). Additionally, the UI was showing "+10" coins badge instead of indicating a free spin.

## Root Cause
1. Backend was awarding coins to all users regardless of the video ad's `usage` type
2. Mobile app was displaying the `rewardCoins` value in the badge for all ad types

## Solution Implemented

### 1. Backend Fix - `server/controllers/videoAdController.js`
Modified the `trackVideoAdCompletion()` method to check the video ad's `usage` field:

**Logic:**
- If `usage === 'spin-wheel'`: Skip coin awarding, return success with `spinRefill: true`
- If `usage === 'watch-ads'`: Award coins as normal (existing behavior)

**Changes:**
```javascript
// Check if this is a spin-wheel video ad
// If so, don't award coins - the mobile app will handle spin refill
if (videoAd.usage === 'spin-wheel') {
  videoAd.conversions += 1;
  await videoAd.save();
  
  return res.status(200).json({
    success: true,
    message: 'Video ad completed - spin refill handled by app',
    coinsEarned: 0,
    newBalance: 0,
    spinRefill: true
  });
}

// For watch-ads usage, award coins to user
// ... existing coin awarding logic ...
```

### 2. Mobile App Fix - `apps/lib/ad_selection_screen.dart`

#### Fix 2a: Response Handling in `_watchAd()` method
Updated to handle spin-wheel type properly:

**Logic:**
- For `adType === 'spin-wheel'`: Close immediately without showing success dialog
- For `adType === 'watch-ads'`: Show success dialog with coins earned

```dart
if (response['success']) {
  // For spin-wheel type, don't show success dialog - just close
  // The spin refill is handled by the parent screen
  if (widget.adType == 'spin-wheel') {
    Navigator.pop(context, true); // Return to spin wheel
  } else {
    // For watch-ads type, show success dialog with coins earned
    final coinsEarned = response['coinsEarned'] ?? reward;
    _showSuccessDialog(coinsEarned, ad['title'] ?? 'Ad');
  }
}
```

#### Fix 2b: UI Badge in `_buildAdCard()` method
Updated the reward badge to show different content based on ad type:

**Logic:**
- For `adType === 'watch-ads'`: Show "+10" coins badge (yellow)
- For `adType === 'spin-wheel'`: Show "Free Spin" badge (purple with casino icon)

```dart
// Reward badge - only show for watch-ads, not for spin-wheel
if (widget.adType != 'spin-wheel')
  Container(
    // Yellow badge with coins icon and "+10"
    ...
  )
else
  // For spin-wheel, show spin icon instead
  Container(
    // Purple badge with casino icon and "Free Spin"
    ...
  ),
```

## Flow After Fix

### Spin Wheel Video Ad Flow:
1. User clicks "Watch ads" on Spin Wheel screen
2. AdSelectionScreen opens with `adType='spin-wheel'`
3. Video ad shows "Free Spin" badge (not "+10")
4. User selects and watches a video ad with `usage='spin-wheel'`
5. Backend tracks completion WITHOUT awarding coins
6. Mobile app receives success response
7. AdSelectionScreen closes immediately (no success dialog)
8. Spin Wheel screen refills spins: `_spinsLeft = 5`
9. **Result: User gets ONLY spins (no coins), UI shows "Free Spin"**

### Watch Ads Video Ad Flow:
1. User navigates to Watch Ads & Earn screen
2. AdSelectionScreen opens with `adType='watch-ads'`
3. Video ad shows "+10" coins badge (yellow)
4. User selects and watches a video ad with `usage='watch-ads'`
5. Backend tracks completion AND awards coins
6. Mobile app receives success response with `coinsEarned`
7. AdSelectionScreen shows success dialog with coins earned
8. **Result: User gets coins, UI shows "+10" badge**

## Files Modified
- `server/controllers/videoAdController.js` - Updated `trackVideoAdCompletion()` method
- `apps/lib/ad_selection_screen.dart` - Updated `_watchAd()` and `_buildAdCard()` methods

## Testing Checklist
- [ ] Watch video ad on Spin Wheel → Verify "Free Spin" badge shows (not "+10")
- [ ] Watch video ad on Spin Wheel → Verify spins refill to 5
- [ ] Check user's coin balance → Should NOT increase
- [ ] Watch video ad on Watch Ads screen → Verify "+10" coins badge shows
- [ ] Watch video ad on Watch Ads screen → Verify coins awarded
- [ ] Check user's coin balance → Should increase by video ad reward amount
- [ ] Verify success dialog shows for watch-ads but not for spin-wheel

## Notes
- The `usage` field on VideoAd model already supports 'watch-ads' and 'spin-wheel' values
- The mobile app already had the spin refill logic in place
- This fix ensures the backend respects the video ad's intended usage type
- UI now clearly indicates the reward type (coins vs. free spin)
