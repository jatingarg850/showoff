# Play Store Deployment Guide for ShowOff.life

## 🚀 Quick Start

### Option 1: Automated Build (Recommended)

1. **Create Keystore** (First time only):
   ```bash
   cd apps\android
   keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias showoff-key-alias
   ```
   
   Save the passwords you create!

2. **Update key.properties**:
   Edit `apps\android\key.properties` with your passwords:
   ```properties
   storePassword=YOUR_PASSWORD_HERE
   keyPassword=YOUR_PASSWORD_HERE
   keyAlias=showoff-key-alias
   storeFile=app-release-key.jks
   ```

3. **Run Build Script**:
   ```bash
   build_aab.bat
   ```

4. **Upload to Play Store**:
   - Find AAB at: `apps\build\app\outputs\bundle\release\app-release.aab`
   - Upload to Google Play Console

### Option 2: Manual Build

```bash
cd apps
flutter clean
flutter pub get
flutter build appbundle --release
```

## 📋 Pre-Deployment Checklist

### 1. Update Version Number
Edit `apps\pubspec.yaml`:
```yaml
version: 1.0.0+1  # Increment +1, +2, +3 for each release
```

### 2. Update App Information
- App name: Check `apps\android\app\src\main\AndroidManifest.xml`
- Package name: `com.showoff.life` (already configured)
- Icons: Located in `apps\android\app\src\main\res\`

### 3. Test Release Build
```bash
cd apps
flutter build appbundle --release
flutter install --release
```

### 4. Verify API Configuration
Check `apps\lib\config\api_config.dart`:
- Ensure production URL is set: `http://144.91.77.89:3000/api`
- WebSocket URL is correct

## 🔐 Security Checklist

- [ ] Keystore file is NOT in git (check .gitignore)
- [ ] key.properties is NOT in git
- [ ] API keys are in environment variables
- [ ] Firebase config files are secure
- [ ] Production server is using HTTPS (recommended)

## 📱 Play Store Requirements

### App Information Needed:
1. **App Title**: ShowOff.life
2. **Short Description**: (50 characters max)
3. **Full Description**: (4000 characters max)
4. **Screenshots**: 
   - At least 2 screenshots
   - Recommended: 1080x1920 or 1440x2560
5. **Feature Graphic**: 1024x500 pixels
6. **App Icon**: 512x512 pixels (high-res)
7. **Privacy Policy URL**: Required
8. **Content Rating**: Complete questionnaire
9. **Target Audience**: Select age groups
10. **Category**: Social or Entertainment

### Required Assets:
- [ ] App icon (512x512)
- [ ] Feature graphic (1024x500)
- [ ] Screenshots (minimum 2)
- [ ] Privacy policy URL
- [ ] App description
- [ ] Release notes

## 🔄 Update Process (Future Releases)

1. **Increment Version**:
   ```yaml
   version: 1.0.1+2  # Increment both version and build number
   ```

2. **Build New AAB**:
   ```bash
   build_aab.bat
   ```

3. **Upload to Play Store**:
   - Go to "Release" > "Production"
   - Create new release
   - Upload new AAB
   - Add release notes
   - Submit for review

## 🐛 Troubleshooting

### Build Fails with "Keystore not found"
- Ensure keystore is in `apps\android\app-release-key.jks`
- Check that path in key.properties is correct

### "Invalid keystore format" Error
- Verify passwords in key.properties match keystore
- Ensure no extra spaces in key.properties

### "Duplicate class" Error
- Run `flutter clean`
- Delete `apps\android\.gradle` folder
- Rebuild

### App Crashes on Release Build
- Check ProGuard rules if minification is enabled
- Test with `flutter run --release` before building AAB

### Upload Rejected by Play Store
- Ensure version code is higher than previous release
- Check that package name matches Play Store listing
- Verify all required permissions are declared

## 📊 Version History

| Version | Build | Date | Changes |
|---------|-------|------|---------|
| 1.0.0   | 1     | TBD  | Initial release |

## 🔗 Useful Links

- [Google Play Console](https://play.google.com/console)
- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Android App Signing](https://developer.android.com/studio/publish/app-signing)
- [Play Store Policies](https://play.google.com/about/developer-content-policy/)

## 📞 Support

If you encounter issues:
1. Check error messages carefully
2. Review this guide
3. Check Flutter documentation
4. Verify all prerequisites are met

## ⚠️ Important Notes

- **NEVER** commit keystore files to git
- **ALWAYS** backup your keystore file securely
- **KEEP** passwords in a secure password manager
- **TEST** release builds before uploading
- **INCREMENT** version numbers for each release
- **REVIEW** Play Store policies before submission

---

**Ready to deploy?** Run `build_aab.bat` and follow the prompts!
