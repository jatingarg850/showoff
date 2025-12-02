# Google Play Store Release Guide

## Overview
Complete guide to build and release ShowOff.life app to Google Play Store with correct release configuration.

## Prerequisites Checklist

### ✅ Required Files
- [x] Release keystore: `key/key.jks`
- [x] Key properties: `apps/key/key.properties`
- [x] Release google-services.json: `apps/h/google-services.json`
- [x] Build configuration: `apps/android/app/build.gradle.kts`

### ✅ Configuration Details
- **Package Name:** `com.showoff.life`
- **Release SHA-1:** `6a48e4e831b68ec8d4691b273465da605d03d759`
- **Keystore Alias:** `key`
- **Keystore Password:** `flashcoders`

## Quick Start

### Step 1: Verify Setup
```bash
verify_release_setup.bat
```

This will check:
- ✅ Release google-services.json exists
- ✅ Correct SHA-1 fingerprint
- ✅ Keystore exists
- ✅ key.properties configured
- ✅ Build configuration
- ✅ Flutter installation

### Step 2: Build App Bundle
```bash
build_playstore_release.bat
```

This will:
1. Copy release google-services.json
2. Verify keystore
3. Clean previous builds
4. Get dependencies
5. Build app bundle
6. Show output location

### Step 3: Upload to Play Store
1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app
3. Go to "Release" → "Production"
4. Click "Create new release"
5. Upload `apps/build/app/outputs/bundle/release/app-release.aab`
6. Fill in release notes
7. Submit for review

## Manual Build Steps

If you prefer to build manually:

### 1. Copy Release Configuration
```bash
copy apps\h\google-services.json apps\android\app\google-services.json
```

### 2. Clean Build
```bash
cd apps
flutter clean
flutter pub get
```

### 3. Build App Bundle
```bash
flutter build appbundle --release
```

### 4. Find Output
```
apps\build\app\outputs\bundle\release\app-release.aab
```

## Release Configuration Files

### 1. google-services.json (Release)
Location: `apps/h/google-services.json`

Contains:
- Firebase project configuration
- Release SHA-1 fingerprint
- OAuth client IDs for release
- API keys

**Important:** This is different from debug google-services.json!

### 2. key.properties
Location: `apps/key/key.properties`

```properties
storePassword=flashcoders
keyPassword=flashcoders
keyAlias=key
storeFile=../../key/key.jks
```

### 3. Keystore
Location: `key/key.jks`

- **Type:** JKS (Java KeyStore)
- **Alias:** key
- **Password:** flashcoders
- **SHA-1:** 6a48e4e831b68ec8d4691b273465da605d03d759

## SHA-1 Fingerprints

### Debug SHA-1
```
50:55:54:AA:76:69:64:65:6F:2F:6D:70:34:AA:78:2D:61:6D:7A:2D
```
Used for: Development and testing

### Release SHA-1
```
6a48e4e831b68ec8d4691b273465da605d03d759
```
Used for: Play Store release

## Google Services Configuration

### Debug (apps/android/app/google-services.json)
- Used during development
- Debug SHA-1 fingerprint
- Local testing

### Release (apps/h/google-services.json)
- Used for Play Store
- Release SHA-1 fingerprint
- Production environment

## Build Output

### App Bundle (.aab)
- **Location:** `apps/build/app/outputs/bundle/release/app-release.aab`
- **Size:** ~50-100 MB (varies)
- **Format:** Android App Bundle
- **Signed:** Yes (with release keystore)

### What's Included:
- ✅ All app code and resources
- ✅ Release signing
- ✅ Optimized for Play Store
- ✅ Multiple APK variants (for different devices)

## Troubleshooting

### Error: "Keystore not found"
**Solution:**
```bash
# Create keystore if missing
keytool -genkey -v -keystore key/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
```

### Error: "google-services.json not found"
**Solution:**
```bash
# Copy release version
copy apps\h\google-services.json apps\android\app\google-services.json
```

### Error: "Signing config not found"
**Solution:** Check `apps/android/app/build.gradle.kts` has:
```kotlin
signingConfigs {
    create("release") {
        storeFile = file(keystoreProperties["storeFile"] as String)
        storePassword = keystoreProperties["storePassword"] as String
        keyAlias = keystoreProperties["keyAlias"] as String
        keyPassword = keystoreProperties["keyPassword"] as String
    }
}
```

### Error: "Google Sign-In not working"
**Solution:** Verify SHA-1 in Firebase Console matches keystore:
```bash
keytool -list -v -keystore key/key.jks -alias key
```

### Build is slow
**Normal:** First build takes 5-15 minutes
**Subsequent builds:** 2-5 minutes

