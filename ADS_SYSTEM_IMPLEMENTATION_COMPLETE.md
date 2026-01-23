# Ad System Reorganization - Implementation Complete

## Backend Changes Completed ✅

### 1. RewardedAd Model Updated
**File**: `server/models/RewardedAd.js`

**Changes**:
- Added `adType` field with enum: ['watch-ads', 'spin-wheel', 'interstitial']
- Default value: 'watch-ads'
- Added indexes for faster queries:
  - `{ adType: 1 }`
  - `{ adType: 1, isActive: 1 }`

**Usage**:
```javascript
// Create watch ads
const watchAd = await RewardedAd.create({
  adNumber: 1,
  adType: 'watch-ads',
  // ... other fields
});

// Create spin wheel ads
const spinAd = await RewardedAd.create({
  adNumber: 2,
  adType: 'spin-wheel',
  // ... other fields
});

// Create interstitial ads
const interstitialAd = await RewardedAd.create({
  adNumber: 3,
  adType: 'interstitial',
  // ... other fields
});
```

### 2. VideoAd Model Updated
**File**: `server/models/VideoAd.js`

**Changes**:
- Added `usage` field with enum: ['watch-ads', 'spin-wheel']
- Default value: 'watch-ads'
- Added indexes for faster queries:
  - `{ usage: 1 }`
  - `{ usage: 1, isActive: 1 }`

**Usage**:
```javascript
// Create watch ads video
const watchVideo = await VideoAd.create({
  title: "Watch Ad Video",
  usage: 'watch-ads',
  // ... other fields
});

// Create spin wheel video
const spinVideo = await VideoAd.create({
  title: "Spin Wheel Video",
  usage: 'spin-wheel',
  // ... other fields
});
```

### 3. Admin Controller Updated
**File**: `server/controllers/adminController.js`

**Function**: `getAdsForApp()`

**Changes**:
- Added support for `type` query parameter
- Filters ads by adType if provided
- Returns adType in response

**API Usage**:
```
GET /api/rewarded-ads                    - Get all active ads
GET /api/rewarded-ads?type=watch-ads     - Get watch ads only
GET /api/rewarded-ads?type=spin-wheel    - Get spin wheel ads only
GET /api/rewarded-ads?type=interstitial  - Get interstitial ads only
```

**Example Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439011",
      "adNumber": 1,
      "title": "Watch Ad 1",
      "description": "Watch this ad to earn coins",
      "icon": "gift",
      "color": "#667eea",
      "adProvider": "admob",
      "rewardCoins": 10,
      "isActive": true,
      "adType": "watch-ads",
      "providerConfig": {}
    }
  ]
}
```

### 4. Video Ad Controller Updated
**File**: `server/controllers/videoAdController.js`

**Function**: `getVideoAdsForApp()`

**Changes**:
- Added support for `usage` query parameter
- Filters video ads by usage if provided
- Returns usage in response

**API Usage**:
```
GET /api/video-ads                       - Get all active video ads
GET /api/video-ads?usage=watch-ads       - Get watch ads video only
GET /api/video-ads?usage=spin-wheel      - Get spin wheel video only
```

**Example Response**:
```json
{
  "success": true,
  "data": [
    {
      "id": "507f1f77bcf86cd799439012",
      "title": "Video Ad 1",
      "description": "Watch this video to earn coins",
      "videoUrl": "https://s3.ap-southeast-1.wasabisys.com/showofforiginal/videos/...",
      "thumbnailUrl": "https://s3.ap-southeast-1.wasabisys.com/showofforiginal/images/...",
      "duration": 30,
      "rewardCoins": 10,
      "icon": "video",
      "color": "#667eea",
      "isActive": true,
      "usage": "watch-ads",
      "adType": "video"
    }
  ]
}
```

## Mobile App Changes Needed

### 1. Update RewardedAdService
**File**: `apps/lib/services/rewarded_ad_service.dart`

**Changes Needed**:
```dart
// Add type parameter to fetch methods
static Future<List<Map<String, dynamic>>> fetchRewardedAds({String? type}) async {
  try {
    String url = '${ApiService.baseUrl}/rewarded-ads';
    if (type != null) {
      url += '?type=$type';
    }
    
    final response = await http.get(Uri.parse(url));
    // ... rest of implementation
  }
}

// Add usage parameter to video ads fetch
static Future<List<Map<String, dynamic>>> fetchVideoAds({String? usage}) async {
  try {
    String url = '${ApiService.baseUrl}/video-ads';
    if (usage != null) {
      url += '?usage=$usage';
    }
    
    final response = await http.get(Uri.parse(url));
    // ... rest of implementation
  }
}
```

### 2. Update AdSelectionScreen
**File**: `apps/lib/ad_selection_screen.dart`

**Changes Needed**:
```dart
class AdSelectionScreen extends StatefulWidget {
  final String adType; // 'watch-ads', 'spin-wheel', 'interstitial'
  
  const AdSelectionScreen({
    super.key,
    this.adType = 'watch-ads',
  });
  
  // ... rest of implementation
}

