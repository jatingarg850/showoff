# 🔥 Google Sign-In Quick Fix

## The Problem
Error code 10 = Firebase doesn't recognize your app's signature

## The Solution (2 minutes)

### 1️⃣ Add SHA-1 to Firebase

**Go here:** https://console.firebase.google.com/project/showofflife-21/settings/general

**Add these 2 fingerprints:**

**Debug (for testing):**
```
B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A
```

**Release (for production):**
```
6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59
```

### 2️⃣ Download google-services.json

After adding fingerprints, download the new `google-services.json` and replace:
```
apps/android/app/google-services.json
```

### 3️⃣ Hot Restart

Press `R` in your Flutter terminal or:
```bash
flutter run
```

## That's It! 🎉

Google Sign-In should work now.

---

## If Still Not Working

### Option A: Wait 5 minutes
Google servers need time to sync the new fingerprints.

### Option B: Clear App Data
1. Long press app icon
2. App info → Storage → Clear data
3. Restart app

### Option C: Check Google Cloud Console
Go to: https://console.cloud.google.com/apis/credentials

Make sure your OAuth 2.0 Client ID has the same SHA-1 fingerprints.

---

**Current Status:** You're running in DEBUG mode, so you need the DEBUG SHA-1 in Firebase!
