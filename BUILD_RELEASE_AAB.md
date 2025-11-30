# Build Signed AAB for Play Store

## Step 1: Create Keystore (First Time Only)

Run this command to create your keystore:

```bash
cd apps\android
keytool -genkey -v -keystore app-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias showoff-key-alias
```

You'll be asked for:
- Keystore password (create a strong password)
- Key password (can be same as keystore password)
- Your name
- Organization
- City
- State
- Country code

**IMPORTANT:** Save these passwords! You'll need them for all future app updates.

## Step 2: Update key.properties

Edit `apps/android/key.properties` and add your passwords:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=showoff-key-alias
storeFile=app-release-key.jks
```

## Step 3: Update Application ID (Already Done)

The applicationId has been changed to `com.showoff.life` in build.gradle.kts

## Step 4: Build the AAB

Run from the `apps` directory:

```bash
flutter clean
flutter pub get
flutter build appbundle --release
```

## Step 5: Find Your AAB

The signed AAB will be at:
```
apps\build\app\outputs\bundle\release\app-release.aab
```

## Step 6: Upload to Play Store

1. Go to Google Play Console
2. Select your app
3. Go to "Release" > "Production"
4. Click "Create new release"
5. Upload the `app-release.aab` file
6. Fill in release notes
7. Review and roll out

## Important Notes

- **Never commit key.properties or .jks files to git!** (Already in .gitignore)
- Keep your keystore file and passwords safe - you can't update your app without them
- The keystore is valid for 10,000 days (27+ years)
- If you lose the keystore, you'll need to publish a new app with a different package name

## Troubleshooting

### Error: "Keystore file not found"
Make sure you created the keystore in `apps/android/` directory

### Error: "Invalid keystore format"
Make sure you're using the correct password in key.properties

### Error: "Execution failed for task ':app:validateSigningRelease'"
Check that all values in key.properties are correct

## Version Management

To update version for new releases, edit `apps/pubspec.yaml`:

```yaml
version: 1.0.0+1  # Format: major.minor.patch+buildNumber
```

Increment the build number (+1, +2, etc.) for each Play Store release.
