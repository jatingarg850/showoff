# Fix Version Code Error & Rebuild AAB

## Problem
Error: "Version code 10 has already been used. Try another version code."

This happens when you try to upload an AAB with a version code that's already been used on Google Play Store.

## Solution

### Step 1: Update Version Code
**File**: `apps/pubspec.yaml`

Changed from:
```yaml
version: 1.10.0+10
```

To:
```yaml
version: 1.10.1+11
```

**Explanation:**
- `1.10.1` = Version name (displayed to users)
- `+11` = Build number/Version code (must be unique for each upload)

### Step 2: Clean Flutter
```bash
cd apps
flutter clean
flutter pub get
```

### Step 3: Rebuild AAB
```bash
flutter build appbundle --release
```

### Step 4: Verify Build
```bash
# Check if AAB was created
ls -lh build/app/outputs/bundle/release/app-release.aab
```

### Step 5: Upload to Google Play Store
1. Go to Google Play Console
2. Select your app
3. Go to "Release" → "Production"
4. Click "Create new release"
5. Upload the new AAB file
6. Review and publish

## Version Code Rules

**Important:**
- Version code must be **unique** for each upload
- Version code must be **higher** than the previous one
- Version code must be an **integer** (no decimals)
- Version code is **not** shown to users

**Format:**
```
version: MAJOR.MINOR.PATCH+BUILD_NUMBER

Example:
version: 1.10.1+11
         ^^^^^^^ ^^
         |       |
         |       +-- Build number (version code) - must increment
         +---------- Version name (shown to users)
```

## Version Code History

| Version | Build Code | Status |
|---------|-----------|--------|
| 1.10.0 | 10 | ✅ Already used |
| 1.10.1 | 11 | ✅ Current (ready to upload) |
| 1.10.2 | 12 | ⏳ Next upload |
| 1.11.0 | 13 | ⏳ Major update |

## Quick Commands

```bash
# Clean and rebuild
cd apps
flutter clean
flutter pub get
flutter build appbundle --release

# Check file size
ls -lh build/app/outputs/bundle/release/app-release.aab

# Check version in pubspec.yaml
grep "^version:" pubspec.yaml
```

## Troubleshooting

### Still Getting Version Code Error?
1. Check Google Play Console for previously uploaded versions
2. Make sure version code is higher than all previous uploads
3. Wait 24 hours if you just deleted a release
4. Try incrementing by 2 or 3 instead of 1

### Build Failed?
```bash
# Try these steps
flutter clean
rm -rf build/
flutter pub get
flutter build appbundle --release
```

### AAB File Not Found?
```bash
# Check if build succeeded
flutter build appbundle --release -v

# Look for the file
find . -name "app-release.aab"
```

## Next Steps

1. ✅ Version code updated to 11
2. ⏳ Run `flutter clean && flutter pub get`
3. ⏳ Build AAB: `flutter build appbundle --release`
4. ⏳ Upload to Google Play Store
5. ⏳ Review and publish

**Your app is ready to rebuild!**
