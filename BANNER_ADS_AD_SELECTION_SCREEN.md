# Banner Ads Integration - Ad Selection Screen

## Overview
Banner ads have been successfully integrated into the "Watch Ads & Earn" screen (Ad Selection Screen) using your AdMob banner ad unit ID.

## AdMob Configuration

### Ad Unit IDs Used
- **AdMob App ID**: `ca-app-pub-3244693086681200~5375559724`
- **Android Banner Ad Unit ID**: `ca-app-pub-3244693086681200/6601730347`

## Implementation Details

### 1. Ad Service Configuration (`apps/lib/services/ad_service.dart`)

Added banner ad unit ID and loading method:

```dart
static String get bannerAdUnitId {
  if (Platform.isAndroid) {
    // Production Android Banner Ad Unit ID
    return 'ca-app-pub-3244693086681200/6601730347';
  } else if (Platform.isIOS) {
    return 'ca-app-pub-3940256099942544/6300978111'; // Test ID
  }
  throw UnsupportedError('Unsupported platform');
}

// Load a banner ad
static Future<BannerAd?> loadBannerAd() async {
  // Check if user is ad-free
  final shouldShow = await shouldShowAds();
  if (!shouldShow) {
    debugPrint('⏭️ Skipping banner ad load - user has ad-free subscription');
    return null;
  }

  final completer = Completer<BannerAd?>();

  final bannerAd = BannerAd(
    adUnitId: bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: BannerAdListener(
      onAdLoaded: (ad) {
        debugPrint('✅ Banner ad loaded successfully');
        if (!completer.isCompleted) {
          completer.complete(ad as BannerAd);
        }
      },
      onAdFailedToLoad: (ad, error) {
        debugPrint('❌ Banner ad failed to load: $error');
        ad.dispose();
        if (!completer.isCompleted) {
          completer.complete(null);
        }
      },
    ),
  );

  bannerAd.load();

  // Wait for the ad to load with a timeout
  return completer.future.timeout(
    const Duration(seconds: 10),
    onTimeout: () {
      debugPrint('⏱️ Banner ad load timeout after 10 seconds');
      return null;
    },
  );
}
```

### 2. Ad Selection Screen Integration (`apps/lib/ad_selection_screen.dart`)

#### State Variables Added
```dart
BannerAd? _bannerAd;
bool _bannerAdLoaded = false;
```

#### Initialization
```dart
@override
void initState() {
  super.initState();
  _loadAds();
  _preloadAllAds();
  _loadBannerAd(); // Load banner ad
}
```

#### Banner Ad Loading Method
```dart
Future<void> _loadBannerAd() async {
  try {
    debugPrint('⏳ Loading banner ad...');
    final bannerAd = await AdService.loadBannerAd();
    if (bannerAd != null && mounted) {
      setState(() {
        _bannerAd = bannerAd;
        _bannerAdLoaded = true;
      });
      debugPrint('✅ Banner ad loaded and ready to display');
    } else {
      debugPrint('⚠️ Banner ad returned null');
    }
  } catch (e) {
    debugPrint('❌ Error loading banner ad: $e');
  }
}
```

#### Cleanup
```dart
@override
void dispose() {
  _videoController?.dispose();
  _bannerAd?.dispose(); // Dispose banner ad
  super.dispose();
}
```

#### UI Integration
The banner ad is displayed at the bottom of the screen using a Stack layout:

```dart
Stack(
  children: [
    SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        // ... ad list content ...
        // Add bottom padding for banner ad
        const SizedBox(height: 80),
      ),
    ),
    // Banner ad at bottom
    if (_bannerAdLoaded && _bannerAd != null)
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          color: Colors.white,
          child: SizedBox(
            width: _bannerAd!.size.width.toDouble(),
            height: _bannerAd!.size.height.toDouble(),
            child: AdWidget(ad: _bannerAd!),
          ),
        ),
      ),
  ],
)
```

## How It Works

### Loading Process
1. When ad selection screen loads, `_loadBannerAd()` is called
2. Banner ad is loaded asynchronously in the background
3. Once loaded, it's displayed at the bottom of the screen
4. Ad-free subscribers never see the banner ad

### Display
- Banner ad appears at the bottom of the screen
- Content scrolls above the banner ad
- Bottom padding (80px) ensures content doesn't overlap with ad
- Ad is automatically disposed when screen is closed

### Ad-Free Support
- Banner ads are skipped for ad-free subscribers
- Subscription status is checked before loading
- No banner ad is shown if user has ad-free subscription

## Features

✅ **Automatic Loading**: Banner ad loads automatically when screen opens
✅ **Ad-Free Support**: Respects ad-free subscriptions
✅ **Proper Cleanup**: Ad is disposed when screen closes
✅ **Error Handling**: Gracefully handles ad load failures
✅ **Timeout Protection**: 10-second timeout for ad loading
✅ **Responsive Layout**: Content scrolls above banner ad
✅ **Console Logging**: Detailed debug logs for troubleshooting

## Testing

### Test Ads (Before Going Live)
To test with Google's test ads, temporarily use these test IDs:
- **Android Banner**: `ca-app-pub-3940256099942544/6300978111`

### Production Ads (Current)
Your production ad unit ID is now active:
- **Android Banner**: `ca-app-pub-3244693086681200/6601730347`

### Important Notes
1. **Ad Approval**: New ad units may take up to 1 hour to start serving ads
2. **Test Devices**: Add your device as a test device in AdMob to avoid invalid traffic
3. **Ad-Free Users**: Banner ads are never shown to ad-free subscribers
4. **Size**: Standard banner ad size is 320x50 pixels

## Debugging

### Console Logs
- `⏳ Loading banner ad...` - Banner ad loading started
- `✅ Banner ad loaded and ready to display` - Banner ad ready
- `⚠️ Banner ad returned null` - Ad failed to load
- `❌ Error loading banner ad: $e` - Error occurred

### Common Issues

**Banner ad not showing:**
1. Check if user is ad-free (ads won't show)
2. Check if ad unit ID is correct
3. Wait up to 1 hour for new ad units to activate
4. Check AdMob console for approval status
5. Verify internet connection is active

**Banner ad overlapping content:**
- Bottom padding of 80px is already added to prevent overlap
- Adjust padding if needed based on actual ad size

**Ad loading timeout:**
- Check internet connection
- Verify ad unit ID is correct
- Check AdMob console for errors

## Files Modified

1. **apps/lib/services/ad_service.dart**
   - Added `bannerAdUnitId` property
   - Added `loadBannerAd()` method

2. **apps/lib/ad_selection_screen.dart**
   - Added `_bannerAd` and `_bannerAdLoaded` state variables
   - Added `_loadBannerAd()` method
   - Updated `initState()` to load banner ad
   - Updated `dispose()` to clean up banner ad
   - Updated `build()` to display banner ad at bottom
   - Added `google_mobile_ads` import

## Next Steps

1. **Test on Device**: Build and test the app on an Android device
2. **Monitor AdMob**: Check AdMob console for impressions and revenue
3. **iOS Setup**: Add iOS banner ad unit ID when ready (currently using test ID)
4. **Analytics**: Track ad performance and user engagement
5. **Optimization**: Monitor CTR and adjust placement if needed

## Support

For issues or questions:
- Check AdMob console for ad unit status
- Review console logs for error messages
- Verify ad unit IDs are correct
- Ensure app has internet permission in AndroidManifest.xml
- Check that google_mobile_ads package is properly configured