// Update _loadAds to use adType
Future<void> _loadAds() async {
  try {
    // Fetch ads based on type
    final rewardedAds = await RewardedAdService.fetchRewardedAds(type: adType);
    final videoAds = await RewardedAdService.fetchVideoAds(usage: adType);
    
    // Combine and display
    _adOptions = [...rewardedAds, ...videoAds];
  }
}
```

### 3. Update Spin Wheel Screen
**File**: `apps/lib/spin_wheel_screen.dart`

**Changes Needed**:
```dart
void _showOutOfSpinsModal() {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('No Spins Left'),
      content: const Text('Watch ads to get more spins!'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdSelectionScreen(
                  adType: 'spin-wheel',  // ← Pass spin-wheel type
                ),
              ),
            );
          },
          child: const Text('Watch Ads'),
        ),
      ],
    ),
  );
}
```

### 4. Add Interstitial Ads to Reel Screen
**File**: `apps/lib/syt_reel_screen.dart`

**Changes Needed**:
```dart
int _reelCount = 0;

void _onReelSwipe() {
  _reelCount++;
  
  // Show interstitial ad every 3 reels
  if (_reelCount % 3 == 0) {
    AdMobService.showInterstitialAd();
  }
}
```

## Admin Panel Changes Needed

### 1. Update Rewarded Ads Form
Add `adType` field when creating/editing ads:
```html
<select name="adType">
  <option value="watch-ads">Watch Ads & Earn</option>
  <option value="spin-wheel">Spin Wheel Refill</option>
  <option value="interstitial">Interstitial (Between Reels)</option>
</select>
```

### 2. Update Video Ads Form
Add `usage` field when creating/editing ads:
```html
<select name="usage">
  <option value="watch-ads">Watch Ads & Earn</option>
  <option value="spin-wheel">Spin Wheel Refill</option>
</select>
```

### 3. Add Filtering in Admin Views
Filter ads by type/usage in admin dashboard:
```javascript
// In admin rewarded ads view
const type = req.query.type; // 'watch-ads', 'spin-wheel', 'interstitial'
const filter = type ? { adType: type } : {};
const ads = await RewardedAd.find(filter);
```

## Testing Checklist

### Backend API Testing
- [ ] GET `/api/rewarded-ads` returns all ads
- [ ] GET `/api/rewarded-ads?type=watch-ads` returns only watch ads
- [ ] GET `/api/rewarded-ads?type=spin-wheel` returns only spin wheel ads
- [ ] GET `/api/rewarded-ads?type=interstitial` returns only interstitial ads
- [ ] GET `/api/video-ads` returns all video ads
- [ ] GET `/api/video-ads?usage=watch-ads` returns only watch ads videos
- [ ] GET `/api/video-ads?usage=spin-wheel` returns only spin wheel videos

### Mobile App Testing
- [ ] Watch Ads & Earn shows only AdMob ads
- [ ] Spin Wheel shows admin panel ads when spins exhausted
- [ ] Interstitial ads show between reels
- [ ] Coins awarded correctly for each ad type
- [ ] Daily limits enforced for watch ads
- [ ] No daily limit for spin wheel ads

### Admin Panel Testing
- [ ] Can create ads with adType
- [ ] Can create video ads with usage
- [ ] Can filter ads by type/usage
- [ ] Statistics show per type/usage
- [ ] Video ads upload correctly

## Database Migration

If you have existing ads, run these commands to set default values:

```javascript
// Set all existing rewarded ads to 'watch-ads' type
db.rewardedads.updateMany({}, { $set: { adType: 'watch-ads' } });

// Set all existing video ads to 'watch-ads' usage
db.videoad.updateMany({}, { $set: { usage: 'watch-ads' } });
```

## Summary

✅ **Backend Changes Complete**:
- RewardedAd model updated with adType field
- VideoAd model updated with usage field
- Admin controller updated to filter by adType
- Video ad controller updated to filter by usage
- Indexes added for performance

⏳ **Mobile App Changes Needed**:
- Update RewardedAdService to support type/usage parameters
- Update AdSelectionScreen to accept adType parameter
- Update Spin Wheel to show admin ads
- Add interstitial ads to Reel Screen

⏳ **Admin Panel Changes Needed**:
- Add adType field to rewarded ads form
- Add usage field to video ads form
- Add filtering by type/usage in views

## Next Steps

1. **Restart server** to apply model changes
2. **Update mobile app** with new ad type support
3. **Update admin panel** forms and views
4. **Test all ad types** in each screen
5. **Deploy to production**

## API Documentation

### Rewarded Ads Endpoints
```
GET /api/rewarded-ads                    - Get all active ads
GET /api/rewarded-ads?type=watch-ads     - Get watch ads
GET /api/rewarded-ads?type=spin-wheel    - Get spin wheel ads
GET /api/rewarded-ads?type=interstitial  - Get interstitial ads
POST /api/rewarded-ads/:adNumber/click   - Track click
POST /api/rewarded-ads/:adNumber/conversion - Track conversion
```

### Video Ads Endpoints
```
GET /api/video-ads                       - Get all active video ads
GET /api/video-ads?usage=watch-ads       - Get watch ads videos
GET /api/video-ads?usage=spin-wheel      - Get spin wheel videos
POST /api/video-ads/:id/view             - Track view
POST /api/video-ads/:id/complete         - Track completion & award coins
```

### Coin Endpoints
```
POST /api/coins/watch-ad                 - Award coins for watching ad
POST /api/coins/spin-wheel               - Spin wheel and award coins
```

Everything is ready for the mobile app and admin panel updates!
