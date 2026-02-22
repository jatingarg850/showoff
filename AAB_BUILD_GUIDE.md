# Build AAB for Play Store - Complete Guide

## Overview
This guide explains how to build an Android App Bundle (AAB) for Play Store using your keystore.

## Keystore Information
- **Keystore File**: `keystore/upload-showofflife.jks`
- **Certificate**: `keystore/upload_certificate.pem`
- **Key Alias**: `upload-showofflife`
- **Store Password**: `showofflife`
- **Key Password**: `showofflife`

## Configuration Files

### 1. Key Properties (`apps/key/key.properties`)
```properties
storePassword=showofflife
keyPassword=showofflife
keyAlias=upload-showofflife
storeFile=../../../keystore/upload-showofflife.jks
```

### 2. Build Configuration (`apps/android/app/build.gradle.kts`)
The build.gradle.kts is already configured to:
- Load keystore properties from `key/key.properties`
- Sign release builds with the keystore
- Generate signed AAB for Play Store

## Building AAB

### Method 1: Using Build Script (Recommended)
Simply run the batch file:
```bash
build_aab_playstore.bat
```

This script will:
1. ✅ Clean previous builds
2. ✅ Get Flutter dependencies
3. ✅ Build signed AAB
4. ✅ Verify the output file
5. ✅ Show file location and next steps

### Method 2: Manual Build
If you prefer to build manually:

```bash
cd apps
flutter clean
flutter pub get
flutter build appbundle --release
```

## Output Location
After successful build, the AAB file will be at:
```
apps/build/app/outputs/bundle/release/app-release.aab
```

## Uploading to Play Store

### Step 1: Go to Google Play Console
1. Visit https://play.google.com/console
2. Sign in with your Google account
3. Select your app (ShowOff.life)

### Step 2: Create New Release
1. Go to **Release** → **Production**
2. Click **Create new release**
3. Click **Browse files** and select your AAB file

### Step 3: Review and Publish
1. Review the app details
2. Add release notes (what's new)
3. Click **Review release**
4. Click **Rollout to Production**

## Troubleshooting

### Build Fails with Keystore Error
**Error**: `Keystore file not found` or `Invalid keystore password`

**Solution**:
1. Verify keystore file exists: `keystore/upload-showofflife.jks`
2. Check key.properties has correct path and passwords
3. Ensure you're in the correct directory

### Build Fails with Gradle Error
**Error**: `Gradle build failed`

**Solution**:
1. Run `flutter clean` to remove cached files
2. Run `flutter pub get` to fetch dependencies
3. Check Android SDK is installed: `flutter doctor`
4. Update Flutter: `flutter upgrade`

### AAB File Too Large
**Issue**: AAB file is larger than expected

**Solution**:
1. Enable minification in build.gradle.kts:
   ```kotlin
   isMinifyEnabled = true
   isShrinkResources = true
   ```
2. Remove unused dependencies from pubspec.yaml
3. Optimize assets and images

## Build Variants

### Release Build (Default)
```bash
flutter build appbundle --release
```
- Optimized for production
- Signed with keystore
- Minified code (optional)
- Recommended for Play Store

### Debug Build (Testing Only)
```bash
flutter build appbundle --debug
```
- Not optimized
- Unsigned
- Larger file size
- For testing only

## Version Management

### Update Version Before Release
Edit `pubspec.yaml`:
```yaml
version: 1.0.0+1
```

Format: `major.minor.patch+buildNumber`

Example progression:
- `1.0.0+1` → Initial release
- `1.0.1+2` → Bug fix
- `1.1.0+3` → New features
- `2.0.0+4` → Major update

### Update in Android Manifest
The version is automatically synced from pubspec.yaml.

## Security Best Practices

### ✅ DO:
- Keep keystore file in secure location
- Back up keystore file regularly
- Use strong passwords
- Never commit keystore to public repositories
- Use the same keystore for all app updates

### ❌ DON'T:
- Share keystore file or passwords
- Commit keystore to Git
- Use weak passwords
- Lose your keystore (you can't recover it)
- Use different keystores for updates

## Keystore Backup

### Create Backup
```bash
copy keystore\upload-showofflife.jks keystore\upload-showofflife.jks.backup
```

### Store Safely
1. External hard drive
2. Cloud storage (encrypted)
3. Password manager
4. Physical safe

## Common Issues

### Issue: "Keystore was tampered with, or password was incorrect"
**Cause**: Wrong password or corrupted keystore
**Fix**: Verify password in key.properties

### Issue: "Certificate has expired"
**Cause**: Signing certificate expired
**Fix**: Create new keystore with new certificate

### Issue: "App not signed with same certificate as previous version"
**Cause**: Using different keystore
**Fix**: Use the same keystore (upload-showofflife.jks)

## File Sizes Reference

Typical AAB file sizes:
- Small app: 20-50 MB
- Medium app: 50-100 MB
- Large app: 100-200 MB

Your app size depends on:
- Number of assets (images, videos)
- Dependencies
- Code size
- Minification settings

## Next Steps After Upload

1. **Wait for Review**: Usually 2-4 hours
2. **Monitor Crashes**: Check Play Console for crash reports
3. **Gather Feedback**: Monitor user reviews
4. **Plan Updates**: Track feature requests
5. **Prepare Next Release**: Start working on next version

## Useful Commands

```bash
# Check Flutter version
flutter --version

# Check Android setup
flutter doctor

# List available devices
flutter devices

# Build and run on device
flutter run --release

# Build APK (for testing)
flutter build apk --release

# Build AAB (for Play Store)
flutter build appbundle --release

# Clean build artifacts
flutter clean

# Get dependencies
flutter pub get

# Upgrade Flutter
flutter upgrade
```

## Support

For issues with:
- **Flutter**: https://flutter.dev/docs
- **Play Store**: https://support.google.com/googleplay
- **Android**: https://developer.android.com

---

**Last Updated**: February 2026
**App**: ShowOff.life
**Keystore**: upload-showofflife.jks
