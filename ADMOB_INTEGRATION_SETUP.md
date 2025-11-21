# Google AdMob Integration - Rewarded Ads

## Overview
ShowOff Life uses Google AdMob rewarded ads to allow users to earn coins by watching advertisements.

## Current Implementation Status

### ✅ Completed
- AdMob package installed (`google_mobile_ads: ^5.3.1`)
- AdMob service created (`apps/lib/services/admob_service.dart`)
- Wallet screen integrated with AdMob
- Backend API ready for coin rewards
- Test ad units configured

### Reward System
- **Coins per ad**: 10 coins (configurable in `.env`)
- **Daily limits** (based on subscription tier):
  - Free: 5 ads/day
  - Basic: 10 ads/day
  - Pro: 15 ads/day
  - VIP: 50 ads/day
- **Cooldown**: 15 minutes after every 3 ads

## Test Ad Unit IDs (Currently Active)

### Android
```
ca-app-pub-3940256099942544/5224354917
```

### iOS
```
ca-app-pub-3940256099942544/1712485313
```

**Note**: These are Google's official test ad unit IDs. They will show test ads only.

## Setup for Production

### Step 1: Create AdMob Account
1. Go to https://admob.google.com/
2. Sign in with Google account
3. Click "Get Started"
4. Follow the setup wizard

### Step 2: Create App in AdMob
1. In AdMob dashboard, click "Apps" → "Add App"
2. Select platform (Android/iOS)
3. Enter app name: "ShowOff Life"
4. Enable user metrics if desired
5. Click "Add App"
6. Note down the **App ID**

### Step 3: Create Rewarded Ad Unit
1. In your app, click "Ad units" → "Add ad unit"
2. Select "Rewarded"
3. Name: "Coin Reward Ad"
4. Click "Create ad unit"
5. Note down the **Ad Unit ID**
6. Repeat for both Android and iOS

### Step 4: Update Ad Unit IDs

Update `apps/lib/services/admob_service.dart`:

```dart
static String get rewardedAdUnitId {
  if (_rewardedAdUnitId != null) {
    return _rewardedAdUnitId!;
  }
  
  // Production Ad Unit IDs
  if (Platform.isAndroid) {
    _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your Android Ad Unit ID
  } else if (Platform.isIOS) {
    _rewardedAdUnitId = 'ca-app-pub-XXXXXXXXXXXXXXXX/YYYYYYYYYY'; // Your iOS Ad Unit ID
  } else {
    _rewardedAdUnitId = '';
  }
  return _rewardedAdUnitId!;
}
```

### Step 5: Configure Android

#### AndroidManifest.xml
Add to `apps/android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <application>
        <!-- AdMob App ID -->
        <meta-data
            android:name="com.google.android.gms.ads.APPLICATION_ID"
            android:value="ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY"/>
    </application>
</manifest>
```

Replace `ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY` with your AdMob App ID.

### Step 6: Configure iOS

#### Info.plist
Add to `apps/ios/Runner/Info.plist`:

```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-XXXXXXXXXXXXXXXX~YYYYYYYYYY</string>

<!-- Optional: SKAdNetwork IDs for better ad performance -->
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>cstr6suwn9.skadnetwork</string>
  </dict>
  <!-- Add more SKAdNetwork IDs as needed -->
</array>
```

Replace with your AdMob App ID.

## How It Works

### User Flow
```
1. User taps "Watch Ad" button in Wallet screen
2. Loading dialog appears
3. AdMob loads rewarded ad
4. Ad is displayed to user
5. User watches ad completely
6. User earns reward
7. Backend API called to credit coins
8. Success message shown
9. Wallet balance updated
```

### Code Flow

