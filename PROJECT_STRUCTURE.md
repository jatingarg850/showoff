# ShowOff.life - Project Structure

## 📁 Complete Project Structure

```
showoff-life/
│
├── apps/                           # Flutter Mobile Application
│   ├── lib/
│   │   ├── account_setup/         # Profile setup screens
│   │   │   ├── bio_screen.dart
│   │   │   ├── display_name_screen.dart
│   │   │   ├── interests_screen.dart
│   │   │   └── profile_picture_screen.dart
│   │   │
│   │   ├── auth/                  # Authentication screens
│   │   │   ├── forgot_password_screen.dart
│   │   │   ├── login_screen.dart
│   │   │   ├── new_password_screen.dart
│   │   │   ├── otp_screen.dart
│   │   │   ├── signin_choice_screen.dart
│   │   │   ├── signin_email_screen.dart
│   │   │   └── signin_phone_screen.dart
│   │   │
│   │   ├── config/                # App configuration
│   │   │   └── api_config.dart    # API endpoint configuration
│   │   │
│   │   ├── models/                # Data models
│   │   │   ├── daily_challenges.dart
│   │   │   ├── selfie_achievements.dart
│   │   │   ├── selfie_notifications.dart
│   │   │   └── selfie_streak_manager.dart
│   │   │
│   │   ├── providers/             # State management
│   │   │   ├── auth_provider.dart
│   │   │   └── profile_provider.dart
│   │   │
│   │   ├── services/              # API & Storage services
│   │   │   ├── api_service.dart   # Complete API integration
│   │   │   └── storage_service.dart # Local storage
│   │   │
│   │   ├── main.dart              # App entry point
│   │   ├── splash_screen.dart
│   │   ├── onboarding_screen.dart
│   │   ├── main_screen.dart       # Main navigation
│   │   ├── profile_screen.dart    # User profile
│   │   ├── user_profile_screen.dart # Other user profiles
│   │   ├── reel_screen.dart       # Reels feed
│   │   ├── talent_screen.dart     # SYT competition
│   │   ├── wallet_screen.dart     # Coin wallet
│   │   ├── upload_content_screen.dart
│   │   ├── camera_screen.dart
│   │   ├── daily_selfie_screen.dart
│   │   ├── spin_wheel_screen.dart
│   │   ├── referrals_screen.dart
│   │   ├── withdrawal_screen.dart
│   │   ├── transaction_history_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── store_screen.dart
│   │   ├── subscription_screen.dart
│   │   ├── leaderboard_screen.dart
│   │   ├── achievements_screen.dart
│   │   ├── community_screen.dart
│   │   ├── chat_screen.dart
│   │   ├── comments_screen.dart
│   │   ├── search_screen.dart
│   │   ├── notification_screen.dart
│   │   ├── gift_screen.dart
│   │   ├── cart_screen.dart
│   │   ├── product_detail_screen.dart
│   │   ├── help_support_screen.dart
│   │   ├── about_app_screen.dart
│   │   ├── terms_conditions_screen.dart
│   │   ├── privacy_safety_screen.dart
│   │   └── ... (other screens)
│   │
│   ├── assets/                    # App assets
│   │   ├── appicon/
│   │   ├── splash/
│   │   ├── onboarding/
│   │   ├── signup/
│   │   ├── setup/
│   │   ├── reel/
│   │   ├── gift/
│   │   ├── navbar/
│   │   └── ... (other assets)
│   │
│   ├── pubspec.yaml              # Flutter dependencies
│   └── README.md
│
├── server/                        # Node.js Backend Server
│   ├── config/                   # Configuration files
│   │   ├── database.js           # MongoDB connection
│   │   └── wasabi.js             # Wasabi S3 configuration
│   │
│   ├── controllers/              # Business logic
│   │   ├── authController.js     # Authentication
│   │   ├── postController.js     # Posts management
│   │   ├── profileController.js  # Profile management
│   │   ├── followController.js   # Follow system
│   │   ├── sytController.js      # SYT competition
│   │   ├── coinController.js     # Coin system
│   │   └── withdrawalController.js # Withdrawals & KYC
│   │
│   ├── middleware/               # Express middleware
│   │   ├── auth.js               # JWT authentication
│   │   └── upload.js             # File upload (Wasabi S3)
│   │
│   ├── models/                   # MongoDB schemas
│   │   ├── User.js               # User model
│   │   ├── Post.js               # Post model
│   │   ├── SYTEntry.js           # SYT entry model
│   │   ├── DailySelfie.js        # Daily selfie model
│   │   ├── Comment.js            # Comment model
│   │   ├── Like.js               # Like model
│   │   ├── Follow.js             # Follow model
│   │   ├── Vote.js               # Vote model
│   │   ├── Transaction.js        # Transaction model
│   │   └── Withdrawal.js         # Withdrawal model
│   │
│   ├── routes/                   # API routes
│   │   ├── authRoutes.js
│   │   ├── postRoutes.js
│   │   ├── profileRoutes.js
│   │   ├── followRoutes.js
│   │   ├── sytRoutes.js
│   │   ├── coinRoutes.js
│   │   └── withdrawalRoutes.js
│   │
│   ├── utils/                    # Utility functions
│   │   ├── generateToken.js      # JWT token generation
│   │   └── coinSystem.js         # Coin reward logic
│   │
│   ├── scripts/                  # Utility scripts
│   │   └── test-api.sh           # API testing script
│   │
│   ├── server.js                 # Main server file
│   ├── package.json              # Node dependencies
│   ├── .env.example              # Environment variables template
│   ├── .gitignore
│   └── README.md                 # Server documentation
│
├── SETUP_GUIDE.md                # Complete setup instructions
├── PROJECT_STRUCTURE.md          # This file
└── README.md                     # Project overview
```

