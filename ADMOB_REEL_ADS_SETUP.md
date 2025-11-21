# AdMob Reel Ads Setup Guide

## Overview
Google AdMob interstitial ads are now integrated into the reel screen. Ads will automatically show every 4 reels as users scroll through content.

## Features
- ✅ Interstitial ads show every 4 reels
- ✅ Video pauses when ad is shown
- ✅ Video resumes after ad is dismissed
- ✅ Ads preload in the background
- ✅ Automatic ad reload after each display

## Configuration

### 1. Get Your AdMob Ad Unit IDs

1. Go to [AdMob Console](https://apps.admob.com/)
2. Select your app
3. Go to "Ad units" section
4. Create a new "Interstitial" ad unit
5. Copy the Ad Unit ID

### 2. Replace Test IDs with Real IDs

Edit `apps/lib/services/ad_service.dart`:

```dart
static String get interstitialAdUnitId {
  if (Platform.isAndroid) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your Android Ad Unit ID
  } else if (Platform.isIOS) {
    return 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your iOS Ad Unit ID
  }
  throw UnsupportedError('Unsupported platform');
}
```

### 3. Adjust Ad Frequency (Optional)

In `apps/lib/reel_screen.dart`, find this line:

```dart
final int _adFrequency = 4; // Show ad every 4 reels
```

Change the number to show ads more or less frequently:
- `3` = Show ad every 3 reels (more frequent)
- `5` = Show ad every 5 reels (less frequent)
- `10` = Show ad every 10 reels (much less frequent)

## Testing

### Test Mode
The app currently uses Google's test ad unit IDs. These will show test ads that you can click without affecting your AdMob account.

### Production Mode
Once you replace the test IDs with your real Ad Unit IDs:
1. Build a release version of the app
2. Test on a real device (not emulator)
3. Wait 24-48 hours for ads to start showing consistently

## How It Works

1. **Ad Loading**: An interstitial ad loads when the app starts
2. **Counter**: Every time user swipes to a new reel, a counter increments
3. **Ad Display**: When counter reaches 4, the ad shows
4. **Video Pause**: Current video pauses automatically
5. **Ad Dismissal**: After user closes the ad, video resumes
6. **Reload**: A new ad loads in the background for the next cycle

## Troubleshooting

### Ads Not Showing
- Make sure you're using real Ad Unit IDs (not test IDs)
- Check your AdMob account is approved and active
- Verify your app is published or in testing mode in AdMob
- Wait 24-48 hours after first setup

### Ads Showing Too Often
- Increase the `_adFrequency` value in `reel_screen.dart`

### Ads Showing Too Rarely
- Decrease the `_adFrequency` value in `reel_screen.dart`

### Video Not Resuming After Ad
- Check console logs for errors
- Ensure video controller is not disposed

## Revenue Optimization Tips

1. **Frequency**: 4-5 reels is optimal (not too annoying, good revenue)
2. **User Experience**: Don't show ads too frequently or users will leave
3. **Testing**: A/B test different frequencies to find the sweet spot
4. **Timing**: Ads show between reels, not during video playback

## Support

For AdMob-specific issues, refer to:
- [AdMob Help Center](https://support.google.com/admob)
- [Flutter Google Mobile Ads Plugin](https://pub.dev/packages/google_mobile_ads)
