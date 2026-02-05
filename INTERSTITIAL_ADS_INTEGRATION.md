# Interstitial Ads Integration - Reel Screen

## Overview
Interstitial ads have been successfully integrated into the Reel Screen using your AdMob ad unit IDs.

## AdMob Configuration

### Ad Unit IDs Used
- **AdMob App ID**: `ca-app-pub-3244693086681200~5375559724`
- **Android Interstitial Ad Unit ID**: `ca-app-pub-3244693086681200/8765150836`

### Implementation Details

#### 1. Ad Service Configuration (`apps/lib/services/ad_service.dart`)
The ad service has been updated with your production Android interstitial ad unit ID:

```dart
static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    // Production Android Interstitial Ad Unit ID
    return 'ca-app-pub-3244693086681200/8765150836';
  } else if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/4411468910'; // Test ID
  }
  throw UnsupportedError('Unsupported platform');
}
```

#### 2. Reel Screen Integration (`apps/lib/reel_screen.dart`)
The reel screen already has complete interstitial ad support:

**Key Features:**
- Ads load automatically when the reel screen initializes
- Ads are shown based on configurable frequency (default: every 6 reels)
- Ad frequency can be adjusted from the admin panel
- Ads are skipped for ad-free subscribers
- Ads can be globally disabled from admin settings
- Video pauses when ad is shown and resumes after dismissal
- Ad counter tracks reels viewed since last ad

**Ad Display Logic:**
```dart
// Show ad after every N reels (configurable)
if (_reelsSinceLastAd >= _adFrequency) {
  _showAdIfReady();
}
```

#### 3. Ad Loading Process
1. When reel screen loads, `_loadInterstitialAd()` is called
2. Ad is loaded asynchronously in the background
3. When user swipes to the next reel, counter increments
4. When counter reaches frequency threshold, ad is displayed
5. After ad dismissal, counter resets and new ad loads

#### 4. Admin Panel Control
Ads can be controlled from the admin panel:
- **Enable/Disable Ads**: Toggle ads on/off globally
- **Ad Frequency**: Set how many reels between ads (1-50)
- Settings are loaded on app startup

#### 5. Subscription Integration
- Ad-free subscribers never see ads
- Subscription status is checked on app startup
- Ad-free status is verified before showing ads

## How It Works in Reel Screen

### Initialization
```dart
@override
void initState() {
  super.initState();
  _checkSubscriptionStatus(); // Checks ad-free status
  _loadFeed(); // Loads reels
}

Future<void> _checkSubscriptionStatus() async {
  // Check if user is ad-free
  // Load ad settings from admin panel
  if (!_isAdFree) {
    _loadInterstitialAd(); // Start loading ad
  }
}
```

### On Page Change (Reel Swipe)
```dart
void _onPageChanged(int index) {
  // ... other logic ...
  
  if (!_isAdFree && _adsEnabled) {
    _reelsSinceLastAd++;
    if (_reelsSinceLastAd >= _adFrequency) {
      _showAdIfReady(); // Show ad
    }
  }
}
```

### Ad Display
```dart
void _showAdIfReady() {
  if (_interstitialAd != null) {
    _pauseCurrentVideo(); // Pause video
    AdService.showInterstitialAd(
      _interstitialAd,
      onAdDismissed: () {
        _reelsSinceLastAd = 0; // Reset counter
        _interstitialAd = null;
        _loadInterstitialAd(); // Load next ad
        _resumeCurrentVideo(); // Resume video
      },
    );
  }
}
```

## Testing

### Test Ads (Before Going Live)
To test with Google's test ads, temporarily use these test IDs:
- **Android Interstitial**: `ca-app-pub-3940256099942544/1033173712`

### Production Ads (Current)
Your production ad unit ID is now active:
- **Android Interstitial**: `ca-app-pub-3244693086681200/8765150836`

### Important Notes
1. **Ad Approval**: New ad units may take up to 1 hour to start serving ads
2. **Test Devices**: Add your device as a test device in AdMob to avoid invalid traffic
3. **Frequency**: Default is 6 reels between ads (configurable from admin panel)
4. **Ad-Free Users**: Ads are never shown to ad-free subscribers

## Admin Panel Settings

The following settings can be configured from the admin panel:

```json
{
  "ads": {
    "enabled": true,           // Enable/disable ads globally
    "adFrequency": 6           // Show ad after every N reels (1-50)
  }
}
```

## Debugging

### Console Logs
The implementation includes detailed logging:
- `✅ Interstitial ad loaded successfully` - Ad loaded
- `🎬 Showing interstitial ad` - Ad is being displayed
- `✅ Ad dismissed, resetting counter` - Ad closed, counter reset
- `📺 Reel X viewed. Reels since ad: Y / Z` - Reel counter status

### Common Issues

**Ads not showing:**
1. Check if user is ad-free (ads won't show)
2. Check if ads are enabled in admin panel
3. Check if ad unit ID is correct
4. Wait up to 1 hour for new ad units to activate
5. Check AdMob console for approval status

**Ads showing too frequently:**
- Adjust `_adFrequency` in admin panel (increase the number)

**Ads not loading:**
- Ensure internet connection is active
- Check AdMob console for errors
- Verify ad unit ID is correct

## Files Modified

1. **apps/lib/services/ad_service.dart**
   - Updated Android interstitial ad unit ID to production ID

2. **apps/lib/reel_screen.dart**
   - Already has complete interstitial ad implementation
   - No changes needed

## Next Steps

1. **Test on Device**: Build and test the app on an Android device
2. **Monitor AdMob**: Check AdMob console for impressions and revenue
3. **Adjust Frequency**: Fine-tune ad frequency based on user feedback
4. **iOS Setup**: Add iOS ad unit ID when ready (currently using test ID)
5. **Analytics**: Track ad performance and user engagement

## Support

For issues or questions:
- Check AdMob console for ad unit status
- Review console logs for error messages
- Verify ad unit IDs are correct
- Ensure app has internet permission in AndroidManifest.xml
