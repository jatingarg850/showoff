# Ad System Reorganization - Complete Implementation Plan

## Current Architecture Analysis

### What's Working
✅ AdMob ads configured with test IDs
✅ Video ads uploading to Wasabi S3
✅ Rewarded ads model in database
✅ Coin awarding system
✅ Admin panel for video ads

### What Needs Fixing
❌ Watch Ads & Earn mixing AdMob + Video ads (should be AdMob only)
❌ Spin Wheel not showing admin panel ads for refills
❌ No interstitial ads between reels
❌ Ad type separation not clear in API responses

## Reorganized Ad System

### 1. WATCH ADS & EARN (AdMob Only)
**Purpose**: Users watch AdMob rewarded ads to earn coins
**Location**: Wallet → Watch Ads & Earn
**Ad Source**: AdMob (via admob_service.dart)
**Rewards**: Configurable per ad in RewardedAd model
**Daily Limit**: Based on subscription tier (5-50 ads/day)
**Cooldown**: 15 minutes after every 3 ads

**Flow**:
```
User clicks "Watch Ads"
    ↓
AdSelectionScreen loads
    ↓
Fetch ONLY AdMob ads from /api/rewarded-ads
    ↓
Show AdMob ads (no video ads)
    ↓
User selects ad
    ↓
AdMobService.showRewardedAd()
    ↓
POST /api/coins/watch-ad
    ↓
Award coins
```

### 2. SPIN WHEEL REFILL (Admin Panel Ads)
**Purpose**: Users watch admin panel ads to get extra spins
**Location**: Spin Wheel Screen → "Watch ads to spin again"
**Ad Source**: Admin panel (RewardedAd model)
**Rewards**: Fixed per ad (admin configured)
**Frequency**: Can watch multiple times per day

**Flow**:
```
User clicks "Watch ads to spin again"
    ↓
AdSelectionScreen loads
    ↓
Fetch ONLY admin panel ads from /api/rewarded-ads?type=spin-wheel
    ↓
Show admin ads (no AdMob, no video ads)
    ↓
User selects ad
    ↓
Show ad (AdMob or custom)
    ↓
POST /api/coins/watch-ad
    ↓
Award coins
    ↓
Grant extra spin
```

### 3. INTERSTITIAL ADS (Between Reels)
**Purpose**: Show ads between reel videos
**Location**: SYT Reel Screen (between video transitions)
**Ad Source**: AdMob interstitial ads
**Frequency**: Every 3-5 reels

**Flow**:
```
User swipes to next reel
    ↓
Check if should show interstitial (every 3-5 reels)
    ↓
AdMobService.showInterstitialAd()
    ↓
Show ad
    ↓
Continue to next reel
```

### 4. VIDEO ADS (Custom Backend Ads)
**Purpose**: Custom video ads managed by admin
**Location**: Can be used in Watch Ads or Spin Wheel
**Ad Source**: Admin panel (VideoAd model)
**Rewards**: Configurable per video
**Storage**: Wasabi S3

**Flow**:
```
Admin uploads video ad
    ↓
Files stored in Wasabi S3
    ↓
VideoAd document created
    ↓
App fetches from /api/video-ads
    ↓
Show video ad
    ↓
POST /api/video-ads/:id/complete
    ↓
Award coins
```

## Implementation Changes

### Backend Changes

#### 1. Update RewardedAd Model
Add `adType` field to distinguish between different ad types:
```javascript
adType: {
  type: String,
  enum: ['watch-ads', 'spin-wheel', 'interstitial'],
  default: 'watch-ads'
}
```

#### 2. Update Rewarded Ads Routes
Add filtering by ad type:
```
GET /api/rewarded-ads?type=watch-ads      - For Watch Ads & Earn
GET /api/rewarded-ads?type=spin-wheel     - For Spin Wheel refills
GET /api/rewarded-ads?type=interstitial   - For between reels
```

#### 3. Update Video Ads Routes
Add filtering by usage:
```
GET /api/video-ads?usage=watch-ads        - For Watch Ads & Earn
GET /api/video-ads?usage=spin-wheel       - For Spin Wheel refills
```

### Mobile App Changes

