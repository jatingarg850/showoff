# Upload Reward System - Quick Reference

## TL;DR

Users earn **5 coins** for each upload (posts, selfies, SYT entries) with a **10 per day** limit. All amounts are customizable via `.env`.

## Configuration

```env
UPLOAD_REWARD_COINS_PER_POST=5    # Coins per upload
MAX_UPLOADS_PER_DAY=10            # Max uploads per day
```

## Endpoints with Upload Rewards

| Endpoint | Method | Path | Reward |
|----------|--------|------|--------|
| Create Post (URL) | POST | `/api/posts/create-with-url` | 5 coins |
| Create Post (File) | POST | `/api/posts` | 5 coins |
| Daily Selfie | POST | `/api/dailyselfie/submit` | 5 coins |
| SYT Entry | POST | `/api/syt/submit` | 5 coins |

## API Response

```json
{
  "success": true,
  "data": { /* content data */ },
  "reward": {
    "coinsAwarded": 5,
    "dailyUploadsCount": 1,
    "maxUploadsPerDay": 10,
    "limitReached": false
  }
}
```

## User Tracking Fields

```javascript
{
  dailyUploadsCount: 1,           // Current day's uploads
  lastUploadDate: "2026-01-05",   // Last upload date
  coinBalance: 105,               // Total coins
  totalCoinsEarned: 105           // Cumulative earned
}
```

## Daily Limit Logic

- **Resets**: At midnight UTC
- **Shared**: All upload types share same counter
- **Tracked**: `dailyUploadsCount` and `lastUploadDate`
- **Limit**: 10 uploads per day (configurable)

## Share Rewards (Separate System)

| Endpoint | Method | Path | Reward |
|----------|--------|------|--------|
| Share Post | POST | `/api/posts/:id/share` | 5 coins |

**Note**: Share rewards use separate counter (`dailySharesCount`, `lastShareDate`)

## Transaction Logging

All rewards logged with:
- **Type**: `upload_reward`
- **Amount**: 5 coins (configurable)
- **Description**: `"Upload reward for post (1/10 today)"`

## Testing Quick Commands

```bash
# Create post
curl -X POST http://localhost:3000/api/posts/create-with-url \
  -H "Authorization: Bearer TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"mediaUrl":"https://via.placeholder.com/640x480.jpg","mediaType":"image"}'

# Check user profile
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer TOKEN"

# Check transactions
curl -X GET http://localhost:3000/api/transactions \
  -H "Authorization: Bearer TOKEN"
```

## Customization Examples

**Double Rewards:**
```env
UPLOAD_REWARD_COINS_PER_POST=10
```

**Stricter Limit:**
```env
MAX_UPLOADS_PER_DAY=5
```

**No Limit:**
```env
MAX_UPLOADS_PER_DAY=999
```

## Debugging

**Check logs for:**
```
✅ Upload reward: 5 coins added to user USER_ID (1/10)
⚠️ Daily upload limit reached for user USER_ID
```

**Check database:**
```javascript
db.users.findOne({ _id: ObjectId("USER_ID") }, {
  dailyUploadsCount: 1,
  lastUploadDate: 1,
  coinBalance: 1
})
```

## Files Modified

- `server/controllers/postController.js`
- `server/controllers/dailySelfieController.js`
- `server/controllers/sytController.js`
- `server/models/User.js` (previous session)
- `server/.env` (previous session)

## Key Features

✅ Customizable rewards and limits
✅ Daily automatic reset
✅ Shared counter across upload types
✅ Transaction logging
✅ Error handling
✅ Independent share rewards

## Status

✅ **COMPLETE** - Ready for testing and deployment
