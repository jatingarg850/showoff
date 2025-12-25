# Flexible Ads Implementation Guide

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Admin Panel                              │
│  - Edit ads with provider dropdown                          │
│  - Dynamic form fields based on provider                    │
│  - Set flexible rewards (1-10000)                           │
│  - Save provider-specific configuration                     │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Admin API Endpoints                            │
│  PUT /api/admin/rewarded-ads/:adNumber                      │
│  - Accepts providerConfig object                            │
│  - Validates provider-specific fields                       │
│  - Saves to database                                        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│           RewardedAd Database Model                         │
│  - providerConfig: nested object per provider               │
│  - rewardCoins: flexible 1-10000 range                      │
│  - adProvider: admob|meta|custom|third-party                │
│  - All other fields: title, description, icon, color        │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│              Public API Endpoints                           │
│  GET /api/rewarded-ads                                      │
│  - Returns ads with providerConfig                          │
│  - Returns flexible rewardCoins                             │
│  - Returns all customization fields                         │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│                  Flutter App                                │
│  - Fetches ads with provider config                         │
│  - Initializes provider-specific SDK                        │
│  - Shows flexible reward amounts                            │
│  - Tracks impressions/clicks/conversions                    │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema Details

### RewardedAd Collection

```javascript
{
  _id: ObjectId,
  
  // Basic Info
  adNumber: 1-5,
  title: String,
  description: String,
  icon: String,
  color: String,
  
  // Flexible Rewards
  rewardCoins: Number (1-10000),
  
  // Provider Configuration
  adProvider: String (admob|meta|custom|third-party),
  adLink: String,
  
  // Provider-Specific Credentials
  providerConfig: {
    admob: {
      adUnitId: String,
      appId: String
    },
    meta: {
      placementId: String,
      appId: String,
      accessToken: String
    },
    custom: {
      apiKey: String,
      apiSecret: String,
      endpoint: String
    },
    thirdParty: {
      apiKey: String,
      apiSecret: String,
      endpoint: String,
      customField1: String,
      customField2: String
    }
  },
  
  // Status & Tracking
  isActive: Boolean,
  impressions: Number,
  clicks: Number,
  conversions: Number,
  rotationOrder: Number,
  lastServedAt: Date,
  servedCount: Number,
  
  // Timestamps
  createdAt: Date,
  updatedAt: Date
}
```

## Admin Controller Implementation

### updateRewardedAd Method

```javascript
exports.updateRewardedAd = async (req, res) => {
  const { 
    adLink, 
    adProvider, 
    rewardCoins,      // NEW: Flexible rewards
    isActive, 
    title, 
    description, 
    icon, 
    color,
    providerConfig    // NEW: Provider-specific config
  } = req.body;
  
  // Find or create ad
  let ad = await RewardedAd.findOne({ adNumber: req.params.adNumber });
  
  if (!ad) {
    // Create new ad with all fields
    ad = await RewardedAd.create({
      adNumber: parseInt(req.params.adNumber),
      adLink,
      adProvider,
      rewardCoins,
      isActive,
      title,
      description,
      icon,
      color,
      providerConfig
    });
  } else {
    // Update existing ad
    if (adLink) ad.adLink = adLink;
    if (adProvider) ad.adProvider = adProvider;
    if (rewardCoins !== undefined) ad.rewardCoins = rewardCoins;
    if (isActive !== undefined) ad.isActive = isActive;
    if (title) ad.title = title;
    if (description) ad.description = description;
    if (icon) ad.icon = icon;
    if (color) ad.color = color;
    
    // Merge provider config (preserve existing, update new)
    if (providerConfig) {
      ad.providerConfig = {
        ...ad.providerConfig,
        ...providerConfig
      };
    }
    
    await ad.save();
  }
  
  return ad;
};
```

### getAdsForApp Method

```javascript
exports.getAdsForApp = async (req, res) => {
  const ads = await RewardedAd.find({ isActive: true })
    .sort({ rotationOrder: 1, adNumber: 1 });
  
  // Update impressions
  await Promise.all(ads.map(ad => {
    ad.impressions += 1;
    ad.lastServedAt = new Date();
    ad.servedCount += 1;
    return ad.save();
  }));
  
  // Return ads with provider config
  const adsForApp = ads.map(ad => ({
    id: ad._id,
    adNumber: ad.adNumber,
    title: ad.title,
    description: ad.description,
    icon: ad.icon,
    color: ad.color,
    adLink: ad.adLink,
    adProvider: ad.adProvider,
    rewardCoins: ad.rewardCoins,        // NEW: Flexible rewards
    isActive: ad.isActive,
    providerConfig: ad.providerConfig   // NEW: Provider config
  }));
  
  return adsForApp;
};
```

