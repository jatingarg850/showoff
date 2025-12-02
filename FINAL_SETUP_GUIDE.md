# Final Setup Guide - Using Original Keystore

## ✅ Keystore Configuration

### Your Original Keystore:
- **Location:** `apps/key/key.jks`
- **Password:** `flashcoders`
- **Alias:** `key`

### SHA Fingerprints:
**SHA-1:**
```
6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59
```

**SHA-256:**
```
91:CA:60:E6:EC:01:66:59:71:07:26:6A:45:BE:D5:6D:1C:A6:3C:35:34:7D:47:40:05:12:38:C6:8B:A6:01:AA
```

## 🔧 What You Need to Do Now:

### 1. Update Firebase Console
Go to: https://console.firebase.google.com/project/showofflife-life/settings/general

**Add SHA-1 Fingerprint:**
- Scroll to your Android app (`com.showoff.life`)
- Under "SHA certificate fingerprints", click "Add fingerprint"
- Add: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`

### 2. Update Google Cloud Console OAuth
Go to: https://console.cloud.google.com/apis/credentials?project=showofflife-life

**Update or Create New OAuth Client:**
- Find your Android OAuth client or create new one
- Package name: `com.showoff.life`
- SHA-1: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`

### 3. Download Updated google-services.json
After adding the SHA-1, download the new `google-services.json` from Firebase and replace:
```
apps/android/app/google-services.json
```

### 4. Rebuild the App
```bash
cd apps
flutter clean
flutter build appbundle --release
```

## 📦 Your Release AAB Will Be At:
```
apps/build/app/outputs/bundle/release/app-release.aab
```

## 🎯 App Details:
- **Package Name:** `com.showoff.life`
- **Version:** 1.8.0 (Build 8)
- **Keystore:** `apps/key/key.jks`
- **Password:** `flashcoders`

## ⚠️ Important Notes:

1. **This keystore is different** from the one we created earlier
2. **You MUST update Firebase and Google Cloud** with the new SHA-1
3. **Download the updated google-services.json** after adding SHA-1
4. **This keystore will work for Play Store** if it was used for previous versions

## 🔐 Backup Your Keystore:
Make sure to backup these files securely:
- `apps/key/key.jks`
- `apps/key/key.properties`

Without these, you cannot update your app in the future!

---

**Next Steps:**
1. Add SHA-1 to Firebase
2. Update OAuth in Google Cloud
3. Download new google-services.json
4. Rebuild AAB
5. Upload to Play Store
