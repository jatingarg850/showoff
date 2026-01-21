# Watch Ads & Earn - 5 Ad Types Implementation

## Overview
Implemented a complete "Watch Ads & Earn" system with 5 different ad types offering varying coin rewards from 5 to 25 coins.

## Ad Types

### 1. Quick Video Ad (5 coins)
- **Icon**: Play Circle
- **Color**: Purple (#701CF5)
- **Description**: Watch a 15-30 second video ad
- **Provider**: AdMob
- **Reward**: 5 coins
- **Use Case**: Quick, short video advertisements

### 2. Product Demo (10 coins)
- **Icon**: Video
- **Color**: Orange (#FF6B35)
- **Description**: Watch product demonstration video
- **Provider**: AdMob
- **Reward**: 10 coins
- **Use Case**: Product showcase and demo videos

### 3. Interactive Quiz (15 coins)
- **Icon**: Hand Pointer
- **Color**: Blue (#4FACFE)
- **Description**: Answer quick questions & earn
- **Provider**: Meta
- **Reward**: 15 coins
- **Use Case**: Interactive engagement with higher rewards

### 4. Survey Rewards (20 coins)
- **Icon**: Clipboard
- **Color**: Green (#43E97B)
- **Description**: Complete a quick survey
- **Provider**: Custom
- **Reward**: 20 coins
- **Use Case**: User feedback and survey collection

### 5. Premium Offer (25 coins)
- **Icon**: Star
- **Color**: Yellow (#FBBF24)
- **Description**: Exclusive premium content
- **Provider**: Third-party
- **Reward**: 25 coins
- **Use Case**: Premium/exclusive content with highest reward

## Files Modified

### Frontend (Flutter)
1. **apps/lib/services/rewarded_ad_service.dart**
   - Updated `getDefaultAds()` method with 5 new ad types
   - Coin rewards: 5, 10, 15, 20, 25
   - Each ad has unique title, description, icon, and color

2. **apps/lib/ad_selection_screen.dart** (Already implemented)
   - Displays all 5 ads in a beautiful card layout
   - Shows coin rewards prominently
   - Supports watching ads and earning coins
   - Displays success dialog after watching

### Backend (Node.js)
1. **server/scripts/seed-rewarded-ads.js**
   - Updated seed script with 5 new ad types
   - Coin rewards: 5, 10, 15, 20, 25
   - Includes provider configurations for each ad type
   - Run with: `node server/scripts/seed-rewarded-ads.js`

2. **server/models/RewardedAd.js** (Already supports flexible rewards)
   - `rewardCoins` field supports 1-10000 coins
   - Flexible reward system already in place

## How It Works

### User Flow
1. User navigates to "Watch Ads & Earn" screen
2. Sees 5 different ad options with coin rewards
3. Selects an ad to watch
4. AdMob/provider ad is displayed
5. After watching, coins are awarded
6. Success dialog shows coins earned
7. Coins are added to user's wallet

### Backend Flow
1. Frontend fetches ads from `/api/rewarded-ads`
2. If no ads available, uses default ads (5 types)
3. User watches ad via AdMob/provider
4. Frontend calls `/api/rewarded-ads/:adNumber/click` to track
5. After completion, calls `/api/rewarded-ads/:adNumber/conversion`
6. Frontend calls `ApiService.watchAd(adNumber)` to award coins
7. Backend validates and awards coins to user

## Coin Reward Distribution

| Ad Type | Coins | Difficulty | Time |
|---------|-------|-----------|------|
| Quick Video Ad | 5 | Easy | 15-30s |
| Product Demo | 10 | Easy | 30-60s |
| Interactive Quiz | 15 | Medium | 1-2 min |
| Survey Rewards | 20 | Medium | 2-3 min |
| Premium Offer | 25 | Hard | 3-5 min |

## Setup Instructions

### 1. Seed the Database
```bash
cd server
node scripts/seed-rewarded-ads.js
```

This will create 5 rewarded ads in the database with the new coin amounts.

### 2. Verify in Admin Panel
- Navigate to Admin Panel → Rewarded Ads
- Should see all 5 ads with their respective coin rewards
- Can edit rewards or add more ads as needed

### 3. Test in App
- Open the app and navigate to "Watch Ads & Earn"
- Should see all 5 ad types
- Click on any ad to watch and earn coins
- Verify coins are added to wallet

## API Endpoints

### Get Rewarded Ads
```
GET /api/rewarded-ads
```
Returns list of active rewarded ads with coin rewards.

### Track Ad Click
```
POST /api/rewarded-ads/:adNumber/click
```
Tracks when user clicks on an ad.

### Track Ad Conversion
```
POST /api/rewarded-ads/:adNumber/conversion
```
Tracks when user completes watching an ad.

### Watch Ad (Award Coins)
```
POST /api/watch-ad/:adNumber
```
Awards coins to user after watching ad.

## Admin Management

### Edit Ad Rewards
1. Go to Admin Panel → Rewarded Ads
2. Click on an ad to edit
3. Change the `rewardCoins` value
4. Save changes
5. Changes take effect immediately

### Add New Ad Type
1. Go to Admin Panel → Rewarded Ads
2. Click "Create New Ad"
3. Fill in details:
   - Title
   - Description
   - Icon name
   - Color (hex code)
   - Reward coins (5-25 recommended)
   - Provider (admob, meta, custom, third-party)
4. Save

### Deactivate Ad
1. Go to Admin Panel → Rewarded Ads
2. Toggle the "Active" status
3. Ad will no longer appear to users

## Features

✅ 5 different ad types with unique rewards
✅ Flexible coin rewards (5-25 coins)
✅ Beautiful card-based UI
✅ Real-time coin tracking
✅ Success notifications
✅ Admin management panel
✅ Multiple ad providers support
✅ Ad impression/click/conversion tracking
✅ Responsive design
✅ Error handling

## Customization

### Change Coin Amounts
Edit `server/scripts/seed-rewarded-ads.js` and update `rewardCoins` values, then re-run the seed script.

### Change Ad Titles/Descriptions
Edit `apps/lib/services/rewarded_ad_service.dart` in the `getDefaultAds()` method.

### Add More Ad Types
1. Add new entry to `initialAds` array in seed script
2. Update `adNumber` (6, 7, etc.)
3. Add corresponding entry in Flutter default ads
4. Run seed script to create in database

### Change Colors/Icons
Edit the `color` and `icon` fields in either the seed script or Flutter service.

## Testing Checklist

- [ ] Seed script runs successfully
- [ ] All 5 ads appear in admin panel
- [ ] All 5 ads appear in app's "Watch Ads & Earn" screen
- [ ] Coin rewards display correctly (5, 10, 15, 20, 25)
- [ ] Can watch an ad and earn coins
- [ ] Success dialog shows correct coin amount
- [ ] Coins are added to user's wallet
- [ ] Admin can edit ad rewards
- [ ] Admin can deactivate ads
- [ ] Deactivated ads don't appear in app

## Notes

- Default ads are used as fallback if database fetch fails
- Coin rewards are flexible and can be changed anytime
- Each ad type has a unique provider for diversity
- Ad impressions, clicks, and conversions are tracked
- System supports unlimited ad types (not limited to 5)
