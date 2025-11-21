# How to Get AdMob Credentials - Step by Step Guide

## Overview
This guide will walk you through creating an AdMob account and getting your App ID and Ad Unit IDs for ShowOff Life app.

## Step 1: Create Google AdMob Account

### 1.1 Go to AdMob Website
Visit: **https://admob.google.com/**

### 1.2 Sign In
- Click **"Get Started"** or **"Sign In"**
- Use your Google account (Gmail)
- If you don't have a Google account, create one first

### 1.3 Accept Terms
- Read and accept AdMob Terms & Conditions
- Accept Google Ads Terms of Service
- Click **"Continue to AdMob"**

### 1.4 Complete Account Setup
- Select your country/region
- Select your timezone
- Choose "Yes" if you want to receive performance suggestions
- Click **"Create AdMob Account"**

## Step 2: Add Your App to AdMob

### 2.1 Navigate to Apps
- In AdMob dashboard, click **"Apps"** in the left sidebar
- Click **"Add App"** button

### 2.2 Select Platform
- Choose **"Android"** (for Android app)
- You'll need to do this separately for iOS later

### 2.3 App Store Listing
- Select **"No"** for "Is your app listed on a supported app store?"
- (Select "Yes" if your app is already on Google Play Store)

### 2.4 Enter App Details
- **App name**: `ShowOff Life`
- **Platform**: Android
- Click **"Add"**

### 2.5 Get Your App ID
After adding the app, you'll see:
```
App ID: ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY
```

**IMPORTANT**: Copy this App ID! You'll need it for AndroidManifest.xml

**Format**: `ca-app-pub-[16 digits]~[10 digits]`

Example: `ca-app-pub-1234567890123456~1234567890`

## Step 3: Create Rewarded Ad Unit

### 3.1 Navigate to Ad Units
- In your app's page, click **"Ad units"** tab
- Click **"Add ad unit"** or **"Get started"**

### 3.2 Select Ad Format
- Choose **"Rewarded"** (for coin rewards)
- Click **"Select"**

### 3.3 Configure Ad Unit
- **Ad unit name**: `Coin Reward Ad` (or any name you prefer)
- **Advanced settings** (optional):
  - Reward amount: 10 (this is just for display, actual coins awarded by your server)
  - Reward item: Coins
- Click **"Create ad unit"**

### 3.4 Get Your Ad Unit ID
After creating, you'll see:
```
Ad unit ID: ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY
```

**IMPORTANT**: Copy this Ad Unit ID! You'll need it for your Flutter code.

**Format**: `ca-app-pub-[16 digits]/[10 digits]`

Example: `ca-app-pub-1234567890123456/9876543210`

### 3.5 Click "Done"

## Step 4: Repeat for iOS (Optional)

If you have an iOS app:

### 4.1 Add iOS App
- Go to **"Apps"** → **"Add App"**
- Select **"iOS"**
- Enter app name: `ShowOff Life`
- Click **"Add"**

### 4.2 Get iOS App ID
Copy the iOS App ID (different from Android)

### 4.3 Create iOS Ad Unit
- In iOS app page, click **"Ad units"**
- Click **"Add ad unit"** → **"Rewarded"**
- Name: `Coin Reward Ad iOS`
- Click **"Create ad unit"**
- Copy the iOS Ad Unit ID

## Step 5: Update Your App Code

### 5.1 Update AndroidManifest.xml

File: `apps/android/app/src/main/AndroidManifest.xml`

Replace the test App ID with your real App ID:

```xml
<application>
    <!-- ... other content ... -->
    
    <!-- AdMob App ID - REPLACE WITH YOUR REAL APP ID -->
    <meta-data
        android:name="com.google.android.gms.ads.APPLICATION_ID"
        android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
</application>
```

### 5.2 Update iOS Info.plist (if you have iOS app)

File: `apps/ios/Runner/Info.plist`

