# AAB Build - Quick Start

## 🚀 Build in 3 Steps

### Step 1: Run Build Script
```bash
build_aab_playstore.bat
```

### Step 2: Wait for Build
- Takes 5-15 minutes depending on your system
- Watch the console for progress

### Step 3: Upload to Play Store
- Find AAB at: `apps/build/app/outputs/bundle/release/app-release.aab`
- Go to Google Play Console
- Upload to Production release

## 📋 Keystore Details

| Item | Value |
|------|-------|
| Keystore File | `keystore/upload-showofflife.jks` |
| Key Alias | `upload-showofflife` |
| Store Password | `showofflife` |
| Key Password | `showofflife` |
| Certificate | `keystore/upload_certificate.pem` |

## ✅ Pre-Build Checklist

- [ ] Keystore file exists: `keystore/upload-showofflife.jks`
- [ ] Key properties configured: `apps/key/key.properties`
- [ ] Flutter installed: `flutter --version`
- [ ] Android SDK installed: `flutter doctor`
- [ ] Version updated in `pubspec.yaml`
- [ ] All code committed to Git

## 🔧 Manual Build (If Script Fails)

```bash
cd apps
flutter clean
flutter pub get
flutter build appbundle --release
```

## 📦 Output

**Location**: `apps/build/app/outputs/bundle/release/app-release.aab`

**File Size**: Typically 50-100 MB

**Signed**: Yes (with upload-showofflife keystore)

## 🎯 Next Steps

1. Upload AAB to Play Store Console
2. Add release notes
3. Review and publish
4. Monitor for crashes
5. Gather user feedback

## ⚠️ Important

- **Keep keystore safe** - You can't recover it if lost
- **Use same keystore** - For all future updates
- **Back up keystore** - Store in secure location
- **Never share** - Keystore password or file

## 🆘 Troubleshooting

| Problem | Solution |
|---------|----------|
| Build fails | Run `flutter clean` then try again |
| Keystore error | Check `apps/key/key.properties` |
| Gradle error | Run `flutter doctor` to check setup |
| File not found | Verify keystore path is correct |

## 📞 Support

- Flutter: https://flutter.dev
- Play Store: https://support.google.com/googleplay
- Android: https://developer.android.com

---

**App**: ShowOff.life  
**Keystore**: upload-showofflife.jks  
**Status**: Ready to build ✅
