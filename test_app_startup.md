# App Startup Test Checklist

## Pre-Test Setup
```bash
cd apps
flutter clean
flutter pub get
```

## Test 1: Cold Start (Logged Out)
1. Uninstall app completely from device/emulator
2. Run: `flutter run`
3. **Expected**: App launches to splash screen → onboarding
4. **Success Criteria**: No crashes, smooth transition

## Test 2: Cold Start (Logged In)
1. Login with test credentials
2. Close app completely (swipe from recent apps)
3. Launch app from icon
4. **Expected**: App launches to splash screen → main screen
5. **Success Criteria**: 
   - No crashes
   - Notifications initialize in background
   - App is immediately responsive

## Test 3: Network Failure Handling
1. Turn off WiFi/mobile data
2. Launch app
3. **Expected**: App launches normally, shows offline state
4. **Success Criteria**: No crashes, graceful degradation

## Test 4: Service Initialization
1. Check logs for initialization messages:
   - ✅ FCM initialization (or warning if failed)
   - ✅ AdMob initialization (or warning if failed)
   - ✅ Notification service (only if logged in)
2. **Success Criteria**: All services handle errors gracefully

## Test 5: Upload Flow
1. Navigate to create post
2. Select/record video
3. Add caption
4. Select thumbnail
5. Upload
6. **Expected**: Upload completes without crashes
7. **Success Criteria**: Proper error handling, no context issues

## Common Issues to Watch For

### ❌ Crash Indicators:
- "ShowOff.life keeps stopping" dialog
- App freezes on splash screen
- Black screen after splash
- Immediate crash on launch

### ✅ Success Indicators:
- Smooth splash → onboarding/main transition
- Console shows initialization messages
- No unhandled exceptions
- App responds to user input immediately

## Debug Commands

### View logs:
```bash
flutter logs
```

### Check for errors:
```bash
flutter logs | findstr "ERROR"
flutter logs | findstr "FATAL"
flutter logs | findstr "Exception"
```

### Hot restart (during development):
```
Press 'R' in terminal
```

### Hot reload (during development):
```
Press 'r' in terminal
```

## Expected Console Output (Success)

```
⚠️ FCM initialization failed: [error] (or ✅ FCM initialized)
⚠️ AdMob initialization failed: [error] (or ✅ AdMob initialized)
✅ Notification service initialized (only if logged in)
✅ WebSocket connected (only if logged in)
```

## If App Still Crashes

1. Check `flutter logs` for exact error
2. Verify server is running at http://144.91.77.89:3000
3. Check network connectivity
4. Verify google-services.json is in correct location
5. Try `flutter clean && flutter pub get` again
6. Check Android/iOS specific logs:
   - Android: `adb logcat`
   - iOS: Xcode console
