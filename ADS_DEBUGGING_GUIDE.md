# Ad Display Debugging Guide

## Issue: Ads Not Showing After 6 Reels

### Root Causes to Check

1. **Ad Settings Not Loading**
   - Admin panel settings not being fetched
   - API endpoint returning error
   - Settings not being applied to app state

2. **Ad Counter Logic**
   - Counter not incrementing properly
   - Counter not resetting after ad shown
   - Frequency threshold not being reached

3. **Ad Service Issues**
   - Interstitial ad not loading
   - Ad unit ID invalid or not configured
   - Ad network not responding

4. **User Status**
   - User marked as ad-free
   - Subscription status not loading correctly

## Console Log Debugging

### Expected Log Flow

When app starts:
```
✅ Ad settings loaded: enabled=true, frequency=6
⏳ Loading interstitial ad...
✅ Interstitial ad loaded successfully
```

When scrolling through reels:
```
📺 Reel 0 viewed. Reels since ad: 1 / 6
📺 Reel 1 viewed. Reels since ad: 2 / 6
📺 Reel 2 viewed. Reels since ad: 3 / 6
📺 Reel 3 viewed. Reels since ad: 4 / 6
📺 Reel 4 viewed. Reels since ad: 5 / 6
📺 Reel 5 viewed. Reels since ad: 6 / 6
🎬 Time to show ad! (6 >= 6)
🎬 Ad check: _reelsSinceLastAd=6, _adFrequency=6
   _adsEnabled=true, _isAdFree=false, _interstitialAd=<InterstitialAd object>
✅ Showing interstitial ad
```

After ad dismissed:
```
✅ Ad dismissed, resetting counter
✅ Interstitial ad loaded successfully
```

### Troubleshooting by Log

#### Issue: "Ad settings response not successful or no data"
**Cause**: API endpoint not returning correct format
**Solution**:
1. Check admin panel is running
2. Verify `/api/admin/settings` endpoint exists
3. Check user has admin token
4. Verify response format matches expected structure

#### Issue: "No ads object in response data"
**Cause**: Response doesn't have `ads` field
**Solution**:
1. Check `getSystemSettings()` in adminController.js
2. Verify it returns `{ success: true, data: { ads: { ... } } }`
3. Check admin panel saved settings correctly

#### Issue: "Ads disabled, skipping ad"
**Cause**: `_adsEnabled` is false
**Solution**:
1. Check admin panel "Enable Ads" toggle is ON
2. Click "Save Ad Settings"
3. Restart app to reload settings

#### Issue: "User is ad-free, skipping ad"
**Cause**: User has ad-free subscription
**Solution**:
1. Check user subscription status
2. Verify subscription doesn't have `adFree: true`
3. Test with non-ad-free user

#### Issue: "Ad not ready yet, loading..."
**Cause**: Interstitial ad still loading
**Solution**:
1. Wait longer before scrolling to 6th reel
2. Check ad unit ID is valid
3. Check internet connection
4. Check AdMob account has ads available

#### Issue: "Interstitial ad returned null"
**Cause**: Ad failed to load
**Solution**:
1. Check ad unit ID in ad_service.dart
2. Verify using test ad unit IDs (currently set)
3. Check AdMob account status
4. Check device has internet connection

## Step-by-Step Debugging

### Step 1: Verify Admin Settings
1. Open admin panel: `http://localhost:3000/admin/settings`
2. Find "Ad Settings" card
3. Check "Enable Ads" is toggled ON
4. Check "Ad Frequency" is set to 6
5. Click "Save Ad Settings"
6. Check browser console for success message

### Step 2: Verify API Endpoint
1. Open browser console (F12)
2. Go to Network tab
3. Restart app
4. Look for request to `/api/admin/settings`
5. Check response:
   ```json
   {
     "success": true,
     "data": {
       "ads": {
         "enabled": true,
         "adFrequency": 6,
         "interstitialEnabled": true,
         "rewardedEnabled": true,
         "bannerEnabled": true
       }
     }
   }
   ```