## Admin Template Implementation

### Provider Field Templates

```javascript
const providerFieldTemplates = {
  admob: `
    <div class="form-group">
      <label>AdMob Ad Unit ID *</label>
      <input type="text" id="admobAdUnitId" required>
    </div>
    <div class="form-group">
      <label>AdMob App ID</label>
      <input type="text" id="admobAppId">
    </div>
  `,
  
  meta: `
    <div class="form-group">
      <label>Meta Placement ID *</label>
      <input type="text" id="metaPlacementId" required>
    </div>
    <div class="form-group">
      <label>Meta App ID *</label>
      <input type="text" id="metaAppId" required>
    </div>
    <div class="form-group">
      <label>Meta Access Token *</label>
      <input type="password" id="metaAccessToken" required>
    </div>
  `,
  
  custom: `
    <div class="form-group">
      <label>API Key *</label>
      <input type="password" id="customApiKey" required>
    </div>
    <div class="form-group">
      <label>API Secret *</label>
      <input type="password" id="customApiSecret" required>
    </div>
    <div class="form-group">
      <label>API Endpoint *</label>
      <input type="url" id="customEndpoint" required>
    </div>
  `,
  
  'third-party': `
    <div class="form-group">
      <label>API Key *</label>
      <input type="password" id="thirdPartyApiKey" required>
    </div>
    <div class="form-group">
      <label>API Secret *</label>
      <input type="password" id="thirdPartyApiSecret" required>
    </div>
    <div class="form-group">
      <label>API Endpoint *</label>
      <input type="url" id="thirdPartyEndpoint" required>
    </div>
    <div class="form-group">
      <label>Custom Field 1</label>
      <input type="text" id="thirdPartyCustomField1">
    </div>
    <div class="form-group">
      <label>Custom Field 2</label>
      <input type="text" id="thirdPartyCustomField2">
    </div>
  `
};
```

### Dynamic Form Update

```javascript
function updateProviderFields() {
  const provider = document.getElementById('adProvider').value;
  const fieldsContainer = document.getElementById('providerFields');
  
  // Render provider-specific fields
  fieldsContainer.innerHTML = providerFieldTemplates[provider] || '';
  
  // Restore saved values if editing
  if (currentProviderConfig[provider]) {
    const config = currentProviderConfig[provider];
    Object.keys(config).forEach(key => {
      const fieldId = provider + key.charAt(0).toUpperCase() + key.slice(1);
      const field = document.getElementById(fieldId);
      if (field) {
        field.value = config[key] || '';
      }
    });
  }
}
```

### Provider Config Collection

```javascript
function getProviderConfig() {
  const provider = document.getElementById('adProvider').value;
  const config = {};

  if (provider === 'admob') {
    config.admob = {
      adUnitId: document.getElementById('admobAdUnitId')?.value || '',
      appId: document.getElementById('admobAppId')?.value || ''
    };
  } else if (provider === 'meta') {
    config.meta = {
      placementId: document.getElementById('metaPlacementId')?.value || '',
      appId: document.getElementById('metaAppId')?.value || '',
      accessToken: document.getElementById('metaAccessToken')?.value || ''
    };
  } else if (provider === 'custom') {
    config.custom = {
      apiKey: document.getElementById('customApiKey')?.value || '',
      apiSecret: document.getElementById('customApiSecret')?.value || '',
      endpoint: document.getElementById('customEndpoint')?.value || ''
    };
  } else if (provider === 'third-party') {
    config.thirdParty = {
      apiKey: document.getElementById('thirdPartyApiKey')?.value || '',
      apiSecret: document.getElementById('thirdPartyApiSecret')?.value || '',
      endpoint: document.getElementById('thirdPartyEndpoint')?.value || '',
      customField1: document.getElementById('thirdPartyCustomField1')?.value || '',
      customField2: document.getElementById('thirdPartyCustomField2')?.value || ''
    };
  }

  return config;
}
```

## App-Side Implementation

### RewardedAdService Methods

