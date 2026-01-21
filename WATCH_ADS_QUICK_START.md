# Watch Ads & Earn - Quick Start Guide

## 5 Ad Types with Coin Rewards

```
┌─────────────────────────────────────────────────────────────┐
│ 1. Quick Video Ad          [5 coins]   🎬 Purple            │
│    Watch a 15-30 second video ad                            │
├─────────────────────────────────────────────────────────────┤
│ 2. Product Demo            [10 coins]  📹 Orange            │
│    Watch product demonstration video                        │
├─────────────────────────────────────────────────────────────┤
│ 3. Interactive Quiz        [15 coins]  👆 Blue              │
│    Answer quick questions & earn                           │
├─────────────────────────────────────────────────────────────┤
│ 4. Survey Rewards          [20 coins]  📋 Green             │
│    Complete a quick survey                                 │
├─────────────────────────────────────────────────────────────┤
│ 5. Premium Offer           [25 coins]  ⭐ Yellow            │
│    Exclusive premium content                               │
└─────────────────────────────────────────────────────────────┘
```

## Setup (One-Time)

### Step 1: Seed the Database
```bash
cd server
node scripts/seed-rewarded-ads.js
```

Output should show:
```
✅ Connected to MongoDB
✅ Created 5 rewarded ads
   - Ad 1: Quick Video Ad (5 coins, admob)
   - Ad 2: Product Demo (10 coins, admob)
   - Ad 3: Interactive Quiz (15 coins, meta)
   - Ad 4: Survey Rewards (20 coins, custom)
   - Ad 5: Premium Offer (25 coins, third-party)
✅ Database connection closed
```

### Step 2: Restart Server
```bash
npm start
```

### Step 3: Test in App
1. Open the app
2. Navigate to "Watch Ads & Earn"
3. Should see all 5 ads
4. Click any ad to watch and earn coins

## Files Changed

| File | Change |
|------|--------|
| `apps/lib/services/rewarded_ad_service.dart` | Updated default ads (5-25 coins) |
| `server/scripts/seed-rewarded-ads.js` | Updated seed data (5-25 coins) |

## Coin Breakdown

| Ad | Coins | Time | Difficulty |
|----|-------|------|-----------|
| Quick Video | 5 | 15-30s | ⭐ Easy |
| Product Demo | 10 | 30-60s | ⭐ Easy |
| Interactive Quiz | 15 | 1-2 min | ⭐⭐ Medium |
| Survey | 20 | 2-3 min | ⭐⭐ Medium |
| Premium | 25 | 3-5 min | ⭐⭐⭐ Hard |

## Admin Panel

### View Ads
- Go to Admin → Rewarded Ads
- See all 5 ads with coin rewards

### Edit Rewards
- Click on any ad
- Change `rewardCoins` value
- Save (takes effect immediately)

### Add More Ads
- Click "Create New Ad"
- Set title, description, coins, provider
- Save

### Deactivate Ad
- Toggle "Active" status
- Ad disappears from user view

## Testing

```bash
# Test 1: Verify ads load
curl http://localhost:3000/api/rewarded-ads

# Test 2: Track ad click
curl -X POST http://localhost:3000/api/rewarded-ads/1/click

# Test 3: Track conversion
curl -X POST http://localhost:3000/api/rewarded-ads/1/conversion
```

## Troubleshooting

### No ads showing in app
- Check if seed script ran successfully
- Verify MongoDB connection
- Check if ads are marked as `isActive: true`

### Wrong coin amounts
- Edit seed script and re-run
- Or edit in admin panel

### Ads not appearing after edit
- Restart server
- Clear app cache
- Refresh the ads list

## Features

✅ 5 unique ad types
✅ Flexible coin rewards (5-25)
✅ Beautiful UI with icons and colors
✅ Real-time coin tracking
✅ Admin management
✅ Multiple ad providers
✅ Impression/click/conversion tracking
✅ Success notifications

## Next Steps

1. ✅ Seed database with 5 ads
2. ✅ Test in app
3. ✅ Customize coin amounts if needed
4. ✅ Add more ad types (optional)
5. ✅ Configure ad providers (AdMob, Meta, etc.)