#### 1. Initialize AdMob (main.dart)
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdMobService.initialize();
  runApp(MyApp());
}
```

#### 2. Show Ad (wallet_screen.dart)
```dart
Future<void> _watchAd() async {
  // Show loading
  showDialog(context: context, builder: (_) => CircularProgressIndicator());
  
  // Load and show ad
  final adWatched = await AdMobService.showRewardedAd();
  
  // Close loading
  Navigator.pop(context);
  
  if (adWatched) {
    // Call backend to award coins
    final response = await ApiService.watchAd();
    // Show success message
  }
}
```

#### 3. Backend Awards Coins (server)
```javascript
// POST /api/coins/watch-ad
exports.watchAd = async (req, res) => {
  // Check daily limit
  // Check cooldown
  // Award coins
  // Update user stats
  // Return success
};
```

## Backend Configuration

### Environment Variables
In `server/.env`:

```env
AD_WATCH_COINS=10
```

### Daily Limits
Configured in `server/controllers/coinController.js`:

```javascript
const dailyLimits = {
  free: 5,
  basic: 10,
  pro: 15,
  vip: 50,
};
```

### Cooldown System
- After every 3 ads: 15-minute cooldown
- Prevents abuse
- Resets daily at midnight

## Testing

### Test with Test Ads
1. Run the app with test ad unit IDs (current setup)
2. Tap "Watch Ad" in wallet screen
3. Ad should load and display
4. Watch ad completely
5. Verify coins are credited

### Test Ad Behavior
- **Test ads load quickly** (1-2 seconds)
- **Test ads are short** (5-30 seconds)
- **Test ads always reward** (no failures)

### Production Testing
1. Replace test IDs with production IDs
2. Test on real device (not emulator)
3. Verify ads load from real advertisers
4. Check coin rewards work correctly
5. Test daily limits and cooldowns

## Troubleshooting

### Ad Not Loading
**Possible causes:**
- No internet connection
- Ad inventory not available
- Invalid ad unit ID
- App not registered in AdMob

**Solutions:**
- Check internet connection
- Wait and try again (ad inventory varies)
- Verify ad unit ID is correct
- Ensure app is properly configured in AdMob

### Ad Loads But Doesn't Show
**Possible causes:**
- Ad dismissed before showing
- Full-screen content callback not set

**Solutions:**
- Check AdMobService implementation
- Verify callbacks are properly configured

### Coins Not Credited
**Possible causes:**
- Backend API error
- Daily limit reached
- Cooldown active

**Solutions:**
- Check server logs
- Verify user hasn't exceeded daily limit
- Check if cooldown is active

### "Ad Not Available" Message
**Possible causes:**
- Using test IDs in production
- Low ad fill rate
- Geographic restrictions

**Solutions:**
- Use production ad unit IDs
- Try again later
- Check AdMob dashboard for fill rate

## Best Practices

### 1. User Experience
- Show loading indicator while ad loads
- Provide clear instructions
- Show remaining daily ads
- Display cooldown timer

### 2. Ad Placement
- Don't force ads too frequently
- Respect user's time
- Provide value for watching

### 3. Error Handling
- Gracefully handle ad load failures
- Provide alternative ways to earn coins
- Log errors for debugging

### 4. Compliance
- Follow AdMob policies
- Don't incentivize clicks
- Don't encourage invalid traffic
- Respect user privacy

### 5. Monitoring
- Track ad performance in AdMob dashboard
- Monitor fill rates
- Check eCPM (earnings per thousand impressions)
- Analyze user engagement

## AdMob Dashboard

### Key Metrics
- **Impressions**: Number of ads shown
- **Match Rate**: % of ad requests filled
- **Show Rate**: % of loaded ads actually shown
- **eCPM**: Estimated earnings per 1000 impressions
- **Revenue**: Total earnings

### Access Dashboard
https://admob.google.com/

### Useful Sections
- **Home**: Overview and key metrics
- **Apps**: Manage your apps
- **Ad units**: View and create ad units
- **Mediation**: Configure ad networks
- **Reports**: Detailed analytics
- **Account**: Settings and payments

## Revenue Estimates

### Typical eCPM Rates
- **Tier 1 countries** (US, UK, CA, AU): $5-$15
- **Tier 2 countries** (EU, JP, KR): $2-$8
- **Tier 3 countries** (IN, BR, MX): $0.50-$3

### Example Calculation
- 1000 users watch 5 ads/day = 5000 impressions/day
- eCPM = $5
- Daily revenue = (5000 / 1000) × $5 = $25/day
- Monthly revenue = $25 × 30 = $750/month

## Security Considerations

### Server-Side Validation
- Always validate ad watch on server
- Don't trust client-side only
- Check daily limits server-side
- Implement fraud detection

### Rate Limiting
- Limit API calls per user
- Implement cooldowns
- Track suspicious patterns

### Fraud Prevention
- Monitor for bot activity
- Check for unusual patterns
- Implement device fingerprinting
- Use AdMob's built-in fraud protection

## Support Resources

- **AdMob Help**: https://support.google.com/admob
- **Flutter Plugin Docs**: https://pub.dev/packages/google_mobile_ads
- **AdMob Policies**: https://support.google.com/admob/answer/6128543
- **Integration Guide**: https://developers.google.com/admob/flutter/quick-start

## Production Checklist

- [ ] Create AdMob account
- [ ] Register app in AdMob
- [ ] Create rewarded ad units (Android & iOS)
- [ ] Update ad unit IDs in code
- [ ] Add AdMob App ID to AndroidManifest.xml
- [ ] Add AdMob App ID to Info.plist
- [ ] Test with production ad units
- [ ] Verify coin rewards work
- [ ] Test daily limits
- [ ] Test cooldown system
- [ ] Monitor AdMob dashboard
- [ ] Set up payment method in AdMob
- [ ] Review and comply with AdMob policies

---

**Status**: ✅ Fully Integrated with Test Ads | ⚠️ Needs Production Ad Unit IDs
**Last Updated**: 2024
**Reward**: 10 coins per ad
**Daily Limit**: 5-50 ads (based on subscription tier)
