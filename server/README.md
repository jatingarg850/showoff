# ShowOff.life Backend Server

Complete backend server for ShowOff.life social media platform with MongoDB and Wasabi S3 storage.

## Features

- ✅ User Authentication (Email/Phone)
- ✅ Profile Management with Completion Tracking
- ✅ Image & Video Upload to Wasabi S3
- ✅ Social Feed (Posts, Reels)
- ✅ Like, Comment, Share System
- ✅ Follow/Unfollow System
- ✅ Coin-Based Reward System
- ✅ Upload Rewards (5 coins per post, max 10 posts)
- ✅ View-Based Earnings (10 coins per 1000 views)
- ✅ Rewarded Ads System
- ✅ Referral System (50 coins for first 100, then 20 coins)
- ✅ Daily Spin Wheel (5-50 coins)
- ✅ SYT Competition System (Weekly/Monthly/Quarterly)
- ✅ Daily Selfie Challenge
- ✅ Voting System
- ✅ Gift Coins Feature
- ✅ Withdrawal System with KYC
- ✅ Transaction History
- ✅ Premium Subscriptions

## Installation

### Prerequisites

- Node.js (v16 or higher)
- MongoDB (local or Atlas)
- Wasabi S3 Account

### Setup

1. **Install dependencies:**
```bash
cd server
npm install
```

2. **Configure environment variables:**
```bash
cp .env.example .env
```

Edit `.env` file with your credentials:
- MongoDB connection string
- Wasabi S3 credentials
- JWT secret
- Other configuration

3. **Start the server:**

Development mode:
```bash
npm run dev
```

Production mode:
```bash
npm start
```

## Environment Variables

### Required Variables

```env
# MongoDB
MONGODB_URI=mongodb://localhost:27017/showoff_life

# JWT
JWT_SECRET=your_secret_key_here
JWT_EXPIRE=30d

# Wasabi S3
WASABI_ACCESS_KEY_ID=your_access_key
WASABI_SECRET_ACCESS_KEY=your_secret_key
WASABI_BUCKET_NAME=showoff-life
WASABI_REGION=us-east-1
WASABI_ENDPOINT=https://s3.us-east-1.wasabisys.com
```

## API Endpoints

### Authentication
- `POST /api/auth/register` - Register new user
- `POST /api/auth/login` - Login user
- `GET /api/auth/me` - Get current user

### Profile
- `PUT /api/profile` - Update profile
- `POST /api/profile/picture` - Upload profile picture
- `GET /api/profile/:username` - Get user profile
- `GET /api/profile/stats` - Get my stats

### Posts
- `POST /api/posts` - Create post (with media upload)
- `GET /api/posts/feed` - Get feed
- `GET /api/posts/user/:userId` - Get user posts
- `POST /api/posts/:id/like` - Like/Unlike post
- `POST /api/posts/:id/comment` - Add comment
- `GET /api/posts/:id/comments` - Get comments
- `POST /api/posts/:id/view` - Increment view count

### Follow System
- `POST /api/follow/:userId` - Follow user
- `DELETE /api/follow/:userId` - Unfollow user
- `GET /api/follow/followers/:userId` - Get followers
- `GET /api/follow/following/:userId` - Get following
- `GET /api/follow/check/:userId` - Check if following

### SYT Competition
- `POST /api/syt/submit` - Submit SYT entry
- `GET /api/syt/entries` - Get entries
- `POST /api/syt/:id/vote` - Vote for entry
- `GET /api/syt/leaderboard` - Get leaderboard

### Coins System
- `POST /api/coins/watch-ad` - Watch ad and earn coins
- `POST /api/coins/spin-wheel` - Spin wheel
- `GET /api/coins/transactions` - Get transaction history
- `POST /api/coins/gift` - Send gift coins
- `GET /api/coins/balance` - Get coin balance

### Withdrawal
- `POST /api/withdrawal/request` - Request withdrawal
- `GET /api/withdrawal/history` - Get withdrawal history
- `POST /api/withdrawal/kyc` - Submit KYC
- `GET /api/withdrawal/kyc-status` - Get KYC status

## Coin System Rules

### Upload Rewards
- 5 coins per post (max 10 posts)
- 10-coin bonus for uploading all 10 within 7 days of signup
- Disables after user earns 5,000 total coins from uploads/views

### View-Based Earnings
- 10 coins per 1,000 views
- Daily cap: 5,000 coins
- Monthly cap: 100,000 coins

### Rewarded Ads
- 10 coins per ad watch
- Daily limits:
  - Free: 5 ads
  - Basic: 10 ads
  - Pro: 15 ads
  - VIP: 50 ads
- 15-minute cooldown after every 3 ads

### Referral System
- 50 coins per referral for first 100 referrals
- 20 coins per referral after 100
- System disables after 100 million users

### Daily Spin Wheel
- Once every 24 hours
- Random reward: 5-50 coins

### SYT Competition Prizes
**Weekly:**
- 1st: 1,000 coins
- 2nd: 500 coins
- 3rd: 200 coins

**Monthly:**
- 1st: 10,000 coins
- 2nd: 5,000 coins
- 3rd: 2,000 coins

**Quarterly:**
- 1st: 100,000 coins
- 2nd: 50,000 coins
- 3rd: 20,000 coins

### Daily Selfie Challenge
- Winner: 200 coins + "Selfie Star" badge for 24 hours

## Database Models

- **User** - User accounts and profiles
- **Post** - User posts (images/videos/reels)
- **SYTEntry** - Show Your Talent competition entries
- **DailySelfie** - Daily selfie challenge submissions
- **Comment** - Comments on posts and entries
- **Like** - Likes on posts, comments, entries
- **Follow** - Follow relationships
- **Vote** - Votes for competitions
- **Transaction** - Coin transaction history
- **Withdrawal** - Withdrawal requests

## File Upload

Files are uploaded to Wasabi S3 storage:
- Images: `images/` folder
- Videos: `videos/` folder
- Public read access
- Max file size: 100MB (configurable)

## Security Features

- JWT authentication
- Password hashing with bcrypt
- Rate limiting
- Helmet security headers
- CORS enabled
- Input validation
- File type validation

## Development

```bash
# Install dependencies
npm install

# Run in development mode with auto-reload
npm run dev

# Run in production mode
npm start
```

## Testing

Test the API using:
- Postman
- Thunder Client (VS Code)
- cURL

Example:
```bash
# Health check
curl http://localhost:3000/health

# Register user
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "user@example.com",
    "password": "password123",
    "username": "johndoe",
    "displayName": "John Doe"
  }'
```

## Production Deployment

1. Set `NODE_ENV=production`
2. Use MongoDB Atlas for database
3. Configure Wasabi S3 bucket
4. Set strong JWT secret
5. Enable HTTPS
6. Configure proper CORS origins
7. Set up monitoring and logging

## Support

For issues and questions, please contact the development team.

## License

Proprietary - All rights reserved
