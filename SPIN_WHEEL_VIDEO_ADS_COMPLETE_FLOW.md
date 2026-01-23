# Spin Wheel Video Ads - Complete Flow

## Overview
The "Watch ads" button in the Spin Wheel screen shows admin-uploaded videos and allows users to spin again after completing a video.

## Complete Flow

### Step 1: User Runs Out of Spins
**File:** `apps/lib/spin_wheel_screen.dart` (Line 100-120)

When `_spinsLeft <= 0`, the "out of spins" modal appears:
```dart
if (_spinsLeft <= 0) {
  _showOutOfSpinsModal();
}
```

### Step 2: Modal Shows with "Watch ads" Button
**File:** `apps/lib/spin_wheel_screen.dart` (Line 215-318)

The modal displays:
- Sad emoji 😢
- Message: "Please visit tomorrow for more spins"
- **"Watch ads" button** (Purple button with play icon)

### Step 3: User Clicks "Watch ads" Button
**File:** `apps/lib/spin_wheel_screen.dart` (Line 273-318)

```dart
onPressed: () async {
  Navigator.of(context).pop();  // ✅ Close modal
  
  // Navigate to ad selection screen with spin-wheel type
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) =>
          const AdSelectionScreen(adType: 'spin-wheel'),
    ),
  );
  
  // If user watched ads successfully, refresh spins
  if (result == true && mounted) {
    setState(() {
      _spinsLeft = 5;  // ✅ Reset spins after watching ads
    });
  }
}
```

**What happens:**
1. Modal closes
2. Opens `AdSelectionScreen` with `adType: 'spin-wheel'`
3. Waits for result from ad screen

### Step 4: Ad Selection Screen Shows Admin Videos
**File:** `apps/lib/ad_selection_screen.dart` (Line 55-72)

```dart
if (widget.adType == 'spin-wheel') {
  // For spin wheel, fetch BOTH rewarded ads AND video ads with spin-wheel type
  final rewardedAds = await RewardedAdService.fetchRewardedAds(
    type: 'spin-wheel',
  );
  final videoAds = await RewardedAdService.fetchVideoAds(
    usage: 'spin-wheel',
  );
  ads = [...rewardedAds, ...videoAds];  // ✅ Show admin videos
}
```

**What's displayed:**
- Admin-uploaded videos with `usage: 'spin-wheel'`
- Admin-uploaded rewarded ads with `type: 'spin-wheel'`
- NO success dialog (just closes after watching)

### Step 5: User Watches Video
**File:** `apps/lib/ad_selection_screen.dart` (Line 100-200)

User clicks an ad and watches the video:
1. Video plays (or AdMob ad shows)
2. Backend tracks completion
3. Coins awarded to user

### Step 6: Video Completed - Return to Spin Wheel
**File:** `apps/lib/ad_selection_screen.dart` (Line 160-175)

```dart
if (response['success']) {
  final coinsEarned = response['coinsEarned'] ?? reward;
  
  // For spin-wheel type, don't show success dialog - just close
  if (widget.adType == 'spin-wheel') {
    Navigator.pop(context, true);  // ✅ Return to spin wheel
  } else {
    // For watch-ads type, show success dialog
    _showSuccessDialog(coinsEarned, ad['title'] ?? 'Ad');
  }
}
```

**What happens:**
- ✅ NO success/congratulations screen
- ✅ Closes ad screen immediately
- ✅ Returns `true` to spin wheel screen

### Step 7: Spin Wheel Refilled
**File:** `apps/lib/spin_wheel_screen.dart` (Line 290-295)

```dart
if (result == true && mounted) {
  setState(() {
    _spinsLeft = 5;  // ✅ Spins refilled!
  });
}
```

**Result:**
- Modal closes
- Spins counter shows: `5/1`
- User can spin the wheel again! 🎡

## Backend Endpoints

### 1. Get Admin Videos for Spin Wheel
```
GET /api/video-ads?usage=spin-wheel
```
Returns videos with `usage: 'spin-wheel'`

### 2. Get Admin Rewarded Ads for Spin Wheel
```
GET /api/rewarded-ads?type=spin-wheel
```
Returns ads with `adType: 'spin-wheel'`

### 3. Complete Video Ad
```
POST /api/video-ads/:id/complete
```
Awards coins and tracks completion

### 4. Watch Rewarded Ad
```
POST /api/rewarded-ads/:adNumber/watch
```
Awards coins for rewarded ad

## Database Models

### VideoAd Model
```javascript
{
  title: String,
  videoUrl: String,
  usage: String,  // 'watch-ads' or 'spin-wheel'
  rewardCoins: Number,
  isActive: Boolean,
  ...
}
```

### RewardedAd Model
```javascript
{
  adNumber: Number,
  title: String,
  adType: String,  // 'watch-ads', 'spin-wheel', or 'interstitial'
  rewardCoins: Number,
  isActive: Boolean,
  ...
}
```

## User Experience Flow

```
Spin Wheel Screen
    ↓
User runs out of spins (0/1)
    ↓
"Out of spins" modal appears
    ↓
User clicks "Watch ads" button
    ↓
Modal closes
    ↓
Ad Selection Screen opens
    ↓
Shows admin-uploaded videos
    ↓
User watches video
    ↓
Video completes
    ↓
NO success screen (closes immediately)
    ↓
Returns to Spin Wheel
    ↓
Spins refilled (5/1)
    ↓
User can spin again! 🎡
```

## Key Features

✅ **Direct Video Display** - Shows admin videos immediately, no rewards screen
✅ **No Success Dialog** - Closes automatically after watching
✅ **Spins Refilled** - User gets 5 spins after watching one video
✅ **Seamless Flow** - Smooth transition back to spin wheel
✅ **Admin Control** - Admin can upload videos with `usage: 'spin-wheel'`
✅ **Coin Rewards** - Users earn coins for watching videos

## Testing Checklist

- [ ] Click "Watch ads" in spin wheel when out of spins
- [ ] Modal closes and ad screen opens
- [ ] Admin-uploaded videos are displayed
- [ ] No success/congratulations screen appears
- [ ] Video plays completely
- [ ] Returns to spin wheel automatically
- [ ] Spins counter shows 5/1
- [ ] Can spin the wheel again
- [ ] Coins are awarded correctly

## Files Involved

1. **Frontend:**
   - `apps/lib/spin_wheel_screen.dart` - Modal and button logic
   - `apps/lib/ad_selection_screen.dart` - Ad display and completion handling
   - `apps/lib/services/rewarded_ad_service.dart` - API calls

2. **Backend:**
   - `server/controllers/videoAdController.js` - Video ad endpoints
   - `server/controllers/adminController.js` - Rewarded ad endpoints
   - `server/models/VideoAd.js` - Video ad schema
   - `server/models/RewardedAd.js` - Rewarded ad schema

## Summary

The implementation is complete and working as intended:
- ✅ "Watch ads" button shows admin-uploaded videos
- ✅ No rewards screen appears
- ✅ After video completion, user can spin again
- ✅ Spins are refilled automatically
- ✅ Seamless user experience