### Step 3: Check App Logs
1. Open Flutter console (or logcat for Android)
2. Look for "Ad settings loaded" message
3. Verify `enabled=true` and `frequency=6`
4. Check for any error messages

### Step 4: Test Ad Counter
1. Scroll through reels one by one
2. Watch console for counter incrementing
3. Should see: 1/6, 2/6, 3/6, 4/6, 5/6, 6/6
4. At 6/6, should see "Time to show ad!"

### Step 5: Test Ad Display
1. When counter reaches 6, ad should show
2. Check for "Showing interstitial ad" message
3. Ad should appear on screen
4. Dismiss ad
5. Check for "Ad dismissed, resetting counter"
6. Counter should reset to 0

## Common Issues and Solutions

### Issue: Counter Not Incrementing
**Symptoms**: Logs show counter stuck at 1 or 2
**Cause**: `_onPageChanged` not being called properly
**Solution**:
1. Check PageView is properly configured
2. Verify `onPageChanged: _onPageChanged` is set
3. Check for errors in _onPageChanged method

### Issue: Counter Incrementing Too Fast
**Symptoms**: Counter jumps from 1 to 6+ immediately
**Cause**: Multiple page changes triggering counter
**Solution**:
1. Add debounce to counter increment
2. Only increment on actual page change, not on initialization
3. Check for duplicate _onPageChanged calls

### Issue: Ad Shows But Doesn't Dismiss
**Symptoms**: Ad appears but won't close
**Cause**: Ad callback not working
**Solution**:
1. Check AdService.showInterstitialAd implementation
2. Verify fullScreenContentCallback is set
3. Check onAdDismissedFullScreenContent is called

### Issue: Ad Shows Every Reel
**Symptoms**: Ad shows after every reel, not every 6
**Cause**: Counter not resetting after ad
**Solution**:
1. Check `_reelsSinceLastAd = 0` is called in onAdDismissed
2. Verify counter is being reset properly
3. Check for race conditions

## Testing Checklist

- [ ] Admin panel loads without errors
- [ ] Ad Settings card is visible
- [ ] "Enable Ads" toggle works
- [ ] "Ad Frequency" input accepts values 1-50
- [ ] "Save Ad Settings" button works
- [ ] Settings persist after page refresh
- [ ] App fetches settings on startup
- [ ] Console shows "Ad settings loaded"
- [ ] Console shows correct frequency value
- [ ] Interstitial ad loads successfully
- [ ] Counter increments as reels scroll
- [ ] Ad shows at correct frequency
- [ ] Ad can be dismissed
- [ ] Counter resets after ad
- [ ] Ads don't show for ad-free users
- [ ] Ads don't show when disabled

## Advanced Debugging

### Enable Verbose Logging
Add to reel_screen.dart initState:
```dart
debugPrintBeginFrame = true;
debugPrintEndFrame = true;
```

### Check Ad Unit ID
In ad_service.dart:
```dart
// Android test ID (currently set)
'ca-app-pub-3940256099942544/1033173712'

// To use production ID, replace with your actual ID
// Format: ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx
```

### Monitor Memory Usage
- Check if ad loading causes memory leaks
- Monitor with Android Studio Profiler
- Check for unreleased ad objects

### Test with Different Frequencies
1. Change frequency to 2 in admin panel
2. Scroll 2 reels, ad should show
3. Change to 3, scroll 3 reels, ad should show
4. Verify counter resets each time

## Performance Considerations

- Ad loading should not block UI
- Ad should load in background
- Counter increment should be instant
- Ad display should be smooth

## Next Steps

1. Check console logs for errors
2. Verify admin settings are saved
3. Test counter incrementing
4. Test ad display
5. Adjust frequency if needed
6. Monitor ad performance

## Support

If ads still don't show:
1. Check all console logs
2. Verify admin panel settings
3. Check API endpoint response
4. Verify ad unit IDs
5. Test with test ad IDs
6. Check internet connection
7. Restart app and try again
