# Admin Panel - New Features Quick Reference

## 1. Rewarded Ads Management

### Access
`GET /api/admin/rewarded-ads`

### Update Ad
```bash
PUT /api/admin/rewarded-ads/1
{
  "adLink": "https://example.com/ad1",
  "adProvider": "custom",
  "rewardCoins": 10,
  "isActive": true
}
```

### Response
```json
{
  "success": true,
  "message": "Rewarded Ad 1 updated successfully",
  "data": {
    "adNumber": 1,
    "adLink": "https://example.com/ad1",
    "adProvider": "custom",
    "rewardCoins": 10,
    "isActive": true,
    "impressions": 0,
    "clicks": 0,
    "conversions": 0
  }
}
```

---

## 2. Music Management

### Get All Music
```bash
GET /api/admin/music?page=1&limit=20&approved=false
```

### Approve Music
```bash
PUT /api/admin/music/{musicId}/approve
{
  "isApproved": true
}
```

### Delete Music
```bash
DELETE /api/admin/music/{musicId}
```

### Response
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "title": "Song Name",
      "artist": "Artist Name",
      "duration": 180,
      "genre": "pop",
      "mood": "happy",
      "isApproved": false,
      "uploadedBy": {
        "username": "user123",
        "displayName": "User Name"
      },
      "usageCount": 5,
      "likes": 12
    }
  ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 45,
    "pages": 3
  }
}
```

---

## 3. User Earnings Breakdown

### Get User Earnings
```bash
GET /api/admin/users/{userId}/earnings
```

### Response
```json
{
  "success": true,
  "data": {
    "user": {
      "_id": "...",
      "username": "user123",
      "displayName": "User Name",
      "coinBalance": 1500,
      "totalCoinsEarned": 5000
    },
    "earnings": {
      "videoUploadEarnings": 1200,
      "contentSharingEarnings": 800,
      "wheelSpinEarnings": 500,
      "rewardedAdEarnings": 1000,
      "referralEarnings": 500,
      "otherEarnings": 0,
      "totalEarnings": 4000
    },
    "recentTransactions": [
      {
        "_id": "...",
        "type": "upload_reward",
        "amount": 10,
        "description": "Content upload reward",
        "createdAt": "2024-12-22T10:30:00Z"
      }
    ]
  }
}
```

### Get Top Earners
```bash
GET /api/admin/top-earners?limit=20&period=30
```

### Response
```json
{
  "success": true,
  "data": [
    {
      "_id": "...",
      "username": "topuser",
      "displayName": "Top User",
      "coinBalance": 5000,
      "totalCoinsEarned": 15000,
      "earnings": {
        "videoUploadEarnings": 5000,
        "contentSharingEarnings": 3000,
        "wheelSpinEarnings": 2000,
        "rewardedAdEarnings": 3000,
        "referralEarnings": 2000,
        "otherEarnings": 0,
        "totalEarnings": 15000
      }
    }
  ]
}
```

---

## 4. SYT Management

### Get SYT Entries
```bash
GET /api/admin/syt?page=1&limit=20&status=active
```

### Declare Winner
```bash
PUT /api/admin/syt/{entryId}/winner
```

### Response
```json
{
  "success": true,
  "message": "SYT winner declared and rewarded successfully",
  "data": {
    "_id": "...",
    "user": "...",
    "mediaUrl": "...",
    "isWinner": true,
    "winnerDeclaredAt": "2024-12-22T10:30:00Z",
    "votesCount": 150
  }
}
```

### Toggle SYT Entry
```bash
PUT /api/admin/syt/{entryId}/toggle
```

### Delete SYT Entry
```bash
DELETE /api/admin/syt/{entryId}
```

---

## 5. User Profile - Video Deletion

### Delete Post
```bash
DELETE /api/posts/{postId}
```

### Response
```json
{
  "success": true,
  "message": "Post deleted successfully"
}
```

### Frontend Usage
- Long-press on video in profile grid
- Select "Delete Post" from menu
- Confirm deletion
- Post removed from profile

---

## Integration Notes

### Admin Panel UI
The admin panel should include new sections:
1. **Rewarded Ads** - Manage 5 ad slots with links and rewards
2. **Music Library** - Approve/reject user-uploaded music
3. **User Analytics** - View detailed earnings breakdown
4. **SYT Management** - Declare winners and manage entries

### Real-time Sync
- All admin changes update database immediately
- App fetches fresh data on:
  - App startup
  - Screen navigation
  - Pull-to-refresh
  - WebSocket updates

### Coin Awards
- Video upload: 10 coins
- Ad watch: 10 coins
- SYT winner: 500 coins
- Referral: 50 coins

---

## Error Handling

All endpoints return standardized error responses:

```json
{
  "success": false,
  "message": "Error description"
}
```

Common errors:
- 404: Resource not found
- 400: Invalid request data
- 403: Not authorized (admin only)
- 500: Server error

---

## Testing Commands

### Test Rewarded Ads
```bash
curl -X GET http://localhost:3000/api/admin/rewarded-ads \
  -H "Authorization: Bearer {token}"

curl -X PUT http://localhost:3000/api/admin/rewarded-ads/1 \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{
    "adLink": "https://example.com/ad1",
    "adProvider": "custom",
    "rewardCoins": 10,
    "isActive": true
  }'
```

### Test Music Management
```bash
curl -X GET http://localhost:3000/api/admin/music \
  -H "Authorization: Bearer {token}"

curl -X PUT http://localhost:3000/api/admin/music/{musicId}/approve \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{"isApproved": true}'
```

### Test User Earnings
```bash
curl -X GET http://localhost:3000/api/admin/users/{userId}/earnings \
  -H "Authorization: Bearer {token}"

curl -X GET http://localhost:3000/api/admin/top-earners?limit=20 \
  -H "Authorization: Bearer {token}"
```

### Test Video Deletion
```bash
curl -X DELETE http://localhost:3000/api/posts/{postId} \
  -H "Authorization: Bearer {token}"
```

---

## Database Queries

### Find all rewarded ads
```javascript
db.rewardedads.find()
```

### Find approved music
```javascript
db.musics.find({ isApproved: true })
```

### Find user earnings
```javascript
db.usereanings.findOne({ user: ObjectId("userId") })
```

### Find SYT winners
```javascript
db.sytentries.find({ isWinner: true })
```

---

## Performance Considerations

- Music queries use indexes on `isApproved` and `genre`
- Rewarded ads queries use index on `adNumber`
- User earnings queries use index on `user` field
- Pagination implemented for all list endpoints
- Limit results to prevent memory issues

---

## Security

- All admin endpoints require authentication
- Admin role verification on all endpoints
- Input validation on all requests
- File deletion only for local storage
- S3/Wasabi URLs preserved for cloud storage

---

## Future Enhancements

1. **Batch Operations** - Update multiple ads/music at once
2. **Analytics Dashboard** - Real-time earnings charts
3. **Music Recommendations** - AI-based music suggestions
4. **Ad Performance** - Track CTR and conversion rates
5. **Automated Rewards** - Scheduled coin distributions
