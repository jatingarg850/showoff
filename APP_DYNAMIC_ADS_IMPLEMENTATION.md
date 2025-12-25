# App Dynamic Ads Implementation - Complete

## Overview
Updated the Flutter app to display fully dynamic ads with flexible rewards and multi-provider support. Ads now pull all customization from the server and display them dynamically.

## What Changed

### 1. Ad Selection Screen (`apps/lib/ad_selection_screen.dart`)

#### Dynamic Ad Display
- **Title**: Pulled from server (customizable in admin panel)
- **Description**: Pulled from server (customizable in admin panel)
- **Icon**: Pulled from server as icon name, converted to Flutter IconData
- **Color**: Pulled from server as hex code, converted to Color
- **Reward**: Pulled from server as flexible amount (1-10000 coins)
- **Provider**: Pulled from server (admob, meta, custom, third-party)
- **Status**: Pulled from server (active/inactive)

#### New Features
1. **Hex Color Support**
   - Server sends color as hex code (e.g., "#667eea")
   - App converts hex to Flutter Color
   - Fallback to default color if invalid

2. **Icon Name Mapping**
   - Server sends icon name (e.g., "gift", "star", "fire")
   - App maps to Flutter IconData
   - Supports 14+ icon types
   - Fallback to play_circle_filled

3. **Flexible Rewards**
   - Uses `RewardedAdService.getRewardCoins(ad)` to get reward
   - Supports 1-10000 coins per ad
   - Different ads can have different rewards
   - Shows actual reward in success dialog

4. **Provider Display**
   - Shows provider badge for non-AdMob ads
   - Displays provider name (META, CUSTOM, THIRD-PARTY)
   - Uses ad color for badge styling

5. **Provider-Specific Ad Handling**
   - AdMob: Shows AdMob rewarded ad
   - Meta: Shows AdMob as fallback (Meta SDK integration ready)
   - Custom: Shows AdMob as fallback
   - Third-party: Shows AdMob as fallback
   - All track impressions/clicks/conversions

### 2. Helper Functions

#### `_hexToColor(String hexString)`
Converts hex color codes to Flutter Color:
```dart
// Input: "#667eea" or "667eea"
// Output: Color(0xFF667eea)
// Fallback: Color(0xFF667eea) on error
```

#### `_getIconFromName(String iconName)`
Maps icon names to Flutter IconData:
```dart
// Supported icons:
// gift, star, heart, fire, trophy, coins, gem, crown
// zap, target, play-circle, video, hand-pointer, clipboard
```

### 3. Ad Card Display

**Before**: Static layout with hardcoded colors and icons
**After**: Dynamic layout with:
- Dynamic color from server
- Dynamic icon from server
- Dynamic title and description
- Dynamic reward amount
- Provider badge for non-AdMob ads
- Inactive state styling

## API Integration

### Fetch Ads
```dart
final ads = await RewardedAdService.getAds();
// Returns list of ads with all dynamic fields
```

### Get Reward
```dart
final reward = RewardedAdService.getRewardCoins(ad);
// Returns flexible reward (1-10000)
```

### Get Provider Config
```dart
final config = RewardedAdService.getProviderConfig(ad, provider);
// Returns provider-specific configuration
```

### Track Ad Events
```dart
await RewardedAdService.trackAdClick(adNumber);
await RewardedAdService.trackAdConversion(adNumber);
```

## Data Flow

```
Admin Panel (Edit Ad)
    ↓
Server Database (RewardedAd)
    ↓
API: GET /api/rewarded-ads
    ↓
App: RewardedAdService.getAds()
    ↓
Ad Selection Screen
    ↓
Display Dynamic Ad Card
    ↓
User Watches Ad
    ↓
Track Events + Award Coins
```

## Example Ad Data

```json
{
  "id": "507f1f77bcf86cd799439011",
  "adNumber": 1,
  "title": "Watch & Earn",
  "description": "Watch video ad to earn coins",
  "icon": "play-circle",
  "color": "#667eea",
  "rewardCoins": 15,
  "adProvider": "admob",
  "isActive": true,
  "providerConfig": {
    "admob": {
      "adUnitId": "ca-app-pub-3940256099942544/5224354917",
      "appId": "ca-app-pub-3940256099942544~3347511713"
    }
  }
}
```

## Supported Icons

| Icon Name | Flutter Icon | Use Case |
|-----------|--------------|----------|
| gift | card_giftcard | Gift/reward ads |
| star | star | Premium ads |
| heart | favorite | Engagement ads |
| fire | local_fire_department | Hot/trending ads |
| trophy | emoji_events | Achievement ads |
| coins | monetization_on | Coin ads |
| gem | diamond | Premium/exclusive |
| crown | workspace_premium | VIP/premium |
| zap | flash_on | Quick/fast ads |
| target | track_changes | Targeted ads |
| play-circle | play_circle_filled | Video ads |
| video | video_library | Video content |
| hand-pointer | touch_app | Interactive ads |
| clipboard | assignment | Survey/form ads |