Add:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>
```

### 5.3 Update AdMob Service

File: `apps/lib/services/admob_service.dart`

Replace test Ad Unit IDs with your real ones:

```dart
static String get rewardedAdUnitId {
  if (_rewardedAdUnitId != null) {
    return _rewardedAdUnitId!;
  }
  
  // Production Ad Unit IDs - REPLACE WITH YOUR REAL IDs
  if (Platform.isAndroid) {
    _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your Android Ad Unit ID
  } else if (Platform.isIOS) {
    _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/ZZZZZZZZZZ'; // Your iOS Ad Unit ID
  } else {
    _rewardedAdUnitId = '';
  }
  return _rewardedAdUnitId!;
}
```

## Step 6: Test Your Integration

### 6.1 Build and Run
```bash
cd apps
flutter clean
flutter pub get
flutter run
```

### 6.2 Test Ad Display
- Open the app
- Go to Wallet screen
- Tap "Watch Ad" button
- Ad should load and display

### 6.3 Verify in AdMob Dashboard
- Go to AdMob dashboard
- Check **"Reports"** section
- You should see ad requests and impressions (may take 24-48 hours to show)

## Important Notes

### Test vs Production IDs

**Test IDs** (Currently in your app):
- App ID: `ca-app-pub-3940256099942544~3347511713`
- Ad Unit ID: `ca-app-pub-3940256099942544/5224354917`

**Your Production IDs** (Get from AdMob):
- App ID: `ca-app-pub-[YOUR-16-DIGITS]~[YOUR-10-DIGITS]`
- Ad Unit ID: `ca-app-pub-[YOUR-16-DIGITS]/[YOUR-10-DIGITS]`

### When to Use Test IDs
- ✅ During development
- ✅ For testing functionality
- ✅ Before app is published

### When to Use Production IDs
- ✅ For production builds
- ✅ When publishing to Play Store
- ✅ To earn real revenue

### ⚠️ Important Warnings

1. **Never click your own ads in production**
   - This violates AdMob policies
   - Can get your account banned
   - Use test IDs during development

2. **Don't use test IDs in production**
   - Won't earn revenue
   - Against AdMob policies

3. **Keep IDs secure**
   - Don't share publicly
   - Use environment variables for sensitive data

## Step 7: Set Up Payment Method

### 7.1 Navigate to Payments
- In AdMob dashboard, click **"Payments"**
- Click **"Manage payment methods"**

### 7.2 Add Payment Information
- Select your country
- Choose payment method:
  - Bank transfer (recommended)
  - Wire transfer
  - Check (US only)

### 7.3 Enter Bank Details
- Bank name
- Account holder name
- Account number
- SWIFT/IFSC code
- Branch details

### 7.4 Verify Information
- AdMob will send a test deposit
- Verify the amount in your account
- Enter the amount in AdMob to confirm

### 7.5 Set Payment Threshold
- Minimum: $100 (default)
- You'll receive payment when you reach this amount

## Step 8: Monitor Performance

### 8.1 Dashboard Metrics
Check these regularly:
- **Impressions**: Number of ads shown
- **Match Rate**: % of ad requests filled
- **eCPM**: Earnings per 1000 impressions
- **Revenue**: Total earnings

### 8.2 Optimize Performance
- Monitor which ad formats perform best
- Check fill rates by country
- Adjust ad placement if needed
- Review user feedback

## Troubleshooting

### Issue: "App ID not found"
**Solution**: 
- Verify App ID is correct in AndroidManifest.xml
- Make sure format is: `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY`
- Check for typos

### Issue: "Ad failed to load"
**Solution**:
- Check internet connection
- Verify Ad Unit ID is correct
- Wait a few hours (new ad units take time to activate)
- Check AdMob dashboard for errors

### Issue: "Invalid Ad Unit ID"
**Solution**:
- Ensure Ad Unit ID format is correct
- Verify you're using the right ID for the platform (Android/iOS)
- Check if ad unit is active in AdMob dashboard

### Issue: "No ads available"
**Solution**:
- Normal for new apps (low fill rate initially)
- Try different geographic locations
- Wait for AdMob to learn your app's audience
- Check if your app complies with AdMob policies

## Quick Reference

### Where to Find Your IDs

**AdMob Dashboard**: https://admob.google.com/

**App ID Location**:
- Apps → Select your app → App settings → App ID

**Ad Unit ID Location**:
- Apps → Select your app → Ad units → Select ad unit → Ad unit ID

### ID Formats

```
App ID:      ca-app-pub-1234567890123456~1234567890
Ad Unit ID:  ca-app-pub-1234567890123456/9876543210
```

### Files to Update

1. `apps/android/app/src/main/AndroidManifest.xml` - App ID
2. `apps/ios/Runner/Info.plist` - App ID (iOS)
3. `apps/lib/services/admob_service.dart` - Ad Unit IDs

## Support Resources

- **AdMob Help Center**: https://support.google.com/admob
- **AdMob Community**: https://groups.google.com/g/google-admob-ads-sdk
- **Flutter AdMob Plugin**: https://pub.dev/packages/google_mobile_ads
- **AdMob Policies**: https://support.google.com/admob/answer/6128543

## Checklist

- [ ] Created AdMob account
- [ ] Added Android app to AdMob
- [ ] Got Android App ID
- [ ] Created Rewarded ad unit for Android
- [ ] Got Android Ad Unit ID
- [ ] (Optional) Added iOS app to AdMob
- [ ] (Optional) Got iOS App ID and Ad Unit ID
- [ ] Updated AndroidManifest.xml with App ID
- [ ] Updated admob_service.dart with Ad Unit IDs
- [ ] Tested ad display in app
- [ ] Set up payment method in AdMob
- [ ] Verified ads are showing in AdMob reports

---

**Current Status**: Using test IDs (safe for development)
**Next Step**: Get your real AdMob credentials and replace test IDs
**Timeline**: AdMob account setup takes 5-10 minutes
**Activation**: New ad units may take 1-2 hours to start serving ads
