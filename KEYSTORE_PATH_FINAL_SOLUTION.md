# Keystore Path Final Solution

## Issue
Build was failing with `NullPointerException` during signing because the keystore files were in the wrong location.

## Root Cause
The `build.gradle.kts` looks for keystore properties at:
```
rootProject.file("key/key.properties")
```
Which resolves to: `apps/android/key/key.properties`

But the files were located at: `apps/key/`

## Solution
Copied keystore files to the correct location that Gradle expects:

### File Locations
```
apps/android/key/key.jks          ← Keystore file
apps/android/key/key.properties   ← Properties file
```

### key.properties Content
```properties
storePassword=flashcoders
keyPassword=flashcoders
keyAlias=key
storeFile=../key/key.jks
```

**Important:** The `storeFile` path is relative to `apps/android/app/` directory, so `../key/key.jks` resolves to `apps/android/key/key.jks`

## Build Command
```bash
cd apps
flutter build appbundle --release
```

## Success Output
```
✅ Loaded keystore properties from: C:\Users\coddy\Music\showoff\apps\android\key\key.properties
   Store file: ../key/key.jks
   Key alias: key
Running Gradle task 'bundleRelease'...
√ Built build\app\outputs\bundle\release\app-release.aab (54.4MB)
```

## Output Location
```
apps/build/app/outputs/bundle/release/app-release.aab
```

## Quick Build Script
Use the existing batch file:
```bash
build_playstore_release.bat
```

## Backup Locations
Original keystore files are also kept at:
```
apps/key/key.jks
apps/key/key.properties
```

## Important Notes
1. Never commit keystore files to git (already in .gitignore)
2. Keep backup of keystore in secure location
3. If keystore is lost, you cannot update the app on Play Store
4. The storePassword and keyPassword are both: `flashcoders`
5. The keyAlias is: `key`

## Troubleshooting

### Error: Keystore file not found
**Solution:** Ensure files are in `apps/android/key/` directory

### Error: NullPointerException during signing
**Solution:** Check that `key.properties` exists and has correct paths

### Error: Wrong password
**Solution:** Verify password in `key.properties` matches keystore password

## File Structure
```
apps/
├── android/
│   ├── key/
│   │   ├── key.jks              ← Keystore (used by build)
│   │   └── key.properties       ← Properties (used by build)
│   └── app/
│       └── build.gradle.kts     ← References ../key/key.jks
└── key/
    ├── key.jks                  ← Backup copy
    └── key.properties           ← Backup copy
```

## Build Process
1. Gradle reads: `apps/android/key/key.properties`
2. Gets storeFile path: `../key/key.jks`
3. Resolves to: `apps/android/key/key.jks` (relative to app directory)
4. Signs the AAB with the keystore
5. Outputs to: `apps/build/app/outputs/bundle/release/app-release.aab`

## Success! ✅
The AAB is now ready for Play Store upload at:
```
apps/build/app/outputs/bundle/release/app-release.aab (54.4MB)
```