## Supported Colors

Any hex color code works:
- `#667eea` - Purple
- `#FF6B35` - Orange
- `#4FACFE` - Blue
- `#43E97B` - Green
- `#FBBF24` - Amber
- `#8b5cf6` - Violet
- `#ec4899` - Pink
- `#f97316` - Orange

## Testing

### Test 1: Dynamic Title & Description
1. Edit Ad 1 in admin panel
2. Change title to "New Title"
3. Change description to "New Description"
4. Save
5. Refresh app
6. Verify new title and description appear

### Test 2: Dynamic Color
1. Edit Ad 2 in admin panel
2. Change color to "#FF6B35" (orange)
3. Save
4. Refresh app
5. Verify ad card is orange

### Test 3: Dynamic Icon
1. Edit Ad 3 in admin panel
2. Change icon to "star"
3. Save
4. Refresh app
5. Verify star icon appears

### Test 4: Flexible Reward
1. Edit Ad 4 in admin panel
2. Change reward to 50 coins
3. Save
4. Refresh app
5. Verify "+50" appears in reward badge
6. Watch ad and verify 50 coins earned

### Test 5: Provider Display
1. Edit Ad 5 in admin panel
2. Change provider to "meta"
3. Save
4. Refresh app
5. Verify "Provider: META" badge appears

### Test 6: Inactive Ad
1. Edit any ad in admin panel
2. Uncheck "Active"
3. Save
4. Refresh app
5. Verify ad card is grayed out and not clickable

## Code Changes

### File: `apps/lib/ad_selection_screen.dart`

**Key Changes:**
1. Added `_hexToColor()` helper function
2. Added `_getIconFromName()` helper function
3. Updated `_buildAdCard()` to use dynamic values
4. Added provider badge display
5. Updated success dialog to show ad title
6. Added provider-specific ad handling in `_watchAd()`
7. Added debug logging for provider tracking

**New Methods:**
- `_hexToColor(String hexString)` - Converts hex to Color
- `_getIconFromName(String iconName)` - Maps icon names to IconData

**Updated Methods:**
- `_buildAdCard()` - Now fully dynamic
- `_watchAd()` - Handles multiple providers
- `_showSuccessDialog()` - Shows ad title

## Backward Compatibility

✅ Existing ads continue to work
✅ Default values for missing fields
✅ Fallback colors and icons
✅ No breaking changes

## Performance

- Ads cached for 1 hour
- Minimal overhead for color/icon conversion
- No additional API calls
- Smooth UI updates

## Future Enhancements

1. **Meta SDK Integration**
   - Implement Meta Audience Network SDK
   - Use placementId from providerConfig

2. **Custom Provider Integration**
   - Implement custom ad network SDK
   - Use apiKey and endpoint from providerConfig

3. **Provider Fallback Chain**
   - Try primary provider first
   - Fall back to secondary provider
   - Fall back to AdMob as last resort

4. **Ad Analytics**
   - Track provider-specific metrics
   - Monitor provider performance
   - Auto-switch providers based on performance

5. **A/B Testing**
   - Test different rewards
   - Test different icons/colors
   - Test different providers

## Troubleshooting

### Ads not showing?
- Check API endpoint is correct
- Verify ads exist in database
- Check browser console for errors
- Restart app

### Wrong color showing?
- Verify hex code format (#RRGGBB)
- Check color is valid hex
- Fallback color is #667eea

### Wrong icon showing?
- Verify icon name is in supported list
- Check icon name spelling
- Fallback icon is play_circle_filled

### Reward not updating?
- Verify reward is 1-10000
- Check API returns correct reward
- Verify RewardedAdService.getRewardCoins() works

### Provider badge not showing?
- Verify provider is not "admob"
- Check provider name is correct
- Verify ad data includes provider

## Files Modified

1. **apps/lib/ad_selection_screen.dart**
   - Complete rewrite for dynamic ads
   - Added helper functions
   - Added provider support
   - Added flexible rewards

2. **apps/lib/services/rewarded_ad_service.dart**
   - Already supports dynamic data
   - `getRewardCoins()` method
   - `getProviderConfig()` method

## Summary

The app now displays fully dynamic ads with:
✅ Dynamic titles and descriptions
✅ Dynamic colors (hex codes)
✅ Dynamic icons (icon names)
✅ Flexible rewards (1-10000 coins)
✅ Multi-provider support
✅ Provider badges
✅ Inactive ad handling
✅ Full backward compatibility

All changes are pulled from the server, so admins can update ads without app updates!
