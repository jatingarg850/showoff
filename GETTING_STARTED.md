# Getting Started with ShowOff.life

## ✅ What's Working

### Backend (Server)
- ✅ MongoDB connected
- ✅ User registration and authentication
- ✅ OTP verification for phone signup
- ✅ Profile management
- ✅ File uploads (local storage fallback)
- ✅ Coin system
- ✅ All API endpoints functional

### Frontend (Flutter App)
- ✅ Complete UI implementation
- ✅ Authentication flow (signup, login, OTP)
- ✅ Profile setup and editing
- ✅ Navigation and routing
- ✅ All screens implemented

## 🎯 Quick Start Guide

### 1. Start the Backend Server

```bash
cd server
npm run dev
```

The server will start on `http://localhost:3000`

**Check the console for OTP codes during development!**

### 2. Start the Flutter App

```bash
cd apps
flutter run
```

### 3. Create Your First Account

1. **Sign Up** with phone number
2. **Enter OTP** (check server console for the code)
3. **Set Password**
4. **Complete Profile** (name, bio, interests, profile picture)
5. **Upload Content** to start earning coins!

## 📱 Current App State

### What You Can Do Now:

✅ **Authentication**
- Sign up with phone/email
- OTP verification (codes logged in server console)
- Login with credentials

✅ **Profile**
- Complete profile setup
- Upload profile picture
- Edit bio and interests
- View profile completion percentage

✅ **Navigation**
- Browse all screens
- See UI/UX design
- Test navigation flow

### What Needs Real Data:

⚠️ **Feed/Reels**
- Currently shows dummy data
- Upload videos to see real content
- Comments/likes will work once posts exist

⚠️ **Search**
- Shows demo users
- Will show real users once they sign up

⚠️ **SYT (Show Your Talent)**
- Ready to accept entries
- Needs users to submit content

## 🔧 Known Issues & Solutions

### Issue: "No posts available"
**Solution:** Upload your first video/image post!
- Go to upload screen
- Select video/image
- Add caption
- Post to feed

### Issue: "This is demo data"
**Solution:** This is expected for search results until more users sign up

### Issue: Comments not working
**Solution:** Comments only work on real posts, not dummy data

### Issue: Can't see OTP code
**Solution:** Check the server terminal/console - OTP codes are logged there in development mode

## 🚀 Next Steps to Full Functionality

### 1. Create Content
Upload videos and images to populate the feed:
- Use the upload button in the app
- Add captions and hashtags
- Posts will appear in feed for all users

### 2. Invite Friends
- Share your referral code
- Earn coins for referrals
- Build your network

### 3. Engage with Content
Once posts exist:
- Like and comment
- Send gifts
- Bookmark favorites
- Share content

### 4. Earn Coins
- Upload content (5 coins per post)
- Get views (10 coins per 1000 views)
- Receive gifts
- Referrals (50 coins for first 100, 20 after)
- Watch ads
- Spin the wheel daily

### 5. Withdraw Earnings
Once you have enough coins:
- Go to Wallet
- Request withdrawal
- Minimum: 10,000 coins ($100)

## 🔐 Environment Setup

### Backend (.env)
Already configured with defaults:
- MongoDB: `mongodb://localhost:27017/showoff_life`
- JWT Secret: Set for development
- File uploads: Local storage (no S3 needed for dev)
- Coin system: All configured

### Frontend (API Config)
Already pointing to: `http://localhost:3000/api`

## 📊 Testing the Coin System

1. **Complete Profile** → Get completion bonus
2. **Upload 10 Posts** → Get upload bonus
3. **Spin Wheel** → Daily chance to win coins
4. **Refer Friends** → Earn referral coins
5. **Get Views** → Earn from engagement

## 🎨 Features Overview

### Implemented Features:
- ✅ User authentication (phone/email)
- ✅ OTP verification
- ✅ Profile management
- ✅ Post upload (images/videos)
- ✅ Feed/Reels view
- ✅ Comments system
- ✅ Likes and bookmarks
- ✅ Gift sending
- ✅ Coin system
- ✅ Withdrawal requests
- ✅ SYT competitions
- ✅ Spin wheel
- ✅ Referral system
- ✅ Search users
- ✅ Notifications
- ✅ Settings

### Ready for Production:
- Configure S3/Wasabi for file storage
- Set up SMS/Email service for OTP
- Configure payment gateway (Razorpay)
- Set up proper database (MongoDB Atlas)
- Configure environment variables

## 💡 Tips

1. **Development Mode**: OTP codes are logged to console and returned in API response
2. **File Uploads**: Using local storage - files saved to `server/uploads/`
3. **Dummy Data**: Search and some screens show demo data until real content exists
4. **Coin Balance**: Starts at 0, earn by completing profile and uploading content
5. **Profile Completion**: Upload picture, add bio, select interests to reach 100%

## 🐛 Troubleshooting

### Server won't start
- Check MongoDB is running: `mongod`
- Check port 3000 is available
- Run `npm install` in server directory

### App won't connect to server
- Check server is running
- Verify API URL in `apps/lib/config/api_config.dart`
- Check firewall settings

### Can't upload files
- Check `server/uploads/` directory exists
- Verify file size limits in `.env`
- Check file type is allowed (images/videos)

### OTP not working
- Check server console for OTP code
- Verify phone number format
- Check OTP hasn't expired (5 minutes)

## 📞 Support

For issues or questions:
1. Check server console for errors
2. Check Flutter console for errors
3. Review API responses in network tab
4. Check this documentation

---

**Ready to start?** Follow the Quick Start Guide above! 🚀