```dart
// Get provider-specific configuration
static Map<String, dynamic>? getProviderConfig(
  Map<String, dynamic> ad,
  String provider,
) {
  final providerConfig = ad['providerConfig'] as Map<String, dynamic>?;
  if (providerConfig == null) return null;

  switch (provider) {
    case 'admob':
      return providerConfig['admob'] as Map<String, dynamic>?;
    case 'meta':
      return providerConfig['meta'] as Map<String, dynamic>?;
    case 'custom':
      return providerConfig['custom'] as Map<String, dynamic>?;
    case 'third-party':
      return providerConfig['thirdParty'] as Map<String, dynamic>?;
    default:
      return null;
  }
}

// Get flexible reward coins
static int getRewardCoins(Map<String, dynamic> ad) {
  return ad['rewardCoins'] as int? ?? 10;
}
```

### Usage in Ad Selection Screen

```dart
Future<void> _watchAd(Map<String, dynamic> ad) async {
  // Get provider and config
  final provider = ad['adProvider'];
  final config = RewardedAdService.getProviderConfig(ad, provider);
  final reward = RewardedAdService.getRewardCoins(ad);
  
  // Initialize provider-specific SDK
  if (provider == 'admob') {
    final adUnitId = config?['adUnitId'];
    // Initialize AdMob with adUnitId
  } else if (provider == 'meta') {
    final placementId = config?['placementId'];
    // Initialize Meta with placementId
  } else if (provider == 'custom') {
    final apiKey = config?['apiKey'];
    final endpoint = config?['endpoint'];
    // Initialize custom provider
  }
  
  // Show ad and award flexible reward
  final adWatched = await AdMobService.showRewardedAd();
  if (adWatched) {
    // Award flexible reward coins
    await awardCoins(reward);
  }
}
```

## API Request/Response Examples

### Request: Update Ad with AdMob Config
```json
{
  "title": "Watch & Earn",
  "description": "Watch video ad to earn coins",
  "adLink": "https://example.com/ad",
  "adProvider": "admob",
  "icon": "play-circle",
  "color": "#667eea",
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

### Response: Get Ads for App
```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439011",
      "adNumber": 1,
      "title": "Watch & Earn",
      "description": "Watch video ad to earn coins",
      "rewardCoins": 15,
      "icon": "play-circle",
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

## Validation Rules

### Provider-Specific Validation

**AdMob:**
- adUnitId: Required, format `ca-app-pub-*/`
- appId: Optional

**Meta:**
- placementId: Required
- appId: Required
- accessToken: Required

**Custom:**
- apiKey: Required
- apiSecret: Required
- endpoint: Required, valid URL

**Third-Party:**
- apiKey: Required
- apiSecret: Required
- endpoint: Required, valid URL
- customField1: Optional
- customField2: Optional

### Reward Validation
- rewardCoins: 1-10000
- Must be integer
- Cannot be null

## Error Handling

### Admin Panel Validation
```javascript
if (provider === 'admob' && !document.getElementById('admobAdUnitId')?.value) {
  alert('Please enter AdMob Ad Unit ID');
  return;
}

if (provider === 'meta') {
  if (!document.getElementById('metaPlacementId')?.value) {
    alert('Please enter Meta Placement ID');
    return;
  }
  // ... validate other required fields
}
```

### Server-Side Validation
```javascript
if (rewardCoins !== undefined) {
  if (rewardCoins < 1 || rewardCoins > 10000) {
    return res.status(400).json({
      success: false,
      message: 'Reward coins must be between 1 and 10000'
    });
  }
}
```

## Migration Path

### From Old System to New System

1. **Existing ads continue to work** - No breaking changes
2. **Edit ads to add provider config** - Use admin panel
3. **Update reward amounts** - Change from fixed to flexible
4. **Test in app** - Verify provider initialization works

### Backward Compatibility

- Old ads without providerConfig still work
- Default provider config is empty object
- Reward amounts default to existing values
- No database migration required

## Performance Considerations

1. **Caching**: App caches ads for 1 hour
2. **Impressions**: Updated on each fetch
3. **Provider Config**: Included in response (minimal overhead)
4. **Database**: Indexed on adNumber and isActive

## Security Best Practices

1. **API Keys**: Store in database (encrypt in production)
2. **Access Control**: Admin endpoints require authentication
3. **Validation**: All inputs validated server-side
4. **HTTPS**: Use HTTPS in production
5. **Secrets**: Never expose in client app

## Deployment Checklist

- [ ] Update RewardedAd model
- [ ] Update admin controller
- [ ] Update admin template
- [ ] Update app service
- [ ] Restart server
- [ ] Test admin panel
- [ ] Test API endpoints
- [ ] Test app functionality
- [ ] Verify provider initialization
- [ ] Monitor logs for errors
