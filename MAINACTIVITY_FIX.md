# MainActivity ClassNotFoundException Fix

## The Real Problem

The app was crashing with:
```
java.lang.ClassNotFoundException: Didn't find class "com.showofflife.app.MainActivity"
```

## Root Cause

**Package Mismatch**: The Android configuration expected MainActivity at `com.showofflife.app.MainActivity`, but the actual file was at `com.showoff.life.MainActivity`.

### Configuration Files:
- **build.gradle.kts**: `namespace = "com.showofflife.app"`
- **build.gradle.kts**: `applicationId = "com.showofflife.app"`
- **AndroidManifest.xml**: `android:name=".MainActivity"` (resolves to `com.showofflife.app.MainActivity`)

### Actual File Location:
- **Wrong**: `apps/android/app/src/main/kotlin/com/showoff/life/MainActivity.kt`
- **Expected**: `apps/android/app/src/main/kotlin/com/showofflife/app/MainActivity.kt`

## Fix Applied

1. **Created correct MainActivity**:
   - Location: `apps/android/app/src/main/kotlin/com/showofflife/app/MainActivity.kt`
   - Package: `package com.showofflife.app`
   - Includes edge-to-edge support for Android 15+

2. **Fixed notification icon in AndroidManifest.xml**:
   - Changed from `@drawable/ic_notification` (doesn't exist)
   - Changed to `@mipmap/ic_launcher` (app icon)
   - Fixed notification color to use Android system color

## Files Modified

1. **Created**: `apps/android/app/src/main/kotlin/com/showofflife/app/MainActivity.kt`
2. **Modified**: `apps/android/app/src/main/AndroidManifest.xml`

## How to Test

```bash
cd apps
flutter clean
flutter pub get
flutter run
```

The app should now:
- ✅ Launch without ClassNotFoundException
- ✅ Show splash screen
- ✅ Navigate to onboarding or main screen
- ✅ No "keeps stopping" dialog

## Why This Happened

Multiple MainActivity files existed in different packages from previous configurations:
- `com.example.showoff_life.MainActivity`
- `com.showoff.life.MainActivity`
- `com.showofflife.showoff_life.MainActivity`

But none matched the current package name `com.showofflife.app` defined in build.gradle.kts.

## Prevention

When changing package names:
1. Update `build.gradle.kts` namespace and applicationId
2. Update MainActivity package and file location
3. Ensure AndroidManifest.xml matches
4. Clean and rebuild: `flutter clean && flutter pub get`
