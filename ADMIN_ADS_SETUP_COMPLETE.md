# Admin Ads Setup - Complete & Ready

## ✅ What's Done

1. **Database Schema Updated**
   - Added `providerConfig` for multi-provider support
   - Added flexible `rewardCoins` (1-10000 range)
   - Fixed duplicate index warning

2. **Admin Controller Enhanced**
   - `updateRewardedAd()` handles provider configuration
   - `getAdsForApp()` returns provider config to app
   - Full support for AdMob, Meta, Custom, Third-party

3. **Admin Template Redesigned**
   - Dynamic form fields based on provider selection
   - Provider dropdown with automatic field updates
   - Color picker with hex input sync
   - Flexible reward input (1-10000)
   - Full form validation

4. **Initial Ads Created**
   - 5 ads seeded with different providers
   - Ad 1: AdMob (10 coins)
   - Ad 2: AdMob (10 coins)
   - Ad 3: Meta (15 coins)
   - Ad 4: Custom (20 coins)
   - Ad 5: Third-party (25 coins)

5. **App Service Updated**
   - `getProviderConfig()` method to extract provider config
   - `getRewardCoins()` method for flexible rewards
   - Updated API endpoint to `/rewarded-ads`

## 🚀 How to Access

### Step 1: Restart Server
```bash
npm restart
# or
pm2 restart server
```

### Step 2: Access Admin Panel
```
http://localhost:3000/admin/rewarded-ads
```

You should now see:
- ✅ 5 ad cards displayed
- ✅ Statistics (impressions, clicks, conversions, served)
- ✅ Edit, Enable/Disable, Reset buttons on each ad

## 📝 Edit an Ad

### Step 1: Click "Edit" Button
Click the edit button on any ad card

### Step 2: Modal Opens
You'll see a form with:
- Ad Number (read-only)
- Title
- Description
- Ad Link
- **Provider Dropdown** (NEW)
- **Provider-Specific Fields** (NEW - changes based on provider)
- Icon
- Color (with color picker)
- Reward Coins (1-10000)
- Rotation Order
- Active checkbox

### Step 3: Select Provider
Choose from:
- **AdMob** - Shows: Ad Unit ID, App ID
- **Meta** - Shows: Placement ID, App ID, Access Token
- **Custom** - Shows: API Key, API Secret, Endpoint
- **Third-Party** - Shows: API Key, API Secret, Endpoint, Custom Fields

### Step 4: Fill Provider Fields
Enter credentials for your chosen provider

### Step 5: Set Flexible Reward
Enter any amount from 1 to 10000 coins

### Step 6: Save
Click "Save Changes"

## 🔧 Provider Configuration Examples

### AdMob
```
Provider: AdMob
Ad Unit ID: ca-app-pub-3940256099942544/5224354917
App ID: ca-app-pub-3940256099942544~3347511713
Reward: 10 coins
```

### Meta
```
Provider: Meta
Placement ID: YOUR_PLACEMENT_ID
App ID: YOUR_APP_ID
Access Token: YOUR_ACCESS_TOKEN
Reward: 15 coins
```

### Custom
```
Provider: Custom
API Key: your_api_key
API Secret: your_api_secret
Endpoint: https://api.example.com
Reward: 20 coins
```

### Third-Party
```
Provider: Third-Party
API Key: your_api_key
API Secret: your_api_secret
Endpoint: https://api.thirdparty.com
Custom Field 1: optional_value
Custom Field 2: optional_value
Reward: 25 coins
```

## 📱 App-Side Usage

### Fetch Ads with Provider Config
```dart
final ads = await RewardedAdService.getAds();

// Each ad now includes:
// - rewardCoins: flexible reward (1-10000)
// - adProvider: provider type
// - providerConfig: provider-specific credentials
// - title, description, icon, color: customization
```

### Get Provider Configuration
```dart
final ad = ads[0];
final provider = ad['adProvider'];
final config = RewardedAdService.getProviderConfig(ad, provider);
final reward = RewardedAdService.getRewardCoins(ad);

// Use config to initialize provider SDK
if (provider == 'admob') {
  final adUnitId = config?['adUnitId'];
  // Initialize AdMob
} else if (provider == 'meta') {
  final placementId = config?['placementId'];
  // Initialize Meta
}
```