#### 1. Update Ad Selection Screen
Add parameter to specify ad type:
```dart
AdSelectionScreen(
  adType: 'watch-ads',  // or 'spin-wheel', 'interstitial'
)
```

#### 2. Update Spin Wheel Screen
Show admin panel ads when spins exhausted:
```dart
_showOutOfSpinsModal() {
  // Show dialog with "Watch ads" button
  // Navigate to AdSelectionScreen with adType: 'spin-wheel'
}
```

#### 3. Add Interstitial Ads to Reel Screen
Show ads between reel transitions:
```dart
_onReelSwipe() {
  if (_reelCount % 3 == 0) {
    AdMobService.showInterstitialAd();
  }
}
```

## API Endpoints

### Rewarded Ads
```
GET /api/rewarded-ads                     - Get all active ads
GET /api/rewarded-ads?type=watch-ads      - Get watch ads only
GET /api/rewarded-ads?type=spin-wheel     - Get spin wheel ads only
GET /api/rewarded-ads?type=interstitial   - Get interstitial ads only
POST /api/rewarded-ads/:id/click          - Track click
POST /api/rewarded-ads/:id/conversion     - Track conversion
```

### Video Ads
```
GET /api/video-ads                        - Get all active video ads
GET /api/video-ads?usage=watch-ads        - Get watch ads video ads
GET /api/video-ads?usage=spin-wheel       - Get spin wheel video ads
POST /api/video-ads/:id/view              - Track view
POST /api/video-ads/:id/complete          - Track completion & award coins
```

### Coins
```
POST /api/coins/watch-ad                  - Award coins for watching ad
POST /api/coins/spin-wheel                - Spin wheel and award coins
```

## Admin Panel Updates

### Rewarded Ads Management
- Add `adType` field when creating/editing ads
- Filter ads by type in admin panel
- Show statistics per ad type

### Video Ads Management
- Add `usage` field when creating/editing ads
- Filter ads by usage in admin panel
- Show statistics per usage type

## Configuration

### Environment Variables
```
AD_WATCH_COINS=10                         - Default coins for watch ads
SPIN_WHEEL_REFILL_COINS=5                 - Coins for spin wheel refill
INTERSTITIAL_AD_FREQUENCY=3               - Show interstitial every N reels
```

### AdMob Unit IDs
```
ADMOB_REWARDED_AD_UNIT_ID=ca-app-pub-...  - Rewarded ads
ADMOB_INTERSTITIAL_AD_UNIT_ID=ca-app-pub-... - Interstitial ads
```

## Testing Checklist

### Watch Ads & Earn
- [ ] Only AdMob ads shown
- [ ] No video ads shown
- [ ] Coins awarded correctly
- [ ] Daily limit enforced
- [ ] Cooldown working

### Spin Wheel
- [ ] Admin panel ads shown for refills
- [ ] Extra spin granted after watching ad
- [ ] Can watch multiple ads per day
- [ ] Coins awarded correctly

### Interstitial Ads
- [ ] Shown between reels
- [ ] Shown every 3-5 reels
- [ ] Doesn't block reel navigation
- [ ] Properly disposed after showing

### Admin Panel
- [ ] Can create ads with type
- [ ] Can filter ads by type
- [ ] Statistics show per type
- [ ] Video ads upload correctly

## Migration Path

### Phase 1: Backend Updates
1. Add `adType` field to RewardedAd model
2. Add `usage` field to VideoAd model
3. Update routes to support filtering
4. Update controllers to handle filtering

### Phase 2: Mobile App Updates
1. Update AdSelectionScreen to accept adType parameter
2. Update Spin Wheel to show admin ads
3. Add interstitial ads to Reel Screen
4. Update RewardedAdService to filter by type

### Phase 3: Admin Panel Updates
1. Add type/usage fields to forms
2. Add filtering in admin views
3. Update statistics display

### Phase 4: Testing & Deployment
1. Test all ad types
2. Verify coin awarding
3. Check daily limits
4. Deploy to production

## Summary

This reorganization will:
✅ Separate ad types clearly
✅ Show correct ads in each screen
✅ Implement spin wheel refills with admin ads
✅ Add interstitial ads between reels
✅ Maintain backward compatibility
✅ Improve admin control over ads
✅ Better tracking and analytics
