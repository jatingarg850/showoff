# Quick Release Steps - Play Store

## 🚀 3-Step Release Process

### Step 1: Verify Setup (30 seconds)
```bash
verify_release_setup.bat
```
**Expected:** All checks pass ✅

### Step 2: Build App Bundle (10-30 minutes)
```bash
build_playstore_release.bat
```
**Output:** `apps/build/app/outputs/bundle/release/app-release.aab`

### Step 3: Upload to Play Store (5 minutes)
1. Go to [Play Console](https://play.google.com/console)
2. Upload `app-release.aab`
3. Submit for review

---

## 📋 Configuration Summary

| Item | Value |
|------|-------|
| Package | `com.showoff.life` |
| Release SHA-1 | `6a48e4e831b68ec8d4691b273465da605d03d759` |
| Keystore | `key/key.jks` |
| Alias | `key` |
| Password | `flashcoders` |

---

## 🔧 Manual Build (if needed)

```bash
# 1. Copy release config
copy apps\h\google-services.json apps\android\app\google-services.json

# 2. Build
cd apps
flutter clean
flutter pub get
flutter build appbundle --release

# 3. Find output
# apps\build\app\outputs\bundle\release\app-release.aab
```

---

## ⚠️ Before Building

- [ ] Keystore exists at `key/key.jks`
- [ ] Release google-services.json at `apps/h/google-services.json`
- [ ] Version updated in `apps/pubspec.yaml`
- [ ] All features tested

---

## 🐛 Quick Fixes

### Keystore not found
```bash
# Check if exists
dir key\key.jks
```

### Wrong google-services.json
```bash
# Verify SHA-1
findstr "6a48e4e831b68ec8d4691b273465da605d03d759" apps\h\google-services.json
```

### Build fails
```bash
cd apps
flutter clean
flutter pub get
flutter doctor
```

---

## 📦 Output Location

```
apps/
  build/
    app/
      outputs/
        bundle/
          release/
            app-release.aab  ← Upload this file
```

---

## ✅ Success Indicators

### Build Success:
```
✅ App Bundle built successfully!
📦 app-release.aab created
```

### Upload Success:
```
✅ Upload complete
✅ Processing successful
```

### Release Success:
```
✅ Review approved
✅ App published
```

---

## 🎯 Quick Commands

```bash
# Verify setup
verify_release_setup.bat

# Build release
build_playstore_release.bat

# Check Flutter
flutter doctor

# Check version
type apps\pubspec.yaml | findstr "version:"

# Check keystore SHA-1
keytool -list -v -keystore key\key.jks -alias key
```

---

## 📞 Need Help?

1. Check `PLAY_STORE_RELEASE_GUIDE.md` for detailed guide
2. Run `verify_release_setup.bat` to diagnose issues
3. Check error messages carefully
4. Verify all files exist

---

## 🎉 After Release

1. Monitor Play Console for crashes
2. Respond to user reviews
3. Track install statistics
4. Plan next update

---

**Last Updated:** December 2, 2025
**App Version:** 1.0.0+1
**Build Type:** Release (Play Store)
