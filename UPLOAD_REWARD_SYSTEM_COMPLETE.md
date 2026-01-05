# Upload Reward System - Complete Implementation

## Overview
Implemented a comprehensive upload reward system with daily limits across all content creation endpoints. Users earn customizable coins for uploading content (posts, daily selfies, SYT entries) with a daily limit to prevent abuse.

## Configuration (server/.env)
```
# Share and Upload Rewards (Customizable)
SHARE_REWARD_COINS=5              # Coins per share (default: 5)
MAX_SHARES_PER_DAY=10             # Max shares per day (default: 10)
UPLOAD_REWARD_COINS_PER_POST=5    # Coins per upload (default: 5)
MAX_UPLOADS_PER_DAY=10            # Max uploads per day (default: 10)
```

## Database Fields (User Model)
Added tracking fields in `server/models/User.js`:
- `dailyUploadsCount` (Number, default: 0) - Tracks uploads for current day
- `lastUploadDate` (Date) - Timestamp of last upload to detect day changes

## Implementation Details

### 1. Post Creation Endpoints

#### `createPostWithUrl()` - POST /api/posts/create-with-url
- **Location**: `server/controllers/postController.js`
- **Reward Logic**:
  - Checks daily upload count and resets if new day
  - Awards `UPLOAD_REWARD_COINS_PER_POST` coins if under daily limit
  - Updates user's `coinBalance`, `totalCoinsEarned`, `dailyUploadsCount`, `lastUploadDate`
  - Creates transaction record for audit trail
  - Returns response with post data

#### `createPost()` - POST /api/posts
- **Location**: `server/controllers/postController.js`
- **Reward Logic**: Same as `createPostWithUrl()`
- **Response**: Includes `reward` object with:
  ```json
  {
    "coinsAwarded": 5,
    "dailyUploadsCount": 1,
    "maxUploadsPerDay": 10,
    "limitReached": false
  }
  ```

### 2. Daily Selfie Endpoint

#### `submitDailySelfie()` - POST /api/dailyselfie/submit
- **Location**: `server/controllers/dailySelfieController.js`
- **Reward Logic**:
  - Same daily limit logic as post uploads
  - Awards coins for daily selfie submission
  - Tracks daily uploads count (shared across all upload types)
  - Creates transaction record

### 3. SYT Entry Endpoint

#### `submitEntry()` - POST /api/syt/submit
- **Location**: `server/controllers/sytController.js`
- **Reward Logic**:
  - Same daily limit logic as other uploads
  - Awards coins for SYT competition entry
  - Tracks daily uploads count (shared across all upload types)
  - Creates transaction record with `relatedSYTEntry` reference

## Daily Limit Logic

All endpoints use the same daily limit mechanism:

```javascript
// Reset daily upload count if new day
const today = new Date().setHours(0, 0, 0, 0);
const lastUploadDate = user.lastUploadDate ? new Date(user.lastUploadDate).setHours(0, 0, 0, 0) : 0;

if (today > lastUploadDate) {
  user.dailyUploadsCount = 0;
}

// Check if daily limit reached
if (user.dailyUploadsCount < maxUploadsPerDay) {
  // Award coins
  user.coinBalance += uploadRewardCoins;
  user.totalCoinsEarned += uploadRewardCoins;
  user.dailyUploadsCount += 1;
  user.lastUploadDate = Date.now();
  await user.save();
  
  // Create transaction record
  await Transaction.create({
    user: req.user.id,
    type: 'upload_reward',
    amount: uploadRewardCoins,
    balanceAfter: user.coinBalance,
    description: `Upload reward (${user.dailyUploadsCount}/${maxUploadsPerDay} today)`,
  });
}
```

## Key Features

✅ **Customizable Rewards**: All coin amounts and limits configurable via .env
✅ **Daily Limits**: Prevents abuse with configurable daily upload limits
✅ **Shared Counter**: All upload types (posts, selfies, SYT) share the same daily counter
✅ **Day Reset**: Automatically resets counter at midnight (UTC)
✅ **Transaction Tracking**: All rewards logged in Transaction model for audit trail
✅ **Error Handling**: Gracefully continues if coin award fails
✅ **Response Feedback**: Returns reward status in API responses

## API Response Examples

### Successful Upload (Within Daily Limit)
```json
{
  "success": true,
  "data": { /* post/selfie/entry data */ },
  "reward": {
    "coinsAwarded": 5,
    "dailyUploadsCount": 1,
    "maxUploadsPerDay": 10,
    "limitReached": false
  }
}
```

### Upload Limit Reached
```json
{
  "success": true,
  "data": { /* post/selfie/entry data */ },
  "reward": {
    "coinsAwarded": 0,
    "dailyUploadsCount": 10,
    "maxUploadsPerDay": 10,
    "limitReached": true
  }
}
```

## Testing Checklist

- [ ] Create post with URL - verify 5 coins awarded
- [ ] Create post with file upload - verify 5 coins awarded
- [ ] Submit daily selfie - verify 5 coins awarded
- [ ] Submit SYT entry - verify 5 coins awarded
- [ ] Create 10 posts in one day - verify 11th post doesn't award coins
- [ ] Create post after midnight - verify counter resets
- [ ] Verify transaction records created for each reward
- [ ] Test with custom .env values (e.g., UPLOAD_REWARD_COINS_PER_POST=10)
- [ ] Verify share rewards still work (5 coins per share, max 10/day)

## Files Modified

1. **server/controllers/postController.js**
   - Updated `createPostWithUrl()` with daily limit logic
   - Updated `createPost()` with daily limit logic

2. **server/controllers/dailySelfieController.js**
   - Updated `submitDailySelfie()` with daily limit logic

3. **server/controllers/sytController.js**
   - Updated `submitEntry()` with daily limit logic

4. **server/models/User.js** (Already updated in previous session)
   - Added `dailyUploadsCount` field
   - Added `lastUploadDate` field

5. **server/.env** (Already updated in previous session)
   - Added `UPLOAD_REWARD_COINS_PER_POST=5`
   - Added `MAX_UPLOADS_PER_DAY=10`

## Integration with Existing Systems

- **Share Rewards**: Separate daily counter (`dailySharesCount`, `lastShareDate`)
- **Coin System**: Uses existing `coinBalance` and `totalCoinsEarned` fields
- **Transactions**: Logs all rewards in Transaction model for audit trail
- **User Model**: Extends existing User schema with new tracking fields

## Notes

- Daily limits are per-user and reset at midnight UTC
- All upload types (posts, selfies, SYT) share the same daily counter
- Share rewards have a separate daily counter (not affected by upload limit)
- Coin awards are optional - if they fail, uploads still succeed
- All rewards are logged in Transaction model for transparency
