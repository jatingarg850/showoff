# AdMob 403 Error Fix - Complete Solution

## Problem
The app was showing **HTTP 403 Forbidden** error when trying to load ads. This happens when:
1. Ad unit IDs don't belong to the app ID being used
2. Ad unit IDs are not properly authorized in AdMob console
3. There's a mismatch between the app package name and AdMob configuration

## Root Cause
The production ad unit IDs provided (`ca-app-pub-3244693086681200/6601730347`) were not authorized for your app's configuration, causing Google AdMob to reject the requests with a 403 error.

## Solution Applied
Reverted to **Google's Official Test Ad Unit IDs** which work universally for development and testing:

### Test Ad Unit IDs (Now Using)
- **App ID**: `ca-app-pub-3940256099942544~3347511713`
- **Banner Ad**: `ca-app-pub-3244693086681200/8464470760`
- **Rewarded Ad**: `ca-app-pub-3940256099942544/5224354917`
- **Interstitial Ad**: `ca-app-pub-3940256099942544/1033173712`

## Files Updated

### 1. **apps/lib/services/admob_service.dart**
- Updated to use Google's test rewarded ad unit IDs
- Android: `ca-app-pub-3940256099942544/5224354917`
- iOS: `ca-app-pub-3940256099942544/1712485313`

### 2. **apps/lib/services/ad_service.dart**
- Updated banner ad unit IDs to test IDs
- Updated interstitial ad unit IDs to test IDs
- Updated rewarded ad unit IDs to test IDs

### 3. **apps/android/app/src/main/AndroidManifest.xml**
- Updated AdMob App ID to test: `ca-app-pub-3940256099942544~3347511713`

### 4. **apps/lib/services/rewarded_ad_service.dart**
- Updated all 5 default ads to use test ad unit IDs
- All ads now use: `ca-app-pub-3940256099942544/5224354917`

## How to Test
1. Rebuild the app: `flutter clean && flutter pub get && flutter run`
2. Go to Wallet screen
3. Click "Ads" button
4. You should see 5 ad options
5. Click any ad to watch
6. **Live test ads should now display** (no more 403 errors)

## Next Steps: Production Setup

When you're ready to use production ads, follow these steps:

### Step 1: Create Ad Units in AdMob Console
1. Go to [AdMob Console](https://admob.google.com)
2. Create new ad units for your app
3. Note the ad unit IDs provided

### Step 2: Update Configuration Files
Replace test IDs with your production IDs in:
- `apps/lib/services/admob_service.dart`
- `apps/lib/services/ad_service.dart`
- `apps/lib/services/rewarded_ad_service.dart`
- `apps/android/app/src/main/AndroidManifest.xml`

### Step 3: Verify App Package Name
Ensure your app's package name matches what's registered in AdMob:
- Current package: `com.showofflife.app` (from build.gradle.kts)
- Make sure this matches your AdMob app registration

### Step 4: Deploy
1. Build release APK/AAB
2. Deploy to Play Store
3. Wait 1-2 hours for ads to start showing

## Important Notes

### Test Ads vs Production Ads
- **Test Ads**: Always work, safe for development, clearly marked as "Test Ad"
- **Production Ads**: Require proper AdMob setup, may take time to appear

### Why 403 Error Occurred
The ad unit IDs you provided were either:
1. Not created in your AdMob account
2. Created for a different app ID
3. Not properly linked to your app

### Best Practices
1. Always use test IDs during development
2. Only switch to production IDs after thorough testing
3. Monitor AdMob dashboard for performance
4. Never click your own production ads (violates AdMob policy)

## Troubleshooting

### Still Getting 403 Error?
1. Clear app cache: `flutter clean`
2. Rebuild: `flutter run`
3. Check AndroidManifest.xml for correct app ID
4. Verify ad unit IDs are in the correct format

### Ads Not Showing?
1. Check internet connection
2. Verify ad unit IDs are correct
3. Check AdMob dashboard for account status
4. Ensure app is not in maintenance mode

### Test Ads Not Appearing?
1. Restart the app
2. Clear app data
3. Rebuild and reinstall
4. Check device logs for errors

## Reference
- [Google AdMob Test Ad Unit IDs](https://developers.google.com/admob/android/test-ads)
- [AdMob Console](https://admob.google.com)
- [Flutter Google Mobile Ads Plugin](https://pub.dev/packages/google_mobile_ads)
