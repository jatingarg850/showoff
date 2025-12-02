# Fix Google Sign-In for Debug Mode

## Problem
Google Sign-In fails with error code 10 because Firebase doesn't have your **debug keystore** SHA-1 fingerprint.

## Your SHA-1 Fingerprints

### Debug Mode (Current Issue)
**SHA-1:** `B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A`
**SHA-256:** `69:E1:79:53:38:5B:FA:34:26:9F:26:91:24:88:B6:14:4C:68:7D:42:C0:08:AB:3C:89:9F:DE:F7:BD:42:2C:74`

### Release Mode
**SHA-1:** `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`
**SHA-256:** `91:CA:60:E6:EC:01:66:59:71:07:26:6A:45:BE:D5:6D:1C:A6:3C:35:34:7D:47:40:05:12:38:C6:8B:A6:01:AA`

## Quick Fix (5 minutes)

### Step 1: Go to Firebase Console
1. Open: https://console.firebase.google.com/
2. Select project: **showofflife-21**
3. Click **Project Settings** (gear icon)

### Step 2: Add Debug SHA-1
1. Scroll to **Your apps** → Find Android app `com.showoff.life`
2. Scroll to **SHA certificate fingerprints**
3. Click **Add fingerprint**
4. Paste DEBUG SHA-1:
   ```
   B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A
   ```
5. Click **Save**

### Step 3: Add Release SHA-1 (for production)
1. Click **Add fingerprint** again
2. Paste RELEASE SHA-1:
   ```
   6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59
   ```
3. Click **Save**

### Step 4: Download New google-services.json
1. Click **Download google-services.json**
2. Replace file at: `apps/android/app/google-services.json`

### Step 5: Update Google Cloud Console
1. Go to: https://console.cloud.google.com/
2. Select your project
3. Go to **APIs & Services** → **Credentials**
4. Find **OAuth 2.0 Client ID** for Android
5. Click **Edit**
6. Add BOTH SHA-1 fingerprints:
   - Debug: `B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A`
   - Release: `6A:48:E4:E8:31:B6:8E:C8:D4:69:1B:27:34:65:DA:60:5D:03:D7:59`
7. Click **Save**

### Step 6: Hot Restart App
```bash
# In your running app, press 'R' for hot restart
# Or stop and restart:
flutter run
```

## Why This Happens

- **Debug builds** use Android's default debug keystore
- **Release builds** use your custom keystore (`key.jks`)
- Each keystore has a different SHA-1 fingerprint
- Firebase needs BOTH to work in debug and release modes

## Verification

After adding fingerprints:
1. Wait 2-3 minutes for changes to propagate
2. Hot restart your app
3. Try Google Sign-In
4. Should work without error code 10

## Alternative: Use Release Build for Testing

If you don't want to update Firebase:
```bash
flutter build apk --release
flutter install
```

This will use your release keystore which may already be configured.

## Troubleshooting

### Still getting error 10?
1. Make sure you added the correct SHA-1 (copy-paste carefully)
2. Wait 5-10 minutes for Google servers to sync
3. Clear app data: Settings → Apps → ShowOff → Clear Data
4. Uninstall and reinstall the app

### Wrong package name?
- Verify package name is: `com.showoff.life`
- Check in `apps/android/app/build.gradle.kts`

### OAuth not configured?
1. Go to Google Cloud Console
2. **APIs & Services** → **OAuth consent screen**
3. Make sure it's configured and published

---

**Quick Action:** Add debug SHA-1 `B1:B8:7E:96:42:11:C4:9F:BF:61:BE:DA:BC:0B:37:06:CE:E6:99:7A` to Firebase Console now!
