# Fix Google Sign-In After Keystore Change

## Problem
Google Sign-In is failing with error code 10 because the new keystore's SHA-1 fingerprint is not registered in Firebase Console.

## Your New Keystore Fingerprints

**SHA-1:**
```
0F:EC:A5:BE:CF:83:10:37:1B:4E:D2:71:7A:55:C8:E5:70:62:0B:47
```

**SHA-256:**
```
80:B3:28:72:03:06:01:18:1C:A6:90:C5:7A:71:C8:65:E3:BA:1C:73:15:8B:44:C9:B7:68:77:28:0F:A5:29:81
```

## Steps to Fix

### 1. Go to Firebase Console
1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **showofflife-21**

### 2. Update Android App Configuration
1. Click on **Project Settings** (gear icon)
2. Scroll down to **Your apps** section
3. Find your Android app with package name: `com.showoff.life`
4. Click on the app to expand settings

### 3. Add New SHA Fingerprints
1. Scroll to **SHA certificate fingerprints** section
2. Click **Add fingerprint**
3. Add the SHA-1:
   ```
   0F:EC:A5:BE:CF:83:10:37:1B:4E:D2:71:7A:55:C8:E5:70:62:0B:47
   ```
4. Click **Add fingerprint** again
5. Add the SHA-256:
   ```
   80:B3:28:72:03:06:01:18:1C:A6:90:C5:7A:71:C8:65:E3:BA:1C:73:15:8B:44:C9:B7:68:77:28:0F:A5:29:81
   ```

### 4. Download New google-services.json
1. After adding fingerprints, click **Download google-services.json**
2. Replace the file at: `apps/android/app/google-services.json`

### 5. Update Google Cloud Console (OAuth)
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project
3. Go to **APIs & Services** > **Credentials**
4. Find your **OAuth 2.0 Client ID** for Android
5. Update the **SHA-1 certificate fingerprint** to:
   ```
   0F:EC:A5:BE:CF:83:10:37:1B:4E:D2:71:7A:55:C8:E5:70:62:0B:47
   ```

### 6. Rebuild the App
```bash
cd apps
flutter clean
flutter pub get
flutter build appbundle --release
```

## Alternative: Create New Android App in Firebase

If the above doesn't work, you may need to create a new Android app in Firebase:

1. In Firebase Console, click **Add app** > **Android**
2. Package name: `com.showoff.life`
3. App nickname: ShowOff.life
4. Add both SHA-1 and SHA-256 fingerprints
5. Download the new `google-services.json`
6. Replace in your project

## Verification

After updating, test Google Sign-In:
1. Uninstall the app from your device
2. Install the new AAB
3. Try Google Sign-In
4. Should work without error code 10

## Important Notes

- The package name changed from `com.example.apps` to `com.showoff.life`
- The keystore changed, so SHA fingerprints are different
- Both Firebase and Google Cloud Console need to be updated
- You may need to wait 5-10 minutes for changes to propagate

## Troubleshooting

If still not working:
1. Check that package name matches exactly: `com.showoff.life`
2. Verify SHA-1 is correct in both Firebase and Google Cloud
3. Make sure you downloaded the latest google-services.json
4. Clear app data and try again
5. Check that OAuth consent screen is configured

---

**Quick Fix:** Update Firebase SHA-1 fingerprint and download new google-services.json!