## 🎯 Key Components

### Backend Server (Node.js + Express)

**Technology Stack:**
- **Runtime:** Node.js
- **Framework:** Express.js
- **Database:** MongoDB with Mongoose ODM
- **Storage:** Wasabi S3 (AWS S3 compatible)
- **Authentication:** JWT (JSON Web Tokens)
- **File Upload:** Multer + Multer-S3
- **Security:** Helmet, CORS, Rate Limiting

**Core Features:**
- RESTful API architecture
- JWT-based authentication
- File upload to Wasabi S3
- Coin reward system
- Transaction tracking
- Competition management
- Social features (follow, like, comment)
- Withdrawal and KYC system

### Flutter Mobile App

**Technology Stack:**
- **Framework:** Flutter 3.9.0+
- **Language:** Dart
- **State Management:** Provider
- **HTTP Client:** http package
- **Local Storage:** shared_preferences
- **Media:** camera, image_picker, video_player

**Core Features:**
- Beautiful UI matching design specifications
- Complete authentication flow
- Profile setup with progress tracking
- Social feed (posts, reels)
- SYT competition system
- Daily selfie challenge
- Coin wallet and transactions
- Withdrawal system
- Settings and preferences

## 📊 Data Flow

```
Flutter App
    ↓
API Service (HTTP)
    ↓
Express Server
    ↓
Controllers (Business Logic)
    ↓
Models (MongoDB)
    ↓
Database (MongoDB)

File Uploads:
Flutter App → Multer → Wasabi S3 → URL stored in MongoDB
```

## 🔐 Authentication Flow

```
1. User Registration/Login
   ↓
2. Server validates credentials
   ↓
3. JWT token generated
   ↓
4. Token stored in Flutter (SharedPreferences)
   ↓
5. Token sent with each API request (Authorization header)
   ↓
6. Server validates token
   ↓
7. Request processed
```

## 💰 Coin System Flow

```
User Action (Upload, View, Ad, etc.)
    ↓
API Request to Server
    ↓
Coin System Logic (utils/coinSystem.js)
    ↓
Update User Balance
    ↓
Create Transaction Record
    ↓
Return Updated Balance
    ↓
Update Flutter UI
```

## 📁 File Upload Flow

```
User selects file in Flutter
    ↓
File sent to server (multipart/form-data)
    ↓
Multer middleware processes file
    ↓
File uploaded to Wasabi S3
    ↓
S3 URL returned
    ↓
URL stored in MongoDB
    ↓
URL sent back to Flutter
    ↓
Image/Video displayed from S3 URL
```

