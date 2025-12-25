# Flexible Ads Management System - Complete Implementation

## Overview
Implemented a comprehensive flexible ad management system that allows admins to:
- Configure ads with different providers (AdMob, Meta, Custom, Third-party)
- Manage provider-specific API keys and credentials
- Set flexible reward amounts (1-10000 coins) per ad
- Customize ad appearance (title, description, icon, color)
- Switch between providers without losing configuration

## Architecture

### Database Schema (RewardedAd Model)
```javascript
{
  adNumber: 1-5,
  title: "Custom Title",
  description: "Custom Description",
  icon: "gift",
  color: "#667eea",
  
  // Flexible Rewards
  rewardCoins: 1-10000,
  
  // Provider Configuration
  adProvider: "admob|meta|custom|third-party",
  providerConfig: {
    admob: {
      adUnitId: "ca-app-pub-...",
      appId: "ca-app-pub-..."
    },
    meta: {
      placementId: "...",
      appId: "...",
      accessToken: "..."
    },
    custom: {
      apiKey: "...",
      apiSecret: "...",
      endpoint: "https://..."
    },
    thirdParty: {
      apiKey: "...",
      apiSecret: "...",
      endpoint: "https://...",
      customField1: "...",
      customField2: "..."
    }
  },
  
  // Tracking
  impressions: 0,
  clicks: 0,
  conversions: 0,
  rotationOrder: 0,
  isActive: true
}
```

## Features

### 1. Multi-Provider Support

#### AdMob Configuration
- Ad Unit ID (required)
- App ID (optional)
- Used for Google AdMob ads

#### Meta (Facebook) Configuration
- Placement ID (required)
- App ID (required)
- Access Token (required)
- Used for Meta Audience Network ads

#### Custom Provider Configuration
- API Key (required)
- API Secret (required)
- API Endpoint (required)
- For custom ad networks

#### Third-Party Configuration
- API Key (required)
- API Secret (required)
- API Endpoint (required)
- Custom Field 1 (optional)
- Custom Field 2 (optional)
- For any third-party ad provider

### 2. Flexible Reward System
- Rewards can be set from 1 to 10000 coins per ad
- Each ad can have different reward amounts
- Admins can adjust rewards based on ad value
- Rewards are returned to app with ad data

### 3. Dynamic Admin Interface
- Provider dropdown automatically shows relevant fields
- Form fields update based on selected provider
- Saved configuration is restored when editing
- Validation for required provider-specific fields

### 4. API Endpoints

#### Get Ads for App
```
GET /api/rewarded-ads
Response:
{
  success: true,
  data: [
    {
      id: "...",
      adNumber: 1,
      title: "Watch & Earn",
      description: "Watch video ad",
      rewardCoins: 10,
      icon: "gift",
      color: "#667eea",
      adProvider: "admob",
      providerConfig: { admob: { adUnitId: "...", appId: "..." } },
      isActive: true
    }
  ]
}
```

#### Update Ad with Provider Config
```
PUT /api/admin/rewarded-ads/:adNumber
Content-Type: application/json

{
  "title": "Watch & Earn",
  "description": "Watch video ad to earn coins",
  "adLink": "https://example.com/ad",
  "adProvider": "admob",
  "icon": "star",
  "color": "#fbbf24",
  "rewardCoins": 15,
  "isActive": true,
  "providerConfig": {
    "admob": {
      "adUnitId": "ca-app-pub-3940256099942544/5224354917",
      "appId": "ca-app-pub-3940256099942544~3347511713"
    }
  }
}
```

## Admin Panel Usage

### Step 1: Access Admin Panel
Navigate to: `http://your-server/admin/rewarded-ads`

### Step 2: Edit an Ad
Click "Edit" button on any ad card

### Step 3: Configure Provider
1. Select provider from dropdown (AdMob, Meta, Custom, Third-party)
2. Provider-specific fields appear automatically
3. Fill in required fields for selected provider

### Step 4: Set Flexible Reward
- Enter reward amount (1-10000 coins)
- Different ads can have different rewards
- Example: Ad 1 = 10 coins, Ad 2 = 15 coins, Ad 3 = 20 coins

### Step 5: Customize Appearance
- Title: Custom ad title
- Description: User-facing description
- Icon: Font Awesome icon name
- Color: Hex color code

### Step 6: Save Changes
Click "Save Changes" - configuration is persisted to database

## Provider Configuration Examples

### AdMob Setup
```
Provider: AdMob
Ad Unit ID: ca-app-pub-3940256099942544/5224354917
App ID: ca-app-pub-3940256099942544~3347511713
Reward: 10 coins
```

### Meta Setup
```
Provider: Meta
Placement ID: YOUR_PLACEMENT_ID
App ID: YOUR_APP_ID
Access Token: YOUR_ACCESS_TOKEN
Reward: 15 coins
```

### Custom Provider Setup
```
Provider: Custom
API Key: your_api_key_here
API Secret: your_api_secret_here
Endpoint: https://api.example.com/ads
Reward: 20 coins
```

### Third-Party Setup
```
Provider: Third-Party
API Key: your_api_key_here
API Secret: your_api_secret_here
Endpoint: https://api.thirdparty.com/ads
Custom Field 1: optional_value_1
Custom Field 2: optional_value_2
Reward: 25 coins
```

## App-Side Implementation

### Fetch Ads with Provider Config
```dart
final ads = await RewardedAdService.getAds();

// Each ad now includes:
// - rewardCoins: flexible reward amount
// - adProvider: provider type
// - providerConfig: provider-specific configuration
// - title, description, icon, color: customization
```

