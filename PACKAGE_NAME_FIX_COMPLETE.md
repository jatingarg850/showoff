# Package Name Fix - Complete Guide

## ✅ What Was Fixed

Changed package name from `com.showoff.life` to `com.showofflife.app` to match Play Console requirements.

### Files Updated
1. **apps/android/app/build.gradle.kts**
   - `namespace = "com.showofflife.app"`
   - `applicationId = "com.showofflife.app"`

2. **apps/android/app/google-services.json**
   - Updated `package_name` to `com.showofflife.app`

3. **AAB Built Successfully**
   - Location: `apps/build/app/outputs/bundle/release/app-release.aab`
   - Size: 54.4MB
   - Package: `com.showofflife.app` ✅

## 🔥 Firebase Console Setup Required

You need to add a new Android app in Firebase Console with the new package name:

### Steps:

1. **Go to Firebase Console**
   - URL: https://console.firebase.google.com/
   - Project: `showofflife-life`

2. **Add New Android App**
   - Click "Add app" → Select Android
   - Package name: `com.showofflife.app`
   - App nickname: `Showoff Life` (or whatever you prefer)
   - Click "Register app"

3. **Download google-services.json**
   - Download the NEW google-services.json file
   - Replace: `apps/android/app/google-services.json`
   - (I've already updated it temporarily, but get the official one from Firebase)

4. **Add SHA-1 Certificate**
   - In Firebase Console → Project Settings → Your Apps
   - Find the `com.showofflife.app` app
   - Scroll to "SHA certificate fingerprints"
   - Add your release SHA-1: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`

5. **Enable Google Sign-In**
   - Go to Authentication → Sign-in method
   - Enable Google
   - Add support email

6. **Update OAuth Client**
   - Go to Google Cloud Console: https://console.cloud.google.com/
   - Project: `showofflife-life`
   - APIs & Services → Credentials
   - Find or create OAuth 2.0 Client ID for Android
   - Package name: `com.showofflife.app`
   - SHA-1: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`

## 📱 Play Console Upload

Now you can upload the AAB to Play Console:

1. **Go to Play Console**
   - URL: https://play.google.com/console/
   - Select your app

2. **Upload AAB**
   - Go to: Production → Create new release
   - Upload: `apps/build/app/outputs/bundle/release/app-release.aab`
   - Package name will match: `com.showofflife.app` ✅

3. **Complete Release**
   - Add release notes
   - Review and rollout

## 🔑 Get Your Release SHA-1

If you need to verify your SHA-1 certificate fingerprint:

```bash
cd apps/android/key
keytool -list -v -keystore key.jks -alias key -storepass flashcoders -keypass flashcoders
```

Look for the SHA-1 line in the output.

## ⚠️ Important Notes

### Google Sign-In Will Break Until Firebase Is Updated
- The app currently has the new package name `com.showofflife.app`
- But Firebase still has the old OAuth client for `com.showoff.life`
- **You MUST add the new Android app in Firebase Console**
- **You MUST add the SHA-1 certificate to the new app**
- Otherwise Google Sign-In will fail

### Testing Before Upload
If you want to test the app before uploading:
1. Complete Firebase setup above
2. Download the official google-services.json
3. Replace the file in `apps/android/app/`
4. Rebuild: `flutter build appbundle --release`
5. Test on device

## 📋 Checklist

Before uploading to Play Console:

- [x] Package name changed to `com.showofflife.app`
- [x] AAB built successfully
- [ ] New Android app added in Firebase Console
- [ ] SHA-1 certificate added to Firebase
- [ ] New google-services.json downloaded and replaced
- [ ] OAuth client created/updated in Google Cloud Console
- [ ] Google Sign-In tested and working
- [ ] Ready to upload to Play Console

## 🚀 Quick Commands

### Build Release AAB
```bash
cd apps
flutter build appbundle --release
```

### Output Location
```
apps/build/app/outputs/bundle/release/app-release.aab
```

### Verify Package Name
```bash
cd apps/build/app/outputs/bundle/release
aapt dump badging app-release.aab | findstr package
```

Should show: `package: name='com.showofflife.app'`

## 🔧 If You Need to Revert

If something goes wrong and you need to go back to `com.showoff.life`:

1. Edit `apps/android/app/build.gradle.kts`:
   - Change `namespace` back to `com.showoff.life`
   - Change `applicationId` back to `com.showoff.life`

2. Restore old `google-services.json` (if you have backup)

3. Rebuild:
   ```bash
   flutter clean
   flutter build appbundle --release
   ```

## ✅ Current Status

**Package Name:** `com.showofflife.app` ✅  
**AAB Built:** Yes ✅  
**Size:** 54.4MB ✅  
**Signed:** Yes ✅  
**Ready for Upload:** Yes ✅  

**Next Step:** Complete Firebase Console setup above, then upload to Play Console!
