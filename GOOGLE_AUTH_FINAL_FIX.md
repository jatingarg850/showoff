# ✅ Google Auth Final Fix

## What I Did

I've updated both `google-services.json` files to include BOTH debug and release SHA-1 certificates:

### Debug SHA-1 (for testing):
```
b1b87e964211c49fbf61bedabc0b3706cee6997a
```

### Release SHA-1 (for production):
```
6a48e4e831b68ec8d4691b273465da605d03d759
```

## ⚠️ Important: Update Firebase Console

You MUST add the debug SHA-1 to Firebase Console for this to work:

### Step 1: Go to Firebase Console
https://console.firebase.google.com/project/showofflife-life/settings/general

### Step 2: Add Debug SHA-1
1. Scroll to **SHA certificate fingerprints**
2. Click **Add fingerprint**
3. Paste:
   ```
   B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A
   ```
4. Click **Save**

### Step 3: Verify Release SHA-1 is Already There
Make sure this is also in the list:
```
6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59
```

## 🔄 Test Now

1. **Hot restart your app:**
   ```bash
   # Press 'R' in Flutter terminal
   # Or restart:
   flutter run
   ```

2. **Try Google Sign-In**
   - Should work without error code 10

## 🐛 If Still Not Working

### Option 1: Wait 5 Minutes
Google servers need time to sync the new SHA-1 fingerprints.

### Option 2: Check Google Cloud Console
Go to: https://console.cloud.google.com/apis/credentials

1. Find your **OAuth 2.0 Client ID** for Android
2. Click **Edit**
3. Make sure it has BOTH SHA-1 fingerprints:
   - Debug: `B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A`
   - Release: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`

### Option 3: Clear App Data
```bash
# Uninstall app
adb uninstall com.showoff.life

# Reinstall
flutter run
```

## 📋 What Changed

### Before:
- `apps/android/app/google-services.json` - Only had release SHA-1
- `apps/h/google-services.json` - Had NO oauth_client

### After:
- Both files now have BOTH debug and release SHA-1 certificates
- Google Sign-In will work in both debug and release modes

## ✅ Next Steps

1. Add debug SHA-1 to Firebase Console (see Step 2 above)
2. Wait 2-3 minutes
3. Hot restart app
4. Test Google Sign-In
5. Should work! 🎉

---

**Status:** Files updated ✅ | Firebase Console needs update ⏳
