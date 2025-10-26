# ShowOff.life - Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Start Backend Server (2 minutes)

```bash
cd server
npm install
cp .env.example .env
```

Edit `.env` file with your credentials:
- MongoDB URI (local or Atlas)
- Wasabi S3 credentials
- JWT secret

```bash
npm run dev
```

You should see:
```
MongoDB Connected: localhost
Server running on port 3000
```

### Step 2: Configure Flutter App (1 minute)

Edit `apps/lib/config/api_config.dart`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api'; // Android
// or
static const String baseUrl = 'http://localhost:3000/api'; // iOS
```

### Step 3: Run Flutter App (2 minutes)

```bash
cd apps
flutter pub get
flutter run
```

---

## ✅ Quick Test Flow

1. **Register** → Enter email/phone → Set password
2. **Setup Profile** → Upload picture → Add name → Select interests → Write bio
3. **Get 50 coins!** 🎉
4. **Upload Post** → Select image/video → Add caption → Post
5. **Get 5 coins!** 🎉
6. **View Feed** → See your post → Like other posts
7. **Check Wallet** → See your coins → Watch ad for more
8. **View Profile** → See your stats and posts

---

## 🔧 Troubleshooting

**Can't connect to server?**
- Check server is running: `curl http://localhost:3000/health`
- Update API URL in `api_config.dart`
- For Android Emulator, use `10.0.2.2` not `localhost`

**MongoDB connection error?**
- Start MongoDB: `brew services start mongodb-community` (Mac)
- Or use MongoDB Atlas cloud database

**Wasabi upload error?**
- Check credentials in `.env`
- Verify bucket name is correct
- Ensure bucket policy allows uploads

---

## 📱 Features to Test

✅ Authentication (email/phone)
✅ Profile setup with rewards
✅ Upload posts (images/videos)
✅ Feed with like/comment
✅ SYT competition
✅ Follow/unfollow
✅ Wallet & coins
✅ Transaction history
✅ Referrals

---

## 🎯 API Endpoints

All endpoints are at: `http://localhost:3000/api`

- `POST /auth/register` - Register user
- `POST /auth/login` - Login
- `POST /posts` - Upload post
- `GET /posts/feed` - Get feed
- `POST /posts/:id/like` - Like post
- `POST /syt/submit` - Submit SYT entry
- `POST /syt/:id/vote` - Vote
- `POST /follow/:userId` - Follow user
- `GET /coins/balance` - Get balance
- `POST /coins/watch-ad` - Watch ad
- `GET /coins/transactions` - Transaction history

---

## 💡 Tips

- Use Postman to test API endpoints first
- Check server logs for errors
- Use Flutter DevTools for debugging
- Test on real device for best experience
- MongoDB Compass to view database

---

**Ready to go! Start building your social media empire! 🚀**