## 🗄️ Database Collections

### users
- User accounts and profiles
- Coin balances
- Subscription info
- KYC details

### posts
- User posts (images/videos/reels)
- Engagement metrics
- Hashtags

### sytentries
- Competition entries
- Votes and rankings
- Prize information

### dailyselfies
- Daily selfie submissions
- Challenge themes
- Winners

### comments
- Comments on posts and entries
- Reply system

### likes
- Likes on posts, comments, entries

### follows
- Follow relationships

### votes
- Competition votes
- Daily limits

### transactions
- Coin transaction history
- All coin movements

### withdrawals
- Withdrawal requests
- KYC verification
- Payment details

## 🔄 API Endpoints Summary

### Authentication
- `POST /api/auth/register` - Register
- `POST /api/auth/login` - Login
- `GET /api/auth/me` - Get current user

### Profile
- `PUT /api/profile` - Update profile
- `POST /api/profile/picture` - Upload picture
- `GET /api/profile/:username` - Get profile
- `GET /api/profile/stats` - Get stats

### Posts
- `POST /api/posts` - Create post
- `GET /api/posts/feed` - Get feed
- `POST /api/posts/:id/like` - Like post
- `POST /api/posts/:id/comment` - Comment
- `POST /api/posts/:id/view` - Track view

### Follow
- `POST /api/follow/:userId` - Follow
- `DELETE /api/follow/:userId` - Unfollow
- `GET /api/follow/followers/:userId` - Get followers
- `GET /api/follow/following/:userId` - Get following

### SYT Competition
- `POST /api/syt/submit` - Submit entry
- `GET /api/syt/entries` - Get entries
- `POST /api/syt/:id/vote` - Vote
- `GET /api/syt/leaderboard` - Leaderboard

### Coins
- `POST /api/coins/watch-ad` - Watch ad
- `POST /api/coins/spin-wheel` - Spin wheel
- `GET /api/coins/transactions` - History
- `POST /api/coins/gift` - Send gift
- `GET /api/coins/balance` - Get balance

### Withdrawal
- `POST /api/withdrawal/request` - Request
- `GET /api/withdrawal/history` - History
- `POST /api/withdrawal/kyc` - Submit KYC
- `GET /api/withdrawal/kyc-status` - KYC status

## 🎨 UI Screens (Flutter)

### Authentication Flow
1. Splash Screen
2. Onboarding Screen
3. Welcome Screen
4. Sign Up / Login
5. OTP Verification
6. Profile Setup (4 steps)

### Main App
1. Reel Screen (Feed)
2. Talent Screen (SYT)
3. Upload Screen
4. Wallet Screen
5. Profile Screen

### Additional Screens
- Settings
- Notifications
- Search
- User Profiles
- Comments
- Chat
- Leaderboard
- Achievements
- Store
- Subscription
- Withdrawal
- Transaction History
- Help & Support
- About
- Terms & Conditions
- Privacy & Safety

## 🚀 Deployment Structure

### Development
```
Local Machine:
- MongoDB (localhost:27017)
- Node.js Server (localhost:3000)
- Flutter App (Emulator/Device)
```

### Production
```
Cloud Infrastructure:
- MongoDB Atlas (Cloud Database)
- Server (Heroku/AWS/DigitalOcean)
- Wasabi S3 (File Storage)
- Flutter App (Play Store/App Store)
```

## 📝 Environment Variables

### Server (.env)
- Database connection
- JWT secrets
- Wasabi S3 credentials
- Coin system configuration
- File upload limits

### Flutter (api_config.dart)
- API base URL
- Timeout settings

## 🔒 Security Features

- JWT authentication
- Password hashing (bcrypt)
- Rate limiting
- CORS configuration
- Helmet security headers
- Input validation
- File type validation
- SQL injection prevention (MongoDB)
- XSS protection

## 📈 Scalability Considerations

- Horizontal scaling with load balancers
- Database indexing for performance
- CDN for static assets
- Caching layer (Redis)
- Message queue for background jobs
- Microservices architecture (future)

---

This structure provides a complete, production-ready social media platform with all the features specified in the requirements!