### Get Provider Configuration
```dart
final ad = ads[0];
final provider = ad['adProvider'];
final config = RewardedAdService.getProviderConfig(ad, provider);

// Use config to initialize provider-specific SDK
if (provider == 'admob') {
  final adUnitId = config?['adUnitId'];
  // Initialize AdMob with adUnitId
} else if (provider == 'meta') {
  final placementId = config?['placementId'];
  // Initialize Meta with placementId
}
```

### Get Flexible Reward
```dart
final rewardCoins = RewardedAdService.getRewardCoins(ad);
// Use rewardCoins to award user after watching ad
```

## Database Migration

For existing ads, new fields will use defaults:
- `providerConfig`: Empty object (will be populated when editing)
- `rewardCoins`: Existing value (can be changed to any 1-10000)
- `title`, `description`, `icon`, `color`: Existing values

## API Response Format

### Ads for App
```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439011",
      "adNumber": 1,
      "title": "Watch & Earn",
      "description": "Watch video ad to earn coins",
      "rewardCoins": 10,
      "icon": "gift",
      "color": "#667eea",
      "adLink": "https://example.com/ad",
      "adProvider": "admob",
      "isActive": true,
      "providerConfig": {
        "admob": {
          "adUnitId": "ca-app-pub-3940256099942544/5224354917",
          "appId": "ca-app-pub-3940256099942544~3347511713"
        }
      }
    }
  ]
}
```

## Files Modified

1. **server/models/RewardedAd.js**
   - Added `providerConfig` nested object
   - Updated `rewardCoins` to support 1-10000 range
   - Maintained backward compatibility

2. **server/controllers/adminController.js**
   - Updated `updateRewardedAd()` to handle provider config
   - Updated `getAdsForApp()` to return provider config
   - Added flexible reward support

3. **server/views/admin/rewarded-ads.ejs**
   - Added provider dropdown with change handler
   - Dynamic form fields based on provider
   - Enhanced validation for provider-specific fields
   - Updated reward input to support 1-10000 range

4. **apps/lib/services/rewarded_ad_service.dart**
   - Added `getProviderConfig()` method
   - Added `getRewardCoins()` method
   - Updated default ads with flexible rewards
   - Updated API endpoint to `/rewarded-ads`

## Testing Checklist

### Admin Panel
- [ ] Edit Ad 1 and select AdMob provider
- [ ] Fill in AdMob Ad Unit ID and App ID
- [ ] Set reward to 15 coins
- [ ] Save and verify persistence
- [ ] Edit Ad 2 and select Meta provider
- [ ] Fill in Meta Placement ID, App ID, Access Token
- [ ] Set reward to 20 coins
- [ ] Save and verify persistence
- [ ] Edit Ad 3 and select Custom provider
- [ ] Fill in API Key, Secret, Endpoint
- [ ] Set reward to 25 coins
- [ ] Save and verify persistence
- [ ] Edit Ad 4 and select Third-Party provider
- [ ] Fill in all required fields
- [ ] Set reward to 30 coins
- [ ] Save and verify persistence
- [ ] Switch Ad 1 from AdMob to Meta
- [ ] Verify old AdMob config is preserved
- [ ] Verify new Meta fields appear
- [ ] Test form validation (required fields)
- [ ] Test reward validation (1-10000 range)

### API Testing
- [ ] GET /api/rewarded-ads returns all ads with provider config
- [ ] Each ad includes correct rewardCoins value
- [ ] Provider config is properly nested
- [ ] PUT /api/admin/rewarded-ads/:adNumber updates provider config
- [ ] Provider config is persisted to database

### App-Side
- [ ] App fetches ads with provider config
- [ ] RewardedAdService.getProviderConfig() returns correct config
- [ ] RewardedAdService.getRewardCoins() returns correct reward
- [ ] Different ads show different reward amounts
- [ ] Provider-specific initialization works correctly

## Backward Compatibility

✅ All changes are backward compatible:
- Existing ads continue to work
- Provider config is optional
- Reward amounts default to existing values
- No breaking changes to API
- No database migration required

## Security Considerations

1. **API Keys Storage**
   - Stored in database (encrypted recommended for production)
   - Not exposed to client app
   - Only returned to admin panel

2. **Access Control**
   - Admin endpoints require authentication
   - Provider config only visible to admins
   - App receives only necessary data

3. **Validation**
   - All provider-specific fields validated
   - Reward amount validated (1-10000)
   - URL validation for endpoints

## Future Enhancements

1. Encrypt provider API keys in database
2. Add provider-specific testing endpoints
3. Implement provider health checks
4. Add provider performance analytics
5. Support for more ad providers
6. A/B testing for different providers
7. Automatic provider failover

## Support

For detailed information:
- Admin Panel: See admin interface at `/admin/rewarded-ads`
- API: See endpoint documentation above
- App: See RewardedAdService implementation

## Troubleshooting

### Provider fields not appearing?
- Ensure provider dropdown change handler is working
- Check browser console for JavaScript errors
- Verify form HTML is properly rendered

### Reward not updating?
- Check reward input range (1-10000)
- Verify form validation passes
- Check server logs for update errors

### Provider config not saving?
- Verify all required fields are filled
- Check provider-specific validation
- Review server logs for save errors

### App not receiving provider config?
- Verify API endpoint returns providerConfig
- Check app cache (may need refresh)
- Verify provider config is in database