## 🧪 Testing Checklist

### Admin Panel
- [ ] Page loads with 5 ads displayed
- [ ] Statistics show (0 impressions initially)
- [ ] Click "Edit" on Ad 1
- [ ] Modal opens with all fields
- [ ] Provider dropdown shows all 4 options
- [ ] Change provider and see fields update
- [ ] Change reward to 25 coins
- [ ] Save changes
- [ ] Page reloads with updated ad
- [ ] Edit Ad 2 and verify it still has original config
- [ ] Test all 5 ads can be edited independently

### API Testing
```bash
# Get all ads with provider config
curl http://localhost:3000/api/rewarded-ads

# Update an ad
curl -X PUT http://localhost:3000/api/admin/rewarded-ads/1 \
  -H "Content-Type: application/json" \
  -d '{
    "rewardCoins": 30,
    "adProvider": "meta",
    "providerConfig": {
      "meta": {
        "placementId": "NEW_ID",
        "appId": "NEW_APP_ID",
        "accessToken": "NEW_TOKEN"
      }
    }
  }'
```

### App-Side
- [ ] App fetches ads successfully
- [ ] Each ad shows correct reward amount
- [ ] Provider config is accessible
- [ ] Different ads show different rewards

## 📊 Database Structure

Each ad now stores:
```javascript
{
  adNumber: 1-5,
  title: "Custom Title",
  description: "Custom Description",
  icon: "gift",
  color: "#667eea",
  rewardCoins: 1-10000,
  adProvider: "admob|meta|custom|third-party",
  providerConfig: {
    admob: { adUnitId, appId },
    meta: { placementId, appId, accessToken },
    custom: { apiKey, apiSecret, endpoint },
    thirdParty: { apiKey, apiSecret, endpoint, customField1, customField2 }
  },
  isActive: true,
  impressions: 0,
  clicks: 0,
  conversions: 0,
  rotationOrder: 1
}
```

## 🔄 Switching Providers

You can switch an ad from one provider to another:

1. Edit the ad
2. Change provider dropdown
3. Old provider config is preserved
4. New provider fields appear
5. Fill in new provider credentials
6. Save

**Result**: Old config is kept, new config is added. You can switch back anytime.

## 🎯 Key Features

✅ **Multi-Provider Support**: AdMob, Meta, Custom, Third-party
✅ **Flexible Rewards**: 1-10000 coins per ad
✅ **Provider-Specific Config**: Store API keys per provider
✅ **Dynamic UI**: Form fields change based on provider
✅ **Easy Switching**: Switch providers without losing data
✅ **Full Customization**: Title, description, icon, color
✅ **Backward Compatible**: Existing ads continue to work

## 📚 Documentation

- `FLEXIBLE_ADS_MANAGEMENT_COMPLETE.md` - Full documentation
- `FLEXIBLE_ADS_IMPLEMENTATION_GUIDE.md` - Technical details
- `QUICK_START_FLEXIBLE_ADS.md` - Quick reference

## 🐛 Troubleshooting

### Ads not showing?
- Restart server
- Check browser cache (Ctrl+Shift+Delete)
- Verify MongoDB connection
- Check server logs

### Can't edit ads?
- Verify you're logged in as admin
- Check browser console for errors
- Verify form validation passes
- Check server logs

### Provider fields not appearing?
- Refresh page
- Check browser console
- Verify JavaScript is enabled

### Reward not updating?
- Verify reward is 1-10000
- Check form validation
- Review server logs

## 🚀 Next Steps

1. ✅ Restart server
2. ✅ Access admin panel
3. ✅ Edit ads with new providers
4. ✅ Set flexible rewards
5. ✅ Test in app
6. ✅ Monitor logs

## 📞 Support

All documentation is in the root directory:
- `FLEXIBLE_ADS_MANAGEMENT_COMPLETE.md`
- `FLEXIBLE_ADS_IMPLEMENTATION_GUIDE.md`
- `QUICK_START_FLEXIBLE_ADS.md`
