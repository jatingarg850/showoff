# Upload Reward System - Testing Guide

## Quick Test Commands

### 1. Test Post Upload Reward
```bash
# Create a post with URL
curl -X POST http://localhost:3000/api/posts/create-with-url \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrl": "https://via.placeholder.com/640x480.jpg",
    "mediaType": "image",
    "caption": "Test post",
    "isPublic": true
  }'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": { /* post data */ },
  "reward": {
    "coinsAwarded": 5,
    "dailyUploadsCount": 1,
    "maxUploadsPerDay": 10,
    "limitReached": false
  }
}
```

### 2. Test Daily Selfie Upload Reward
```bash
# Submit daily selfie (requires image file)
curl -X POST http://localhost:3000/api/dailyselfie/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "image=@/path/to/image.jpg"
```

**Expected Response:**
```json
{
  "success": true,
  "data": { /* selfie data */ },
  "message": "Daily selfie submitted successfully! +5 coins earned"
}
```

### 3. Test SYT Entry Upload Reward
```bash
# Submit SYT entry (requires video file)
curl -X POST http://localhost:3000/api/syt/submit \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -F "video=@/path/to/video.mp4" \
  -F "title=My SYT Entry" \
  -F "description=Test entry" \
  -F "category=singing" \
  -F "competitionType=weekly"
```

**Expected Response:**
```json
{
  "success": true,
  "data": { /* entry data */ }
}
```

### 4. Test Daily Limit
```bash
# Create 10 posts (should all succeed with coins)
for i in {1..10}; do
  curl -X POST http://localhost:3000/api/posts/create-with-url \
    -H "Authorization: Bearer YOUR_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{
      \"mediaUrl\": \"https://via.placeholder.com/640x480.jpg\",
      \"mediaType\": \"image\",
      \"caption\": \"Post $i\"
    }"
done

# 11th post should have limitReached: true
curl -X POST http://localhost:3000/api/posts/create-with-url \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "mediaUrl": "https://via.placeholder.com/640x480.jpg",
    "mediaType": "image",
    "caption": "Post 11 - should not award coins"
  }'
```

**Expected Response for 11th post:**
```json
{
  "success": true,
  "message": "Post created successfully",
  "data": { /* post data */ },
  "reward": {
    "coinsAwarded": 0,
    "dailyUploadsCount": 10,
    "maxUploadsPerDay": 10,
    "limitReached": true
  }
}
```

## Verification Steps

### 1. Check User Coin Balance
```bash
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Look for:
- `coinBalance` - should increase by 5 for each upload (up to 10 per day)
- `totalCoinsEarned` - cumulative total

### 2. Check Transaction History
```bash
curl -X GET http://localhost:3000/api/transactions \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Look for transactions with:
- `type: "upload_reward"`
- `amount: 5`
- `description: "Upload reward for post (X/10 today)"`

### 3. Check User Upload Tracking
```bash
curl -X GET http://localhost:3000/api/users/profile \
  -H "Authorization: Bearer YOUR_TOKEN"
```

Look for:
- `dailyUploadsCount` - should be 1-10
- `lastUploadDate` - should be today's date

## Configuration Testing

### Test Custom Reward Amount
1. Update `.env`:
   ```
   UPLOAD_REWARD_COINS_PER_POST=10
   ```

2. Restart server

3. Create a post - should award 10 coins instead of 5

### Test Custom Daily Limit
1. Update `.env`:
   ```
   MAX_UPLOADS_PER_DAY=5
   ```

2. Restart server

3. Create 5 posts - all should award coins
4. Create 6th post - should have `limitReached: true`

## Day Reset Testing

### Test Automatic Day Reset
1. Create 10 posts today - all award coins
2. Manually update user's `lastUploadDate` to yesterday in MongoDB:
   ```javascript
   db.users.updateOne(
     { _id: ObjectId("USER_ID") },
     { $set: { lastUploadDate: new Date(Date.now() - 24*60*60*1000) } }
   )
   ```
3. Create another post - should award coins again (counter reset)

## Share Reward Testing (Separate System)

### Test Share Rewards (Different Counter)
```bash
# Share a post
curl -X POST http://localhost:3000/api/posts/POST_ID/share \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"shareType": "link"}'
```

**Expected Response:**
```json
{
  "success": true,
  "message": "Post shared successfully",
  "coinsAwarded": 5,
  "dailySharesCount": 1,
  "maxSharesPerDay": 10
}
```

**Note:** Share rewards use separate counters (`dailySharesCount`, `lastShareDate`) and don't affect upload limits.

## Debugging

### Check Server Logs
Look for these log messages:
```
✅ Upload reward: 5 coins added to user USER_ID (1/10)
⚠️ Daily upload limit reached for user USER_ID
```

### Check Database
```javascript
// View user's upload tracking
db.users.findOne({ _id: ObjectId("USER_ID") }, {
  dailyUploadsCount: 1,
  lastUploadDate: 1,
  coinBalance: 1,
  totalCoinsEarned: 1
})

// View upload reward transactions
db.transactions.find({
  user: ObjectId("USER_ID"),
  type: "upload_reward"
}).sort({ createdAt: -1 }).limit(10)
```

## Common Issues

### Issue: Coins not awarded
**Solution:**
1. Check if user exists in database
2. Check if `dailyUploadsCount < maxUploadsPerDay`
3. Check server logs for coin award errors
4. Verify `.env` variables are set correctly

### Issue: Daily limit not resetting
**Solution:**
1. Check `lastUploadDate` in database
2. Ensure date comparison logic is working (should reset at midnight UTC)
3. Manually reset by updating `lastUploadDate` to yesterday

### Issue: Share rewards interfering with upload rewards
**Solution:**
- Share rewards use separate counters (`dailySharesCount`, `lastShareDate`)
- Upload rewards use separate counters (`dailyUploadsCount`, `lastUploadDate`)
- They should not interfere with each other

## Success Criteria

✅ User earns 5 coins per upload (configurable)
✅ Daily limit of 10 uploads per day (configurable)
✅ Counter resets at midnight UTC
✅ All upload types share same counter (posts, selfies, SYT)
✅ Share rewards work independently (separate counter)
✅ Transaction records created for audit trail
✅ API responses include reward status
✅ Graceful error handling if coin award fails
