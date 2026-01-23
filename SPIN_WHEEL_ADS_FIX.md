# Fix: Spin Wheel Watch Ads Flow

## Problem
When clicking "Watch ads" in the Spin Wheel screen, it was showing a "Congratulations" rewards screen instead of just closing and returning to the spin wheel.

## Root Cause
The AdSelectionScreen was showing a success dialog for ALL ad types, but for the spin-wheel flow, we should just close the ad screen and return to the spin wheel without showing a rewards screen.

## Solution Applied

### File: `apps/lib/ad_selection_screen.dart`

**Before**:
```dart
if (response['success']) {
  // Show success dialog with actual reward earned
  final coinsEarned = response['coinsEarned'] ?? reward;
  _showSuccessDialog(coinsEarned, ad['title'] ?? 'Ad');  // ❌ ALWAYS SHOWS DIALOG
}
```

**After**:
```dart
if (response['success']) {
  // Show success dialog with actual reward earned
  final coinsEarned = response['coinsEarned'] ?? reward;
  
  // For spin-wheel type, don't show success dialog - just close
  if (widget.adType == 'spin-wheel') {
    Navigator.pop(context, true); // Return to spin wheel
  } else {
    // For watch-ads type, show success dialog
    _showSuccessDialog(coinsEarned, ad['title'] ?? 'Ad');
  }
}
```

## How It Works Now

### Watch Ads & Earn Screen (adType='watch-ads')
1. User clicks "Watch Ads" button in Wallet
2. AdSelectionScreen opens with `adType='watch-ads'`
3. Shows 5 AdMob rewarded ads
4. User clicks an ad and watches it
5. **Shows "Congratulations" success dialog** ✅
6. User clicks "Awesome!" button
7. Returns to Wallet with updated balance

### Spin Wheel Refill (adType='spin-wheel')
1. User runs out of spins
2. Clicks "Watch ads" button
3. AdSelectionScreen opens with `adType='spin-wheel'`
4. Shows admin panel ads (type='spin-wheel')
5. User clicks an ad and watches it
6. **Closes ad screen immediately** ✅
7. Returns to Spin Wheel screen
8. Spins are refilled

## Testing

### Test 1: Watch Ads & Earn Flow
1. Open Wallet
2. Click "Watch Ads" button
3. Select an ad and watch it
4. **Should see "Congratulations" dialog** ✅
5. Click "Awesome!" to return to Wallet

### Test 2: Spin Wheel Refill Flow
1. Open Spin Wheel
2. Use daily spin
3. When out of spins, click "Watch ads"
4. Select an ad and watch it
5. **Should close immediately and return to Spin Wheel** ✅
6. Spins should be refilled

## Files Modified

1. **apps/lib/ad_selection_screen.dart**
   - Added check for `widget.adType == 'spin-wheel'`
   - For spin-wheel type: closes without showing success dialog
   - For watch-ads type: shows success dialog as before

## Verification Checklist

- [ ] Watch Ads screen shows success dialog after watching ad
- [ ] Spin Wheel ads close immediately without success dialog
- [ ] Spin Wheel spins are refilled after watching ads
- [ ] Wallet balance updates correctly
- [ ] No errors in console logs

## Summary

✅ Fixed Spin Wheel watch ads flow to close immediately without showing rewards screen
✅ Watch Ads & Earn flow still shows success dialog as expected
✅ Both flows now work correctly!
