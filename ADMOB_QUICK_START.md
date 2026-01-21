# AdMob Ads - Quick Start

## What Was Fixed

AdMob ads now load and display properly in the "Watch Ads & Earn" screen.

## How It Works

### Automatic Preloading
When user opens "Watch Ads & Earn":
1. All 5 ads start preloading in background
2. Each ad preloads with 500ms delay
3. Ads are ready when user clicks

### Instant Display
When user clicks an ad:
1. Ad is already preloaded
2. Shows immediately (or within 1-2 seconds)
3. User watches and earns coins

## Testing

### Step 1: Open App
- App starts
- AdMob initializes

### Step 2: Navigate to "Watch Ads & Earn"
- Screen opens
- 5 ads appear
- Background: Ads start preloading

### Step 3: Check Console Logs
Look for these logs:
```
✅ AdMob initialized successfully
📥 Preloading ad 1 with unit: ca-app-pub-3940256099942544/5224354917
✅ Rewarded ad 1 preloaded successfully
📥 Preloading ad 2...
✅ Rewarded ad 2 preloaded successfully
... (repeats for ads 3, 4, 5)
```

### Step 4: Click on an Ad
- Ad should show within 1-2 seconds
- Watch the ad
- Earn coins

### Step 5: Verify Success
Check logs for:
```
🎬 Attempting to show ad 1
📺 Showing preloaded ad 1...
👁️ Ad 1 impression
🎁 User earned reward from ad 1: 5 coins
📺 Ad 1 dismissed
```

## Troubleshooting

### Ads not showing
**Check:**
1. AdMob initialized? (look for ✅ log)
2. Ads preloading? (look for 📥 logs)
3. Internet connection? (required for ads)
4. Test ad unit IDs correct? (check admob_service.dart)

**Fix:**
- Restart app
- Check internet connection
- Check console for error logs

### Ads showing but no coins
**Check:**
1. Backend `/api/watch-ad/:adNumber` working?
2. User authenticated?
3. Coin balance in database?

**Fix:**
- Check backend logs
- Verify user is logged in
- Check database for user record

### Slow ad loading
**Normal behavior:**
- First ad: 2-3 seconds
- Subsequent ads: instant (preloaded)

**Optimization:**
- Ads preload automatically
- No action needed

## Production Setup

### Step 1: Get Production Ad Unit IDs
1. Go to Google AdMob console
2. Create rewarded ad units
3. Get your ad unit IDs

### Step 2: Update Code
Edit `apps/lib/services/admob_service.dart`:

```dart
// Replace these:
static const String _androidTestAdUnitId = 'ca-app-pub-YOUR-ID/YOUR-UNIT-1';
static const String _iosTestAdUnitId = 'ca-app-pub-YOUR-ID/YOUR-UNIT-2';
```

### Step 3: Rebuild and Deploy
```bash
flutter clean
flutter pub get
flutter run --release
```

## Key Features

✅ **Automatic Preloading** - Ads load in background
✅ **Instant Display** - Ads show immediately when clicked
✅ **5 Different Ads** - Each ad has unique content
✅ **Coin Rewards** - Users earn coins for watching
✅ **Error Handling** - Graceful fallback if ad fails
✅ **Debug Logging** - Easy to troubleshoot

## Files Changed

1. `apps/lib/services/admob_service.dart` - AdMob service
2. `apps/lib/ad_selection_screen.dart` - Ad screen with preloading

## Console Logs Reference

| Log | Meaning |
|-----|---------|
| ✅ | Success |
| ❌ | Error |
| 📥 | Loading |
| 📺 | Showing |
| 👁️ | Impression |
| 🎁 | Reward |
| 🧹 | Cleanup |

## Next Steps

1. Test ads in development
2. Verify coins are awarded
3. Get production ad unit IDs
4. Update code with production IDs
5. Deploy to Play Store

## Support

If ads still don't show:
1. Check console logs
2. Verify internet connection
3. Check AdMob account status
4. Verify ad unit IDs
5. Check backend `/api/watch-ad/:adNumber` endpoint
