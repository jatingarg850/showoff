# Watch Ads & Earn - Implementation Details

## Summary
Successfully implemented 5 types of rewarded ads with coin rewards ranging from 5 to 25 coins. Users can watch different ad types and earn varying amounts of coins based on the ad complexity and engagement level.

## Changes Made

### 1. Flutter Frontend (`apps/lib/services/rewarded_ad_service.dart`)

**Updated `getDefaultAds()` method:**

```dart
static List<Map<String, dynamic>> getDefaultAds() {
  return [
    {
      'id': '1',
      'adNumber': 1,
      'title': 'Quick Video Ad',
      'description': 'Watch a 15-30 second video ad',
      'rewardCoins': 5,
      'icon': 'play-circle',
      'color': '#701CF5',
      'adProvider': 'admob',
      'isActive': true,
    },
    {
      'id': '2',
      'adNumber': 2,
      'title': 'Product Demo',
      'description': 'Watch product demonstration video',
      'rewardCoins': 10,
      'icon': 'video',
      'color': '#FF6B35',
      'adProvider': 'admob',
      'isActive': true,
    },
    {
      'id': '3',
      'adNumber': 3,
      'title': 'Interactive Quiz',
      'description': 'Answer quick questions & earn',
      'rewardCoins': 15,
      'icon': 'hand-pointer',
      'color': '#4FACFE',
      'adProvider': 'meta',
      'isActive': true,
    },
    {
      'id': '4',
      'adNumber': 4,
      'title': 'Survey Rewards',
      'description': 'Complete a quick survey',
      'rewardCoins': 20,
      'icon': 'clipboard',
      'color': '#43E97B',
      'adProvider': 'custom',
      'isActive': true,
    },
    {
      'id': '5',
      'adNumber': 5,
      'title': 'Premium Offer',
      'description': 'Exclusive premium content',
      'rewardCoins': 25,
      'icon': 'star',
      'color': '#FBBF24',
      'adProvider': 'third-party',
      'isActive': true,
    },
  ];
}
```

**Key Changes:**
- Ad 1: 5 coins (was 10)
- Ad 2: 10 coins (unchanged)
- Ad 3: 15 coins (unchanged)
- Ad 4: 20 coins (unchanged)
- Ad 5: 25 coins (unchanged)
- Updated titles and descriptions for clarity
- Updated colors for better visual distinction

### 2. Backend Seed Script (`server/scripts/seed-rewarded-ads.js`)

**Updated `initialAds` array:**

```javascript
const initialAds = [
  {
    adNumber: 1,
    title: 'Quick Video Ad',
    description: 'Watch a 15-30 second video ad',
    icon: 'play-circle',
    color: '#701CF5',
    adLink: 'https://example.com/ad1',
    adProvider: 'admob',
    rewardCoins: 5,
    isActive: true,
    rotationOrder: 1,
    providerConfig: { /* ... */ }
  },
  // ... 4 more ads with coins: 10, 15, 20, 25
];
```

**Key Changes:**
- Ad 1: 5 coins (was 10)
- Updated all titles and descriptions
- Updated colors to match Flutter
- Maintained provider diversity (admob, admob, meta, custom, third-party)

## Ad Type Details

