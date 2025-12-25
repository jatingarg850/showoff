# Quick Start - Flexible Ads Management

## What's New?

✅ **Multi-Provider Support**: AdMob, Meta, Custom, Third-party
✅ **Flexible Rewards**: Set any reward from 1-10000 coins per ad
✅ **Provider-Specific Config**: Store API keys and credentials per provider
✅ **Dynamic Admin Interface**: Form fields change based on selected provider
✅ **Backward Compatible**: Existing ads continue to work

## 5-Minute Setup

### 1. Access Admin Panel
```
http://your-server/admin/rewarded-ads
```

### 2. Edit an Ad
Click "Edit" on any ad card

### 3. Select Provider
Choose from:
- **AdMob** - Google AdMob ads
- **Meta** - Facebook/Instagram ads
- **Custom** - Your custom ad network
- **Third-Party** - Any other provider

### 4. Fill Provider Fields
Fields appear automatically based on provider:

**AdMob:**
- Ad Unit ID (required)
- App ID (optional)

**Meta:**
- Placement ID (required)
- App ID (required)
- Access Token (required)

**Custom:**
- API Key (required)
- API Secret (required)
- Endpoint (required)

**Third-Party:**
- API Key (required)
- API Secret (required)
- Endpoint (required)
- Custom Field 1 (optional)
- Custom Field 2 (optional)

### 5. Set Flexible Reward
Enter any amount from 1 to 10000 coins

Examples:
- Ad 1: 10 coins
- Ad 2: 15 coins
- Ad 3: 20 coins
- Ad 4: 25 coins
- Ad 5: 50 coins

### 6. Save
Click "Save Changes"

## Common Scenarios

### Scenario 1: Switch from AdMob to Meta
1. Edit ad
2. Change provider from "AdMob" to "Meta"
3. AdMob fields disappear, Meta fields appear
4. Fill in Meta credentials
5. Save

**Result**: Old AdMob config is preserved, new Meta config is saved

### Scenario 2: Increase Reward for Popular Ad
1. Edit ad
2. Change reward from 10 to 25 coins
3. Save

**Result**: Users now earn 25 coins instead of 10

### Scenario 3: Add Custom Ad Network
1. Edit ad
2. Select "Custom" provider
3. Fill in API Key, Secret, Endpoint
4. Set reward
5. Save

**Result**: Ad now uses custom network with your credentials

## API Examples

### Get All Ads with Provider Config
```bash
curl http://localhost:5000/api/rewarded-ads
```

Response includes:
- `rewardCoins`: Flexible reward amount
- `adProvider`: Provider type
- `providerConfig`: Provider-specific credentials

### Update Ad with New Provider
```bash
curl -X PUT http://localhost:5000/api/admin/rewarded-ads/1 \
  -H "Content-Type: application/json" \
  -d '{
    "adProvider": "meta",
    "rewardCoins": 20,
    "providerConfig": {
      "meta": {
        "placementId": "YOUR_PLACEMENT_ID",
        "appId": "YOUR_APP_ID",
        "accessToken": "YOUR_TOKEN"
      }
    }
  }'
```

## App-Side Usage

### Get Ads with Provider Config
```dart
final ads = await RewardedAdService.getAds();

for (var ad in ads) {
  final provider = ad['adProvider'];
  final reward = RewardedAdService.getRewardCoins(ad);
  final config = RewardedAdService.getProviderConfig(ad, provider);
  
  print('Ad: ${ad['title']}');
  print('Provider: $provider');
  print('Reward: $reward coins');
  print('Config: $config');
}
```

### Initialize Provider-Specific SDK
```dart
final ad = ads[0];
final provider = ad['adProvider'];
final config = RewardedAdService.getProviderConfig(ad, provider);

if (provider == 'admob') {
  final adUnitId = config?['adUnitId'];
  // Initialize AdMob
} else if (provider == 'meta') {
  final placementId = config?['placementId'];
  // Initialize Meta
} else if (provider == 'custom') {
  final apiKey = config?['apiKey'];
  final endpoint = config?['endpoint'];
  // Initialize custom provider
}
```

## Provider Credentials

### AdMob
Get from: https://admob.google.com
- Ad Unit ID: Format `ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx`
- App ID: Format `ca-app-pub-xxxxxxxxxxxxxxxx~xxxxxxxxxx`

### Meta
Get from: https://developers.facebook.com/docs/audience-network
- Placement ID: Your placement identifier
- App ID: Your Meta app ID
- Access Token: Your access token

### Custom Provider
Use your own credentials:
- API Key: Your API key
- API Secret: Your API secret
- Endpoint: Your API endpoint URL

### Third-Party
Use provider's credentials:
- API Key: Provider's API key
- API Secret: Provider's API secret
- Endpoint: Provider's API endpoint
- Custom Fields: Provider-specific fields

## Reward Ranges

| Reward | Use Case |
|--------|----------|
| 1-5 | Quick ads, low-value |
| 5-10 | Standard ads |
| 10-20 | Premium ads |
| 20-50 | High-value ads |
| 50+ | Exclusive offers |

## Troubleshooting

### Provider fields not showing?
- Refresh page
- Check browser console for errors
- Verify JavaScript is enabled

### Can't save changes?
- Verify all required fields are filled
- Check reward is between 1-10000
- Review server logs

### App not getting provider config?
- Verify API returns providerConfig
- Check app cache
- Restart app

## Files Changed

- `server/models/RewardedAd.js` - Database schema
- `server/controllers/adminController.js` - API logic
- `server/views/admin/rewarded-ads.ejs` - Admin UI
- `apps/lib/services/rewarded_ad_service.dart` - App service

## Next Steps

1. ✅ Restart server
2. ✅ Access admin panel
3. ✅ Edit ads with new providers
4. ✅ Set flexible rewards
5. ✅ Test in app

## Support

See `FLEXIBLE_ADS_MANAGEMENT_COMPLETE.md` for detailed documentation.
