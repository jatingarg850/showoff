# Ad System Implementation Guide - Complete

## Overview
The ad system has been successfully separated into different types to serve different purposes:
- **Watch Ads & Earn**: Shows 5 AdMob rewarded ads (type='watch-ads')
- **Spin Wheel Refill**: Shows admin panel ads only (type='spin-wheel')
- **Interstitial Ads**: Shows between reels (type='interstitial')
- **Video Ads**: Can be used in any screen based on usage type

## Backend Implementation ✅

### 1. Database Models

#### RewardedAd Model (`server/models/RewardedAd.js`)
- **New Field**: `adType` (enum: 'watch-ads', 'spin-wheel', 'interstitial')
- **Default**: 'watch-ads'
- **Indexes**: Added for faster queries on adType

```javascript
adType: {
  type: String,
  enum: ['watch-ads', 'spin-wheel', 'interstitial'],
  default: 'watch-ads',
}
```

#### VideoAd Model (`server/models/VideoAd.js`)
- **New Field**: `usage` (enum: 'watch-ads', 'spin-wheel')
- **Default**: 'watch-ads'
- **Indexes**: Added for faster queries on usage

```javascript
usage: {
  type: String,
  enum: ['watch-ads', 'spin-wheel'],
  default: 'watch-ads',
}
```

### 2. API Endpoints

#### Get Rewarded Ads with Type Filtering
```
GET /api/rewarded-ads?type=watch-ads
GET /api/rewarded-ads?type=spin-wheel
GET /api/rewarded-ads?type=interstitial
```

**Controller**: `server/controllers/adminController.js` - `getAdsForApp()`
- Filters ads by adType
- Updates impressions and tracking
- Returns ads formatted for mobile app

#### Get Video Ads with Usage Filtering
```
GET /api/video-ads?usage=watch-ads
GET /api/video-ads?usage=spin-wheel
```

**Controller**: `server/controllers/videoAdController.js` - `getVideoAdsForApp()`
- Filters ads by usage
- Updates impressions and tracking
- Returns ads formatted for mobile app

### 3. Admin Panel Endpoints

#### Create Rewarded Ad
```
POST /admin/rewarded-ads/create
Body: {
  adNumber: 1,
  title: "Ad Title",
  description: "Ad Description",
  adLink: "https://...",
  adProvider: "admob",
  rewardCoins: 10,
  icon: "gift",
  color: "#667eea",
  adType: "watch-ads",  // NEW FIELD
  rotationOrder: 0,
  isActive: true
}
```

#### Update Rewarded Ad
```
POST /admin/rewarded-ads/:id/update
Body: {
  title: "Updated Title",
  adType: "spin-wheel",  // Can change type
  ...other fields
}
```

#### Create Video Ad
```
POST /admin/video-ads/create
Body (multipart/form-data):
  - video: <file>
  - thumbnail: <file>
  - title: "Video Title"
  - description: "Description"
  - duration: 30
  - rewardCoins: 10
  - icon: "video"
  - color: "#667eea"
  - usage: "watch-ads"  // NEW FIELD
  - rotationOrder: 0
  - isActive: true
```

#### Update Video Ad
```
POST /admin/video-ads/:id/update
Body (multipart/form-data):
  - title: "Updated Title"
  - usage: "spin-wheel"  // Can change usage
  ...other fields
```

## Mobile App Implementation ✅

### 1. Ad Selection Screen (`apps/lib/ad_selection_screen.dart`)
- **New Parameter**: `adType` (String)
- **Default**: 'watch-ads'
- **Usage**: Determines which ads to load

```dart
const AdSelectionScreen({
  super.key,
  this.adType = 'watch-ads'  // NEW PARAMETER
});
```

### 2. Ad Loading Logic
```dart
if (widget.adType == 'watch-ads') {
  // Fetch AdMob rewarded ads (type=watch-ads)
  final rewardedAds = await RewardedAdService.fetchRewardedAds(
    type: 'watch-ads',
  );
  // Fetch video ads for watch-ads
  final videoAds = await RewardedAdService.fetchVideoAds(
    usage: 'watch-ads',
  );
  ads = [...rewardedAds, ...videoAds];
} else if (widget.adType == 'spin-wheel') {
  // Fetch ONLY admin panel ads (type=spin-wheel)
  final adminAds = await RewardedAdService.fetchRewardedAds(
    type: 'spin-wheel',
  );
  ads = adminAds;
}
```

### 3. Rewarded Ad Service (`apps/lib/services/rewarded_ad_service.dart`)
- **New Methods**:
  - `fetchRewardedAds({String? type})` - Fetch with type filter
  - `fetchVideoAds({String? usage})` - Fetch with usage filter

```dart
static Future<List<Map<String, dynamic>>> fetchRewardedAds({
  String? type,
}) async {
  String url = '${ApiService.baseUrl}/rewarded-ads';
  if (type != null) {
    url += '?type=$type';
  }
  // ... fetch and return
}
```

