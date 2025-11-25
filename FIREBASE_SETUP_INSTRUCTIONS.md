# Firebase Setup - Final Steps

## ✅ Code Implementation Complete!

I've implemented all the code for Firebase Cloud Messaging. Now you need to complete these manual steps:

---

## Step 1: Create Firebase Project (5 minutes)

1. **Go to Firebase Console**: https://console.firebase.google.com/
2. **Create Project**:
   - Click "Add project"
   - Name: "ShowOff" (or your choice)
   - Disable Google Analytics (optional)
   - Click "Create project"

---

## Step 2: Add Android App (5 minutes)

1. **In Firebase Console**, click the Android icon
2. **Register app**:
   - Package name: `com.example.apps`
   - App nickname: "ShowOff Android"
   - Click "Register app"

3. **Download google-services.json**:
   - Click "Download google-services.json"
   - **Save it to**: `apps/android/app/google-services.json`
   - This file is required for Firebase to work!

---

## Step 3: Get Firebase Service Account Key (5 minutes)

1. **In Firebase Console**, go to:
   - Project Settings (gear icon) → Service Accounts
2. **Generate new private key**:
   - Click "Generate new private key"
   - Click "Generate key"
   - A JSON file will download

3. **Save the file**:
   - Rename it to: `firebase-service-account.json`
   - **Move it to**: `server/firebase-service-account.json`
   - **Important**: Add to `.gitignore` (don't commit this file!)

---

## Step 4: Install Dependencies

### Flutter Dependencies:
```bash
cd apps
flutter pub add firebase_core firebase_messaging
flutter pub get
```

### Server Dependencies:
```bash
cd server
npm install firebase-admin
```

---

## Step 5: Update .gitignore

Add these lines to your `.gitignore`:
```
# Firebase
firebase-service-account.json
google-services.json
```

---

## Step 6: Rebuild and Test

### Rebuild Flutter App:
```bash
cd apps
flutter clean
flutter pub get
flutter run
```

### Check Logs:
Look for these in Flutter console:
```
✅ Firebase initialized
✅ FCM permission granted
📱 FCM Token: [token]...
✅ FCM token sent to server
```

### Test Notifications:

#### Test 1: Foreground (App Open)
1. Keep app open
2. Send notification from admin panel
3. Should see notification in app

#### Test 2: Background (App Minimized)
1. Press HOME button
2. Send notification
3. **Should see push notification!** 🎉

#### Test 3: Closed App
1. Close app completely
2. Send notification
3. **Should see push notification!** 🎉

---

## 🎯 What I've Implemented

### Flutter Side:
- ✅ FCM service (`apps/lib/services/fcm_service.dart`)
- ✅ Firebase initialization in `main.dart`
- ✅ Background message handler
- ✅ Foreground message handler
- ✅ Notification tap handler
- ✅ Token management

### Server Side:
- ✅ FCM service (`server/utils/fcmService.js`)
- ✅ User model updated (added `fcmToken` field)
- ✅ FCM token endpoint (`POST /api/users/fcm-token`)
- ✅ Notification controller updated (sends via FCM)
- ✅ Bulk FCM sending support
- ✅ Invalid token cleanup

### Android Configuration:
- ✅ build.gradle updated (Google Services plugin)
- ✅ AndroidManifest.xml updated (FCM service)
- ✅ Notification channel configured

---

## 📋 Checklist

Before testing, make sure you have:

- [ ] Created Firebase project
- [ ] Added Android app to Firebase
- [ ] Downloaded `google-services.json`
- [ ] Placed `google-services.json` in `apps/android/app/`
- [ ] Downloaded Firebase service account key
- [ ] Placed `firebase-service-account.json` in `server/`
- [ ] Added both files to `.gitignore`
- [ ] Installed Flutter dependencies (`firebase_core`, `firebase_messaging`)
- [ ] Installed server dependencies (`firebase-admin`)
- [ ] Rebuilt Flutter app
- [ ] Restarted server

---

## 🐛 Troubleshooting

### Issue: "google-services.json not found"
**Solution**: Make sure the file is in `apps/android/app/google-services.json`

### Issue: "Firebase Admin initialization failed"
**Solution**: Make sure `firebase-service-account.json` is in `server/` folder

### Issue: No FCM token in logs
**Solution**: 
- Check Firebase permission granted
- Rebuild app: `flutter clean && flutter pub get && flutter run`

### Issue: Notifications not received in background
**Solution**:
- Check FCM token saved in database
- Check server logs for FCM send confirmation
- Make sure Firebase service account key is correct

---

## ✅ Success Indicators

When everything works, you'll see:

### Flutter Logs:
```
✅ Firebase initialized
✅ FCM permission granted
📱 FCM Token: eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9...
✅ FCM token sent to server
```

### Server Logs (when sending notification):
```
✅ Batch 1: Created 1 notifications in database
📡 Batch 1: WebSocket: 1, FCM: 1
✅ FCM notification sent to user 6925455a0916073edcd40dad
```

### User Experience:
- ✅ Notification appears when app is open
- ✅ Push notification when app is in background
- ✅ Push notification when app is closed
- ✅ Can tap notification to open app

---

## 🎉 You're Almost Done!

Just complete the 3 manual steps:
1. Create Firebase project
2. Download `google-services.json`
3. Download service account key

Then rebuild and test!

---

**Need Help?**
- Firebase Console: https://console.firebase.google.com/
- Firebase Docs: https://firebase.google.com/docs/cloud-messaging
- Flutter Firebase: https://firebase.flutter.dev/

---

**Status**: Code implementation ✅ COMPLETE  
**Next**: Complete manual Firebase setup steps above  
**Time**: ~15 minutes for manual steps
