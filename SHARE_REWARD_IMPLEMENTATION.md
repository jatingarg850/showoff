# Share Reward System Implementation

## Overview
When users share a reel, they now receive **5 coins** credited to their wallet automatically. This incentivizes users to share content and increases viral potential.

## What Changed

### 1. Server-Side: Updated Share Endpoint
**File**: `server/controllers/postController.js`

**Changes to `sharePost` function**:
- Added coin reward logic after share is recorded
- Awards 5 coins to the user's wallet
- Creates a transaction record for tracking
- Returns `coinsAwarded` in response
- Graceful error handling (doesn't fail share if coin reward fails)

**Code Flow**:
```javascript
1. Create share record in database
2. Increment post share count
3. Add 5 coins to user's coinBalance
4. Add 5 coins to user's totalCoinsEarned
5. Create transaction record (type: 'share_reward')
6. Return success with coinsAwarded: 5
```

### 2. Client-Side: Updated Share UI
**File**: `apps/lib/reel_screen.dart`

**Changes to `_sharePost` method**:
- Extracts `coinsAwarded` from API response
- Shows coin reward notification with icon and message
- Uses purple gradient background (brand color)
- Displays for 3 seconds
- Shows "+5 coins earned for sharing! 🎉"

**Notification Design**:
```
┌─────────────────────────────────────┐
│ 💰 +5 coins earned for sharing! 🎉 │
└─────────────────────────────────────┘
```

## How It Works

### User Flow
```
User clicks Share button
    ↓
Share dialog opens (native share)
    ↓
User selects app/contact to share with
    ↓
Share is sent
    ↓
Backend records share
    ↓
Backend adds 5 coins to wallet
    ↓
Backend creates transaction record
    ↓
App receives response with coinsAwarded: 5
    ↓
App shows coin reward notification
    ↓
User sees "+5 coins earned for sharing! 🎉"
```

### Database Changes
**User Model**:
- `coinBalance` increased by 5
- `totalCoinsEarned` increased by 5

**Transaction Record Created**:
```javascript
{
  user: userId,
  type: 'share_reward',
  amount: 5,
  balanceAfter: newCoinBalance,
  description: 'Share reward for post'
}
```

**Share Record Created**:
```javascript
{
  user: userId,
  post: postId,
  shareType: 'link'
}
```

## Key Features

✅ **Automatic Reward** - No manual claim needed
✅ **Instant Notification** - User sees reward immediately
✅ **Transaction Tracking** - All rewards recorded in transaction history
✅ **Error Handling** - Share succeeds even if coin reward fails
✅ **Wallet Integration** - Coins immediately available in wallet
✅ **Incentive System** - Encourages content sharing
✅ **Viral Growth** - More shares = more users discovering content

## Testing Checklist

- [ ] Share a reel from the reel screen
- [ ] Verify coin reward notification appears
- [ ] Verify notification shows "+5 coins earned for sharing! 🎉"
- [ ] Check user's wallet balance increased by 5 coins
- [ ] Check transaction history shows share_reward transaction
- [ ] Share multiple reels and verify coins accumulate
- [ ] Test with different share methods (WhatsApp, SMS, etc.)
- [ ] Verify share count increments correctly
- [ ] Test error scenarios (network failure, etc.)
- [ ] Verify coin reward doesn't appear if API fails

## Console Output Examples

### Server-Side
```
✅ Share reward: 5 coins added to user 507f1f77bcf86cd799439011
```

### Client-Side
```
🎬 Sharing post: 507f1f77bcf86cd799439012
✅ Share successful, coins awarded: 5
```

## API Response

**Before**:
```json
{
  "success": true,
  "sharesCount": 42,
  "message": "Post shared successfully"
}
```

**After**:
```json
{
  "success": true,
  "sharesCount": 42,
  "message": "Post shared successfully",
  "coinsAwarded": 5
}
```

## Files Modified

1. **server/controllers/postController.js**
   - Updated `sharePost` function
   - Added coin reward logic
   - Added transaction creation

2. **apps/lib/reel_screen.dart**
   - Updated `_sharePost` method
   - Added coin reward notification
   - Enhanced user feedback

## Reward Details

| Action | Coins | Frequency | Limit |
|--------|-------|-----------|-------|
| Share Reel | 5 | Per share | Unlimited |
| Upload | 10 | Per upload | 5000 total |
| View (per 1000) | 10 | Continuous | Daily/Monthly |

## Future Enhancements

- [ ] Add share streak bonus (extra coins for consecutive shares)
- [ ] Add referral bonus when shared user signs up
- [ ] Add leaderboard for most shares
- [ ] Add daily share limit with bonus multiplier
- [ ] Add share analytics dashboard
- [ ] Add social sharing achievements/badges

## Important Notes

1. **Reward Timing**: Coins are awarded immediately after share is recorded
2. **No Duplicate Prevention**: Currently allows multiple shares of same reel (each awards coins)
3. **Transaction History**: All shares tracked in transaction history for transparency
4. **Wallet Integration**: Coins immediately available for spending
5. **Error Resilience**: Share succeeds even if coin reward fails (graceful degradation)

## Troubleshooting

**Coins not appearing in wallet**:
- Check network connection
- Verify user is authenticated
- Check server logs for errors
- Verify Transaction model is working

**Notification not showing**:
- Check if `coinsAwarded` is in response
- Verify mounted state before showing snackbar
- Check if another snackbar is already showing

**Share count not incrementing**:
- Verify Share model is working
- Check post.sharesCount is being saved
- Verify stats reload is working