### Ad 1: Quick Video Ad (5 coins)
- **Purpose**: Quick engagement with minimal time commitment
- **Duration**: 15-30 seconds
- **Provider**: AdMob
- **Icon**: Play Circle (🎬)
- **Color**: Purple (#701CF5)
- **Use Case**: Users who want quick coin rewards

### Ad 2: Product Demo (10 coins)
- **Purpose**: Product showcase and demonstration
- **Duration**: 30-60 seconds
- **Provider**: AdMob
- **Icon**: Video (📹)
- **Color**: Orange (#FF6B35)
- **Use Case**: Users interested in product information

### Ad 3: Interactive Quiz (15 coins)
- **Purpose**: Interactive engagement with questions
- **Duration**: 1-2 minutes
- **Provider**: Meta
- **Icon**: Hand Pointer (👆)
- **Color**: Blue (#4FACFE)
- **Use Case**: Users who enjoy interactive content

### Ad 4: Survey Rewards (20 coins)
- **Purpose**: Collect user feedback and opinions
- **Duration**: 2-3 minutes
- **Provider**: Custom
- **Icon**: Clipboard (📋)
- **Color**: Green (#43E97B)
- **Use Case**: Users willing to provide feedback

### Ad 5: Premium Offer (25 coins)
- **Purpose**: Exclusive premium content
- **Duration**: 3-5 minutes
- **Provider**: Third-party
- **Icon**: Star (⭐)
- **Color**: Yellow (#FBBF24)
- **Use Case**: Users seeking maximum rewards

## How It Works

### User Perspective
1. User opens app and navigates to "Watch Ads & Earn"
2. Sees 5 ad options with coin rewards displayed
3. Selects an ad based on reward amount and time availability
4. Watches the ad completely
5. Receives success notification with coins earned
6. Coins are added to wallet immediately

### Technical Flow
1. **Load Ads**: Frontend calls `GET /api/rewarded-ads`
2. **Display**: Shows 5 ads with coin amounts
3. **Watch**: User clicks ad, AdMob/provider ad displays
4. **Track**: Frontend tracks click and conversion
5. **Award**: Backend validates and awards coins
6. **Confirm**: Success dialog shows coins earned

### Database Flow
1. Seed script creates 5 ads in MongoDB
2. Each ad has unique properties (title, description, coins, provider)
3. Admin can edit coin amounts anytime
4. Changes take effect immediately
5. Ads are fetched fresh on each app load

## API Endpoints Used

### Get Rewarded Ads
```
GET /api/rewarded-ads
Response: { success: true, data: [ad1, ad2, ad3, ad4, ad5] }
```

### Track Ad Click
```
POST /api/rewarded-ads/:adNumber/click
Response: { success: true }
```

### Track Ad Conversion
```
POST /api/rewarded-ads/:adNumber/conversion
Response: { success: true }
```

### Award Coins
```
POST /api/watch-ad/:adNumber
Response: { success: true, coinsEarned: 5-25 }
```

## Admin Management

### View All Ads
- Admin Panel → Rewarded Ads
- Shows all 5 ads with coin amounts

### Edit Ad Rewards
1. Click on ad
2. Change `rewardCoins` value
3. Save
4. Changes take effect immediately

### Add New Ad Type
1. Click "Create New Ad"
2. Fill in details
3. Set coin reward (5-25 recommended)
4. Save

### Deactivate Ad
- Toggle "Active" status
- Ad disappears from user view

## Coin Distribution Strategy

| Tier | Coins | Time | Difficulty | Target User |
|------|-------|------|-----------|------------|
| Entry | 5 | 15-30s | Easy | New users, quick earners |
| Basic | 10 | 30-60s | Easy | Regular users |
| Medium | 15 | 1-2 min | Medium | Engaged users |
| High | 20 | 2-3 min | Medium | Committed users |
| Premium | 25 | 3-5 min | Hard | Dedicated users |

## Monetization Benefits

1. **User Engagement**: 5 different ad types keep users engaged
2. **Flexible Rewards**: Users can choose based on time availability
3. **Revenue Scaling**: Higher rewards for longer engagement
4. **Provider Diversity**: Multiple ad providers reduce dependency
5. **Admin Control**: Easy to adjust rewards based on performance

## Testing Checklist

- [ ] Seed script runs without errors
- [ ] All 5 ads appear in database
- [ ] All 5 ads appear in admin panel
- [ ] All 5 ads appear in app's "Watch Ads & Earn" screen
- [ ] Coin amounts display correctly (5, 10, 15, 20, 25)
- [ ] Can watch each ad type
- [ ] Coins are awarded correctly
- [ ] Success dialog shows correct amount
- [ ] Admin can edit coin amounts
- [ ] Changes take effect immediately
- [ ] Deactivated ads don't appear in app
- [ ] Tracking (click/conversion) works

## Deployment Steps

1. **Update Code**
   - Pull latest changes
   - Verify files are updated

2. **Seed Database**
   ```bash
   cd server
   node scripts/seed-rewarded-ads.js
   ```

3. **Restart Server**
   ```bash
   npm start
   ```

4. **Test in App**
   - Open app
   - Navigate to "Watch Ads & Earn"
   - Verify all 5 ads appear
   - Test watching an ad

5. **Monitor**
   - Check admin panel for ad stats
   - Monitor user engagement
   - Adjust rewards if needed

## Customization Options

### Change Coin Amounts
Edit `rewardCoins` in seed script or admin panel.

### Change Ad Titles/Descriptions
Edit in `rewarded_ad_service.dart` or admin panel.

### Change Colors/Icons
Edit `color` and `icon` fields in seed script or admin panel.

### Add More Ad Types
1. Add new entry to `initialAds` array
2. Update `adNumber` (6, 7, etc.)
3. Run seed script

### Change Ad Providers
Edit `adProvider` field (admob, meta, custom, third-party).

## Performance Considerations

- Ads are fetched fresh on each load (no caching)
- Coin awards are validated server-side
- Tracking is asynchronous (doesn't block UI)
- Database queries are indexed for speed
- Admin changes take effect immediately

## Security

- All coin awards validated server-side
- User authentication required
- Admin-only access to management
- Fraud detection on unusual patterns
- Transaction logging for audit trail

## Future Enhancements

1. **A/B Testing**: Test different coin amounts
2. **Personalization**: Show ads based on user preferences
3. **Scheduling**: Show different ads at different times
4. **Limits**: Daily/weekly coin earning limits
5. **Bonuses**: Bonus coins for watching multiple ads
6. **Streaks**: Bonus for consecutive days
7. **Leaderboards**: Top earners from ads
8. **Analytics**: Detailed ad performance metrics
