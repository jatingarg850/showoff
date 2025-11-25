# Get Firebase Configuration Files

## ✅ Dependencies Installed!

I've installed:
- ✅ `firebase_core` and `firebase_messaging` in Flutter
- ✅ `firebase-admin` in server

Now you just need 2 files from Firebase Console:

---

## Step 1: Get google-services.json (5 minutes)

### 1.1 Go to Firebase Console
https://console.firebase.google.com/

### 1.2 Create/Select Project
- If you already have "showofflife-21" project, select it
- Otherwise, create a new project

### 1.3 Add Android App
1. Click the Android icon (or Project Settings → Your apps)
2. Click "Add app" or "Add Android app"
3. Fill in:
   - **Package name**: `com.example.apps`
   - **App nickname**: ShowOff Android
   - **Debug signing certificate**: Leave blank (optional)
4. Click "Register app"

### 1.4 Download google-services.json
1. Click "Download google-services.json"
2. **Save it to**: `C:\Users\coddy\Music\showoff\apps\android\app\google-services.json`

**Important**: The file MUST be in `apps/android/app/` folder!

---

## Step 2: Get Firebase Service Account Key (5 minutes)

### 2.1 In Firebase Console
Go to: **Project Settings** (gear icon) → **Service Accounts** tab

### 2.2 Generate Private Key
1. Click "Generate new private key"
2. Click "Generate key" in the popup
3. A JSON file will download (e.g., `showofflife-21-firebase-adminsdk-xxxxx.json`)

### 2.3 Save the File
1. Rename it to: `firebase-service-account.json`
2. **Move it to**: `C:\Users\coddy\Music\showoff\server\firebase-service-account.json`

**Important**: The file MUST be in `server/` folder!

---

## Step 3: Add to .gitignore

Make sure these files are NOT committed to git:

```
# Add to .gitignore
firebase-service-account.json
google-services.json
```

---

## Step 4: Rebuild Flutter App

```powershell
cd apps
flutter clean
flutter pub get
flutter run
```

---

## ✅ Verification

### After placing the files, you should see:

**Flutter logs:**
```
✅ Firebase initialized
✅ FCM permission granted
📱 FCM Token: [token]...
✅ FCM token sent to server
```

**Server logs:**
```
✅ Firebase Admin initialized
```

---

## 🎯 File Locations Summary

```
showoff/
├── apps/
│   └── android/
│       └── app/
│           └── google-services.json  ← Place here!
└── server/
    └── firebase-service-account.json  ← Place here!
```

---

## 🐛 Troubleshooting

### "google-services.json not found"
- Check file is in: `apps/android/app/google-services.json`
- File name must be exactly: `google-services.json`

### "Firebase Admin initialization failed"
- Check file is in: `server/firebase-service-account.json`
- File name must be exactly: `firebase-service-account.json`

### "Package name mismatch"
- Make sure you used package name: `com.example.apps`
- This matches your `build.gradle.kts` file

---

## 📝 Quick Checklist

- [ ] Go to Firebase Console
- [ ] Create/select project
- [ ] Add Android app with package `com.example.apps`
- [ ] Download `google-services.json`
- [ ] Place in `apps/android/app/`
- [ ] Go to Service Accounts
- [ ] Generate private key
- [ ] Rename to `firebase-service-account.json`
- [ ] Place in `server/`
- [ ] Add both to `.gitignore`
- [ ] Rebuild Flutter app
- [ ] Test notifications!

---

## 🎉 That's It!

Once you have both files in place:
1. Rebuild Flutter app
2. Restart server
3. Test notifications - they'll work in background! 🚀

---

**Firebase Console**: https://console.firebase.google.com/  
**Your Project**: showofflife-21  
**Time**: ~10 minutes total
