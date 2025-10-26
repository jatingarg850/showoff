# ShowOff.life - Complete Setup Guide

This guide will help you set up the complete ShowOff.life application with backend server, MongoDB, and Wasabi S3 storage.

## 📋 Prerequisites

### Required Software
- **Node.js** (v16 or higher) - [Download](https://nodejs.org/)
- **MongoDB** - [Download](https://www.mongodb.com/try/download/community) or use [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
- **Flutter** (v3.9.0 or higher) - [Install Guide](https://flutter.dev/docs/get-started/install)
- **Android Studio** or **Xcode** (for mobile development)

### Required Accounts
- **Wasabi S3** - [Sign up](https://wasabi.com/) for cloud storage
- **MongoDB Atlas** (optional) - For cloud database

---

## 🚀 Part 1: Backend Server Setup

### Step 1: Install Dependencies

```bash
cd server
npm install
```

### Step 2: Configure Environment Variables

1. Copy the example environment file:
```bash
cp .env.example .env
```

2. Edit `.env` file with your credentials:

```env
# Server Configuration
PORT=3000
NODE_ENV=development

# MongoDB Configuration
MONGODB_URI=mongodb://localhost:27017/showoff_life
# Or use MongoDB Atlas:
# MONGODB_URI=mongodb+srv://username:password@cluster.mongodb.net/showoff_life

# JWT Secret (generate a strong random string)
JWT_SECRET=your_super_secret_jwt_key_change_this_in_production
JWT_EXPIRE=30d

# Wasabi S3 Configuration
WASABI_ACCESS_KEY_ID=your_wasabi_access_key
WASABI_SECRET_ACCESS_KEY=your_wasabi_secret_key
WASABI_BUCKET_NAME=showoff-life
WASABI_REGION=us-east-1
WASABI_ENDPOINT=https://s3.us-east-1.wasabisys.com

# File Upload Configuration
MAX_FILE_SIZE=104857600
ALLOWED_IMAGE_TYPES=image/jpeg,image/png,image/jpg,image/webp
ALLOWED_VIDEO_TYPES=video/mp4,video/mpeg,video/quicktime,video/x-msvideo

# Coin System Configuration
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

### Step 3: Set Up Wasabi S3

1. **Create Wasabi Account:**
   - Go to [wasabi.com](https://wasabi.com/)
   - Sign up for an account
   - Choose a region (e.g., us-east-1)

2. **Create Access Keys:**
   - Go to "Access Keys" in Wasabi console
   - Click "Create New Access Key"
   - Save the Access Key ID and Secret Access Key
   - Add them to your `.env` file

3. **Create Bucket:**
   - Go to "Buckets" in Wasabi console
   - Click "Create Bucket"
   - Name it `showoff-life` (or your preferred name)
   - Set bucket policy to allow public read access for uploaded files
   - Update `WASABI_BUCKET_NAME` in `.env`

### Step 4: Set Up MongoDB

**Option A: Local MongoDB**
```bash
# Install MongoDB locally
# macOS
brew install mongodb-community

# Start MongoDB
brew services start mongodb-community

# Your connection string:
MONGODB_URI=mongodb://localhost:27017/showoff_life
```

**Option B: MongoDB Atlas (Cloud)**
1. Go to [MongoDB Atlas](https://www.mongodb.com/cloud/atlas)
2. Create a free cluster
3. Create a database user
4. Whitelist your IP address (or use 0.0.0.0/0 for development)
5. Get your connection string
6. Update `MONGODB_URI` in `.env`

### Step 5: Start the Server

```bash
# Development mode (with auto-reload)
npm run dev

# Production mode
npm start
```

You should see:
```
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║           ShowOff.life API Server                        ║
║                                                           ║
║   Server running on port 3000                            ║
║   Environment: development                               ║
║                                                           ║
║   API Documentation: http://localhost:3000/              ║
║   Health Check: http://localhost:3000/health            ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
MongoDB Connected: localhost
```

### Step 6: Test the Server

```bash
# Health check
curl http://localhost:3000/health

# Should return:
# {"success":true,"message":"Server is running","timestamp":"..."}
```

---

## 📱 Part 2: Flutter App Setup

### Step 1: Install Flutter Dependencies

```bash
cd apps
flutter pub get
```

### Step 2: Configure API Endpoint

Edit `apps/lib/config/api_config.dart`:

```dart
class ApiConfig {
  // For Android Emulator
  static const String baseUrl = 'http://10.0.2.2:3000/api';
  
  // For iOS Simulator
  // static const String baseUrl = 'http://localhost:3000/api';
  
  // For Real Device (replace with your computer's IP)
  // static const String baseUrl = 'http://192.168.1.100:3000/api';
  
  // For Production
  // static const String baseUrl = 'https://your-domain.com/api';
}
```

**Finding Your Computer's IP Address:**

**Windows:**
```bash
ipconfig
# Look for "IPv4 Address"
```

**macOS/Linux:**
```bash
ifconfig
# Look for "inet" under your active network interface
```

### Step 3: Run the App

**Android:**
```bash
flutter run
```

**iOS:**
```bash
cd ios
pod install
cd ..
flutter run
```

---

## 🧪 Testing the Complete System

### 1. Test User Registration

1. Open the app
2. Go through onboarding
3. Click "Sign Up"
4. Fill in the registration form:
   - Username: `testuser`
   - Display Name: `Test User`
   - Email: `test@example.com`
   - Password: `password123`
5. Complete profile setup:
   - Upload profile picture
   - Add display name
   - Select interests
   - Write bio
6. You should receive 50 coins for profile completion!

### 2. Test Post Upload

1. Click the "+" button in the navigation bar
2. Select "Upload Content"
3. Choose an image or video
4. Add a caption
5. Post it
6. You should receive 5 coins for the upload!

### 3. Test Coin System

**Watch Ad:**
- Go to Wallet screen
- Click "Watch Ad"
- Earn 10 coins

**Spin Wheel:**
- Go to Wallet screen
- Click "Spin Wheel"
- Win 5-50 coins (once per day)

**View Rewards:**
- Posts automatically earn coins based on views
- 10 coins per 1,000 views

### 4. Test SYT Competition

1. Go to Talent (SYT) screen
2. Click "Submit Entry"
3. Upload a video (max 3 minutes)
4. Fill in title, description, category
5. Choose competition type (weekly/monthly)
6. Submit
7. Other users can vote (1 vote per day)
8. Each vote earns you 1 coin!

### 5. Test Follow System

1. Search for a user
2. View their profile
3. Click "Follow"
4. Check followers/following counts

---

## 🔧 Troubleshooting

### Server Issues

**MongoDB Connection Error:**
```
Error: connect ECONNREFUSED 127.0.0.1:27017
```
**Solution:** Make sure MongoDB is running
```bash
# macOS
brew services start mongodb-community

# Windows
net start MongoDB

# Linux
sudo systemctl start mongod
```

**Wasabi S3 Upload Error:**
```
Error: Access Denied
```
**Solution:** 
- Check your Wasabi credentials in `.env`
- Verify bucket name is correct
- Ensure bucket policy allows uploads

### Flutter App Issues

**API Connection Error:**
```
SocketException: Failed to connect
```
**Solution:**
- Check if server is running (`http://localhost:3000/health`)
- Verify API endpoint in `api_config.dart`
- For Android Emulator, use `10.0.2.2` instead of `localhost`
- For real device, use your computer's IP address
- Ensure firewall allows connections on port 3000

**Package Installation Error:**
```bash
flutter pub get
# If errors occur, try:
flutter clean
flutter pub get
```

---

## 📊 Database Structure

The system creates these collections automatically:

- **users** - User accounts and profiles
- **posts** - User posts (images/videos/reels)
- **sytentries** - SYT competition entries
- **dailyselfies** - Daily selfie challenge
- **comments** - Comments on posts
- **likes** - Likes on content
- **follows** - Follow relationships
- **votes** - Competition votes
- **transactions** - Coin transaction history
- **withdrawals** - Withdrawal requests

---

## 🎯 Feature Checklist

After setup, verify these features work:

- [ ] User registration and login
- [ ] Profile setup with picture upload
- [ ] Profile completion rewards (50 coins)
- [ ] Post upload (images/videos)
- [ ] Upload rewards (5 coins per post)
- [ ] Social feed
- [ ] Like and comment system
- [ ] Follow/unfollow users
- [ ] SYT competition submission
- [ ] Voting system
- [ ] Daily spin wheel
- [ ] Watch ads for coins
- [ ] Coin balance tracking
- [ ] Transaction history
- [ ] Withdrawal system
- [ ] KYC submission

---

## 🚀 Production Deployment

### Backend Deployment

**Recommended Platforms:**
- **Heroku** - Easy deployment
- **AWS EC2** - Full control
- **DigitalOcean** - Simple and affordable
- **Railway** - Modern platform

**Steps:**
1. Set `NODE_ENV=production`
2. Use MongoDB Atlas for database
3. Set strong JWT secret
4. Configure CORS for your domain
5. Enable HTTPS
6. Set up monitoring (PM2, New Relic)

### Flutter App Deployment

**Android:**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS:**
```bash
flutter build ios --release
```

---

## 📞 Support

For issues or questions:
1. Check the troubleshooting section
2. Review server logs: `server/logs/`
3. Check Flutter console for errors
4. Verify all environment variables are set correctly

---

## 🎉 Success!

If you've completed all steps, you now have:
- ✅ Backend server running with MongoDB
- ✅ Wasabi S3 storage configured
- ✅ Flutter app connected to backend
- ✅ Complete coin reward system
- ✅ Social features (posts, likes, comments, follows)
- ✅ SYT competition system
- ✅ Withdrawal and KYC system

**Next Steps:**
- Customize the UI to match your brand
- Add more features as needed
- Test thoroughly before production
- Set up analytics and monitoring
- Configure push notifications
- Implement payment gateway integration

Happy coding! 🚀