### 4. Navigation Updates

#### Spin Wheel Screen (`apps/lib/spin_wheel_screen.dart`)
```dart
// When showing ads after spin wheel
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdSelectionScreen(
      adType: 'spin-wheel',  // Pass spin-wheel type
    ),
  ),
);
```

#### Wallet Screen (`apps/lib/wallet_screen.dart`)
```dart
// When showing ads from Watch Ads & Earn
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const AdSelectionScreen(
      adType: 'watch-ads',  // Pass watch-ads type
    ),
  ),
);
```

## Setup Instructions

### 1. Run Database Migration
```bash
node MIGRATE_AD_TYPES.js
```

This script will:
- Set default `adType='watch-ads'` for all existing rewarded ads
- Set default `usage='watch-ads'` for all existing video ads
- Display migration summary

### 2. Create Admin Panel Ads

#### Create Watch Ads (AdMob)
Use the admin panel to create 5 rewarded ads with:
- `adType: 'watch-ads'`
- `adProvider: 'admob'`
- Ad numbers 1-5

#### Create Spin Wheel Ads (Admin Panel)
Use the admin panel to create rewarded ads with:
- `adType: 'spin-wheel'`
- `adProvider: 'custom'` or 'third-party'
- Any ad numbers (6+)

#### Create Video Ads
Upload video ads with:
- `usage: 'watch-ads'` for Watch Ads & Earn screen
- `usage: 'spin-wheel'` for Spin Wheel refill

### 3. Test the System

#### Test Watch Ads Endpoint
```bash
curl "http://localhost:3000/api/rewarded-ads?type=watch-ads"
```

Expected: Returns only ads with `adType='watch-ads'`

#### Test Spin Wheel Ads Endpoint
```bash
curl "http://localhost:3000/api/rewarded-ads?type=spin-wheel"
```

Expected: Returns only ads with `adType='spin-wheel'`

#### Test Video Ads Endpoints
```bash
curl "http://localhost:3000/api/video-ads?usage=watch-ads"
curl "http://localhost:3000/api/video-ads?usage=spin-wheel"
```

### 4. Test Mobile App

#### Watch Ads & Earn Screen
1. Open Wallet screen
2. Click "Watch Ads" button
3. Should show 5 AdMob ads + any video ads with `usage='watch-ads'`

#### Spin Wheel Refill
1. Open Spin Wheel screen
2. Use daily spin
3. When out of spins, click "Watch ads"
4. Should show ONLY admin panel ads (type='spin-wheel')
5. Should NOT show the 5 AdMob ads

## API Response Examples

### Get Watch Ads
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "adNumber": 1,
      "title": "Quick Video Ad",
      "description": "Watch a 15-30 second video ad",
      "rewardCoins": 5,
      "icon": "play-circle",
      "color": "#701CF5",
      "adProvider": "admob",
      "adType": "watch-ads",
      "isActive": true
    },
    {
      "id": "...",
      "title": "Video Ad Title",
      "description": "Watch this video to earn coins",
      "videoUrl": "https://...",
      "thumbnailUrl": "https://...",
      "duration": 30,
      "rewardCoins": 10,
      "icon": "video",
      "color": "#667eea",
      "usage": "watch-ads",
      "adType": "video",
      "isActive": true
    }
  ]
}
```

### Get Spin Wheel Ads
```json
{
  "success": true,
  "data": [
    {
      "id": "...",
      "adNumber": 6,
      "title": "Admin Panel Ad",
      "description": "Custom admin ad",
      "rewardCoins": 20,
      "icon": "gift",
      "color": "#FF6B35",
      "adProvider": "custom",
      "adType": "spin-wheel",
      "isActive": true
    }
  ]
}
```

## Troubleshooting

### Issue: Ads not showing in Watch Ads screen
**Solution**: 
1. Check that ads have `adType='watch-ads'`
2. Verify ads have `isActive=true`
3. Check API endpoint: `GET /api/rewarded-ads?type=watch-ads`

### Issue: Spin Wheel showing wrong ads
**Solution**:
1. Check that ads have `adType='spin-wheel'`
2. Verify mobile app is passing `adType='spin-wheel'` parameter
3. Check API endpoint: `GET /api/rewarded-ads?type=spin-wheel`

### Issue: Video ads not showing
**Solution**:
1. Check that video ads have correct `usage` field
2. Verify video files are uploaded to Wasabi S3
3. Check API endpoint: `GET /api/video-ads?usage=watch-ads`

## Summary

✅ **Backend**: Complete with type filtering endpoints
✅ **Mobile App**: Updated to pass adType parameter
✅ **Admin Panel**: New endpoints to create/update ads with types
✅ **Database**: Models updated with adType and usage fields
✅ **Migration**: Script to set defaults for existing ads

The ad system is now fully separated and ready to use!