## Version Management

### Update Version
Edit `apps/pubspec.yaml`:
```yaml
version: 1.0.0+1
#        ↑     ↑
#     version  build number
```

- **Version:** User-facing (1.0.0, 1.0.1, 1.1.0)
- **Build Number:** Internal (1, 2, 3, 4...)

### Version History
- 1.0.0+1 - Initial release
- 1.0.1+2 - Bug fixes
- 1.1.0+3 - New features

## Play Store Submission

### Required Information

#### 1. App Details
- **App Name:** ShowOff.life
- **Short Description:** (80 characters max)
- **Full Description:** (4000 characters max)
- **Category:** Social / Video

#### 2. Graphics
- **App Icon:** 512x512 PNG
- **Feature Graphic:** 1024x500 PNG
- **Screenshots:** At least 2 (phone)
- **Screenshots:** At least 2 (tablet) - optional

#### 3. Content Rating
- Complete questionnaire
- Get rating certificate
- Add to app listing

#### 4. Privacy Policy
- Required for apps with user data
- Must be publicly accessible URL

#### 5. App Content
- Ads: Yes (AdMob integrated)
- In-app purchases: Yes (coins, subscriptions)
- Target audience: 13+

### Release Tracks

#### Internal Testing
- Quick testing with small group
- No review required
- Instant updates

#### Closed Testing
- Larger test group
- Email list or Google Groups
- Pre-release testing

#### Open Testing
- Public beta
- Anyone can join
- Feedback collection

#### Production
- Public release
- Full review process
- Available to all users

## Post-Release

### Monitor
1. **Crashes:** Check Play Console → Quality → Crashes
2. **ANRs:** Check Application Not Responding errors
3. **Reviews:** Respond to user feedback
4. **Statistics:** Monitor installs, uninstalls, ratings

### Update Process
1. Fix bugs or add features
2. Increment version number
3. Build new app bundle
4. Upload to Play Console
5. Submit for review

## Security Best Practices

### ✅ DO:
- Keep keystore secure and backed up
- Use strong passwords
- Store credentials in key.properties (gitignored)
- Use release configuration for production
- Test thoroughly before release

### ❌ DON'T:
- Commit keystore to git
- Share keystore publicly
- Use debug configuration for release
- Skip testing
- Hardcode API keys in code

## Backup Checklist

### Critical Files to Backup:
- [ ] `key/key.jks` - **MOST IMPORTANT**
- [ ] `apps/key/key.properties`
- [ ] `apps/h/google-services.json`
- [ ] Keystore passwords (secure location)

**⚠️ WARNING:** If you lose the keystore, you cannot update your app on Play Store!

## Build Verification

### After Building, Verify:
```bash
# Check app bundle exists
dir apps\build\app\outputs\bundle\release\app-release.aab

# Check file size (should be 50-100 MB)
# Check signing (should show release keystore)
```

### Test Before Release:
1. Install on physical device
2. Test all features
3. Test Google Sign-In
4. Test payments
5. Test notifications
6. Test video upload/playback

## Support

### Resources:
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Flutter Release Guide](https://docs.flutter.dev/deployment/android)
- [Firebase Console](https://console.firebase.google.com)

### Common Issues:
- Google Sign-In: Check SHA-1 fingerprint
- Crashes: Check Play Console crash reports
- Upload errors: Verify app bundle format
- Review rejection: Read policy guidelines

## Checklist Before Submission

- [ ] App builds successfully
- [ ] All features tested
- [ ] Google Sign-In works
- [ ] Payments work
- [ ] Notifications work
- [ ] No crashes
- [ ] Version number updated
- [ ] Release notes written
- [ ] Screenshots prepared
- [ ] Store listing complete
- [ ] Privacy policy published
- [ ] Content rating obtained

## Timeline

### First Release:
- Build: 10-30 minutes
- Upload: 5-10 minutes
- Review: 1-7 days
- **Total: 1-7 days**

### Updates:
- Build: 5-15 minutes
- Upload: 5-10 minutes
- Review: 1-3 days
- **Total: 1-3 days**

## Success Indicators

### Build Success:
```
✅ App Bundle built successfully!
📦 app-release.aab created
🔐 Signed with release keystore
```

### Upload Success:
```
✅ Upload complete
✅ Processing successful
✅ Ready for review
```

### Release Success:
```
✅ Review approved
✅ App published
✅ Available on Play Store
```

## Next Steps After This Guide

1. Run `verify_release_setup.bat`
2. Fix any errors found
3. Run `build_playstore_release.bat`
4. Upload to Play Console
5. Complete store listing
6. Submit for review
7. Wait for approval
8. Celebrate! 🎉
