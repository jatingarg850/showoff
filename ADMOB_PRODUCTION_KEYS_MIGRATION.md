# AdMob Production Keys Migration - Complete

## Summary
Successfully migrated all AdMob test keys to production keys across the entire application.

## Production Keys Used
- **App ID**: `ca-app-pub-3244693086681200~5375559724`
- **Ad Unit ID (Banner/Rewarded)**: `ca-app-pub-3244693086681200/6601730347`
- **Ad Unit ID (Interstitial)**: `ca-app-pub-3244693086681200/8765150836`

## Files Updated

### 1. **apps/lib/services/admob_service.dart**
- Updated `_androidTestAdUnitId` from test ID to production: `ca-app-pub-3244693086681200/6601730347`
- Updated `_iosTestAdUnitId` from test ID to production: `ca-app-pub-3244693086681200/6601730347`
- Changed comment from "Test Ad Unit IDs" to "Production Ad Unit IDs"

### 2. **apps/lib/services/ad_service.dart**
- Updated `interstitialAdUnitId` (Android & iOS): `ca-app-pub-3244693086681200/8765150836`
- Updated `bannerAdUnitId` (Android & iOS): `ca-app-pub-3244693086681200/6601730347`
- Updated `rewardedAdUnitId` (Android & iOS): `ca-app-pub-3244693086681200/6601730347`
- Changed comments from "Test ID" to "Production"

### 3. **apps/android/app/src/main/AndroidManifest.xml**
- Updated AdMob App ID meta-data from test: `ca-app-pub-3940256099942544~3347511713`
- To production: `ca-app-pub-3244693086681200~5375559724`
- Changed comment from "Test ID for development" to "Production"

### 4. **server/.env**
- Added new AdMob configuration variables:
  ```
  ADMOB_APP_ID=ca-app-pub-3244693086681200~5375559724
  ADMOB_BANNER_AD_UNIT_ID=ca-app-pub-3244693086681200/6601730347
  ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-3244693086681200/6601730347
  ADMOB_INTERSTITIAL_AD_UNIT_ID=ca-app-pub-3244693086681200/8765150836
  ```

### 5. **apps/lib/services/rewarded_ad_service.dart**
- Updated all 5 default ads to use production AdMob configuration
- Each ad now includes `providerConfig` with production ad unit IDs
- Changed all ads from mixed providers (admob, meta, custom, third-party) to all use `admob` provider
- All ads now use production ad unit: `ca-app-pub-3244693086681200/6601730347`

### 6. **server/scripts/seed-rewarded-ads.js**
- Updated seed data for rewarded ads 1 and 2
- Changed ad unit IDs from test to production: `ca-app-pub-3244693086681200/6601730347`
- Changed app IDs from test to production: `ca-app-pub-3244693086681200~5375559724`

## How It Works

### Wallet Screen Ad Flow
1. User clicks "Ads" button on wallet screen
2. App navigates to `AdSelectionScreen` with `adType: 'watch-ads'`
3. Ad selection screen loads default ads from `RewardedAdService.getDefaultAds()`
4. All 5 default ads now use production AdMob ad unit IDs
5. When user clicks an ad, `AdMobService.showRewardedAd()` is called
6. AdMob service uses production ad unit ID: `ca-app-pub-3244693086681200/6601730347`
7. Live ads from Google AdMob network are displayed instead of test ads

## What Changed
- **Before**: Test ads were showing (Google's official test ad unit IDs)
- **After**: Live production ads from your AdMob account are displayed

## Testing
To verify the changes are working:
1. Build and run the app
2. Navigate to Wallet screen
3. Click the "Ads" button
4. You should now see 5 ad options
5. Click any ad to watch
6. Live ads should display instead of test ads

## Important Notes
- The app will now serve live ads from your AdMob account
- Make sure your AdMob account is properly set up and approved
- Ads may take up to 1 hour to start showing after configuration
- Monitor your AdMob dashboard for impressions and performance

## Rollback
If you need to revert to test ads for development:
- Replace production ad unit IDs with Google's test IDs:
  - Test Banner/Rewarded: `ca-app-pub-3244693086681200/8464470760`
  - Test Interstitial: `ca-app-pub-3940256099942544/4411468910`
