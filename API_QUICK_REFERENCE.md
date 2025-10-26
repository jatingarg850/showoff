# ShowOff.life - API Quick Reference

## 🔗 Base URL
```
http://localhost:3000/api
```

## 🔐 Authentication
All protected endpoints require JWT token in header:
```
Authorization: Bearer <token>
```

---

## 📋 API ENDPOINTS

### Authentication
```
POST   /auth/register          Register new user
POST   /auth/login             Login user
GET    /auth/me                Get current user info
```

### Profile
```
PUT    /profile                Update profile (name, bio, interests)
POST   /profile/picture        Upload profile picture
GET    /profile/:username      Get user profile by username
GET    /profile/stats          Get my stats (coins, followers, etc.)
```

### Posts
```
POST   /posts                  Create post (multipart: media file)
GET    /posts/feed             Get feed (query: page, limit)
GET    /posts/user/:userId     Get user's posts
POST   /posts/:id/like         Like/unlike post
POST   /posts/:id/comment      Add comment (body: text)
GET    /posts/:id/comments     Get post comments
POST   /posts/:id/view         Increment view count
```

### Follow System
```
POST   /follow/:userId         Follow user
DELETE /follow/:userId         Unfollow user
GET    /follow/followers/:userId    Get followers list
GET    /follow/following/:userId    Get following list
GET    /follow/check/:userId        Check if following
```

### SYT Competition
```
POST   /syt/submit             Submit entry (multipart: video)
GET    /syt/entries            Get entries (query: type, period, filter)
POST   /syt/:id/vote           Vote for entry
GET    /syt/leaderboard        Get leaderboard (query: type)
```

### Coins System
```
POST   /coins/watch-ad         Watch ad and earn coins
POST   /coins/spin-wheel       Spin wheel (once per day)
GET    /coins/transactions     Get transaction history
POST   /coins/gift             Send gift coins (body: recipientId, amount)
GET    /coins/balance          Get coin balance
```

### Withdrawal
```
POST   /withdrawal/request     Request withdrawal
GET    /withdrawal/history     Get withdrawal history
POST   /withdrawal/kyc         Submit KYC (multipart: documents)
GET    /withdrawal/kyc-status  Get KYC status
```

---

## 📤 REQUEST EXAMPLES

### Register User
```json
POST /auth/register
{
  "username": "johndoe",
  "displayName": "John Doe",
  "password": "password123",
  "email": "john@example.com",
  "referralCode": "ABC123"
}
```

### Upload Post
```
POST /posts
Content-Type: multipart/form-data

media: <file>
caption: "Amazing sunset!"
hashtags: "sunset,nature,beautiful"
type: "image"
```

### Send Gift
```json
POST /coins/gift
{
  "recipientId": "user_id_here",
  "amount": 50,
  "message": "Great content!"
}
```

### Submit SYT Entry
```
POST /syt/submit
Content-Type: multipart/form-data

video: <file>
title: "My Dance Performance"
category: "dancing"
competitionType: "weekly"
description: "Check out my moves!"
```

---

## 📥 RESPONSE FORMAT

### Success Response
```json
{
  "success": true,
  "data": { ... },
  "message": "Operation successful"
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description"
}
```

---

## 💰 COIN REWARDS

| Action | Coins | Limit |
|--------|-------|-------|
| Profile Completion | +50 | One-time |
| Upload Post | +5 | 10 posts |
| Upload Bonus | +10 | All 10 in 7 days |
| 1,000 Views | +10 | 5,000/day |
| Watch Ad | +10 | 5-50/day (tier) |
| Referral (first 100) | +50 | Per referral |
| Referral (after 100) | +20 | Per referral |
| Spin Wheel | +5-50 | Once/day |
| Vote Received | +1 | Per vote |

---

## 🔑 ENVIRONMENT VARIABLES

```env
# Server
PORT=3000
NODE_ENV=development

# MongoDB
MONGODB_URI=mongodb://localhost:27017/showoff_life

# JWT
JWT_SECRET=your_secret_key
JWT_EXPIRE=30d

# Wasabi S3
WASABI_ACCESS_KEY_ID=your_key
WASABI_SECRET_ACCESS_KEY=your_secret
WASABI_BUCKET_NAME=showoff-life
WASABI_REGION=us-east-1
WASABI_ENDPOINT=https://s3.us-east-1.wasabisys.com

# Coin System
UPLOAD_REWARD_COINS=5
MAX_UPLOAD_POSTS=10
UPLOAD_BONUS_COINS=10
VIEW_REWARD_PER_1000=10
DAILY_COIN_CAP=5000
MONTHLY_COIN_CAP=100000
AD_WATCH_COINS=10
REFERRAL_COINS_FIRST_100=50
REFERRAL_COINS_AFTER=20
COIN_TO_USD_RATE=100
```

---

## 🧪 TESTING WITH CURL

### Health Check
```bash
curl http://localhost:3000/health
```

### Register
```bash
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "username": "testuser",
    "displayName": "Test User",
    "password": "password123",
    "email": "test@example.com"
  }'
```

### Login
```bash
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "emailOrPhone": "test@example.com",
    "password": "password123"
  }'
```

### Get Balance (with token)
```bash
curl http://localhost:3000/api/coins/balance \
  -H "Authorization: Bearer YOUR_TOKEN_HERE"
```

---

## 📱 FLUTTER INTEGRATION

### API Service Location
```
apps/lib/services/api_service.dart
```

### Configure Server URL
```dart
// apps/lib/config/api_config.dart
static const String baseUrl = 'http://10.0.2.2:3000/api';
```

### Example Usage
```dart
// Register
final response = await ApiService.register(
  username: 'johndoe',
  displayName: 'John Doe',
  password: 'password123',
  email: 'john@example.com',
);

// Upload Post
final response = await ApiService.createPost(
  mediaFile: File('path/to/image.jpg'),
  caption: 'Amazing!',
  hashtags: ['sunset', 'nature'],
);

// Get Feed
final response = await ApiService.getFeed(page: 1, limit: 20);
```

---

**Quick Reference Complete! Use this for rapid development and testing.** 🚀
